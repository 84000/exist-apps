xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')

let $sponsorship-text-ids := sponsorship:text-ids('sponsored')
let $publication-status := section:publication-status('LOBBY', $sponsorship-text-ids)
let $text-statuses := tei-content:text-statuses-sorted('translation')
let $recent-updates := translations:recent-updates()

let $xml-response :=
    common:response(
        'operations/index', 
        'operations', 
        (
            $publication-status,
            $text-statuses,
            $recent-updates
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/index.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )