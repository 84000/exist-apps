xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $lang := request:get-parameter('lang', 'en')

return
    common:response(
        "about/prototype", 
        $common:app-id,
        (
            common:app-texts('about.prototype', <replace xmlns="http://read.84000.co/ns/1.0"/>, $lang)
        )
    )
