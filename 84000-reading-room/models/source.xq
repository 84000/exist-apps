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
import module namespace glossary="http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $tei := tei-content:tei($resource-id, 'translation')
let $tei-location := translation:location($tei, $resource-id)

(: Prefer ref-index parameter :)
(: Pass a page index to get a page, or zero to get all pages :)
let $ref-index := 
    if(request:get-parameter('ref-index', '')[functx:is-a-number(.)]) then
        xs:integer(request:get-parameter('ref-index', ''))
    
    (: legacy links using page parameter :)
    else if(request:get-parameter('page', '')[functx:is-a-number(.)]) then
        xs:integer(request:get-parameter('page', ''))
    
    (: Accept a folio ref e.g. F.1.a, and convert that into a page number :)
    else if (request:get-parameter('folio', '')[matches(., '^[a-zA-Z0-9\.]{3,12}$', 'i')]) then
        source:folio-to-page($tei, $resource-id, request:get-parameter('folio', ''))
    
    else if (lower-case($resource-suffix) eq 'html') then
        1
    
    else 
        0

let $view-mode := ($source:view-modes/m:view-mode[@id eq request:get-parameter('view-mode', '')], $source:view-modes/m:view-mode[@id eq 'default'])[1]

(: Request parameters :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { "source/folio" }, 
        attribute resource-id { $tei-location/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute ref-index { $ref-index },
        attribute view-mode { $view-mode/@id },
        request:get-parameter('glossary-id', '')[not(. eq '')][1] ! attribute glossary-id { . },
        $view-mode
    }

(: Suppress cache if there's a highlight :)
(: Update the cache-key string to invalidate existing cache :)
let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache']) then
        let $tei-timestamp := tei-content:last-modified($tei)
        let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
        where $tei-timestamp instance of xs:dateTime and $entities-timestamp instance of xs:dateTime
        return 
            lower-case(
                string-join((
                    $tei-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $common:app-version ! replace(., '\.', '-')
                ),'-')
            )
    else ()

let $cached := common:cache-get($request, $cache-key)

where $tei
return 
    (: Return cached :)
    if($cached) then $cached 
    
    (: Not cached :)
    else
    
        let $translation := 
            element { QName('http://read.84000.co/ns/1.0', 'translation')} {
                attribute id { tei-content:id($tei) },
                attribute status { tei-content:publication-status($tei) },
                attribute status-group { tei-content:publication-status-group($tei) },
                translation:titles($tei, $request/@resource-id),
                tei-content:ancestors($tei, $request/@resource-id, 1),
                tei-content:source($tei, $request/@resource-id),
                translation:toh($tei, $request/@resource-id),
                translation:folio-content($tei, $request/@resource-id, $ref-index),
                if($request/m:view-mode[@id eq 'editor']) then
                    translation:glossary($tei, (), $view-mode, ())
                else if($request[@glossary-id]) then
                    translation:glossary($tei, $request/@glossary-id, $view-mode, ())
                else ()
            }
        
        let $rdf := 
            if($view-mode[@id eq 'editor']) then
                source:bdrc-rdf($translation/m:toh)
            else ()
        
        (: Check the sort index in the translation :)
        let $ref-sort-index := 
            if($ref-index gt 0) then
                translation:folio-sort-index($tei, $request/@resource-id, $ref-index)
            else 0
        
        let $source := 
            if($ref-index gt 0) then (
                
                (: Get a page of text :)
                source:etext-page($tei-location, $ref-sort-index, true()),
                
                (: Include back link to the passage in the text :)
                let $ref-1 := $translation/m:folio-content//tei:ref[@xml:id][1]
                where $ref-1
                return
                    element { QName('http://read.84000.co/ns/1.0', 'back-link') } {
                        attribute url { concat($common:environment/m:url[@id eq 'reading-room'], '/translation/', $request/@resource-id, '.html', '?part=', $ref-1/@xml:id, '#', $ref-1/@xml:id) }
                    }
                
            )
            (: Get the whole text :)
            else 
                source:etext-full($tei-location)
        
        (: Get the cached outline of the text :)
        let $outline := translation:outline-cached($tei)
        let $outlines-related := translation:outlines-related($tei, $translation/m:part, ())
        
        let $glossary-cache := glossary:glossary-cache($tei, (), false())
        let $entities-data := translation:entities((), $translation/m:part[@id eq 'glossary']//tei:gloss/@xml:id)
        
        let $xml-response := 
            common:response(
                $request/@model, 
                $common:app-id,
                (
                    $request,
                    $source,
                    $translation,
                    $outline,
                    $outlines-related,
                    $entities-data,
                    $glossary-cache,
                    $rdf
                    
                )
            )
        
        return
            
            (: return html data :)
            if($request/@resource-suffix = ('html')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/source.xsl"), $cache-key)
            
            (: return xml data :)
            else 
                common:serialize-xml($xml-response)
        