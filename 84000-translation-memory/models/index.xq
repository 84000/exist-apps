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

let $translations := translations:files($tei-content:published-statuses)
let $translation-id := request:get-parameter('translation-id', $translations/m:file[1]/@id)
let $translation := tei-content:tei($translation-id, 'translation')
let $toh-key := translation:toh-key($translation, '') (: get the first/default toh-key so that it is consistent :)
let $volume := translation:volume($translation, $toh-key)
let $folios := translation:folios($translation, $toh-key)
let $folio-request := request:get-parameter('folio', '')
let $volume-request := request:get-parameter('volume', '')
let $folio := 
    if(xs:string($volume) eq xs:string($volume-request) and $folios/m:folio[lower-case(@id) eq $folio-request]) then
        lower-case($folio-request)
    else
        lower-case($folios/m:folio[1]/@id)

let $action := 
    if(request:get-parameter('action', '') eq 'remember-translation') then
        translation-memory:remember($translation-id, $folio, request:get-parameter('source', ''), request:get-parameter('translation', ''))
    else
        ()

let $ekangyur-volume-number := source:ekangyur-volume-number($volume)
let $folio-str := substring-after($folio, 'f.')
let $folio-page := substring-before($folio-str, '.')
let $folio-side := substring-after($folio-str, '.')
let $ekangyur-page-number := 
    if(functx:is-a-number($folio-page)) then 
        source:ekangyur-page-number($volume, $folio-page, $folio-side)
    else
        0

return
    
    common:response(
        'translation-memory',
        'translation-memory',
        (
            <request xmlns="http://read.84000.co/ns/1.0" translation-id="{ $translation-id }" folio="{ $folio }" />,
            <action xmlns="http://read.84000.co/ns/1.0">{ $action }</action>,
            $translations,
            $folios,
            translation:folio-content($translation, $folio, $toh-key),
            source:ekangyur-page($ekangyur-volume-number, $ekangyur-page-number, true()),
            translation-memory:folio($translation-id, $folio)
        )
    )
