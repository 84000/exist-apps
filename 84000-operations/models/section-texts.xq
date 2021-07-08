xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $section-id := request:get-parameter('section-id', 'lobby')
let $published-only := request:get-parameter('published-only', false())
let $include-descendants := request:get-parameter('include-descendants', false())

let $xml-response := 
    common:response(
        'operations/section-texts',
        'operations',
        (
            section:texts($section-id, $published-only, $include-descendants)
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/section-texts.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )