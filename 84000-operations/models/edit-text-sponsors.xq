xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-translation="http://operations.84000.co/update-translation" at "../modules/update-translation.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)
let $request-id := request:get-parameter('id', '') (: in get :)
let $post-id := request:get-parameter('post-id', '') (: in post :)
let $form-action := request:get-parameter('form-action', '')
let $tei := 
    if($post-id) then
        tei-content:tei($post-id, 'translation')
    else
        tei-content:tei($request-id, 'translation')

let $text-id := tei-content:id($tei)

let $document-uri := base-uri($tei)
let $document-uri-tokenised := tokenize($document-uri, '/')
let $document-filename := $document-uri-tokenised[last()]
let $document-path := substring-before($document-uri, $document-filename)
let $tei-locked-by-user := xmldb:document-has-lock(concat("xmldb:exist://", $document-path), $document-filename)

(: Process input :)
let $updated := 
    if($post-id and $tei and $text-id and $form-action eq 'update-sponsorship') then (
        update-translation:title-statement($tei),
        update-translation:project($text-id)
    )
     else ()

(: Return output :)
let $acknowledgment := translation:acknowledgment($tei)
return
    common:response(
        'operations/edit-text-sponsors', 
        'operations', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { $updated }
            </updates>,
            <translation 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"
                document-url="{ concat($document-path, $document-filename) }" 
                locked-by-user="{ $tei-locked-by-user }"
                status="{ tei-content:translation-status($tei) }">
                { translation:titles($tei) }
                { translation:sponsors($tei, true()) }
                { translation:publication($tei) }
                { translation:toh($tei, '') }
            </translation>,
            sponsors:sponsors('all', false(), true()),
            sponsorship:text-status($text-id, true())
        )
    )
    
    