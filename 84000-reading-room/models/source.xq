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

let $resource-id := request:get-parameter('resource-id', '')
let $folio := request:get-parameter('folio', '')
let $anchor := request:get-parameter('anchor', '')

let $tei := tei-content:tei($resource-id, 'translation')
let $volume := translation:volume($tei, $resource-id)

let $ekangyur-volume-number := source:ekangyur-volume-number($volume)

let $folio-page := substring-before($folio, '.')
let $folio-side := substring-after($folio, '.')
let $ekangyur-page-number := 
    if(functx:is-a-number($folio-page)) then 
        source:ekangyur-page-number($volume, $folio-page, $folio-side)
    else
        0

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
                folio="{ $folio }"/>,
                
            (: Include back link to the text :)
            <back-link 
                xmlns="http://read.84000.co/ns/1.0"
                url="{ concat($reading-room-path, '/translation/', $resource-id, '.html#', $anchor) }">
                <title>{ tei-content:title($tei) }</title>
            </back-link>,
            
            (: Include the source data :)
            source:ekangyur-page($ekangyur-volume-number, $ekangyur-page-number, false()),
            
            (: If it's html include app texts :)
            if(request:get-parameter('resource-suffix', '') = ('html', 'epub', 'azw3')) then
                common:app-texts('source', <replace xmlns="http://read.84000.co/ns/1.0"/>)
            else
                ()
        )
    )
