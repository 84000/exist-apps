xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace file-upload="http://operations.84000.co/file-upload" at "../modules/file-upload.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../modules/translation-status.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)

let $text-id := request:get-parameter('text-id', '')
let $submission-id := request:get-parameter('submission-id', '')
let $tei := tei-content:tei($text-id, 'translation')

let $updated := 
    if(not(request:get-parameter('checklist[]', '') = '')) then
    (
        file-upload:generate-tei($text-id, $submission-id),
        translation-status:update-submission($text-id, $submission-id)
    )
    else
        ()
    
return
    common:response(
        'operations/edit-text-submission', 
        'operations',
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                text-id="{ $text-id }"
                submission-id="{ $submission-id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { $updated }
            </updates>,
            <translation 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"
                status="{ tei-content:translation-status($tei) }">
                { 
                    element title { 
                        tei-content:title($tei) 
                    },
                    translation:toh($tei,'')
                }
            </translation>,
            doc('../config/submission-checklist.xml'),
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                translation-status:submissions($text-id)
            }
        )
    )