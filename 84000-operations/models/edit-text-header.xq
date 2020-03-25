xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-translation="http://operations.84000.co/update-translation" at "../modules/update-translation.xql";
import module namespace file-upload="http://operations.84000.co/file-upload" at "../modules/file-upload.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../modules/translation-status.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";

import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)
let $request-id := request:get-parameter('id', '') (: in get :)
let $post-id := request:get-parameter('post-id', '') (: in post :)
let $tei := 
    if($post-id) then
        tei-content:tei($post-id, 'translation')
    else
        tei-content:tei($request-id, 'translation')

let $text-id := tei-content:id($tei)
let $translation-status := translation-status:text($text-id)
let $current-version-str := string($translation-status/@version)

(: Delete a submission :)
(: The parameter delete-submission also triggers translation-status:update :)
let $delete-submission-id := request:get-parameter('delete-submission-id', '')
let $delete-submission := 
    if($delete-submission-id gt '') then
        file-upload:delete-file($text-id, $delete-submission-id)
    else 
        ()

(: Process input, if it's posted :)
let $updated := 
    if($post-id or $delete-submission-id) then (
        update-translation:update($tei),
        file-upload:process-upload($text-id),
        translation-status:update($text-id)
     )
     else
        ()

(: If it's a new version :)
let $tei-version-str := translation:version-str($tei)
let $commit-version := 
    if($store:conf and not(translation-status:is-current-version($tei-version-str, $current-version-str))) then (
        
        (: Commit to GitHub :)
        (:deploy:commit-data('sync', tei-content:document-url($tei), ''),:)
        deploy:push('data-tei', (), (), tei-content:document-url($tei)),
        
        (: Store associated files :)
        if(tei-content:translation-status-group($tei) eq 'published')then
            for $bibl in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
            return
                (   
                    (: pdf :)
                    store:create(concat($bibl/@key, '.pdf')),
                    (: one ebook format does both :)
                    store:create(concat($bibl/@key, '.epub')),
                    (: rdf :)
                    store:create(concat($bibl/@key, '.rdf')),
                    (:deploy:commit-data('sync', 'rdf', concat('Sync ', $bibl/@key, '.rdf')):)
                    deploy:push('data-rdf', (), concat('Sync ', $bibl/@key, '.rdf'), ())
                )
        else
            ()
    )
    else 
        ()

return
    common:response(
        'operations/edit-text-header', 
        'operations', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"
                delete-submission="{ $delete-submission-id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { $updated }
            </updates>,
            <translation 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"
                document-url="{ tei-content:document-url($tei) }" 
                locked-by-user="{ tei-content:locked-by-user($tei) }"
                status="{ tei-content:translation-status($tei) }"
                status-group="{ tei-content:translation-status-group($tei) }">
                { 
                    for $bibl in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                    return
                        (
                            translation:toh($tei, $bibl/@key),
                            translation:location($tei, $bibl/@key),
                            translation:downloads($tei, $bibl/@key, 'all')
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
            doc('../config/contributor-types.xml'),
            doc('../config/publication-tasks.xml'),
            doc('../config/submission-checklist.xml'),
            <translation-status xmlns="http://read.84000.co/ns/1.0" >
            {
                translation-status:notes($text-id),
                translation-status:tasks($text-id),
                translation-status:submissions($text-id),
                translation-status:status-updates($tei)
            }
            </translation-status>
        )
    )
    
    