xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "/db/apps/84000-reading-room/modules/glossary.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT22084-066-009';
declare variable $local:request-tei := $local:request-text-id[. gt ''] ! tei-content:tei(., 'translation');
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:operations-data := collection(concat($common:data-path, '/operations'));
declare variable $local:entities := $local:operations-data//eft:entities;
declare variable $local:published-statuses := $tei-content:text-statuses/eft:status[@type eq 'translation'][@group eq 'published']/@status-id;

declare function local:process-gloss($gloss as element(tei:gloss), $text-id as xs:string, $glossary-xhtml as element()) as element(eft:glossary)* {

    let $entity := ($local:entities//eft:instance[@id eq $gloss/@xml:id]/parent::eft:entity)[1]
    let $entity-names := $entity ! helpers:distinct-names(., 'en')
    let $definition-tei := $gloss/tei:note[@type eq 'definition']
    let $definition-html := $glossary-xhtml//xhtml:div[@id eq $gloss/@xml:id]/descendant::xhtml:p[matches(@class, '(^|\s)definition(\s|$)')]
    let $definition-html-string := string-join($definition-html ! serialize(.)) ! replace(., '\s+xmlns=[^\s|>]*', '')
    return
        for $term in $gloss/tei:term[not(@xml:lang eq 'bo' and @n)]
        let $term-lang := ($term/@xml:lang, 'en')[1]
        let $term-text := helpers:normalize-text($term)
        let $term-lang-index := functx:index-of-node($gloss/tei:term[(@xml:lang/string(), 'en')[1] eq $term-lang], $term)
        let $term-id := string-join(($gloss/@xml:id, $term-lang, $term-lang-index), '/')
        let $entity-name := $entity-names[@language eq $term-lang][eft:content/text() eq $term-text]
        let $name-id := ($entity-name/@xmlId, string-join(('error', $term-lang, $term-text), ':'))[1]
        return
            types:glossary(
                $term-id, 
                $entity/@xml:id, 
                $name-id, 
                $text-id, 
                $term[@type eq 'translationMain'] ! $definition-html-string, 
                $term[@type eq 'translationMain'] ! $definition-tei/@rend, 
                $term/@type[. = ('translationMain', 'translationAlternative')], 
                $term/@type[. = $glossary:attestation-types//eft:attestation-type/@id] ! concat('attestation-', .), 
                ($term[@status eq 'verified'] ! true(), false())[1], 
                ($gloss/@mode, 'match')[1]
            )
};

let $response :=
    element glossaries {
        
        attribute modelType { 'glossaries' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/glossaries.json?', string-join((concat('api-version=', $types:api-version), $local:request-tei ! concat('text-id=', $local:request-text-id)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        let $teis := $tei-content:translations-collection//tei:TEI
        let $count-teis := count($teis)
        for $tei at $tei-index in $teis
        where 
            not($local:request-text-id gt '') or count($tei | $local:request-tei) eq 1 
            and $tei//tei:publicationStmt/tei:availability[@status = $local:published-statuses]
            and $tei//tei:back/tei:div[@type eq 'glossary'][not(@status = 'excluded')][descendant::tei:gloss]
        
        let $text-id := tei-content:id($tei)
        let $xml-response := glossary:xml-response($tei, $text-id, 'translation', (), 'glossary', 'glossary-json')
        let $glossary-xhtml := helpers:translation-html($xml-response)
        
        return (
        
            util:log('INFO', concat('Glossaries: ', $text-id, ' (', $tei-index, '/', $count-teis, ')')),
            
            for $gloss in $tei//tei:back/tei:div[@type eq 'glossary']/descendant::tei:gloss[@xml:id]
            return
                local:process-gloss($gloss, $text-id, $glossary-xhtml)
                
        )
    }

return
    if($local:request-store eq 'store') then
        helpers:store($response, concat($response/@modelType, '.json'), ())
    else
        $response