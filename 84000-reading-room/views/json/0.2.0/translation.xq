xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.2.0';
declare variable $local:response := request:get-data()/m:response;
declare variable $local:translation := $local:response/m:translation;
declare variable $local:text-id := $local:response/m:translation/@id;
declare variable $local:toh-key := $local:translation/m:source/@key;
declare variable $local:text-outline := $local:response/m:text-outline[@text-id eq $local:text-id];

declare function local:persistent-location($node as node()) as element() {
    
    if($node[@xml:id]) then
        $node
    else if($node[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]) then
        $node/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]
    else 
        $node/ancestor-or-self::m:part[@id][1]

};

declare function local:parse-translation() {

    element translation {

        attribute api-version { $local:api-version },
        attribute url { concat('/translation/', $local:translation/m:source/@key,'.json?api-version=', $local:api-version) },
        attribute text-id { $local:translation/@id },
        attribute toh-key { $local:toh-key },
        attribute text-version { tei-content:strip-version-number($local:translation/m:publication/m:edition/text()[1]) },
        attribute html { $local:translation/@canonical-html },
        (:attribute debug { string-join($local:translation/m:part/@type, ' / ') },:)
        
        for $title in ($local:translation/m:titles/m:title, $local:translation/m:long-titles/m:title, $local:translation/m:source/m:toh)[normalize-space()]
        return
            element title { 
                attribute lang { ($title/@xml:lang, 'en')[1] }, 
                attribute type { if($title/self::m:toh) then 'toh' else if($title/parent::m:titles) then 'main' else 'long' },
                element value { $title/text() }
            }
        ,
        
        element translation {
            for $part at $index in $local:translation/m:part
            return
                local:parse-parts($part, $index)
        }
        
    }
};

declare function local:parse-parts($part as element(m:part), $index as xs:integer) {

    let $content := (
        
        (: Headings :)
        $part/tei:head ! element heading { 
            attribute type { @type/string() },
            element value { string-join(descendant::text() ! tokenize(., '\n')) ! normalize-space(.) }
        },
        
        let $elements := $part/*[not(self::tei:head)][descendant::text()[normalize-space(.)] or descendant::tei:ref[@cRef]][not(@key) or @key eq $local:toh-key]
        return
            for $element in $elements
            let $location := local:persistent-location($element)
            let $location-id := ($location/@xml:id, $location/@id)[. gt ''][1]
            let $location-index := functx:index-of-node($elements, $element)
            group by $location-id
            let $label := eft-json:label($location[1], $location-id, $local:text-outline)
            order by min($location-index)
            return
                if($element[self::m:note][not(parent::m:part[@id eq 'end-notes'])]) then ()
                else if($element[self::m:orig]) then ()
                else if($element[self::m:part]) then
                    (: Recurse through the tree :)
                    local:parse-parts($element, $location-index)
                else 
                    (: group elements by location and provide a uri :)
                    element passage {
                        attribute xmlId { $location-id },
                        attribute uri { 'http://purl.84000.co/resource/id/' || $location-id },
                        $label ! attribute label { $label }
                    }
    )
    
    return
        eft-json:element-node('part', $index, $part/@id, $part/@prefix/string(), $content)
    
};

local:parse-translation()



