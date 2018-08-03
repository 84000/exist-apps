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

let $resource-id := lower-case(request:get-parameter('resource-id', 'lobby'))
let $published-only := request:get-parameter('published-only', '0')
let $tei := tei-content:tei($resource-id, 'section')

return
    common:response(
        "section", 
        $common:app-id,
        (
            <section
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $resource-id }" 
                type="{ $tei//tei:teiHeader/tei:fileDesc/@type }">
                { section:titles($tei) }
                { tei-content:ancestors($tei, '', 1) }
                { section:abstract($tei) }
                { section:warning($tei) }
                { section:about($tei) }
                { section:text-stats($tei) }
                { 
                    if($resource-id eq 'all-translated') then
                        section:all-translated-texts()
                    else
                        section:texts($resource-id, $published-only) 
                }
                { section:sections($resource-id, $published-only) }
            </section>,
            common:app-texts('section', <replace xmlns="http://read.84000.co/ns/1.0"/>)
        )
    )
