xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := (request:get-attribute('api-version'),'0.2.0')[1];
declare variable $local:response := request:get-data()/eft:response;
declare variable $local:translation := $local:response/eft:translation;
declare variable $local:text-id := $local:response/eft:translation/@id;
declare variable $local:toh-key := $local:translation/eft:source/@key;
declare variable $local:text-outline := $local:response/eft:text-outline[@text-id eq $local:text-id];

declare function local:parse-translation() {

    for $title in ($local:translation/eft:titles/eft:title, $local:translation/eft:long-titles/eft:title, $local:translation/eft:source/eft:toh)[normalize-space()]
    return
        element title { 
            attribute lang { ($title/@xml:lang, 'en')[1] }, 
            attribute type { if($title/self::eft:toh) then 'toh' else if($title/parent::eft:titles) then 'main' else 'long' },
            element value { $title/text() }
        }
    ,
    
    element translation {
        for $part at $index in $local:translation/eft:part
        return
            local:parse-parts($part, $index)
    }
    
};

declare function local:parse-parts($part as element(eft:part), $index as xs:integer) {

    let $content := (
        
        (: Headings :)
        $part/tei:head ! element heading { 
            attribute type { @type/string() },
            element value { string-join(descendant::text() ! tokenize(., '\n')) ! normalize-space(.) }
        },
        
        let $elements := $part/*[not(self::tei:head)][descendant::text()[normalize-space(.)] or descendant::tei:ref[@cRef]][not(@key) or @key eq $local:toh-key]
        return
            for $element in $elements
            let $location := eft-json:persistent-location($element)
            let $location-id := ($location/@xml:id, $location/@id)[. gt ''][1]
            let $location-index := functx:index-of-node($elements, $element)
            group by $location-id
            let $label := eft-json:label($location[1], $location-id, $local:text-outline)
            order by min($location-index)
            return
                if($element[self::eft:note][not(parent::eft:part[@type eq 'end-notes'])]) then ()
                else if($element[self::eft:orig]) then ()
                else if($element[self::eft:part]) then
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

eft-json:response(
    $local:api-version,
    concat('/translation/', $local:translation/eft:source/@key,'.json?api-version=', $local:api-version),
    $local:translation/@canonical-html,
    $local:translation/@id,
    $local:toh-key,
    tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]),
    $local:translation/@status,
    $local:translation/@cache-key,
    local:parse-translation()
)
