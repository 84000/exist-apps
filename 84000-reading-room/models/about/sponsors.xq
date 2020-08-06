xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../modules/sponsors.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $sponsor-ids := $sponsors:sponsors/m:sponsors/m:sponsor[m:type/@id = ('founding', 'matching-funds')]/@xml:id

return
    common:response(
        "about/sponsors", 
        $common:app-id,
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                sharing-url="/about/sponsors.html" 
                tab="{ request:get-parameter('tab', 'matching-funds-tab') }"/>,
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#commsSiteUrl">{ $common:environment/m:url[@id eq 'communications-site'][1]/text() }</value>
                <value key="#readingRoomSiteUrl">{ $common:environment/m:url[@id eq 'reading-room'][1]/text() }</value>
                <value key="#feSiteUrl">{ $common:environment/m:url[@id eq 'front-end'][1]/text() }</value>
            </replace-text>,
            sponsors:sponsors($sponsor-ids, false(), false()),
            translations:sponsored-texts()
        )
    )
