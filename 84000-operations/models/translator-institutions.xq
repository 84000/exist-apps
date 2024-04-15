xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $delete-institution-id := request:get-parameter('delete', '')

let $delete-institution := 
    if($delete-institution-id gt '') then
        contributors:delete($contributors:contributors/m:contributors/m:institution[@xml:id eq $delete-institution-id])
    else
        ()

let $xml-response := 
    common:response(
        'operations/translator-institutions', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0"/>,
            contributors:institutions(false()),
            contributors:regions(false()),
            contributors:institution-types(false())
        )
    )
    
return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/translator-institutions.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )