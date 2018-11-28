xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../modules/contributors.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $lang := request:get-parameter('lang', 'en')

let $header := 
    <header xmlns="http://read.84000.co/ns/1.0" page-id="about/sponsors">
        <img>{ concat($common:environment/m:url[@id eq 'front-end']/text(), common:app-text('about.translators.header-img-src')) }</img>
        <title>{ common:app-text('about.translators.title') }</title>
        <quote>
            <text>{ common:app-text('about.translators.quote') }</text>
            <author>{ common:app-text('about.translators.author') }</author>
        </quote>
    </header>
    
return
    common:response(
        "about/translators", 
        $common:app-id,
        (
            $header,
            contributors:teams(false()),
            contributors:persons(false()),
            contributors:regions(true()),
            contributors:institution-types(true()),
            translations:summary()
        )
    )
