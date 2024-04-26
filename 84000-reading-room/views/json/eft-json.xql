xquery version "3.1";

module namespace eft-json = "http://read.84000.co/json";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace functx="http://www.functx.com";

declare function eft-json:response($api-version as xs:string, $uri as xs:string, $html-url as xs:string, $text-id as xs:string, $toh-key as xs:string?, $publication-version as xs:string, $publication-status as xs:string, $cache-key as xs:string, $content as element()*) as element(eft:response) {
    
    (: Root node of json response object :)
    element { QName('http://read.84000.co/ns/1.0', 'response') } {
        attribute api-version { $api-version },
        attribute uri { $uri },
        attribute html-url { $html-url },
        attribute text-id { $text-id },
        attribute toh-key { $toh-key },
        attribute publication-version { $publication-version },
        attribute publication-status { $publication-status },
        attribute cache-key { $cache-key },
        
        $content
    
    }
    
};

declare function eft-json:titles($titles as element()*) {
    for $title in $titles
    return
        element { QName('http://read.84000.co/ns/1.0', 'title') } {
            element { $title/@xml:lang } {
                text {$title/text() }
            }
        }
};

declare function eft-json:parent-sections($parent as element()?) as element()? {
    if($parent) then
        element { QName('http://read.84000.co/ns/1.0', 'parent-section') } {
            $parent/@id,
            attribute url { concat('/section/', $parent/@id, '.json') },
            eft-json:titles($parent/eft:titles/eft:title),
            eft-json:parent-sections($parent/eft:parent)
        }
    else ()
};

declare function eft-json:tei-to-escaped-xhtml($tei as element()*, $xsl as document-node()) as xs:string? {
    let $tei-primed := common:strip-ids($tei)
    where $tei-primed
    return
        serialize(
            element { QName('http://www.w3.org/1999/xhtml','div') } { 
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

    let $location-pre-processed := $text-outline/eft:pre-processed/eft:*[@id eq $location-id]
    return
        
        if($location[self::tei:note]) then 
            $text-outline//eft:part[@id eq 'end-notes'][1][@prefix] ! concat(@prefix, $location-pre-processed[1] ! concat('.', (@label, @index)[1])) 
        else if($location[self::tei:gloss]) then 
            $text-outline//eft:part[@id eq 'glossary'][1][@prefix] ! concat(@prefix, $location-pre-processed[1] ! concat('.', (@label, @index)[1])) 
        else 
            $text-outline//eft:part[@id eq $location-pre-processed/@part-id][1][@prefix] ! concat(@prefix, $location-pre-processed[1] ! concat('.', (@label, @index)[1]))
    
};

declare function eft-json:content-nodes($nodes as node()*) as node()* {

    for $node at $index in $nodes
    return
    
        if(functx:node-kind($node) eq 'text') then
            $node[normalize-space(.) gt ''] ! eft-json:text-node('text', $index, .)
        
        else if($node[self::tei:head][@type eq parent::eft:part/@type]) then ()
        
        else if($node[self::tei:milestone]) then ()
        
        else
            let $content := (
            
                for $attr in $node/@*[not(local-name() eq 'tid')]
                return
                    eft-json:attribute-node(local-name($attr), $attr/string())
                ,
                
                (: If there are text nodes then serialize the content and return :)
                if($node/node()[functx:node-kind(.) eq 'text'][normalize-space(.)]) then
                    string-join($node/node() ! serialize(.)) ! normalize-space(.) ! eft-json:text-node('markup', $index, element markup { . })
                
                (: If there's just elements the move down the tree :)
                else if($node/node()) then
                    eft-json:content-nodes($node/node())
                    
                else ()
                
            )
            return
                eft-json:element-node(local-name($node), $index, (), (), $content)
            
};

declare function eft-json:persistent-location($node as node()) as element() {
    
    if($node[@xml:id]) then
        $node
    else if($node[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]) then
        $node/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]
    else 
        $node/ancestor-or-self::eft:part[@id][1]

};

declare function eft-json:annotation($type as xs:string) as element(eft:annotation) {
    eft-json:annotation($type, (), (), (), ())
};

declare function eft-json:annotation-link($type as xs:string, $resourceId as element(id)?) as element(eft:annotation) {
    eft-json:annotation($type, $resourceId, (), (), ())
};

declare function eft-json:annotation-substring($substring-text as xs:string?, $substring-occurrence as xs:integer?, $type as xs:string, $resourceId as element(id)?) as element(eft:annotation) {
    eft-json:annotation($type, $resourceId, $substring-text, $substring-occurrence, ())
};

declare function eft-json:annotation($type as xs:string, $resourceId as element(id)?, $substring-text as xs:string?, $substring-occurrence as xs:integer?, $body-text as xs:string?) as element(eft:annotation) {
    element { QName('http://read.84000.co/ns/1.0', 'annotation') } { 
    
        element {'annotationType'} { $type },
        
        if($resourceId or $body-text) then
            element body {
                $resourceId ! (
                    attribute {'id'} { $resourceId/content },
                    attribute {'type'} { $resourceId/idType }
                ),
                $body-text ! element value { . }
            }
        else ()
        ,
        
        if($substring-text) then
            element target {
                element selector {
                    attribute { 'type' } { 'TextQuoteSelector' },
                    element {'exact'} { $substring-text },
                    $substring-occurrence ! element {'substringOccurrence'} { attribute json:literal {'true'}, . }
                }
            }
        else ()
        
    }
};

declare function eft-json:id($type as xs:string, $resourceId as xs:string) as element(id) {
    element id { 
        element {'idType'} { $type },
        element {'content'} { $resourceId }
    }
};