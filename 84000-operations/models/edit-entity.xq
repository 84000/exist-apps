xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../modules/update-entity.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') } {
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute entity-id { request:get-parameter('entity-id', '') },
        attribute instance-id { request:get-parameter('instance-id', '') }
    }

let $update-entity := 
    if(request:get-parameter('form-action', '') eq 'update-entity') then
        update-entity:headers($request/@entity-id)
    else if(request:get-parameter('form-action', '') eq 'instance-set-flag') then
        update-entity:set-flag($request/@instance-id, request:get-parameter('entity-flag', ''))
    else if(request:get-parameter('form-action', '') eq 'instance-clear-flag') then
        update-entity:clear-flag($request/@instance-id, request:get-parameter('entity-flag', ''))
    else ()

let $entity := $entities:entities//m:entity[@xml:id eq $request/@entity-id]

let $xml-response := 
    common:response(
        'operations/edit-entity', 
        'operations', 
        (
            $request,
            $entity,
            $entities:types,
            $entities:flags
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-entity.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )