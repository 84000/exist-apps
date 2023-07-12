xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace section="http://read.84000.co/section" at "../../modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'widget/progress-chart' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

(: Define the cache longevity in the cache-key :)
let $cache-key := format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]") || '-' || replace($common:app-version, '\.', '-')
let $cached := common:cache-get($request, $cache-key)
return if($cached) then $cached else

let $publication-status := section:publication-status('LOBBY', ())

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id,
        (
            $request,
            $publication-status,
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#commsSiteUrl">{ $common:environment/m:url[@id eq 'communications-site'][1]/text() }</value>
                <value key="#readingRoomSiteUrl">{ $common:environment/m:url[@id eq 'reading-room'][1]/text() }</value>
                <value key="#labelPublished">{ common:local-text('translation-status-group.published.label', $request/@lang) }</value>
                <value key="#labelTranslated">{ common:local-text('translation-status-group.translated.label', $request/@lang) }</value>
                <value key="#labelInTranslation">{ common:local-text('translation-status-group.in-translation.label', $request/@lang) }</value>
                <value key="#labelRemaining">{ common:local-text('translation-status-group.remaining.label', $request/@lang) }</value>
            </replace-text>
        )
    )

return
        (: return html :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/widget/progress-chart.xsl"), $cache-key)
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)