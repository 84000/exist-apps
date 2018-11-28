xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare option exist:serialize "method=xml indent=no";

let $include-acknowledgements := (request:get-parameter('include-acknowledgements', '') gt '0')

return
    common:response(
        'operations/translator-teams', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0" include-acknowledgements="{ $include-acknowledgements }"/>,
            contributors:teams($include-acknowledgements),
            contributors:persons(false()),
            $tei-content:text-statuses
        )
    )
