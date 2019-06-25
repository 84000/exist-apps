xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter
    Returns the section xml
    -------------------------------------------------------------
    Can be returned as xml or transformed into json or html.
:)
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := upper-case(request:get-parameter('resource-id', 'lobby'))
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $published-only := request:get-parameter('published-only', false())
let $translations-order := request:get-parameter('translations-order', 'toh')
let $tei := tei-content:tei($resource-id, 'section')

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
                published-only="{ $published-only }"
                translations-order="{ $translations-order }" />,
                
            (: Include section data :)
            section:base-section($tei, $published-only, true())
            
        )
    )
