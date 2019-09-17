xquery version "3.0" encoding "UTF-8";
(:
    Accepts a folio string parameter
    Returns the source tibetan for that folio
    ---------------------------------------------------------------
:)

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../modules/source.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

(: the id of the text :)
let $resource-id := request:get-parameter('resource-id', '')
let $tei := tei-content:tei($resource-id, 'translation')

(: accept a folio and convert to a page number :)
let $folio := request:get-parameter('folio', '')

(: prefer a page number :)
let $page := 
    if(functx:is-a-number(request:get-parameter('page', ''))) then
        request:get-parameter('page', '')
    else
        source:folio-to-page($tei,$resource-id, $folio)

return
    common:response(
        "translation/folio", 
        $common:app-id,
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }" 
                page="{ $page }"/>,
            translation:folio-content($tei, $resource-id, $page)
        )
    )
