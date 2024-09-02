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

(: Return request parameters :)
let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') } {
        attribute id { $text-id },
        attribute form-expand { request:get-parameter('form-expand', 'translation-status') }
    }

(: Process input, if it's posted :)
let $updated := 
    element { QName('http://read.84000.co/ns/1.0', 'updates') } {
        if($form-action = ('update-titles') and $tei) then
            update-tei:title-statement($tei)
            
        else if($form-action eq 'update-source' and $tei) then
            update-tei:source($tei)
            
        else if($form-action eq 'process-upload' and $text-id gt '') then (
            file-upload:process-upload($text-id),
            translation-status:update($text-id)
        )
        else ()
    }

let $publication-status := tei-content:publication-status($tei)
let $publication-status-group := tei-content:publication-status-group($tei)

let $entities :=
    element { QName('http://read.84000.co/ns/1.0', 'entities') } {
        (: Include all authors for the drop down list, and all their related articles :)
        let $attribution-entities := $entities:entities/m:entity[m:instance[@type eq 'source-attribution']]
        return (
            $attribution-entities,
            element related { entities:related($attribution-entities[m:instance/@id = ($tei//tei:sourceDesc/tei:bibl/tei:author/@xml:id | $tei//tei:sourceDesc/tei:bibl/tei:editor/@xml:id)], false(), ('knowledgebase'), (), ()) }
        )
    }

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
            tei-content:source($tei, $bibl/@key)
        ),
        
        tei-content:titles-all($tei),
        translation:publication($tei)
        
    }


let $xml-response := 
    common:response(
        'operations/edit-text-header', 
        'operations', 
        (
            $request,
            $updated,
            $text,
            $entities,
            $tei-content:title-types
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/edit-text-header.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
