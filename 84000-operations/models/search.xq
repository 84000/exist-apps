xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../../84000-reading-room/modules/translation-status.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";

declare option exist:serialize "method=xml indent=no";

let $status := local:get-status-parameter()
let $section := request:get-parameter('section', 'O1JC11494')
let $sort := request:get-parameter('sort', '')
let $range := request:get-parameter('range', '')
let $sponsored := request:get-parameter('sponsored', '')
let $deduplicate := request:get-parameter('deduplicate', '')
let $search-toh := request:get-parameter('search-toh', '')

let $filtered-texts := translations:filtered-texts($section, $status, $sort, $range, $sponsored, $search-toh, $deduplicate)
let $filtered-texts-ids := $filtered-texts/m:text/@id

let $users-groups := local:user-groups()

return
    common:response(
        'operations/search', 
        'operations', 
        (
            $filtered-texts,
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                translation-status:texts($filtered-texts-ids)
            },
            tei-content:text-statuses-selected($status),
            sponsors:sponsorship-statuses(''),
            if('utilities' = $users-groups) then
                element { QName('http://read.84000.co/ns/1.0', 'permission') } {
                    attribute group { 'utilities' }
                }
            else
                ()
        )
    )
