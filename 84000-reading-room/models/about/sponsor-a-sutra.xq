xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $lang := request:get-parameter('lang', 'en')
let $app-texts := common:app-texts('about.sponsor-a-sutra', <replace xmlns="http://read.84000.co/ns/1.0"/>, $lang)

return
    common:response(
        "about/sponsor-a-sutra", 
        $common:app-id,
        (
            $app-texts,
            translations:filtered-texts('O1JC11494', '', 'toh', '0', 'available', '', 'toh')
        )
    )
