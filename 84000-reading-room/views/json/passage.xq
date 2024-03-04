xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.1.0';
declare variable $local:response := request:get-data()/eft:response;
declare variable $local:translation := $local:response/eft:translation;
declare variable $local:text-id := $local:response/eft:translation/@id;
declare variable $local:toh-key := $local:translation/eft:source/@key;
declare variable $local:passage-id := $local:response/eft:request/@passage-id;
declare variable $local:text-outline := $local:response/eft:text-outline[@text-id eq $local:text-id];
declare variable $local:xslt := doc(concat($common:app-path, "/views/html/passage.xsl"));
declare variable $local:xhtml := transform:transform($local:response, $local:xslt, <parameters/>);

declare function local:parse-response() as element()* {
    
    for $location at $index in ($local:translation/descendant::eft:part[@content-status eq 'passage'][not(@id = ('end-notes','glossary'))][not(eft:part[@content-status eq 'passage'])] | $local:translation/eft:part[@id eq 'end-notes']/tei:note | $local:translation/eft:part[@id eq 'glossary']/tei:gloss)
    
    let $location-id := ($location/@xml:id, $location/descendant::tei:milestone/@xml:id)[1]
    
    let $label := eft-json:label($location, $location-id, $local:text-outline)
    
    let $content := (
        (: TEI -> JSON :)
        element tei { 
            if($location[self::tei:note]) then 
                local:content-nodes($location)
            else if($location[self::tei:gloss]) then 
                local:content-nodes($location)
            else 
                $location/* ! local:content-nodes(.)
        },
        (: TEI -> HTML -> JSON :)
        element html { 
            string-join($local:xhtml/descendant-or-self::xhtml:*[@data-location-id eq $location-id] ! serialize(.) ! replace(., '\s+xmlns=[^\s|>]*', '')) ! normalize-space(.)
        }
    )
    
    return
        eft-json:element-node(local-name($location), $index, $location-id, $label, $content)

};

declare function local:content-nodes($nodes as node()*) as node()* {

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
                    local:content-nodes($node/node())
                    
                else ()(: element value { "empty" } :)
                
            )
            return
                eft-json:element-node(local-name($node), $index, (), (), $content)
            
};

declare function local:persistent-location($node as node()) as element() {
    
    if($node[@xml:id]) then
        $node
    else if($node[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]) then
        $node/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]
    else 
        $node/ancestor-or-self::eft:part[@id][1]

};

element response {

    attribute api-version { $local:api-version },
    attribute url { concat('/passage/', $local:translation/eft:source/@key,'.json?passage-id=', $local:passage-id, '&amp;api-version=', $local:api-version) },
    attribute text-id { $local:translation/@id },
    attribute toh-key { $local:toh-key },
    attribute text-version { tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]) },
    attribute html { concat('/passage/', $local:translation/eft:source/@key,'.html?passage-id=', $local:passage-id) },
    
    (:$local:response/eft:request,:)
    
    $local:translation/id($local:passage-id) ! local:parse-response()
    
}
