xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../modules/update-entity.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $request-id := request:get-parameter('id', '')
let $form-action := request:get-parameter('form-action', '')
let $entity-id := request:get-parameter('entity-id', '')
let $target-entity-id := request:get-parameter('target-entity-id', '')
let $predicate := request:get-parameter('predicate', '')
let $similar-search := request:get-parameter('similar-search', '')

let $tei := tei-content:tei($request-id, 'knowledgebase')

let $updated := 
    if($form-action eq 'update-kb-header' and $tei) then 
        update-tei:knowledgebase-header($tei)
    
    else if($form-action eq 'update-entity') then
        update-entity:headers($entity-id)
    
    else if($form-action eq 'match-entity') then
        update-entity:match-instance($entity-id, $request-id, 'knowledgebase-article')
        
    else if($form-action eq 'merge-entities') then
        update-entity:resolve($entity-id, $target-entity-id, $predicate)
    
    else ()

let $knowledgebase-id := tei-content:id($tei)
let $entity := entities:entities($knowledgebase-id, false(), true())/m:entity[1]

let $xml-response := 
    common:response(
        'operations/edit-kb-header', 
        'operations', 
        (
            (: Include request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request') } {
                attribute id { $knowledgebase-id },
                attribute show-tab { request:get-parameter('show-tab', 'kb-form') },
                element similar-search { request:get-parameter('similar-search', '') }
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
            
            (: Include the shared entity :)
            $entity,
            
            (: Report possible matches for reconciliation :)
            let $search-terms := (
                tei-content:titles($tei)//m:title/data(),
                normalize-space($similar-search)
            )[. gt '']
            return
                element { QName('http://read.84000.co/ns/1.0', 'similar-entities') }{
                    entities:similar($entity, $search-terms, $knowledgebase-id)
                }
            ,
            
            (: Translation statuses :)
            tei-content:text-statuses-selected(tei-content:translation-status($tei)),
            
            (: Title types :)
            $tei-content:title-types,
            
            (: Entities config :)
            $entities:predicates,
            $entities:types
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-kb-header.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )