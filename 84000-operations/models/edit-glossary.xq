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
let $default-filter := 'check-all'

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $resource-id := request:get-parameter('resource-id', '')
let $resource-type := request:get-parameter('resource-type', 'translation')
let $first-record := request:get-parameter('first-record', 1)
let $max-records := request:get-parameter('max-records', $default-max-records)
let $filter := request:get-parameter('filter', $default-filter)
let $glossary-id := request:get-parameter('glossary-id', '')
let $form-action := request:get-parameter('form-action', '')
let $search := request:get-parameter('search', '')
let $entity-id := request:get-parameter('entity-id', '')
let $target-entity-id := request:get-parameter('target-entity-id', '')
let $predicate := request:get-parameter('predicate', '')
let $similar-search := request:get-parameter('similar-search', '')

let $resource-id := 
    if($resource-id eq '' and $resource-type eq 'translation') then
        translations:files($translation:marked-up-status-ids)/m:file[1]/@id
    else
        $resource-id

let $tei := tei-content:tei($resource-id, $resource-type)

(: Get the next xml:id :)
let $glossary-id := 
    if($form-action = ('update-glossary') and $glossary-id eq '') then
        tei-content:next-xml-id($tei)
    else
        $glossary-id

(: Process the input :)
let $updates := 
    element { QName('http://read.84000.co/ns/1.0', 'updates') } {
    
        if($form-action eq 'update-glossary') then
            update-tei:update-glossary($tei, $glossary-id)
            
        else if($form-action eq 'cache-locations') then
            update-tei:cache-glossary($tei, $glossary-id)
            
        else if($form-action eq 'cache-locations-uncached') then
            update-tei:cache-glossary($tei, 'uncached')
            
        else if($form-action eq 'cache-locations-all') then
            update-tei:cache-glossary($tei, 'all')
        
        else if($form-action eq 'cache-locations-version') then
            update-tei:cache-glossary($tei, 'version')
            
        else if($form-action eq 'update-entity') then
            update-entity:headers($entity-id)
            
        else if($form-action eq 'match-entity') then
            update-entity:match-instance($entity-id, $glossary-id, 'glossary-item')
            
        else if($form-action eq 'merge-entities') then
            update-entity:resolve($entity-id, $target-entity-id, $predicate)
            
        else if($form-action eq 'merge-all-entities') then
            update-entity:merge-glossary($resource-id, true())
            
        else if(not(request:get-parameter('remove-instance', '') eq '')) then 
            let $remove-instance-id := request:get-parameter('remove-instance', '')
            let $remove-instance-gloss := $glossary:tei//tei:back//id($remove-instance-id)[self::tei:gloss]
            where $remove-instance-gloss
            return (
                update-entity:remove-instance($remove-instance-id),
                update-entity:create($remove-instance-gloss, '')
            )
            
        else ()
    
    }

(:let $schedule := 
    if(scheduler:get-scheduled-jobs()//scheduler:job[@name eq 'cache-glossary-locations'][scheduler:trigger/state/text() eq 'COMPLETE']) then
        scheduler:delete-scheduled-job('cache-glossary-locations')
    else
        scheduler:schedule-xquery-periodic-job(
            '/db/apps/84000-operations/scripts/cache-glossary-locations.xq',
            10000,
            'cache-glossary-locations',
            <parameters>
                <param name="param-name1" value="param-value1"/>
            </parameters>,
            10000,
            0
        ):)

(: Force a filter value :)
let $filter := 
    if($filter eq '') then
        $default-filter
    else 
        $filter

(: Force a max-records value :)
let $max-records := 
    if(functx:is-a-number($max-records) and xs:integer($max-records) gt 0) then
        xs:integer($max-records)
    else
        $default-max-records

(: Get the glossaries - applying any filters :)
let $glossary-filtered := glossary:filter($tei, $resource-type, $filter, $search)

(: Override first-record to show the updated record :)
let $selected-glossary-index := 
    if($glossary-filtered/m:entry[@id eq $glossary-id]) then
        functx:index-of-node($glossary-filtered/m:entry, $glossary-filtered/m:entry[@id eq $glossary-id])
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

let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') }{
        attribute resource-id { request:get-parameter('resource-id', '') },
        attribute resource-type { $resource-type },
        attribute first-record { request:get-parameter('first-record', 1) },
        attribute max-records { $max-records },
        attribute filter { $filter },
        attribute find-expressions { request:get-parameter('find-expressions', '') },
        attribute glossary-id { request:get-parameter('glossary-id', '') },
        attribute form-action { request:get-parameter('form-action', '') },
        attribute entity-id { request:get-parameter('entity-id', '') },
        attribute show-tab { request:get-parameter('show-tab', '') },
        element search { request:get-parameter('search', '') },
        element similar-search { request:get-parameter('similar-search', '') },
        $translation:view-modes/m:view-mode[@id eq 'glossary-editor']
    }

