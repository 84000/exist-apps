xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace store="http://utilities.84000.co/store" at "../modules/store.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../../84000-reading-room/modules/translation-status.xql";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare option exist:serialize "method=xml indent=no";

(: 
    TO DO:
    Select statuses this in the UI.
    For now default to 1 and 2.a.
:)

let $store-conf := $common:environment/m:store-conf

let $text-status-ids := 
    if($store-conf[@type eq 'master']) then
        ('1', '2.a')
    else
        ('1')

let $text-statuses := request:get-parameter('text-statuses', $text-status-ids)

let $store-file-name := request:get-parameter('store', '')

let $store-file := 
    if($store-file-name gt '') then
        if($store-conf[@type eq 'client']/m:translations-master-host) then
            store:download-master($store-file-name, $store-conf/m:translations-master-host)
        else if($store-conf[@type eq 'master']) then
            store:create($store-file-name)
        else
            ()
    else
        ()

let $translations-local := translations:translations($text-statuses, true(), 'all', false())
let $translations-local-ids := $translations-local/m:translation/@id

let $translations-master := 
    if($store-conf[@type eq 'client']) then
        let $request := <hc:request href="{$store-conf/m:translations-master-host}/section/all-translated.xml" method="GET"/>
        let $response := hc:send-request($request)
        return
            element {  QName('http://read.84000.co/ns/1.0', 'translations-master') } {
                $response[2]/m:response/m:section/m:texts
            }
    else
        ()

let $translation-status := 
    if($store-conf[@type eq 'master']) then
        element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
            translation-status:texts($translations-local-ids)
        }
    else
        ()

return
    common:response(
        'utilities/translations',
        'utilities',
        (
            $translations-local,
            $translation-status,
            $translations-master,
            $tei-content:text-statuses,
            $store-file
        )
    )