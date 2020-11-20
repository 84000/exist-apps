xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    'utilities/tests',
    'utilities',
    (
        utilities:request()
    )
)