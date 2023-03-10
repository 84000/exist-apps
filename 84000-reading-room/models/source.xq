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

let $resource-id := request:get-parameter('resource-id', '')
let $tei := tei-content:tei($resource-id, 'translation')
let $tei-location := translation:location($tei, $resource-id)

(: Request parameters :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { "source" }, 
        attribute resource-id { $tei-location/@key },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() },
        attribute ref-index { request:get-parameter('ref-index', '')[functx:is-a-number(.)] },
        attribute folio { request:get-parameter('folio', '')[matches(., '^[a-zA-Z0-9\.]{3,12}$', 'i')] },
        attribute page { request:get-parameter('page', '')[functx:is-a-number(.)] },
        attribute highlight { request:get-parameter('highlight', '') }
    }

(: Suppress cache if there's a highlight :)
(: Update the cache-key string to invalidate existing cache :)
let $cache-key := if($request[@highlight eq '']) then 'source-cache-1' else ()
let $cached := common:cache-get($request, $cache-key)
return if($cached) then $cached else

(: Prefer ref-index parameter :)
let $ref-resource-index := 
    if(functx:is-a-number($request/@ref-index)) then
        xs:integer($request/@ref-index)
    
    (: legacy links using page parameter :)
    else if(functx:is-a-number($request/@page)) then
        xs:integer($request/@page)
    
    (: Accept a folio ref e.g. F.1.a, and convert that into a page number :)
    else if ($request/@folio gt '') then
        source:folio-to-page($tei, $request/@resource-id, $request/@folio)
    
    else 0

(: Convert the ref-index, which is effectively the index of the ref in the TEI, into the source page :)
let $ref-sort-index := 
    if($ref-resource-index gt 0) then
        translation:folio-sort-index($tei, $request/@resource-id, $ref-resource-index)
    else 0

let $source-text := source:etext-page($tei-location, $ref-sort-index, true(), tokenize($request/@highlight, ','))
let $translation-text := translation:folio-content($tei, $request/@resource-id, $ref-resource-index)
let $ref-1 := $translation-text//tei:ref[@xml:id][1]

let $translation-response := 
    element { QName('http://read.84000.co/ns/1.0', 'translation')} {
        attribute id { tei-content:id($tei) },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        translation:titles($tei),
        tei-content:ancestors($tei, $request/@resource-id, 1), 
        translation:toh($tei, $request/@resource-id),
        $translation-text
    }

let $xml-response := 
    common:response(
        "source/folio", 
        $common:app-id,
        (
            (: Include request parameters :)
            $request,
            
            (: The translation :)
            $translation-response,
            
            (: Get a page :)
            if($ref-sort-index gt 0) then (
                $source-text,
                (: Include back link to the passage in the text :)
                <back-link 
                    xmlns="http://read.84000.co/ns/1.0"
                    url="{ concat($common:environment/m:url[@id eq 'reading-room'], '/translation/', $request/@resource-id, '.html', '?part=', $ref-1/@xml:id, '#', $ref-1/@xml:id) }"/>
            )
            
            (: Get the whole text :)
            else if (lower-case($request/@resource-suffix) = ('xml', 'txt')) then
                source:etext-full($tei-location)
                
            else ()
        )
    )

return
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/source.xsl"), $cache-key)
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
        