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
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := upper-case(request:get-parameter('resource-id', 'lobby'))
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $translations-order := request:get-parameter('translations-order', 'toh')
let $filter-id := request:get-parameter('filter-id', '')
let $filter-section-ids := request:get-parameter('filter-section-id[]', '')
let $filter-max-pages := request:get-parameter('filter-max-pages', '')

let $tei := tei-content:tei($resource-id, 'section')
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
(:
let $user-defined-filter := 
    if($filter-section-ids or $filter-max-pages) then (
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            attribute type { 'filter' },
            attribute xml:id { 'USER-DEFINED-FILTER' },
            element head {
                attribute type { 'filter' },
                text { 'Custom Filter' }
            },
            element p {
                if($filter-max-pages) then
                    text { concat('Max. ', $filter-max-pages/@max-pages, ' pages from ') }
                else
                    text { 'Any sized text from ' }
                ,
                if($filter-section-ids) then(
                    text { string-join($filter-section-ids/@section-id, ', ') }
                )  
                else 
                    text { 'all sections.' }
            },
            element { QName('http://read.84000.co/ns/1.0','display') } {
                attribute key { 'carousel' }
            },
            $filter-section-ids,
            $filter-max-pages
        }
    )
    else ():)
(:
let $filter-id :=
    if($filter-section-ids or $filter-max-pages) then
        'USER-DEFINED-FILTER'
    else
        $filter-id:)

(:let $filters := 
    element { node-name($filters) } {
        $filters/@*,
        $filters/*,
        $user-defined-filter
    }:)

let $apply-filters := 
    if($filter-section-ids or $filter-max-pages) then (
        $filter-section-ids,
        $filter-max-pages
    )
    else
        $filters/tei:div[@xml:id eq $filter-id]/m:filter

return 
    
    (: return tei data :)
    if($resource-suffix = ('tei')) then
        $tei
        
    (: return xml data :)
    else 
        let $doc-type := 
            if($resource-suffix = ('navigation.atom', 'acquisition.atom')) then 
                'atom'
            else
                $resource-suffix
    
        (: Atom feeds default to published only, others not :)
        let $published-only := request:get-parameter('published-only', if($doc-type eq 'atom') then true() else false())
        (: Only include direct children texts (or groupings), don't go down the tree :)
        let $child-texts-only := request:get-parameter('child-texts-only', true())
        
        let $include-texts := 
            if(xs:boolean($published-only)) then
                if(xs:boolean($child-texts-only)) then
                    'children-published'
                else
                    'descendants-published'
            else
                if(xs:boolean($child-texts-only)) then
                    'children'
                else
                    'descendants'
    
        return
            common:response(
                "section", 
                $common:app-id,
                (
                   (: Include request parameters :)
                    <request 
                        xmlns="http://read.84000.co/ns/1.0" 
                        resource-id="{ $resource-id }"
                        resource-suffix="{ $resource-suffix }"
                        doc-type="{ $doc-type }"
                        published-only="{ xs:boolean($published-only) }"
                        child-texts-only="{ xs:boolean($child-texts-only) }"
                        translations-order="{ $translations-order }"
                        filter-id="{ $filter-id }">
                        {
                            $filter-section-ids,
                            $filter-max-pages
                        }
                        </request>,
                    
                    (: Include section data :)
                    section:section-tree($tei, true(), $include-texts, $apply-filters),
                    
                    (: Include section filters :)
                    $filters
                    
                )
            )
