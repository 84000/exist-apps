xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace section="http://read.84000.co/section" at "../../modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'widget/progress-panel' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

(: Define the cache longevity in the cache-key :)
let $cache-key := format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]") || '-' || replace($common:app-version, '\.', '-')
let $cached := common:cache-get($request, $cache-key)
return 

    if($cached) then $cached else
    
    let $publication-status := section:publication-status('O1JC11494', ())
    
    let $xml-response := 
        common:response(
            $request/@model, 
            $common:app-id,
            (
                $request,
                $publication-status
            )
        )
    
    return
            (: return html :)
        if($request/@resource-suffix = ('html')) then 
            common:html($xml-response, concat($common:app-path, "/views/html/widget/progress-panel.xsl"), $cache-key)
        
        (: return xml data :)
        else 
            common:serialize-xml($xml-response)
        