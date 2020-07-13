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
    if($form-action = ('update-glossary', 'cache-expressions')) then
        update-translation:update-glossary($tei, $glossary-id)
    else if($form-action eq 'cache-expressions-all') then
        update-translation:cache-expressions($tei, $resource-id)
    else if($form-action eq 'update-entity') then
        entities:update-entity($entity-id)
    else if($form-action eq 'match-entity') then
        entities:match-instance($entity-id, $glossary-id, 'glossary-item')
    else
        ()

(: Get translation data :)
let $translation-data := glossary:translation-data($tei, $resource-id)

(: Get the glossaries :)
let $glossary-filtered := glossary:filter($translation-data, $filter, $search)

(: Trap any input errors with max-records :)
let $max-records := 
    if(functx:is-a-number($max-records) and xs:integer($max-records) gt 0) then
        xs:integer($max-records)
    else
        $default-max-records

(: Override first-record to show the updated record :)
let $selected-glossary-index := 
    if($glossary-filtered/m:item[@uid eq $glossary-id]) then
        functx:index-of-node($glossary-filtered/m:item, $glossary-filtered/m:item[@uid eq $glossary-id])
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
                element similar-search { request:get-parameter('similar-search', '') }
            },
            element { QName('http://read.84000.co/ns/1.0', 'text') }{
                attribute id { $translation-data/@id },
                element { QName('http://read.84000.co/ns/1.0', 'title') }{
                    tei-content:title($tei)
                },
                $translation-data/m:source
            },
            element { QName('http://read.84000.co/ns/1.0', 'glossary') } {
            
                $glossary-filtered/@*,
                
                attribute count-records { count($glossary-filtered/m:item) },
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                
                for $glossary-item in subsequence($glossary-filtered/m:item, $first-record, $max-records)
                    let $entity := entities:entities($glossary-item/@uid)/m:entity[1]
                return
                    element { node-name($glossary-item) }{
                        $glossary-item/@*,
                        attribute active-item { $glossary-item/@uid eq $glossary-id },
                        attribute next-gloss-id { $glossary-filtered/m:item[@uid eq $glossary-item/@uid]/following-sibling::m:item[1]/@uid },
                        $glossary-item/node(),
                        if(not($glossary-item/m:expressions)) then
                            glossary:expressions($translation-data, $glossary-item/@uid)
                        else ()
                        ,
                        element markdown {
                            for $definition in $glossary-item/m:definition
                            return 
                                element { node-name($definition) }{
                                    $definition/@*,
                                    common:markdown($definition/node(), 'http://www.tei-c.org/ns/1.0')
                                }
                        },
                        if($entity) then (
                            $entity,
                            element { QName('http://read.84000.co/ns/1.0', 'entity-glossaries') }{
                                if($entity) then
                                    for $matched-item in glossary:items($entity/m:instance/@id/string(), true())
                                    return
                                        element { node-name($matched-item) } {
                                            $matched-item/@*,
                                            $matched-item/node(),
                                            entities:entities($matched-item/@uid)/m:entity[1]
                                        }
                                else ()
                            }
                        )
                        else 
                            element { QName('http://read.84000.co/ns/1.0', 'similar-entities') }{
                            
                                let $similar-items := glossary:similar-items($glossary-item, $similar-search)
                                let $entities := entities:entities($similar-items/@uid)/m:entity
                                
                                for $entity-id in distinct-values($entities/@xml:id)
                                    let $entity := $entities[@xml:id eq $entity-id]
                                    let $instances := $entity/m:instance
                                    let $score := functx:index-of-node($similar-items, $similar-items[@uid = $instances/@id][1])
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
                                                $instances-items[@uid = $instance/@id]
                                            }
                                    }
                            }
                    }
            },
            $update-glossary
        )
    )
