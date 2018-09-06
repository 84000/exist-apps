xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $tab := request:get-parameter('tab', 'published')
let $lang := request:get-parameter('lang', 'en')

let $tabs := 
    <tabs xmlns="http://read.84000.co/ns/1.0">
        <tab active="{ if($tab eq 'published')then 1 else 0 }" id="published">Published Translations</tab>
        <tab active="{ if($tab eq 'translated')then 1 else 0 }" id="translated">Translations Awaiting Publication</tab>
        <tab active="{ if($tab eq 'in-translation')then 1 else 0 }" id="in-translation">Translations In Progress</tab>
    </tabs>

let $header := 
    <header xmlns="http://read.84000.co/ns/1.0" page-id="about/progress">
        <img>{ concat($common:environment/m:url[@id eq 'front-end']/text(), common:app-text('about.progress.header-img-src')) }</img>
        <title>{ common:app-text('about.progress.title') }</title>
        <quote>
            <text>{ common:app-text('about.progress.quote') }</text>
            <author>{ common:app-text('about.progress.author') }</author>
        </quote>
    </header>

(: 'O1JC11494' = Kangyur only :)
let $texts := 
    if($tab eq 'published') then
        translations:filtered-texts('O1JC11494', $tei-content:published-statuses, 'toh', '0', '', '', false())
    else if ($tab eq 'translated') then
        translations:filtered-texts('O1JC11494', $tei-content:text-statuses/m:status[@group = ('translated')]/@status-id, 'toh', '0', '', '', false())
    else if ($tab eq 'in-translation') then
        translations:filtered-texts('O1JC11494', $tei-content:text-statuses/m:status[@group = ('in-translation')]/@status-id, 'toh', '0', '', '', false())
    else
        ()

return
    common:response(
        "about/progress", 
        $common:app-id,
        (
            $header,
            $tabs,
            translations:summary(),
            $texts
        )
    )
