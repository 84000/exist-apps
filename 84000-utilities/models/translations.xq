xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare option exist:serialize "method=xml indent=no";

(: Get config :)
let $store-conf := $common:environment/m:store-conf
let $utilities-url := $common:environment/m:url[@id eq 'utilities']

let $request := 
    utilities:request(
        element { QName('http://read.84000.co/ns/1.0', 'request')} {
            element parameter { 
                attribute name { 'page-filter' },
                request:get-parameter('page-filter', 'recent-updates')
            }
        }
    )

let $request-page-filter := $request/m:parameter[@name eq 'page-filter']/text()

(: Validate the status :)
let $texts-status := 
    if(not($request-page-filter = ('new-version-translations', 'new-version-placeholders', 'search', 'recent-updates'))) then 
        $tei-content:text-statuses/m:status[@type eq 'translation'][@status-id/string() eq $request-page-filter][not(@status-id eq '0')]/@status-id
    else ()

(: Pull operations data :)
let $pull-data-operations :=
    if($store-conf[@type eq 'client'] and request:get-parameter('form-action', '') eq 'pull-data-operations') then
        deploy:pull('data-operations', request:get-parameter('deploy-password', ''))
    
    else if($store-conf[@type eq 'master'] and request:get-parameter('form-action', '') eq 'push-data-operations') then
        deploy:push('data-operations', request:get-parameter('deploy-password', ''), (), ())
    
    else ()

(: Store a file if requested :)
let $store-file := 
    for $store-file-name in request:get-parameter('store[]', '')[not(. eq '')]
    return
        (: Get files from master :)
        if($store-conf[@type eq 'client'][m:translations-master-host]) then 
            store:download-master($store-file-name, $store-conf/m:translations-master-host, true())
        else ()

(: If this is a client doing a version diff then first get translation versions in MASTER database for comparison :)
let $translations-master := 
    if($store-conf[@type eq 'client']) then
        if($request-page-filter eq 'new-version-translations') then 
            store:master-downloads-data(xs:anyURI(concat($store-conf/m:translations-master-host, '/downloads.xml?resource-ids=translations')))
            
        else if ($request-page-filter eq 'new-version-placeholders') then
            store:master-downloads-data(xs:anyURI(concat($store-conf/m:translations-master-host, '/downloads.xml?resource-ids=placeholders')))
            
        else ()
    else ()

(: Get translations in LOCAL database :)
let $translations-local := 
    if($request-page-filter = ('new-version-translations', 'new-version-placeholders') and $translations-master) then
    
        (: Filter out all the texts with the same version as master :)
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
            
    else if($request-page-filter = ('search') and ($request/m:parameter[@name eq 'toh-min'][text() gt ''] or $request/m:parameter[@name eq 'toh-max'][text() gt ''])) then
        
        (: Search Toh range :)
        translations:filtered-texts('all', (), '', '', '', '', ($request/m:parameter[@name eq 'toh-min']/text(), '')[1], ($request/m:parameter[@name eq 'toh-max']/text(), '')[1], 'toh', '', '')
    
    else if($request-page-filter = ('recent-updates')) then
    
        (: Get recent activity :)
        let $recent-activity := translations:recent-updates()
        return
            if(request:get-parameter('resource-suffix', '') eq 'xlsx') then
                translations:recent-updates-spreadsheet($recent-activity)
            else
                $recent-activity
        
    else if($texts-status) then
    
        (: Get the texts with this status :)
        translations:texts($texts-status, (), 'toh', '', 'all', false())
        
    else ()

(: If this is a client listing by status then get translation versions for these texts in MASTER database for comparison :)
let $translations-master := 
    if(not($request-page-filter = ('new-version-translations', 'new-version-placeholders', 'recent-updates')) and $store-conf[@type eq 'client'] and $translations-local[m:text]) then
        store:master-downloads-data(xs:anyURI(concat($store-conf/m:translations-master-host, '/downloads.xml?resource-ids=', string-join($translations-local/m:text/m:toh/@key, ','))))
    else
        $translations-master

return
    common:response(
        'utilities/translations',
        'utilities',
        (
            $request,
            $translations-local,
            $translations-master,
            tei-content:text-statuses-sorted('translation'),
            $store-file,
            $pull-data-operations
        )
    )