xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare option exist:serialize "method=xml indent=no";

(: Get config :)
let $store-conf := $common:environment/m:store-conf

(: Validate the status ids in post :)
let $texts-status := $tei-content:text-statuses/m:status[xs:string(@status-id) = request:get-parameter('texts-status', '1')][not(@status-id eq '0')]/@status-id

(: Request includes file to store :)
let $store-file-name := request:get-parameter('store', '')
let $store-file := 
    if($store-file-name gt '') then
        if($store-conf[@type eq 'client']/m:translations-master-host) then
            store:download-master($store-file-name, $store-conf/m:translations-master-host)
        else if($store-conf[@type eq 'master']) then
        (
            store:create($store-file-name),
            if(ends-with($store-file-name, '.rdf')) then
                deploy:commit-data('sync', 'rdf', concat('Sync ', $store-file-name))
            else
                ()
        )
        else
            ()
    else
        ()

(: Translations in this database :)
let $translations-local := translations:translations($texts-status, 'all', false())

(: If this is a client get translations in master database :)
let $translations-master := 
    if($store-conf[@type eq 'client']) then
        let $resource-ids-str := string-join($translations-local/m:text/m:toh/@key, ',')
        let $translations-master-request := concat($store-conf/m:translations-master-host, '/downloads.xml?resource-ids=', $resource-ids-str)
        let $request := <hc:request href="{ $translations-master-request }" method="GET"/>
        let $response := hc:send-request($request)
        return
            element {  QName('http://read.84000.co/ns/1.0', 'translations-master') } {
                (: attribute url { $translations-master-request }, :)
                $response[2]/m:response/m:translations
            }
    else
        ()

return
    common:response(
        'utilities/translations',
        'utilities',
        (
            local:request(),
            $translations-local,
            $translations-master,
            $tei-content:text-statuses,
            $store-file
        )
    )