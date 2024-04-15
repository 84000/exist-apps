xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../modules/sponsors.xql";
import module namespace entities="http://read.84000.co/entities" at "../../modules/entities.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'about/sponsors' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

(: Define the cache longevity in the cache-key :)
let $cache-key := format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]") || '-' || replace($common:app-version, '\.', '-')
let $cached := common:cache-get($request, $cache-key)
return if($cached) then $cached else

let $sponsor-ids := $sponsors:sponsors/m:sponsors/m:sponsor[m:type/@id = ('founding', 'matching-funds')]/@xml:id
let $sponsors := sponsors:sponsors($sponsor-ids, false())
let $sponsored-texts := translations:sponsored-texts()

let $entities := 
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        let $attribution-ids := $sponsored-texts//m:attribution/@xml:id
        return 
            $entities:entities//m:instance[@id = $attribution-ids]/parent::m:entity
    }

let $xml-response :=
    common:response(
        $request/@model,
        $common:app-id,
        (   
            $request,
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#commsSiteUrl">{ $common:environment/m:url[@id eq 'communications-site'][1]/text() }</value>
                <value key="#readingRoomSiteUrl">{ $common:environment/m:url[@id eq 'reading-room'][1]/text() }</value>
                <value key="#feSiteUrl">{ $common:environment/m:url[@id eq 'front-end'][1]/text() }</value>
            </replace-text>,
            $sponsors,
            $sponsored-texts,
            $entities
        )
    )

return 
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/about/sponsors.xsl"), $cache-key)
   
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
    