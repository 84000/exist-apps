xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../modules/contributors.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'about/translators' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

let $cache-timestamp := max(collection($common:tei-path)//tei:TEI//tei:notesStmt/tei:note[@type eq "lastUpdated"]/@date-time ! xs:dateTime(.))
let $cached := common:cache-get($request, $cache-timestamp)
return if($cached) then $cached else

let $contributors-teams := contributors:teams(false(), false(), true())
let $contributors-regions := contributors:regions(true())

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
            $contributors-teams,
            $contributors-regions
        )
    )

return 
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then (
        common:html($xml-response, concat($common:app-path, "/views/html/about/translators.xsl"), $cache-timestamp)
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )