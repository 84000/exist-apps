xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace search="http://read.84000.co/search" at "../modules/search.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $search := request:get-parameter('s', '')
let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else
        1

return
    common:response(
        'search',
        $common:app-id,
        if(compare($search, '') gt 0) then 
            search:search($search, $first-record, 15)
        else
            ()
    )