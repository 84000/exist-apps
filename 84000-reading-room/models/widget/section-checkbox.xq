xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../../modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'widget/section-checkbox' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

(: Define the cache longevity in the cache-key :)
let $tei-timestamp := max(collection($common:tei-path)//tei:TEI//tei:notesStmt/tei:note[@type eq "lastUpdated"]/@date-time ! xs:dateTime(.))
let $cache-key := 
    if($tei-timestamp instance of xs:dateTime) then
        lower-case(format-dateTime($tei-timestamp, "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]") || '-' || replace($common:app-version, '\.', '-'))
    else ()
let $cached := common:cache-get($request, $cache-key)
return if($cached) then $cached else

let $section-tree := section:section-tree(tei-content:tei('lobby', 'section'), true(), 'descendants-published')

let $xml-response := 
    common:response(
        $request/@model, 
        $common:app-id,
        (
            $request,
            $section-tree
        )
    )

return
    (: return html :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/widget/section-checkbox.xsl"), $cache-key)
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
