xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $lang := request:get-parameter('lang', 'en')

let $header := 
    <header xmlns="http://read.84000.co/ns/1.0">
        <img>{ concat($common:environment/m:url[@id eq 'front-end']/text(), common:app-text('about.impact.header-img-src')) }</img>
        <title>{ common:app-text('about.impact.title') }</title>
        <quote>
            <text>{ common:app-text('about.impact.quote') }</text>
            <author>{ common:app-text('about.impact.author') }</author>
        </quote>
    </header>

return
    <response 
        xmlns="http://read.84000.co/ns/1.0" 
        model-type="about/impact"
        page-id="about/impact"
        timestamp="{ current-dateTime() }"
        app-id="{ $common:app-id }"
        app-version="{ $common:app-version }"
        user-name="{ common:user-name() }" >
        { $header }
        { translations:summary() }
        { doc(concat($common:data-path, '/operations/user-stats.xml')) }
    </response>
