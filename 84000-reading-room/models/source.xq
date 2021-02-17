xquery version "3.0" encoding "UTF-8";
(:
    Accepts a folio string parameter
    Returns the source tibetan for that folio
    ---------------------------------------------------------------
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../modules/source.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

(: the id of the text :)
let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $ref-index := request:get-parameter('ref-index', '')
let $folio := request:get-parameter('folio', '')
let $page := request:get-parameter('page', '')
let $highlight := tokenize(request:get-parameter('highlight', ''), ',')

let $tei := tei-content:tei($resource-id, 'translation')
let $tei-location := translation:location($tei, $resource-id)

(: Prefer ref-index parameter :)
let $ref-resource-index := 
    if(functx:is-a-number($ref-index)) then
        xs:integer($ref-index)
    
    (: legacy links using page parameter :)
    else if(functx:is-a-number($page)) then
        xs:integer($page)
    
    (: Accept a folio ref e.g. F.1.a, and convert that into a page number :)
    else if ($folio gt '') then
        source:folio-to-page($tei, $resource-id, $folio)
    
    else
        0

(: Convert the ref-index, which is effectively the index of the ref in the TEI, into the source page :)
let $ref-sort-index := 
    if($ref-resource-index gt 0) then
        translation:folio-sort-index($tei, $resource-id, $ref-resource-index)
    else
        0

let $source-text := source:etext-page($tei-location, $ref-sort-index, true(), $highlight)
let $translation-text := translation:folio-content($tei, $resource-id, $ref-resource-index)
let $ref-1 := $translation-text//tei:ref[@xml:id][1]

return 
    common:response(
        "source/folio", 
        $common:app-id,
        (
            (: Include request parameters :)
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }" 
                ref-index="{ $ref-index }"
                ref-sort-index="{ $ref-sort-index }"
                ref-resource-index="{ $ref-resource-index }"
                folio="{ $folio }"
                page="{ $page }"/>,
            
            (: Get a page :)
            if($ref-sort-index gt 0) then (
                
                (: The source text :)
                $source-text,
                
                (: The translation :)
                <translation 
                    xmlns="http://read.84000.co/ns/1.0" 
                    id="{ tei-content:id($tei) }"
                    status="{ tei-content:translation-status($tei) }"
                    status-group="{ tei-content:translation-status-group($tei) }">
                    {
                        translation:titles($tei),
                        tei-content:ancestors($tei, $resource-id, 1), 
                        translation:toh($tei, $resource-id),
                        $translation-text  
                    }
                </translation>,
                
                (: Include back link to the passage in the text :)
                <back-link 
                    xmlns="http://read.84000.co/ns/1.0"
                    url="{ concat($common:environment/m:url[@id eq 'reading-room'], '/translation/', $resource-id, '.html', '?part=', $ref-1/@xml:id, '#', $ref-1/@xml:id) }"/>
                
            )
            
            (: Get the whole text :)
            else if (lower-case($resource-suffix) = ('xml', 'txt')) then
                source:etext-full($tei-location)
                
            else
                ()
        )
    )
