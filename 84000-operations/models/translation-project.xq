xquery version "3.0" encoding "UTF-8";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace file-upload="http://operations.84000.co/file-upload" at "../modules/file-upload.xql";
import module namespace translation-status="http://operations.84000.co/translation-status" at "../modules/translation-status.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $request-id := request:get-parameter('id', '') (: in get :)
let $post-id := request:get-parameter('post-id', '') (: in post :)
let $form-action := request:get-parameter('form-action', '')
let $tei := 
    if($post-id) then 
        tei-content:tei($post-id, 'translation')
    else
        tei-content:tei($request-id, 'translation')

let $text-id := tei-content:id($tei)

(: Delete a submission :)
(: The parameter delete-submission also triggers translation-status:update :)
let $delete-submission-id := request:get-parameter('delete-submission-id', '')
let $delete-submission := 
    if($delete-submission-id gt '') then (
        file-upload:delete-file($text-id, $delete-submission-id),
        translation-status:update($text-id)
    )
    else ()

(: Return request parameters :)
let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') } {
        attribute id { $text-id },
        attribute delete-submission { $delete-submission-id },
        attribute form-expand { request:get-parameter('form-expand', '') }
    }

(: Process input, if it's posted :)
let $updated := 
    element { QName('http://read.84000.co/ns/1.0', 'updates') } {
        if($form-action = ('update-contributors') and $tei) then
            update-tei:title-statement($tei)
        
        else if($form-action eq 'update-publication-status' and $tei) then (
            update-tei:publication-status($tei),
            translation-status:update($text-id)
        )
        
        else if($form-action eq 'process-upload' and $text-id gt '') then (
            file-upload:process-upload($text-id),
            translation-status:update($text-id)
        )
        
        else ()
        
    }

let $publication-status := tei-content:publication-status($tei)
let $publication-status-group := tei-content:publication-status-group($tei)

(: Generate new versions of associated files :)
let $scheduled-job-name := string-join(('store-publication-files', $text-id), '-')
let $publish-content :=
    if($form-action eq 'publish-content' and $text-id gt '' and $store:conf)then
        
        helper:async-script(
            'store-publication-files',
            $scheduled-job-name,
            <parameters xmlns="">
                <param name="resource-id" value="{ $text-id }"/>
                <param name="publish-file-group" value="{ string-join(request:get-parameter('publish-file-group[]',''), ',') }"/>
            </parameters>
        )
            
    else ()

let $scheduled-job := scheduler:get-scheduled-jobs()//scheduler:job[@name eq $scheduled-job-name][not(scheduler:trigger/state/text() eq 'COMPLETE')]

let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') } {
        
        attribute id { $text-id },
        attribute document-url { base-uri($tei) },
        attribute resource-type { tei-content:type($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { $publication-status },
        attribute status-group { $publication-status-group },
        attribute tei-version { tei-content:version-str($tei) },
        
        for $bibl in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key]
        return (
            translation:toh($tei, $bibl/@key),
            tei-content:source($tei, $bibl/@key),
            tei-content:ancestors($tei, $bibl/@key, 1)
        ),
        
        tei-content:titles-all($tei),
        translation:publication($tei),
        translation:contributors($tei, true()),
        tei-content:status-updates($tei),
        translation:files($tei),
        translation:api-status($tei)
        
    }

let $text-statuses-selected := tei-content:text-statuses-selected($publication-status, 'translation')
let $persons := contributors:persons()
let $teams := contributors:teams(true(), false())
let $submission-checklist := doc('../config/submission-checklist.xml')
let $translation-statuses :=
    element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
        translation-status:texts($text-id, true())
    }

let $xml-response := 
    common:response(
        'operations/translation-project', 
        'operations', 
        (
            $request,
            $updated,
            $scheduled-job,
            $text,
            $translation-statuses,
            $text-statuses-selected,
            $persons,
            $teams,
            $tei-content:title-types,
            $contributors:contributor-types,
            $submission-checklist
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/translation-project.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
