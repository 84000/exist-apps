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

declare variable $local:api-version := (request:get-attribute('api-version'),'0.1.0')[1];
declare variable $local:response := request:get-data()/eft:response;
declare variable $local:translation := $local:response/eft:translation;
declare variable $local:text-id := $local:response/eft:translation/@id;
declare variable $local:toh-key := $local:translation/eft:source/@key;
declare variable $local:passage-id := $local:response/eft:request/@passage-id;
declare variable $local:text-outline := $local:response/eft:text-outline[@text-id eq $local:text-id];
declare variable $local:xslt := doc(concat($common:app-path, "/views/html/passage.xsl"));
declare variable $local:xhtml := transform:transform($local:response, $local:xslt, <parameters/>);

declare function local:parse-response() as element()* {
    
    for $location at $index in (
        $local:translation/descendant::eft:part[@content-status eq 'passage'][not(@id = ('end-notes','glossary'))][not(eft:part[@content-status eq 'passage'])] 
        | $local:translation/eft:part[@type eq 'end-notes']/tei:note 
        | $local:translation/eft:part[@type eq 'glossary']/tei:gloss
    )
    
    let $location-id := ($location/@xml:id, $location/descendant::tei:milestone/@xml:id)[1]
    
    let $label := eft-json:label($location, $location-id, $local:text-outline)
    
    let $content := (
        (: TEI -> JSON :)
        element tei { 
            if($location[self::tei:note]) then 
                eft-json:content-nodes($location)
            else if($location[self::tei:gloss]) then 
                eft-json:content-nodes($location)
            else 
                $location/* ! eft-json:content-nodes(.)
        },
        (: TEI -> HTML -> JSON :)
        element html { 
            string-join($local:xhtml/descendant-or-self::xhtml:*[@data-location-id eq $location-id] ! serialize(.) ! replace(., '\s+xmlns=[^\s|>]*', '')) ! normalize-space(.)
        }
    )
    
    return
        eft-json:element-node(local-name($location), $index, $location-id, $label, $content)

};

eft-json:response(
    $local:api-version,
    concat('/passage/', $local:translation/eft:source/@key,'.json?passage-id=', $local:passage-id, '&amp;api-version=', $local:api-version),
    concat('/passage/', $local:translation/eft:source/@key,'.html?passage-id=', $local:passage-id),
    $local:translation/@id,
    $local:toh-key,
    tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]),
    $local:translation/@status,
    $local:translation/@cache-key,
    $local:translation/id($local:passage-id) ! local:parse-response()
)
