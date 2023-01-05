xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace file-upload="http://operations.84000.co/file-upload" at "../modules/file-upload.xql";
import module namespace translation-status="http://operations.84000.co/translation-status" at "../modules/translation-status.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";
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
let $translation-status := translation-status:texts($text-id)
let $current-version-str := $translation-status/@version ! string()

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
        attribute form-expand { request:get-parameter('form-expand', 'translation-status') }
    }

(: Process input, if it's posted :)
let $updated := 
    element { QName('http://read.84000.co/ns/1.0', 'updates') } {
        if($form-action = ('update-titles', 'update-contributors') and $tei) then
            update-tei:title-statement($tei)
            
        else if($form-action eq 'update-source' and $tei) then
            update-tei:source($tei)
            
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

(: If it's a new version :)
let $tei-version-str := tei-content:version-str($tei)
let $is-new-version := not(tei-content:is-current-version($tei-version-str, $current-version-str))
let $translation-status-group := tei-content:translation-status-group($tei)

(: Commit new version to GitHub :)
let $commit-version := 
    if($post-id and $store:conf and $is-new-version) then 
        deploy:push('data-tei', (), concat($text-id, ' / ', $tei-version-str), tei-content:document-url($tei))
    else ()

(: Generate new versions of associated files :)
let $generate-files :=
    if($form-action eq 'generate-files' and $text-id gt '' and $store:conf and $translation-status-group eq 'published')then
        store:create(concat($text-id, '.all'))
    else ()

let $entities :=
    element { QName('http://read.84000.co/ns/1.0', 'entities') } {
        let $attribution-refs-text := $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl//@ref ! replace(., '^eft:', '')
        let $attribution-entities := $entities:entities/m:entity/id($attribution-refs-text)
        let $attribution-refs := $tei-content:translations-collection//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl//@ref ! replace(., '^eft:', '')
        return (
            ($attribution-entities | $entities:entities/m:entity/id($attribution-refs)),
            element related { entities:related($attribution-entities, true(), (), ()) }
        )
    }
    
let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') } {
            
        attribute id { $text-id },
        attribute document-url { tei-content:document-url($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { $translation-status-group },
        attribute tei-version { $tei-version-str },
        
        for $bibl in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
        return (
            translation:toh($tei, $bibl/@key),
            tei-content:source($tei, $bibl/@key),
            translation:downloads($tei, $bibl/@key, 'all')
        ),
        
        element title { 
            tei-content:title($tei) 
        },
        
        tei-content:titles($tei),
        translation:publication($tei),
        translation:contributors($tei, true()),
        tei-content:status-updates($tei)
        
    }
    
let $translation-status :=
    element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
        translation-status:texts($text-id, true())
    }

let $text-statuses-selected := tei-content:text-statuses-selected(tei-content:translation-status($tei), 'translation')
let $persons := contributors:persons(false(), false())
let $teams := contributors:teams(true(), false(), false())
let $glossary-cache := glossary:glossary-cache($tei, (), false())
let $submission-checklist := doc('../config/submission-checklist.xml')

let $xml-response := 
    common:response(
        'operations/edit-text-header', 
        'operations', 
        (
            $request,
            $updated,
            $text,
            $translation-status,
            $text-statuses-selected,
            $persons,
            $teams,
            $entities,
            $glossary-cache,
            $tei-content:title-types,
            $contributors:contributor-types,
            $submission-checklist
        )
    )
    
return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-text-header.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )