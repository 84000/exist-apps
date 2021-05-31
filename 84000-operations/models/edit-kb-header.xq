xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";

let $request-id := request:get-parameter('id', '')
let $form-action := request:get-parameter('form-action', '')

let $tei := tei-content:tei($request-id, 'knowledgebase')

let $updated := 
    if($form-action eq 'update-kb-header' and $tei) then (
        update-tei:knowledgebase-header($tei)
    )
    else ()

return
    common:response(
        'operations/edit-kb-header', 
        'operations', 
        (
            (: Include request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request') } {
                attribute id { $request-id }
            },
            
            (: Details of updates :)
            element { QName('http://read.84000.co/ns/1.0', 'updates') } {
                $updated
            },
            
            (: Knowledgebase content :)
            element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') } {
                
                attribute document-url { tei-content:document-url($tei) },
                attribute locked-by-user { tei-content:locked-by-user($tei) },
                
                knowledgebase:page($tei),
                knowledgebase:publication($tei),
                knowledgebase:taxonomy($tei),
                knowledgebase:article($tei),
                knowledgebase:bibliography($tei),
                knowledgebase:end-notes($tei),
                tei-content:status-updates($tei)
                
            },
            
            (: Config :)
            tei-content:text-statuses-selected(tei-content:translation-status($tei)),
            $tei-content:title-types
        )
    )