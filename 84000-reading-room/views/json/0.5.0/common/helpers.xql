xquery version "3.0";

(: Variations to json types for version 0.5.0 :)
module namespace json-helpers = "http://read.84000.co/json-helpers/0.5.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace json = "http://www.json.org";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "types.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace entities = "http://read.84000.co/entities" at "/db/apps/84000-reading-room/modules/entities.xql";
import module namespace store = "http://read.84000.co/store" at "/db/apps/84000-reading-room/modules/store.xql";
import module namespace functx="http://www.functx.com";

declare variable $json-helpers:json-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'json' }
        }
    };

declare function json-helpers:copy-nodes($nodes as node()*) as node()* {
    for $node in $nodes
    return
        if(functx:node-kind($node) eq 'text') then
            $node
        else if(functx:node-kind($node) eq 'element') then
            element { local-name($node) } {
                for $attr in $node/@*
                return
                    element { local-name($attr) } {
                        if(functx:is-a-number($attr/string())) then
                            attribute json:literal {'true'}
                        else ()
                        ,
                        $attr/string()
                    }
                ,
                json-helpers:copy-nodes($node/node())
            }
        else ()
};

declare function json-helpers:slug($text as xs:string) as xs:string {
    $text ! normalize-space(.) ! lower-case(.) ! replace(., '[^a-zA-Z0-9]', '-') ! replace(., '\-+', '-') ! replace(., '^\-|\-$', '')
};

