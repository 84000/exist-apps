xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-entity-id := if(request:exists()) then request:get-parameter('id', '') else '';
declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT22084-066-009';
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:request-tei := $local:request-text-id[. gt ''] ! tei-content:tei(., 'translation');
declare variable $local:text-xmlids := $local:request-tei//@xml:id;

declare variable $local:operations-data := collection(concat($common:data-path, '/operations'));
declare variable $local:entities := $local:operations-data//eft:entities;
declare variable $local:contributors := $local:operations-data//eft:contributors;
declare variable $local:sponsors := $local:operations-data//eft:sponsors;
declare variable $local:request-entity := 
    if($local:request-entity-id gt '') then 
        $local:operations-data/id($local:request-entity-id) 
    else if($local:text-xmlids) then 
        $local:operations-data//eft:instance[@id = $local:text-xmlids]/parent::*
    else ();

declare variable $local:xslt := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));
declare variable $local:html5-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'html5' }
        },
        element media-type { 
            attribute value { 'text/html' }
        },
        element suppress-indentation { 
            attribute value { 'yes' }
        }
    };

declare function local:entities() {

    for $entity at $entity-index in $local:entities/eft:entity
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($entity except $local:request-entity) eq 0
    
    (: Determine a head term :)
    (: Try attributions :)
    let $instances := $tei-content:translations-collection/id($entity/eft:instance/@id)
    let $head-term := local:head-term($instances[self::tei:author | self::tei:editor], $entity/eft:label)
    (: If not try glossaries :)
    let $head-term := 
        if(not($head-term)) then
            local:head-term($instances[self::tei:gloss](:[not(@mode eq 'surfeit')]:)/tei:term, $entity/eft:label)
        else
            $head-term
    where $head-term
    
    (: Parse the definition :)
    let $definitions := $entity/eft:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]
    let $definition-tei := $definitions ! element { QName('http://www.tei-c.org/ns/1.0', 'p') } { . }
    let $definition-html := $definition-tei ! transform:transform(., $local:xslt, <parameters/>)
    let $definition-string := string-join($definition-html ! serialize(., $local:html5-serialization-parameters) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')) ! normalize-space(.)                       
    
    return
        types:authority($entity/@xml:id, $entity/@timestamp, helpers:normalize-text($head-term), ($head-term/@xml:lang, 'en')[1], ($entity/eft:label[@xml:lang eq 'en'][normalize-space(text())])[1] ! normalize-space(string-join(text())), $definition-string)
    
};

declare function local:contributors() {

    for $contributor at $entity-index in $local:contributors/eft:person
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($contributor except $local:request-entity) eq 0
    
    let $instances := $tei-content:translations-collection/id($contributor/eft:instance/@id)
    let $head-term := local:head-term($instances, $contributor/eft:label)
    where $head-term
    return
        types:authority($contributor/@xml:id, $contributor/@timestamp, $head-term, ($head-term/@xml:lang, 'en')[1], ($contributor/eft:label)[1] ! helpers:normalize-text(.), ())
   
};

declare function local:teams() {

    for $team at $entity-index in $local:contributors/eft:team
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($team except $local:request-entity) eq 0
    
    return
        types:authority($team/@xml:id, $team/@timestamp, ($team/eft:label)[1] ! helpers:normalize-text(.), 'en', (), ())
   
};

declare function local:institutions() {
    
    for $institution at $entity-index in $local:contributors/eft:institution
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($institution except $local:request-entity) eq 0
    
    return
        types:authority($institution/@xml:id, $institution/@timestamp, ($institution/eft:label)[1] ! helpers:normalize-text(.), 'en', (), ())
        
};

declare function local:sponsors() {
    
    for $sponsor at $entity-index in $local:sponsors/eft:sponsor
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($sponsor except $local:request-entity) eq 0
    
    let $instances := $tei-content:translations-collection/id($sponsor/eft:instance/@id)
    let $head-term := local:head-term($instances, $sponsor/eft:label)
    where $head-term
    return
        types:authority($sponsor/@xml:id, $sponsor/@timestamp, $head-term, ($head-term/@xml:lang, 'en')[1], ($sponsor/eft:label)[1] ! helpers:normalize-text(.), ())
    
};

declare function local:head-term($terms, $labels) as element()? {

    let $head-term-lang := (
        $terms[@xml:lang eq 'Bo-Ltn'][normalize-space(text())], 
        $terms[@xml:lang eq 'Sa-Ltn'][normalize-space(text())], 
        $terms[@xml:lang eq 'zh'][normalize-space(text())],
        $terms[@xml:lang eq 'en'][normalize-space(text())]
    )[1]/@xml:lang
    
    let $head-terms-lang := $terms[@xml:lang eq $head-term-lang]
    
    let $distinct-terms := distinct-values($head-terms-lang ! normalize-space(string-join(text())) ! lower-case(.) ! common:normalized-chars(.))
    let $distinct-terms-sorted := fn:sort($distinct-terms, (), function($term) { -count($terms[normalize-space(string-join(text()) ! lower-case(.) ! common:normalized-chars(.)) eq $term]) })
    let $distinct-terms-first := $distinct-terms-sorted[1]
    let $head-term := subsequence($head-terms-lang[normalize-space(string-join(text())) ! lower-case(.) ! common:normalized-chars(.) eq $distinct-terms-first], 1, 1)
    
    return
        if(not($head-term)) then
            ($labels[@xml:lang eq 'Bo-Ltn'][normalize-space(text())], $labels[@xml:lang eq 'Sa-Ltn'][normalize-space(text())], $labels[normalize-space(text())])[1]
        else
            $head-term
    
};

let $response := 
    element authorities {
        
        attribute modelType { 'authorities' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/authorities.json?', string-join((concat('api-version=', $types:api-version), $local:request-entity[@xml:id eq $local:request-entity-id] ! concat('id=', $local:request-entity-id), $local:request-tei ! concat('text-id=', $local:request-text-id)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        local:entities(),
        local:contributors(),
        local:teams(),
        local:institutions(),
        local:sponsors()
            
    }

return
    helpers:store($local:request-store, $response, concat($response/@modelType, '.json'), ())

