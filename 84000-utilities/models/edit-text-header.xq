xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../../84000-reading-room/modules/translation-status.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

(: Only allow on collaboration (master) :)
let $store-conf := $common:environment/m:store-conf

(: Request parameters :)
let $request-id := request:get-parameter('id', '') (: in get :)
let $post-id := request:get-parameter('post-id', '') (: in post :)
let $tei := 
    if($post-id) then
        tei-content:tei($post-id, 'translation')
    else
        tei-content:tei($request-id, 'translation')

let $translation-id := tei-content:id($tei)

(: Process input, if it's posted :)
(: Only allow on collaboration (master) :)
let $updated := 
    if($post-id and $store-conf[@type eq 'master']) then
        (
            translation:update($tei),
            translation-status:update($translation-id)
        )
     else
        ()

return
    common:response(
        'utilities/edit-text-header', 
        'utilities', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $translation-id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { $updated }
            </updates>,
            <translation 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $translation-id }"
                document-url="{ tei-content:document-url($tei) }" 
                locked-by-user="{ tei-content:locked-by-user($tei) }"
                status="{ tei-content:translation-status($tei) }">
                { 
                    for $bibl in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                    return
                        (
                            translation:toh($tei, $bibl/@key),
                            translation:location($tei, $bibl/@key)
                        )
                    ,
                    element title { 
                        tei-content:title($tei) 
                    },
                    tei-content:titles($tei),
                    translation:translation($tei),
                    translation:contributors($tei, true())
                }
            </translation>,
            tei-content:text-statuses-selected(tei-content:translation-status($tei)),
            contributors:persons(false()),
            contributors:teams(true(), false(), false()),
            $tei-content:title-types,
            doc(concat($common:data-path, '/config/contributor-types.xml')),
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                translation-status:notes($translation-id),
                translation-status:tasks($translation-id)
            }
        )
    )
    
    