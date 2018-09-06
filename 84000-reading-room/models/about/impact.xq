xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $lang := request:get-parameter('lang', 'en')

let $header := 
    <header xmlns="http://read.84000.co/ns/1.0" page-id="about/impact">
        <img>{ concat($common:environment/m:url[@id eq 'front-end']/text(), common:app-text('about.impact.header-img-src')) }</img>
        <title>{ common:app-text('about.impact.title') }</title>
        <quote>
            <text>{ common:app-text('about.impact.quote') }</text>
            <author>{ common:app-text('about.impact.author') }</author>
        </quote>
    </header>

return
    common:response(
        "about/impact", 
        $common:app-id,
        (
            $header,
            translations:summary(),
            doc(concat($common:data-path, '/operations/user-stats.xml'))
        )
    )
