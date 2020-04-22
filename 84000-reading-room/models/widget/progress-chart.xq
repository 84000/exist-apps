xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $comms-url := $common:environment/m:url[@id eq 'communications-site'][1]/text()

return
    common:response(
        "widget/progress-chart", 
        $common:app-id,
        (
            translations:summary($source:ekangyur-work),
            translations:summary($source:etengyur-work),
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#commsSiteUrl">{ $comms-url }</value>
            </replace-text>
        )
    )