declare function json-helpers:normalize-text($element as element()) as xs:string? {
    string-join($element//text()) ! normalize-space(.)
};

declare function json-helpers:title-migration-id($source-key as xs:string, $title-type as xs:string, $title as element(), $all-titles as element()*) as xs:string {

    let $language := ($title/@xml:lang, 'en')[1]
    let $similar-titles := $all-titles[@xml:lang eq $title/@xml:lang][@type eq $title/@type][(@key, ($title/@key, '')[1])[1] eq ($title/@key, '')[1]]
    let $index-in-similar-titles := (functx:index-of-node($similar-titles, $title), 1)[1]
    
    return
        string-join(($source-key, $title-type, $language, $index-in-similar-titles), '/')

};

declare function json-helpers:store($data as element(), $file-name as xs:string, $target-subdir as xs:string?) as xs:string {
   
    store:file(string-join(('/db/apps/84000-static/json', $target-subdir[. gt '']), '/'), $file-name, serialize($data, $json-helpers:json-serialization-parameters), 'application/json')
    
};

declare function json-helpers:translation-html($xml-response as element(eft:response)) {

    let $translation := $xml-response/eft:translation
    let $text-id := $translation/@id/string()
    let $tei := tei-content:tei($text-id, 'translation')
    let $cache-key := translation:cache-key($tei, ())
    let $html-cached := ()(:common:cache-get($xml-response/eft:request, $cache-key, false()):)
    return
        if(not($html-cached)) then 
            let $xslt := doc(concat($common:app-path, "/views/html/translation.xsl"))
            let $html-fresh := transform:transform($xml-response, $xslt, <parameters/>)
            let $cache := ()(:common:cache-put($xml-response/eft:request, $html-fresh, $cache-key):)
            return
                $html-fresh
        else $html-cached
        
};

declare function json-helpers:passages($html-sections as element(xhtml:section)*) {
    
    let $xslt := doc('../passages.xsl')
    let $parameters :=
        <parameters>
            <param name="api-version" value="{ $types:api-version }"/>
        </parameters>
    
    return
        transform:transform($html-sections, $xslt, $parameters)
    
};

declare function json-helpers:distinct-names($entity as element()?, $default-lang as xs:string?) as element(eft:name)* {
    json-helpers:distinct-names($entity, (), $default-lang)
};

declare function json-helpers:distinct-names($entity as element()?, $fallback as element()?, $default-lang as xs:string?) as element(eft:name)* {

    let $names := (
        
        if($entity) then (
            if(local-name($entity) = ('team','sponsor')) then
                for $label at $label-index in ($entity/eft:internal-name, $entity/eft:label)
                let $label-lang := ($label/@xml:lang, $default-lang, 'en')[1]
                let $label-id := string-join(($entity/@xml:id, $label-lang, $label-index, 'text'), '/')
                let $label-text := json-helpers:normalize-text($label)
                let $internalName := (local-name($label) = ('internal-name'))
                return
                    types:name($label-id, $label-lang, $label, $entity/@xml:id, $internalName)
            else ()
            ,
            
            for $instance in $entity/eft:instance
            let $tei-target := $tei-content:translations-collection/id($instance/@id)
            return
                (: Glossary terms -> Name :)
                if($tei-target[self::tei:gloss](:[not(@mode eq 'surfeit')]:)) then
                    for $term in $tei-target/tei:term[not(@xml:lang eq 'bo' and @n)]
                    let $term-lang := ($term/@xml:lang, $default-lang, 'en')[1]
                    let $term-lang-index := functx:index-of-node($tei-target/tei:term[(@xml:lang/string(), 'en')[1] eq $term-lang], $term)
                    let $label-id := string-join(($tei-target/@xml:id, $term-lang, $term-lang-index, 'text'), '/')
                    let $term-text := json-helpers:normalize-text($term)
                    where $term-text
                    return
                        types:name($label-id, $term-lang, $term-text, $entity/@xml:id, false())
                
                (: Author/Sponsor -> Name :)
                else if($tei-target[not(@role eq 'translatorMain')]) then (: tei:sponsor, tei:author, tei:editor etc. :)
                    let $target-text := $tei-target ! json-helpers:normalize-text(.)
                    let $target-lang := ($tei-target/@xml:lang, $default-lang, 'en')[1]
                    let $label-id := string-join(($tei-target/@xml:id, $target-lang, 'text'), '/')
                    where $target-text
                    return
                        types:name($label-id, $target-lang, $target-text, $entity/@xml:id, false())
                
                else ()
        )
        else
            let $target-text := $fallback ! json-helpers:normalize-text(.)
            let $target-lang := ($fallback/@xml:lang, $default-lang, 'en')[1]
            let $label-id := string-join(($fallback/@xml:id, $target-lang, 'text'), '/')
            where $target-text
            return
                types:name($label-id, $target-lang, $target-text, (), false())
                
    )
    
    for $name in $names
    let $name-lang := $name/@language
    let $name-content := json-helpers:normalize-text($name/eft:content)
    group by $name-content, $name-lang
    return 
        $name[1]
        
};

declare function json-helpers:glossaries($tei as element(tei:TEI), $html as element(xhtml:html)) as element(eft:glossary)* {
    
    let $text-id := tei-content:id($tei)
    
    for $gloss in $tei//tei:back/tei:div[@type eq 'glossary']/descendant::tei:gloss[@xml:id]
    let $entity := $entities:entities//eft:instance[@id eq $gloss/@xml:id]/parent::eft:entity
    let $entity-names := $entity ! json-helpers:distinct-names(., 'en')
    let $definition-tei := $gloss/tei:note[@type eq 'definition']
    let $definition-html := $html//xhtml:div[@id eq $gloss/@xml:id]/descendant::xhtml:p[matches(@class, '(^|\s)definition(\s|$)')]
    let $definition-html-string := string-join($definition-html ! serialize(.)) ! replace(., '\s+xmlns=[^\s|>]*', '')
    return 
        for $term in $gloss/tei:term[not(@xml:lang eq 'bo' and @n)][normalize-space(string-join(text()))]
        let $term-lang := ($term/@xml:lang, 'en')[1]
        let $term-text := json-helpers:normalize-text($term)
        let $term-lang-index := functx:index-of-node($gloss/tei:term[(@xml:lang/string(), 'en')[1] eq $term-lang], $term)
        let $term-id := string-join(($gloss/@xml:id, $term-lang, $term-lang-index), '/')
        let $entity-name := $entity-names[@language eq $term-lang][eft:content/text() eq $term-text]
        let $name-id := ($entity-name/@xmlId, string-join(('error', $term-lang, $term-text), ':'))[1]
        return
            types:glossary(
                $term-id, 
                $gloss/@xml:id,
                $entity/@xml:id, 
                $name-id, 
                $text-id, 
                $term[@type eq 'translationMain'] ! $definition-html-string, 
                $term[@type eq 'translationMain'] ! $definition-tei/@rend, 
                $term/@type[string() = ('translationMain', 'translationAlternative')], 
                $term/@type[not(string() = ('translationMain', 'translationAlternative'))] ! concat('attestation-', .), 
                ($term[@status eq 'verified'] ! true(), false())[1], 
                ($gloss/@mode, 'match')[1]
            )
};
