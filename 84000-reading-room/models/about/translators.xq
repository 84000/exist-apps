xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../modules/contributors.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/translators", 
    $common:app-id,
    (
        contributors:teams(false(), false(), true()),
        contributors:regions(true()),
        contributors:institution-types(true())
    )
)
