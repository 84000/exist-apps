xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)
let $request-id := request:get-parameter('id', '') (: in get :)
let $text-id := 'UT22084-001-001'

return
    common:response(
        'operations/edit-text-submission', 
        'operations',
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $request-id }"
                text-id="{ $text-id }"/>
        )
    )