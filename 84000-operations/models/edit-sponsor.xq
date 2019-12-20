xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

let $request-id := request:get-parameter('id', '')      (: in get :)
let $post-id := request:get-parameter('post-id', '')    (: in post :)

(: Process input if posted :)
let $new-id := 
    if($post-id) then
        sponsors:update($sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq $post-id])
    else
        ''

let $sponsor := 
    if($new-id gt '') then
        sponsors:sponsor($new-id, true(), true())
    else if($post-id gt '') then
        sponsors:sponsor($post-id, true(), true())
    else if($request-id gt '') then
        sponsors:sponsor($request-id, true(), true())
    else
        ()

return
    common:response(
        'operations/edit-sponsor', 
        'operations', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $sponsor/@xml:id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { if($new-id) then <updated node="sponsor" update="insert"/> else () }
            </updates>,
            $sponsor
        )
    )