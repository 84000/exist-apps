xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace log="http://read.84000.co/log" at "../../84000-reading-room/modules/log.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    'utilities/archive-logs',
    'utilities',
    (
       utilities:request(),
       log:achive-logs()
    )
)