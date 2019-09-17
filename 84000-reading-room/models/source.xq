xquery version "3.0" encoding "UTF-8";
(:
    Accepts a folio string parameter
    Returns the source tibetan for that folio
    ---------------------------------------------------------------
:)

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../modules/source.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

(: the id of the text :)
let $resource-id := request:get-parameter('resource-id', '')
let $tei := tei-content:tei($resource-id, 'translation')
let $tei-location := translation:location($tei, $resource-id)

(: accept a folio and convert to a page number :)
let $folio := request:get-parameter('folio', '')

(: prefer a page number :)
let $page := 
    if(functx:is-a-number(request:get-parameter('page', ''))) then
        request:get-parameter('page', '')
    else
        source:folio-to-page($tei, $resource-id, $folio)

(: An id in the referring doc to link back to :)
let $anchor := concat('source-link-', $page)
let $reading-room-path := $common:environment/m:url[@id eq 'reading-room']/text()

return
    common:response(
        "source/folio", 
        $common:app-id,
        (
            (: Include request parameters :)
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }" 
                page="{ $page }"
                folio="{ $folio }"/>,
                
            (: Include the source data :)
            source:etext-page($tei-location, $page, false()),
            
            (: Include back link to the text :)
            <back-link 
                xmlns="http://read.84000.co/ns/1.0"
                url="{ concat($reading-room-path, '/translation/', $resource-id, '.html#', $anchor) }">
                <title>{ tei-content:title($tei) }</title>
            </back-link>
        )
    )
