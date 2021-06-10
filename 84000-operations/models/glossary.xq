xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../modules/update-entity.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $default-max-records := 3

let $resource-id := request:get-parameter('resource-id', '')
let $first-record := request:get-parameter('first-record', 1)
let $max-records := request:get-parameter('max-records', $default-max-records)
let $filter := request:get-parameter('filter', '')
let $glossary-id := request:get-parameter('glossary-id', '')
let $form-action := request:get-parameter('form-action', '')
let $search := request:get-parameter('search', '')
let $entity-id := request:get-parameter('entity-id', '')
let $target-entity-id := request:get-parameter('target-entity-id', '')
let $predicate := request:get-parameter('predicate', '')
let $similar-search := request:get-parameter('similar-search', '')

let $resource-id := 
    if(not($resource-id gt '')) then
        translations:files($tei-content:marked-up-status-ids)/m:file[1]/@id
    else
        $resource-id

let $tei := tei-content:tei($resource-id, 'translation')

(: Get the next xml:id :)
let $glossary-id := 
    if($form-action = ('update-glossary') and $glossary-id eq '') then
        tei-content:next-xml-id($tei)
    else
        $glossary-id

(: Process the input :)
let $update-glossary := 
    if($form-action eq 'update-glossary') then
        update-tei:update-glossary($tei, $glossary-id)
        
    else if($form-action eq 'cache-locations') then
        update-tei:cache-glossary($tei, $glossary-id)
        
    else if($form-action eq 'cache-locations-uncached') then
        update-tei:cache-glossary($tei, 'uncached')
        
    else if($form-action eq 'cache-locations-all') then
        update-tei:cache-glossary($tei, ())
        
    else if($form-action eq 'update-entity') then
        update-entity:headers($entity-id)
        
    else if($form-action eq 'match-entity') then
        update-entity:match-instance($entity-id, $glossary-id, 'glossary-item')
        
    else if($form-action eq 'resolve-entity') then
        update-entity:resolve($entity-id, $target-entity-id, $predicate)
        
    else ()

(: Get the glossaries - applying any filters :)
let $glossary-filtered := glossary:filter($tei, $resource-id, $filter, $search)

(: Trap any input errors with max-records :)
let $max-records := 
    if(functx:is-a-number($max-records) and xs:integer($max-records) gt 0) then
        xs:integer($max-records)
    else
        $default-max-records

(: Override first-record to show the updated record :)
let $selected-glossary-index := 
    if($glossary-filtered/m:item[@id eq $glossary-id]) then
        functx:index-of-node($glossary-filtered/m:item, $glossary-filtered/m:item[@id eq $glossary-id])
    else 0

let $first-record := 
    if($selected-glossary-index gt 0 and $max-records gt 0) then
        ((floor(($selected-glossary-index - 1) div $max-records) * $max-records) + 1)
    else if(functx:is-a-number($first-record)) then
        if(xs:integer($first-record) mod $max-records gt 0) then
            ((floor((xs:integer($first-record) - 1) div $max-records) * $max-records) + 1)
        else
            xs:integer($first-record)
    else 1

return
    common:response(
        'operations/glossary',
        'operations', (
        
            (: Request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request') }{
                attribute resource-id { request:get-parameter('resource-id', '') },
                attribute first-record { request:get-parameter('first-record', 1) },
                attribute max-records { request:get-parameter('max-records', $default-max-records) },
                attribute filter { request:get-parameter('filter', '') },
                attribute glossary-id { request:get-parameter('glossary-id', '') },
                attribute form-action { request:get-parameter('form-action', '') },
                attribute entity-id { request:get-parameter('entity-id', '') },
                attribute show-tab { request:get-parameter('show-tab', '') },
                element search { request:get-parameter('search', '') },
                element similar-search { request:get-parameter('similar-search', '') },
                $translation:view-modes/m:view-mode[@id eq 'glossary-editor']
            },
            
            (: Details of updates :)
            element { QName('http://read.84000.co/ns/1.0', 'updates') } {
                $update-glossary
            },
            
            (: Translation data :)
            element { QName('http://read.84000.co/ns/1.0', 'translation') }{
                attribute id { tei-content:id($tei) },
                attribute tei-version { tei-content:version-str($tei) },
                attribute document-url { tei-content:document-url($tei) },
                attribute locked-by-user { tei-content:locked-by-user($tei) },
                translation:titles($tei),
                tei-content:source($tei, $resource-id),
                translation:parts($tei, (), $translation:view-modes/m:view-mode[@id eq 'glossary-editor'])
            },
            
            (: Caches :)
            tei-content:cache($tei, false())/m:*,
            
            (: Additional glossary data for selected items :)
            element { QName('http://read.84000.co/ns/1.0', 'glossary') } {
            
                $glossary-filtered/@*,
                
                attribute count-records { count($glossary-filtered/m:item) },
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                attribute tei-version-cached { store:stored-version-str($resource-id, 'cache') },
                
                let $glossary-filtered-subsequence := subsequence($glossary-filtered/m:item, $first-record, $max-records)
                
                (: Check if we have expressions - we may have them from an expressions filter :)
                let $glossary-item-expressions := 
                    if($glossary-filtered/m:item[not(m:expressions)]) then
                        glossary:expressions($tei, $resource-id, $glossary-filtered-subsequence/@id)
                    else ()
            
                for $glossary-item in $glossary-filtered-subsequence
                    let $entity := entities:entities($glossary-item/@id)/m:entity[1]
                return 
                    (: Copy each glossary item :)
                    element { node-name($glossary-item) }{
                    
                        $glossary-item/@*,
                        attribute active-item { $glossary-item[@id eq $glossary-id]/@id },
                        attribute next-gloss-id { $glossary-filtered/m:item[@id eq $glossary-item/@id]/following-sibling::m:item[1]/@id },
                        $glossary-item/node(),
                        
                        (: Add glossary expressions :)
                        (: They may already be included if we did an expressions filter :)
                        if(not($glossary-item[m:expressions])) then
                            element { node-name($glossary-item-expressions) }{
                                $glossary-item-expressions/@*,
                                $glossary-item-expressions/*[descendant::xhtml:*[@data-glossary-id eq $glossary-item/@id]]
                            }
                        else (),
                        
                        (: Include the shared entity :)
                        if($entity) then (
                            $entity,
                            (: Include elements matched to the shared entity :)
                            element { QName('http://read.84000.co/ns/1.0', 'entity-instances') }{
                                entities:instances($entity)
                            }
                        )
                        else ()
                        ,
                        
                        (: Report possible matches for reconciliation :)
                        let $search-terms := (
                            $glossary-item/m:term[@xml:lang = ('bo', 'Bo-Ltn', 'Sa-Ltn')]/data(),
                            $glossary-item/m:alternatives[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data(),
                            normalize-space($similar-search)[. gt '']
                        )
                        return
                            element { QName('http://read.84000.co/ns/1.0', 'similar-entities') }{
                                entities:similar($entity, $search-terms, $glossary-item/@id)
                            }
                        
                    }
               
            },
            
            (: Entities config :)
            $entities:predicates,
            $entities:types
            
        )
    )
