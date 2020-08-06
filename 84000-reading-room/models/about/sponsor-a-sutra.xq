xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../modules/sponsorship.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/sponsor-a-sutra", 
    $common:app-id,
    (
        <request xmlns="http://read.84000.co/ns/1.0" 
            sharing-url="/about/sponsor-a-sutra.html"/>,
        <replace-text xmlns="http://read.84000.co/ns/1.0">
            <value key="#commsSiteUrl">{ $common:environment/m:url[@id eq 'communications-site'][1]/text() }</value>
            <value key="#readingRoomSiteUrl">{ $common:environment/m:url[@id eq 'reading-room'][1]/text() }</value>
            <value key="#feSiteUrl">{ $common:environment/m:url[@id eq 'front-end'][1]/text() }</value>
        </replace-text>,
        translations:sponsorship-texts(),
        $sponsorship:cost-groups
    )
)
