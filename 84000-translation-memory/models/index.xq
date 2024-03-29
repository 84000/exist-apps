xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://translation-memory.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace translation-memory="http://read.84000.co/translation-memory" at "../modules/translation-memory.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

(: Get translations for list. Do it first so we can default to first :)
let $translations := translations:files($translation:published-status-ids)
let $translation-id := request:get-parameter('translation-id', $translations/m:file[1]/@id)

(: Get the tei :)
let $tei:= tei-content:tei($translation-id, 'translation')
(: Get the first/default toh-key so that it is consistent :)
let $toh-key := translation:toh-key($tei, '') 
let $location:= translation:location($tei, $toh-key)

(: Get all the folios in the translation :)
let $folios := translation:folios($tei, $toh-key)
let $folio-request := lower-case(request:get-parameter('folio', ''))
let $folio := $folios/m:folio[lower-case(@tei-folio) = $folio-request][1]
let $folio :=
    if(not($folio)) then
        $folios/m:folio[1]
    else
        $folio

let $tei-folio := string($folio/@tei-folio)
let $page-in-text := number($folio/@page-in-text)

let $folio-translation := 
    if ($tei and $page-in-text gt 0) then
        translation:folio-content($tei, $toh-key, $page-in-text)
    else
        ()

let $folio-source := 
    if ($location and $page-in-text gt 0) then
        source:etext-page($location, $page-in-text, true(), ())
    else
        ()

let $action := 
    if(request:get-parameter('action', '') eq 'remember-translation') then
        translation-memory:remember($translation-id, $tei-folio, request:get-parameter('source', ''), request:get-parameter('translation', ''))
    else
        ()

let $folio-tmx := 
    if ($tei-folio) then
        translation-memory:folio($translation-id, $tei-folio)
    else
        ()

return
    common:response(
        'translation-memory',
        'translation-memory',
        (
            <request xmlns="http://read.84000.co/ns/1.0" translation-id="{ $translation-id }" folio="{ $tei-folio }" />,
            <action xmlns="http://read.84000.co/ns/1.0">{ $action }</action>,
            $translations,
            $folios,
            $folio-translation,
            $folio-source,
            $folio-tmx
        )
    )
