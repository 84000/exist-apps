xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $request := 
    element { QName('http://read.84000.co/ns/1.0','request') } {
        attribute text-id { request:get-parameter('text-id', '') },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') }
    }

(: Validate text-id :)
let $tei := tei-content:tei($request/@text-id, 'translation')

(: Files list for the dropdown :)
(:let $translation-files := 
    element { QName('http://read.84000.co/ns/1.0', 'translations') }{
        for $tei in $tei-content:translations-collection//tei:fileDesc/tei:publicationStmt/tei:availability[@status = $translation:marked-up-status-ids]/ancestor::tei:TEI
        let $text-id := tei-content:id($tei)
        return
            element { QName('http://read.84000.co/ns/1.0', 'text') } {
                attribute id { $text-id },
                if($text-id eq $request/@text-id) then
                    attribute selected { true() }
                else (),
                concat(string-join($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key]/tei:ref, ' / '), ' - ', tei-content:title-any($tei))
            }
    }:)

(: Do actions :)
let $updated := 
    (: Make an archive of the latest tei :)
    if($tei and request:get-parameter('form-action', '') eq 'archive-latest') then
        update-tei:archive-latest($tei)
    else ()


let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute id { tei-content:id($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { base-uri($tei) },
        attribute resource-type { tei-content:type($tei) }, 
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        tei-content:titles-all($tei),
        translation:toh($tei, ''),
        tei-content:status-updates($tei)
    }

(: Get archived texts :)
let $archived-texts := 
    element { QName('http://read.84000.co/ns/1.0','archived-texts') } {
        for $tei in collection(concat($common:archive-path, '/tei'))//tei:publicationStmt/tei:idno/id($request/@text-id)/ancestor::tei:TEI
        let $text-id := tei-content:id($tei)
        let $document-url := base-uri($tei)
        let $file-name := util:unescape-uri(replace($document-url, ".+/(.+)$", "$1"), 'UTF-8')
        let $document-path := substring-before($document-url, concat('/', $file-name))
        let $archive-path := 
            if(contains($document-path, $common:archive-path)) then
                substring-after($document-path, concat($common:archive-path, '/'))
            else ''
        return
            element { QName('http://read.84000.co/ns/1.0', 'text') } {
                attribute id { $text-id }, 
                attribute document-url { $document-url },
                attribute resource-type { tei-content:type($tei) },
                attribute file-name { $file-name },
                attribute archive-path { $archive-path },
                attribute last-modified { tei-content:last-modified($tei) },
                translation:toh($tei, '')
            }
    }

let $xml-response := 
    common:response(
        'operations/annotation-tei', 
        'operations',
        (
            $request,
            (:$translation-files,:)
            $text,
            $archived-texts,
            tei-content:text-statuses-selected($text/@status, 'translation')
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/annotation-tei.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )