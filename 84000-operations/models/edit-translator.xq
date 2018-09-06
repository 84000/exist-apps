xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translators="http://read.84000.co/translators" at "../../84000-reading-room/modules/translators.xql";

declare namespace m="http://read.84000.co/ns/1.0";

let $request-id := request:get-parameter('id', '')      (: in get :)
let $post-id := request:get-parameter('post-id', '')    (: in post :)

(: Process input :)
let $new-id := 
    if($post-id) then
        translators:update($translators:translators/m:translators/m:translator[@xml:id eq $post-id])
    else
        ()

let $translator := 
    if($new-id gt '') then
        translators:translator($new-id, true())
    else if($post-id gt '') then
        translators:translator($post-id, true())
    else if($request-id gt '') then
        translators:translator($request-id, true())
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
            translators:teams(false()),
            translators:institutions()
        )
    )