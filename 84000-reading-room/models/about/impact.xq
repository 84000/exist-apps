xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/impact", 
    $common:app-id,
    (
        translations:summary(),
        doc(concat($common:data-path, '/operations/user-stats.xml'))
    )
)
