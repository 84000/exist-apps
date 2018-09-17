xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

let $post-status := request:get-parameter('status[]', '')
let $get-status := tokenize(request:get-parameter('status', ''), ',')
let $status := 
    if (count($get-status)) then
        $get-status
    else
        $post-status

let $section := request:get-parameter('section', 'O1JC11494')
let $sort := request:get-parameter('sort', '')
let $range := request:get-parameter('range', '')
let $sponsored := request:get-parameter('sponsored', '')
let $deduplicate := request:get-parameter('deduplicate', '')
let $search-toh := request:get-parameter('search-toh', '')

return
    common:response(
        'operations/search', 
        'operations', 
        (
            translations:filtered-texts($section, $status, $sort, $range, $sponsored, $search-toh, ($deduplicate eq 'true')),
            tei-content:text-statuses-selected($status)
        )
    )
