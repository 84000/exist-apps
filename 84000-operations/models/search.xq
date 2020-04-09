xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../modules/translation-status.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $work := request:get-parameter('work', 'UT4CZ5369')
let $status := local:get-status-parameter()
let $sort := request:get-parameter('sort', '')
let $pages-min := request:get-parameter('pages-min', '')
let $pages-max := request:get-parameter('pages-max', '')
let $sponsorship-group := request:get-parameter('sponsorship-group', '')
let $deduplicate := request:get-parameter('deduplicate', '')
let $toh-min := request:get-parameter('toh-min', '')
let $toh-max := request:get-parameter('toh-max', '')

let $filtered-texts := translations:filtered-texts($work, $status, $sort, $pages-min, $pages-max, $sponsorship-group, $toh-min, $toh-max, $deduplicate)

let $filtered-texts-ids := $filtered-texts/m:text/@id

return
    common:response(
        'operations/search', 
        'operations', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                work="{ $work }" 
                status="{ $status }"
                sort="{ $sort }"
                pages-min="{ $pages-min }"
                pages-max="{ $pages-max }"
                sponsorship-group="{ $sponsorship-group }"
                deduplicate="{ $deduplicate }"
                toh-min="{ $toh-min }"
                toh-max="{ $toh-max }"/>
            ,
            $filtered-texts,
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                translation-status:texts($filtered-texts-ids)
            },
            tei-content:text-statuses-selected($status),
            $sponsorship:sponsorship-groups,
            if(common:user-in-group('utilities')) then
                element { QName('http://read.84000.co/ns/1.0', 'permission') } {
                    attribute group { 'utilities' }
                }
            else
                ()
        )
    )
