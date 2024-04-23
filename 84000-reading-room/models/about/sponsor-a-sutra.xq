xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../modules/sponsorship.xql";
import module namespace entities="http://read.84000.co/entities" at "../../modules/entities.xql";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'about/sponsor-a-sutra' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

(: Define the cache longevity in the cache-key :)
let $cache-key := format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]") || '-' || replace($common:app-version, '\.', '-')
let $cached := common:cache-get($request, $cache-key)
return if($cached) then $cached else

let $sponsorship-texts := translations:sponsorship-texts()

let $entities := 
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        let $attribution-ids := $sponsorship-texts//m:attribution/@xml:id
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
            $sponsorship-texts,
            $entities,
            $sponsorship:cost-groups
        )
    )

return 
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/about/sponsor-a-sutra.xsl"), $cache-key)
    
    (: return json data :)
    else if($request/@resource-suffix = ('json')) then
        common:serialize-json(transform:transform($xml-response, doc(concat($common:app-path, "/views/json/0.4.0/sponsorship.xsl")), <parameters/>))
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)