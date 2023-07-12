xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $request := 
    element { QName('http://read.84000.co/ns/1.0','request') } {
        attribute text-id { request:get-parameter('text-id', '') },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute first-record { request:get-parameter('first-record', '1') },
        element search { request:get-parameter('search', '') ! normalize-space(.) }
    }

(: Validate text-id :)
let $tei := tei-content:tei($request/@text-id, 'translation')
let $toh := translation:toh($tei, '')
let $tei-location := translation:location($tei, $toh/@key)

let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute id { tei-content:id($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { base-uri($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        tei-content:titles-all($tei),
        $toh,
        $tei-location
    }

let $source-page := source:etext-page($tei-location, $request/@first-record ! xs:integer(.), true(), ())
let $source-page-marked := glossary:mark-source($source-page, $toh/@number ! xs:integer(.))

let $xml-response := 
    common:response(
        'operations/source', 
        'operations',
        (
            $request,
            $text,
            $source-page-marked
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/source.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )