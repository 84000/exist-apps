xquery version "3.0";

(: Variations to json types for version 0.5.0 :)
module namespace json-helpers = "http://read.84000.co/json-helpers/0.5.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json = "http://www.json.org";

import module namespace json-types = "http://read.84000.co/json-types/0.5.0" at "types.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "/db/apps/84000-reading-room/modules/glossary.xql";
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

declare function json-helpers:passages($xml-response as element(eft:response)) {
    
    let $html := json-helpers:translation-html($xml-response)
    let $xslt := doc('../passages.xsl')
    let $parameters :=
        <parameters>
            <param name="api-version" value="{ $json-types:api-version }"/>
        </parameters>
    
    return
        transform:transform($html, $xslt, $parameters)
    
};