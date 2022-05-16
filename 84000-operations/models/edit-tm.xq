xquery version "3.0" encoding "UTF-8";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../modules/update-tm.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $text-id := request:get-parameter('text-id', '')
let $part-id := request:get-parameter('part-id', '')

let $tei := tei-content:tei($text-id, 'translation')
let $tei-translation := $tei//tei:text/tei:body/tei:div[@type eq 'translation']
let $tmx := collection(concat($common:data-path, '/translation-memory'))//tmx:tmx[tmx:header/@eft:text-id eq $text-id]

return

(: Process update :)
let $update-tm :=
    if(
        $tmx
        and request:get-parameter('form-action', '') eq 'update-tm'
        and request:get-parameter('tu-id', '') gt ''
        and request:get-parameter-names()[. = 'tm-en']
    ) then
        update-tm:update-segment($tmx, request:get-parameter('tu-id', ''), 'en', request:get-parameter('tm-en', ''))
    else if(not($tmx) and request:get-parameter('form-action', '') eq 'create-file') then
        (: TO DO: Create a new TM file :)
        ()
    else ()

(: Check we got a part, if not default to first :)
let $part-id :=
    if(not($tei-translation/tei:div[@xml:id eq $part-id])) then
        $tei-translation/tei:div[1]/@xml:id/string()
    else
        $part-id

let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') }{
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute text-id { $text-id },
        attribute part-id { $part-id }
    }

let $translation := 
    element { QName('http://read.84000.co/ns/1.0', 'translation') }{
        attribute id { tei-content:id($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { tei-content:document-url($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        tei-content:titles($tei),
        translation:toh($tei, ''),
        $tei-translation
    }

(:let $source := source:etext-full(translation:location($tei, '')):)

let $xml-response := 
    common:response(
        'operations/edit-tm',
        'operations', (
            $request,
            $update-tm,
            $translation,
            $tmx
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-tm.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )