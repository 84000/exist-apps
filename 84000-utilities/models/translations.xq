xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace store="http://utilities.84000.co/store" at "../modules/store.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../../84000-reading-room/modules/translation-status.xql";

declare option exist:serialize "method=xml indent=no";

(: 
    TO DO:
    Select statuses this in the UI.
    For now default to 1 and 2.a.
:)

let $text-statuses := request:get-parameter('text-statuses', ('1', '2.a'))

let $store-file-name := request:get-parameter('store', '')

let $store-file := 
    if($store-file-name gt '') then
        store:file($store-file-name)
    else
        ()

let $translations := translations:translations($text-statuses, true(), 'all', false())
let $translations-ids := $translations/m:translation/@id

return
    common:response(
        'utilities/translations',
        'utilities',
        (
            $translations,
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                translation-status:texts($translations-ids)
            },
            $tei-content:text-statuses,
            $store-file
        )
    )