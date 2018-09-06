xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $tab := request:get-parameter('tab', 'founding')
let $lang := request:get-parameter('lang', 'en')

let $tabs := 
    <tabs xmlns="http://read.84000.co/ns/1.0">
        <tab active="{ if($tab eq 'founding')then 1 else 0 }" id="founding">Founding Sponsors</tab>
        <tab active="{ if($tab eq 'sutra')then 1 else 0 }" id="sutra">Sūtra Sponsors</tab>
        <tab active="{ if($tab eq 'matching-funds')then 1 else 0 }" id="matching-funds">Matching Funds Sponsors</tab>
    </tabs>

let $header := 
    <header xmlns="http://read.84000.co/ns/1.0" page-id="about/sponsors">
        <img>{ concat($common:environment/m:url[@id eq 'front-end']/text(), common:app-text('about.sponsors.header-img-src')) }</img>
        <title>{ common:app-text('about.sponsors.title') }</title>
        <quote>
            <text>{ common:app-text('about.sponsors.quote') }</text>
            <author>{ common:app-text('about.sponsors.author') }</author>
        </quote>
    </header>

let $sponsors := doc(concat($common:data-path, '/operations/sponsors.xml'))
let $sponsorship := 
    <sponsorship xmlns="http://read.84000.co/ns/1.0">
        {
            $sponsors/m:sponsors/m:sponsor[@type eq 'founding']
        }
        {
            $sponsors/m:sponsors/m:sponsor[@type eq 'matching-funds']
        }
        {
            translations:sponsored()
        }
    </sponsorship>

return
    common:response(
        "about/sponsors", 
        $common:app-id,
        (
            $header,
            $tabs,
            translations:summary(),
            $sponsorship
        )
    )