let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute id { tei-content:id($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { tei-content:document-url($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        tei-content:titles($tei),
        if($resource-type eq 'translation') then
            translation:toh($tei, '')
        else ()
    }

let $glossary :=
    element { QName('http://read.84000.co/ns/1.0', 'glossary') } {
            
        $glossary-filtered/@*,
        
        attribute count-records { count($glossary-filtered/m:entry) },
        attribute first-record { $first-record },
        attribute max-records { $max-records },
        attribute tei-version-cached { store:stored-version-str($resource-id, 'cache') },
        
        let $glossary-filtered-subsequence := subsequence($glossary-filtered/m:entry, $first-record, $max-records)
        
        (: Check if we have expressions - we may have them from an expressions filter :)
        let $glossary-item-expressions := 
            if($glossary-filtered/m:entry[not(m:expressions)] and $filter = ('check-expressions', 'check-all', 'no-cache', 'new-expressions', 'no-expressions')) then
                glossary:instances($tei, $resource-id, $resource-type, $glossary-filtered-subsequence/@id)
            else ()
        
        for $glossary-item in $glossary-filtered-subsequence
            let $entity := entities:entities($glossary-item/@id, false(), true(), true())/m:entity[1]
        return 
            (: Copy each glossary item :)
            element { node-name($glossary-item) }{
            
                $glossary-item/@*,
                
                if($glossary-item/@id eq $glossary-id) then
                    attribute active-item { true() }
                else (),
                
                $glossary-item/node(),
                
                (: Add glossary expressions :)
                (: They may already be included if we did an expressions filter :)
                if(not($glossary-item[m:expressions]) and $filter = ('check-expressions', 'check-all', 'no-cache', 'new-expressions', 'no-expressions')) then
                    element { node-name($glossary-item-expressions) }{
                        $glossary-item-expressions/@*,
                        $glossary-item-expressions/*[descendant::xhtml:*[@data-glossary-id eq $glossary-item/@id]]
                    }
                else (),
                
                (: Include the shared entity :)
                $entity,
                
                (: Report possible matches for reconciliation :)
                if($filter = ('check-entities', 'check-all', 'missing-entities', 'requires-attention')) then
                    let $search-terms := (
                        $glossary-item/m:term[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data(),
                        $glossary-item/m:alternatives[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data(),
                        if($glossary-item/@id eq $glossary-id) then
                            normalize-space($similar-search)[not(. eq '')]
                        else ()
                    )
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'similar-entities') }{
                            entities:similar($entity, $search-terms, $glossary-item/@id)
                        }
                else ()
            }
       
    }

let $caches := tei-content:cache($tei, false())/m:*

let $xml-response := 
    common:response(
        'operations/glossary',
        'operations', (
            (: Request parameters :)
            $request,
            (: Details of updates :)
            $updates,
            (: Text data :)
            $text,
            (: Additional glossary data for selected items :)
            $glossary,
            (: Caches :)
            $caches,
            (:scheduler:get-scheduled-jobs()//scheduler:job[@name eq 'cache-glossary-locations'],:)
            (: Entities config :)
            $entities:predicates,
            $entities:types,
            $entities:flags
            
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-glossary.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )