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
        contributors:update-team($contributors:contributors/m:contributors/m:team[@xml:id eq $post-id])
    else
        ''

let $team := 
    if($new-id gt '') then
        contributors:team($new-id, true(), true())
    else if($post-id gt '') then
        contributors:team($post-id, true(), true())
    else if($request-id gt '') then
        contributors:team($request-id, true(), true())
    else
        ()

return

    common:response(
        'operations/edit-translator-team', 
        'operations',
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $team/@xml:id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { if($new-id) then <updated/> else () }
            </updates>,
            $team
        )
    )(::)