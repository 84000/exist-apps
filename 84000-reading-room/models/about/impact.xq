xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/impact", 
    $common:app-id,
    (
        <request xmlns="http://read.84000.co/ns/1.0" 
            sharing-url="/about/impact.html"/>,
        (: Calculated strings :)
        <replace-text xmlns="http://read.84000.co/ns/1.0">
            <value key="#visitorsPerWeekFormatted">{ common:format-number(250) }</value>
            <value key="#reachCountriesFormatted">{ common:format-number(242) }</value>
            <value key="#engagementMinutesFormatted">{ common:format-number(6030) }</value>
            <value key="#topTextViewsFormatted">{ common:format-number(43610) }</value>
        </replace-text>
        
    )
)
