xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../modules/sponsors.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $tab := request:get-parameter('tab', 'matching-funds')

let $tabs := 
    <tabs xmlns="http://read.84000.co/ns/1.0">
        <tab active="{ if($tab eq 'matching-funds')then 1 else 0 }" id="matching-funds">Matching Funds Sponsors</tab>
        <tab active="{ if($tab eq 'sutra')then 1 else 0 }" id="sutra">Sūtra Sponsors</tab>
        <tab active="{ if($tab eq 'founding')then 1 else 0 }" id="founding">Founding Sponsors</tab>
    </tabs>
    
let $sponsor-ids := $sponsors:sponsors/m:sponsors/m:sponsor[m:type/@id = ('founding', 'matching-funds')]/@xml:id

return
    common:response(
        "about/sponsors", 
        $common:app-id,
        (
            $tabs,
            translations:summary(),
            sponsors:sponsors($sponsor-ids, false(), false()),
            translations:sponsored-texts()
        )
    )
