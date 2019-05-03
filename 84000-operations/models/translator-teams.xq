xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $include-acknowledgements := (request:get-parameter('include-acknowledgements', '1') gt '0')

let $delete-team-id := request:get-parameter('delete', '')

let $delete-team := 
    if($delete-team-id gt '') then
        contributors:delete($contributors:contributors/m:contributors/m:team[@xml:id eq $delete-team-id])
    else
        ()

return
    common:response(
        'operations/translator-teams', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0" include-acknowledgements="{ $include-acknowledgements }"/>,
            contributors:teams(true(), $include-acknowledgements, true()),
            $tei-content:text-statuses
        )
    )
