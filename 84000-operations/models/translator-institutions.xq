xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translators="http://read.84000.co/translators" at "../../84000-reading-room/modules/translators.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    'operations/translator-institutions', 
    'operations', 
    (
        translators:institutions(),
        translators:regions(false()),
        translators:institution-types(false()),
        $tei-content:text-statuses
    )
)
