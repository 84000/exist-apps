xquery version "3.0" encoding "UTF-8";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $delete-sponsor-id := request:get-parameter('delete', '')

let $delete-sponsor := 
    if($delete-sponsor-id gt '') then
        sponsors:delete($sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq $delete-sponsor-id])
    else
        ()

let $xml-response := 
    common:response(
        'operations/sponsors', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0"/>,
            sponsors:sponsors('all', true())
        )
    )
    
return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/sponsors.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )