xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')

let $summary-kangyur := translations:summary($source:kangyur-work)
let $summary-tengyur := translations:summary($source:tengyur-work)
let $text-statuses := tei-content:text-statuses-sorted('translation')
let $recent-activity := translations:recent-updates()

let $xml-response :=
    common:response(
        'operations/index', 
        'operations', 
        (
            $summary-kangyur,
            $summary-tengyur,
            $text-statuses,
            $recent-activity
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/index.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )