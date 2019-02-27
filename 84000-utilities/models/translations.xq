xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare option exist:serialize "method=xml indent=no";

(: Get config :)
let $store-conf := $common:environment/m:store-conf

(: Which translations? :)
let $text-status-ids := 
    if($store-conf[@type eq 'master']) then
        ('1', '2.a')
    else
        ('1')

(: Status ids in post (Unused) :)
let $text-statuses := request:get-parameter('text-statuses[]', $text-status-ids)

(: Request includes file to store :)
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

(: Translations in this database :)
let $translations-local := translations:translations($text-statuses, true(), 'all', false())

(: If this is a client get translations in master database (Status = 1 only) :)
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

return
    common:response(
        'utilities/translations',
        'utilities',
        (
            $translations-local,
            $translations-master,
            $tei-content:text-statuses,
            $store-file
        )
    )