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
let $utilities-url := $common:environment/m:url[@id eq 'utilities']

(: If client then default to diff view :)
let $default-status := 
    if($store-conf[@type eq 'client']) then
        'diff'
    else
        '1'

(: Get requested status :)
let $request-status :=  request:get-parameter('texts-status', $default-status)

(: Validate the status :)
let $texts-status := $tei-content:text-statuses/m:status[xs:string(@status-id) = $request-status][not(@status-id eq '0')]/@status-id

(: Store a file if requested :)
let $store-file-name := request:get-parameter('store', '')
let $store-file := 
    if($store-file-name gt '') then(
        if($store-conf[@type eq 'client']/m:translations-master-host) then
            store:download-master($store-file-name, $store-conf/m:translations-master-host)
        else if($store-conf[@type eq 'master']) then
            store:create($store-file-name)
        else
            ()
        ,
        if($utilities-url and matches(request:get-uri(), '.*/translations\.html.*')) then
            response:redirect-to(xs:anyURI(concat($utilities-url, '/translations.html?texts-status=',$request-status)))
        else
            ()
    )
    else
        ()

(: If this is a client doing a version diff then first get translation versions in MASTER database for comparison :)
let $translations-master := 
    if($request-status eq 'diff' and $store-conf[@type eq 'client']) then
        store:master-downloads-data(xs:anyURI(concat($store-conf/m:translations-master-host, '/downloads.xml?resource-ids=versioned')))
    else
        ()

(: Get translations in LOCAL database :)
let $translations-local := 
    if($request-status eq 'diff' and $translations-master) then
    
        (: Filter out all the texts with a different version from master :)
        let $local-texts := translations:texts((), $translations-master//m:text/m:downloads/@resource-id, 'toh', '', 'all', false())
        return
            element { node-name($local-texts) } {
                $local-texts/@*,
                for $local-text in $local-texts/m:text
                    let $translation-local-toh := $local-text/m:toh/@key/string()
                    let $translation-local-version := $local-text/m:downloads/@tei-version/string()
                    let $master-version := $translations-master/m:text/m:downloads[@resource-id eq $translation-local-toh]/@tei-version
                where not($translation-local-version eq $master-version)
                return
                    $local-text
            }
    
    else if($texts-status) then
    
        (: Get the texts with this status :)
        translations:texts($texts-status, (), 'toh', '', 'all', false())
        
    else
        ()

(: If this is a client listing by status then get translation versions for these texts in MASTER database for comparison :)
let $translations-master := 
    if(not($request-status eq 'diff') and $store-conf[@type eq 'client'] and $translations-local[m:text]) then
        store:master-downloads-data(xs:anyURI(concat($store-conf/m:translations-master-host, '/downloads.xml?resource-ids=', string-join($translations-local/m:text/m:toh/@key, ','))))
    else
        $translations-master

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