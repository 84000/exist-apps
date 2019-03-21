xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $action := request:get-parameter('action', '')

return 
    common:response(
        'utilities/text-searches',
        'utilities',
        ()
    )