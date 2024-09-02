xquery version "3.0" encoding "UTF-8";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $delete-translator-id := request:get-parameter('delete', '')

let $delete-translator := 
    if($delete-translator-id gt '') then
        contributors:delete($contributors:contributors/m:contributors/m:person[@xml:id eq $delete-translator-id])
    else ()

let $xml-response := 
    common:response(
        'operations/translators', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0"/>,
            contributors:persons(),
            contributors:institutions(false()),
            contributors:teams(true(), false())
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/translators.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )