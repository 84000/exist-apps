xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";

declare namespace m="http://read.84000.co/ns/1.0";

let $request-id := request:get-parameter('id', '')      (: in get :)
let $post-id := request:get-parameter('post-id', '')    (: in post :)

(: Process input :)
let $new-id := 
    if($post-id) then
        contributors:update-person($contributors:contributors/m:contributors/m:person[@xml:id eq $post-id])
    else
        ''

let $translator := 
    if($new-id gt '') then
        contributors:person($new-id, true())
    else if($post-id gt '') then
        contributors:person($post-id, true())
    else if($request-id gt '') then
        contributors:person($request-id, true())
    else
        ()

return
    common:response(
        'operations/edit-translator', 
        'operations',
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $translator/@xml:id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { if($new-id) then <updated/> else () }
            </updates>,
            $translator,
            contributors:teams(false()),
            contributors:institutions(false())
        )
    )