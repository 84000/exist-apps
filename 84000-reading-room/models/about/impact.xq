xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'about/impact' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

(: Define the cache longevity in the cache-key :)
let $cache-key := format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]") || '-' || replace($common:app-version, '\.', '-')
let $cached := common:cache-get($request, $cache-key)
return if($cached) then $cached else

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id,(
            
            $request,
            
            (: Calculated strings :)
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#commsSiteUrl">{ $common:environment/m:url[@id eq 'communications-site'][1]/text() }</value>
                <value key="#readingRoomSiteUrl">{ $common:environment/m:url[@id eq 'reading-room'][1]/text() }</value>
                <value key="#feSiteUrl">{ $common:environment/m:url[@id eq 'front-end'][1]/text() }</value>
                <value key="#visitorsPerWeekFormatted">{ common:format-number(8000) }</value>
                <value key="#reachCountriesFormatted">{ common:format-number(155) }</value>
                <value key="#annualDownloadsFormatted">{ common:format-number(35800) }</value>
                <value key="#sharing-url">/about/impact.html</value>
            </replace-text>
            
        )
    )

return
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/about/impact.xsl"), $cache-key)
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
    