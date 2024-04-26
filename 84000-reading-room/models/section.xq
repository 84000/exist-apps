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
let $resource-id := upper-case(request:get-parameter('resource-id', 'lobby'))
let $doc-type := 
    if($resource-suffix = ('navigation.atom', 'acquisition.atom')) then 
        'atom'
    else
        $resource-suffix
let $filter-id := request:get-parameter('filter-id', '')
let $filter-section-ids := request:get-parameter('filter-section-id[]', '')
let $filter-max-pages := request:get-parameter('filter-max-pages', '')[functx:is-a-number(.)]
let $view-mode := request:get-parameter('view-mode', 'default')

let $tei := tei-content:tei($resource-id, 'section')
let $filters := section:filters($tei)

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'section' }, 
        attribute resource-id { if($tei) then $resource-id else () }, 
        attribute resource-suffix { $resource-suffix }, 
        attribute lang { common:request-lang() },
        attribute doc-type { $doc-type }, 
        attribute published-only { request:get-parameter('published-only', if($doc-type eq 'atom') then true() else false()) ! xs:boolean(.) }, 
        attribute child-texts-only { request:get-parameter('child-texts-only', true()) ! xs:boolean(.) }, 
        attribute translations-order { request:get-parameter('translations-order', 'toh')[. = ('toh', 'latest', 'shortest', 'longest')] }, 
        attribute filter-id { $filters/tei:div[@xml:id eq $filter-id]/@xml:id }, 
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
let $cache-key := 
    let $section-tei := $section:texts//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $request/@resource-id]]
    let $tei-timestamp := max(($tei ! tei-content:last-modified(.), $section-tei ! tei-content:last-modified(.)))
    let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
    where $tei-timestamp instance of xs:dateTime and $entities-timestamp instance of xs:dateTime
    return 
        lower-case(
            string-join((
                $tei-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                (: If there are no child TEI files (e.g. all-translated) then invalidate daily :)
                if(not($section-tei)) then current-dateTime() ! format-dateTime(., "[Y0001]-[M01]-[D01]") else (), 
                $common:app-version ! replace(., '\.', '-')
            ),'-')
        )

let $cached := 
    if($view-mode eq 'default' and $request[@filter-section-ids eq ''][@filter-max-pages eq '']) then
        common:cache-get($request, $cache-key)
    else ()

return 
    if($cached) then $cached 
    
    (: tei :)
    else if($resource-suffix = ('tei')) then $tei
    
    else
        
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
        
        let $sections-data := 
            element { node-name($sections-data) }{
                $sections-data/@*,
                attribute cache-key { $cache-key },
                $sections-data/*
            }
        
        (:let $attribution-entities := $entities:entities/idref($sections-data//m:attribution/@xml:id)/parent::m:entity:)
        let $attribution-id-chunks := common:ids-chunked($sections-data//m:attribution/@xml:id)
        let $attribution-entities := 
            for $key in map:keys($attribution-id-chunks)
            let $attribution-ids-key := map:get($attribution-id-chunks, $key)
            return 
                $entities:entities//m:instance[@id = $attribution-ids-key]/parent::m:entity
        let $attribution-entities := functx:distinct-nodes($attribution-entities)
        
        let $entities := 
            element { QName('http://read.84000.co/ns/1.0', 'entities') }{
                $attribution-entities,
                element related { entities:related($attribution-entities, false(), 'knowledgebase', 'requires-attention', 'excluded') }
            }
        
        let $xml-response := 
            if(not($request/@resource-suffix = ('tei'))) then
                common:response(
                    $request/@model, 
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
            if($request/@resource-suffix = ('html')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/section.xsl"), $cache-key)
            
            (: return tei data :)
            else if($request/@resource-suffix = ('tei')) then 
                common:serialize-xml($tei)
            
            (: return xml data :)
            else 
                common:serialize-xml($xml-response)

        
