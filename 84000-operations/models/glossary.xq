xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-translation="http://operations.84000.co/update-translation" at "../modules/update-translation.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
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
        update-translation:update-glossary($tei, $glossary-id)
    else if($form-action eq 'cache-locations') then
        update-translation:cache-glossary($tei, $glossary-id)
    else if($form-action eq 'cache-locations-uncached') then
        update-translation:cache-glossary($tei, 'uncached')
    else if($form-action eq 'cache-locations-all') then
        update-translation:cache-glossary($tei, ())
    else if($form-action eq 'update-entity') then
        entities:update-entity($entity-id)
    else if($form-action eq 'match-entity') then
        entities:match-instance($entity-id, $glossary-id, 'glossary-item')
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

let $glossary-cache := translation:glossary-cache($tei, (), false())

return
    common:response(
        'operations/glossary',
        'operations', 
        (
            element { QName('http://read.84000.co/ns/1.0', 'request') }{
                attribute resource-id { request:get-parameter('resource-id', '') },
                attribute first-record { request:get-parameter('first-record', 1) },
                attribute max-records { request:get-parameter('max-records', $default-max-records) },
                attribute filter { request:get-parameter('filter', '') },
                attribute glossary-id { request:get-parameter('glossary-id', '') },
                attribute form-action { request:get-parameter('form-action', '') },
                attribute entity-id { request:get-parameter('entity-id', '') },
                attribute item-tab { request:get-parameter('tab-id', '') },
                element search { request:get-parameter('search', '') },
                element similar-search { request:get-parameter('similar-search', '') },
                $translation:view-modes/m:view-mode[@id eq 'glossary-editor']
            },
            element { QName('http://read.84000.co/ns/1.0', 'translation') }{
                attribute id { tei-content:id($tei) },
                attribute tei-version { tei-content:version-str($tei) },
                attribute document-url { tei-content:document-url($tei) },
                attribute locked-by-user { tei-content:locked-by-user($tei) },
                translation:titles($tei),
                tei-content:source($tei, $resource-id),
                translation:glossary($tei),
                translation:notes-cache($tei, false(), false()),
                translation:milestones-cache($tei, false(), false()),
                translation:folios-cache($tei, false(), false()),
                $glossary-cache
            },
            element { QName('http://read.84000.co/ns/1.0', 'glossary') } {
            
                $glossary-filtered/@*,
                
                attribute count-records { count($glossary-filtered/m:item) },
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                $glossary-cache/@seconds-to-build,
                attribute tei-version-cached { store:stored-version-str($resource-id, 'cache') },
                
                let $glossary-filtered-subsequence := subsequence($glossary-filtered/m:item, $first-record, $max-records)
                
                (: Check if we have expressions - we may have them from an expressions filter :)
                let $glossary-item-expressions := 
                    if($glossary-filtered/m:item[not(m:expressions)]) then
                        glossary:expressions($tei, $resource-id, $glossary-filtered-subsequence/@id)
                    else ()
                
                return
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
                            
                            (: Add glossary cache :)
                            if($glossary-cache) then
                                element cache {
                                    $glossary-cache/m:gloss[@id eq $glossary-item/@id]/m:location
                                }
                            else(),
                            
                            (: Add markdorn of the definition :)
                            element markdown {
                                for $definition in $glossary-item/m:definition
                                return 
                                    element { node-name($definition) }{
                                        $definition/@*,
                                        common:markdown($definition/node(), 'http://www.tei-c.org/ns/1.0')
                                    }
                            },
                            
                            (: Add the shared entity :)
                            if($entity) then (
                                $entity,
                                element { QName('http://read.84000.co/ns/1.0', 'entity-glossaries') }{
                                    if($entity) then
                                        for $matched-item in glossary:items($entity/m:instance/@id/string(), true())
                                        return
                                            element { node-name($matched-item) } {
                                                $matched-item/@*,
                                                $matched-item/node(),
                                                entities:entities($matched-item/@id)/m:entity[1]
                                            }
                                    else ()
                                }
                            )
                            
                            (: Or look for possible matches :)
                            else 
                                element { QName('http://read.84000.co/ns/1.0', 'similar-entities') }{
                                
                                    let $similar-items := glossary:similar-items($glossary-item, $similar-search)
                                    let $entities := entities:entities($similar-items/@id)/m:entity
                                    
                                    for $entity-id in distinct-values($entities/@id)
                                        let $entity := $entities[@id eq $entity-id]
                                        let $instances := $entity/m:instance
                                        let $score := functx:index-of-node($similar-items, $similar-items[@id = $instances/@id][1])
                                        let $instances-items := glossary:items($instances/@id, true())
                                    order by $score
                                    return
                                        element { node-name($entity) } {
                                            $entity/@*,
                                            $entity/node()[not(self::m:instance)],
                                            for $instance in $instances
                                            return
                                                element { node-name($instance) } {
                                                    $instance/@*,
                                                    $instances-items[@id = $instance/@id]
                                                }
                                        }
                                }
                        }
            },
            $update-glossary
        )
    )
