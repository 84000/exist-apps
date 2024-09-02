xquery version "3.0" encoding "UTF-8";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $delete-team-id := request:get-parameter('delete', '')

let $delete-team := 
    if($delete-team-id gt '') then
        contributors:delete($contributors:contributors/m:contributors/m:team[@xml:id eq $delete-team-id])
    else ()

let $xml-response := 
    common:response(
        'operations/translator-teams', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0"/>,
            contributors:teams(true(), true())
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/translator-teams.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )