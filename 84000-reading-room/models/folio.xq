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

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $folio := request:get-parameter('folio', '')

let $tei := tei-content:tei($resource-id, 'translation')

return
    common:response(
        "translation/folio", 
        $common:app-id,
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }" 
                folio="{ $folio }"/>,
            translation:folio-content($tei, concat('f.', $folio), $resource-id)
        )
    )
