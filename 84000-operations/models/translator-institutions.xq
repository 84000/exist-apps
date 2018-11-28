xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    'operations/translator-institutions', 
    'operations', 
    (
        contributors:institutions(),
        contributors:regions(false()),
        contributors:institution-types(false()),
        $tei-content:text-statuses
    )
)
