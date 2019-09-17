xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../modules/sponsors.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $sponsor-ids := $sponsors:sponsors/m:sponsors/m:sponsor[m:type/@id = ('founding', 'matching-funds')]/@xml:id

return
    common:response(
        "about/sponsors", 
        $common:app-id,
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                tab="{ request:get-parameter('tab', 'matching-funds-tab') }"/>,
            translations:summary($source:ekangyur-work),
            sponsors:sponsors($sponsor-ids, false(), false()),
            translations:sponsored-texts()
        )
    )
