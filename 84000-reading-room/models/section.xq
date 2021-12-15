xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter
    Returns the section xml
    -------------------------------------------------------------
    Can be returned as xml or transformed into json or html.
:)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../modules/section.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $doc-type := 
    if($resource-suffix = ('navigation.atom', 'acquisition.atom')) then 
        'atom'
    else
        $resource-suffix
let $filter-section-ids := request:get-parameter('filter-section-id[]', '')
let $filter-max-pages := request:get-parameter('filter-max-pages', '')
let $view-mode := request:get-parameter('view-mode', 'default')

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { "section" }, 
        attribute resource-id { upper-case(request:get-parameter('resource-id', 'lobby')) }, 
        attribute resource-suffix { $resource-suffix }, 
        attribute lang { common:request-lang() },
        attribute doc-type { $doc-type }, 
        attribute published-only { request:get-parameter('published-only', if($doc-type eq 'atom') then true() else false()) ! xs:boolean(.) }, 
        attribute child-texts-only { request:get-parameter('child-texts-only', true()) ! xs:boolean(.) }, 
        attribute translations-order { request:get-parameter('translations-order', 'toh') }, 
        attribute filter-id { request:get-parameter('filter-id', '') }, 
        attribute filter-section-ids { $filter-section-ids }, 
        attribute filter-max-pages { $filter-max-pages },
        
        if(not($view-mode eq 'default')) then
            element view-mode { 
                attribute id { $view-mode },
                attribute client { 'browser' }
            }
        else ()
        
    }

(: Suppress cache if there's user input, or a view-mode :)
let $cache-timestamp := 
    if($view-mode eq 'default' and $request[@filter-section-ids eq ''][@filter-max-pages eq '']) then
        max(collection($common:tei-path)//tei:TEI//tei:notesStmt/tei:note[@type eq "lastUpdated"]/@date-time ! xs:dateTime(.))
    else ()
let $cached := common:cache-get($request, $cache-timestamp)
return if($cached) then $cached else

let $include-texts := 
    if(xs:boolean($request/@published-only)) then
        if($request/@child-texts-only eq 'true') then
            'children-published'
        else
            'descendants-published'
    else
        if($request/@child-texts-only eq 'true') then
            'children'
        else
            'descendants'

let $tei := tei-content:tei($request/@resource-id, 'section')
let $filters := section:filters($tei)

let $filter-section-ids := 
    for $filter-section-id in $filter-section-ids[not(. eq '')]
    return
        element { QName('http://read.84000.co/ns/1.0', 'filter') } {
            attribute section-id { $filter-section-id }
        }

let $filter-max-pages := 
    if(functx:is-a-number($filter-max-pages)) then
        element { QName('http://read.84000.co/ns/1.0', 'filter') } {
            attribute max-pages { $filter-max-pages }
        }
    else ()

let $apply-filters := 
    if($filter-section-ids or $filter-max-pages) then (
        $filter-section-ids,
        $filter-max-pages
    )
    else
        $filters/tei:div[@xml:id eq $request/@filter-id]/m:filter

let $sections-data :=
    if(lower-case($request/@resource-id) eq 'all-translated') then 
        section:all-translated($apply-filters)
    else
        section:section-tree($tei, true(), $include-texts)

let $entities := 
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        for $attribution-id in distinct-values($sections-data//m:attribution/@ref ! replace(., '^eft:', ''))
        return
            entities:entity($entities:entities/m:entity/id($attribution-id), true(), true(), false())
    }

let $xml-response := 
    if(not($request/@resource-suffix = ('tei'))) then
        common:response(
            "section", 
            $common:app-id,
            (
               $request,
               $sections-data,
               $entities
            )
        )
    else
        $tei

return
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then (
        common:html($xml-response, concat($common:app-path, "/views/html/section.xsl"), $cache-timestamp)
    )
    
    (: return tei data :)
    else if($request/@resource-suffix = ('tei')) then (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $tei
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
        
