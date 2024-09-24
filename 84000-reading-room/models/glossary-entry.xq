xquery version "3.0" encoding "UTF-8";
(:
    Accepts the entity-id, or filter (type|term-lang|search) parameters
    -------------------------------------------------------------------
    For SEO purposes we allow for single page presentation of the 
    entities e.g. entity-id=entity-123. 
    Links to these individual entities are exposed through the browse page.
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')

let $term-langs := 
    <term-langs xmlns="http://read.84000.co/ns/1.0">
        <lang id="bo" short-code="Tib" filter="true">Tibetan</lang>
        <lang id="Sa-Ltn" short-code="Skt" filter="true">Sanskrit</lang>
        <lang id="en" short-code="Eng" filter="true">Our Translation</lang>
    </term-langs>

let $flagged := request:get-parameter('flagged', '')
let $flag := $entities:flags//m:flag[@id eq  $flagged]

let $view-mode := request:get-parameter('view-mode', 'default')
let $view-mode := $glossary:view-modes/m:view-mode[@id eq $view-mode]
let $exclude-flagged := if($view-mode[@id eq 'editor']) then () else 'requires-attention'
let $exclude-status := if(not($view-mode/@id eq 'editor')) then 'excluded' else ''

(: The requested entity :)
let $request-entity := $entities:entities/id($resource-id)[self::m:entity][1]

(: Perhaps this is a legacy link :)
let $request-entity := 
    if(not($request-entity)) then
        $entities:entities//m:relation[@predicate eq 'sameAs'][@id eq $resource-id][1]/parent::m:entity
    else $request-entity

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary-entry' },
        attribute resource-id { $request-entity/@xml:id },
        attribute resource-suffix { request:get-parameter('resource-suffix', 'html') },
        attribute lang { common:request-lang() },
        attribute view-mode { $view-mode/@id },
        $term-langs,
        $entities:types,
        $view-mode
    }

(: Cache for a day :)
let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache']) then
        let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
        where $entities-timestamp instance of xs:dateTime
        return
            lower-case(
                string-join((
                    current-dateTime() ! format-dateTime(., "[Y0001]-[M01]-[D01]"),
                    $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $common:app-version ! replace(., '\.', '-')
                ),'-')
            )
    else ()

let $cached := common:cache-get($request, $cache-key)

return 
    if($cached) then 
        $cached 
    
    else
        
        (: Get related entities data :)
        let $entities :=
            element { QName('http://read.84000.co/ns/1.0', 'entities')} {
                $request-entity,
                element related {
                    entities:related($request-entity, false(), ('glossary'(:,'knowledgebase':)), $exclude-flagged, $exclude-status)
                }
            }
        
        let $xml-response :=
            common:response(
                $request/@model, 
                $common:app-id, 
                (
                    $request,
                    $entities,
                    $entities:flags,
                    $glossary:attestation-types
                )
            )
        
        return
        
            (: html :)
            if($request/@resource-suffix = ('html')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/glossary-entry.xsl"), $cache-key)
            
            (: xml :)
            else 
                common:serialize-xml($xml-response)
