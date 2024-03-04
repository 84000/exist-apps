xquery version "3.1";

module namespace eft-json = "http://read.84000.co/json";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace functx="http://www.functx.com";

declare function eft-json:titles($titles as element()*) {
    for $title in $titles
    return
        element { 'title' } {
            element { $title/@xml:lang } {
                text {$title/text() }
            }
        }
};

declare function eft-json:parent-sections($parent as element()?) as element()? {
    if($parent) then
        element parent-section {
            $parent/@id,
            attribute url { concat('/section/', $parent/@id, '.json') },
            eft-json:titles($parent/m:titles/m:title),
            eft-json:parent-sections($parent/m:parent)
        }
    else ()
};

declare function eft-json:tei-to-escaped-xhtml($tei as element()*, $xsl as document-node()) as xs:string? {
    let $tei-primed := common:strip-ids($tei)
    where $tei-primed
    return
        serialize(
            element {QName('http://www.w3.org/1999/xhtml','div')} { 
                transform:transform($tei-primed, $xsl, <parameters/>)
            }
        )
};

declare function eft-json:copy-nodes($nodes as node()*) as node()* {
    for $node in $nodes
    return
        if(functx:node-kind($node) eq 'text') then
            $node
        else
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
                eft-json:copy-nodes($node/node())
            }
};

declare function eft-json:attribute-node($attribute-name as xs:string, $value as xs:string) as element() {
    local:node('attribute', $attribute-name, (), (), (), element value { $value })
};

declare function eft-json:text-node($text-type as xs:string, $index as xs:integer, $value as xs:string) as element() {
    local:node('text', $text-type, $index, (), (), element value { $value })
};

declare function eft-json:element-node($node-name as xs:string, $index as xs:integer, $xmlId as xs:string?, $label as xs:string?, $content as node()*) as element() {
    local:node('element', $node-name, $index, $xmlId, $label, $content)
};

declare function local:node($node-type as xs:string, $node-name as xs:string, $index as xs:integer?, $xmlId as xs:string?, $label as xs:string?, $content as node()*) as element() {
    element node {
        attribute type { $node-type },
        $node-name ! attribute name { $node-name },
        $xmlId ! attribute xmlId { . },
        $label ! attribute label { . },
        if(count($content) eq 1 and functx:is-a-number($content/string()) and not($index)) then attribute json:literal {'true'} else (),
        $index ! element index { attribute json:literal {'true'}, . },
        $content
    }
};

declare function eft-json:label($location as element(), $location-id as xs:string, $text-outline as element()) as xs:string? {

    let $location-pre-processed := $text-outline/m:pre-processed/m:*[@id eq $location-id]
    return
        
        if($location[self::tei:note]) then 
            $text-outline//m:part[@id eq 'end-notes'][1][@prefix] ! concat(@prefix, $location-pre-processed[1] ! concat('.', (@label, @index)[1])) 
        else if($location[self::tei:gloss]) then 
            $text-outline//m:part[@id eq 'glossary'][1][@prefix] ! concat(@prefix, $location-pre-processed[1] ! concat('.', (@label, @index)[1])) 
        else 
            $text-outline//m:part[@id eq $location-pre-processed/@part-id][1][@prefix] ! concat(@prefix, $location-pre-processed[1] ! concat('.', (@label, @index)[1]))
    
};