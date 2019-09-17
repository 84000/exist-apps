xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../../84000-reading-room/modules/translation-status.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";

declare option exist:serialize "method=xml indent=no";

let $work := request:get-parameter('work', 'UT4CZ5369')
let $status := local:get-status-parameter()
let $sort := request:get-parameter('sort', '')
let $range := request:get-parameter('range', '')
let $sponsorship-group := request:get-parameter('sponsorship-group', '')
let $deduplicate := request:get-parameter('deduplicate', '')
let $search-toh := request:get-parameter('search-toh', '')

let $filtered-texts := translations:filtered-texts($work, $status, $sort, $range, $sponsorship-group, $search-toh, $deduplicate)

let $filtered-texts-ids := $filtered-texts/m:text/@id

let $users-groups := local:user-groups()

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
                range="{ $range }"
                sponsorship-group="{ $sponsorship-group }"
                deduplicate="{ $deduplicate }">
                <search-toh>{ $search-toh }</search-toh>    
            </request>,
            $filtered-texts,
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                translation-status:texts($filtered-texts-ids)
            },
            tei-content:text-statuses-selected($status),
            $translations:page-size-ranges,
            $sponsorship:sponsorship-groups,
            if('utilities' = $users-groups) then
                element { QName('http://read.84000.co/ns/1.0', 'permission') } {
                    attribute group { 'utilities' }
                }
            else
                ()
        )
    )
