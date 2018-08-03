xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
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
    <header xmlns="http://read.84000.co/ns/1.0">
        <img>{ concat($common:environment/m:url[@id eq 'front-end']/text(), common:app-text('about.translations.header-img-src')) }</img>
        <title>{ common:app-text('about.translations.title') }</title>
        <quote>
            <text>{ common:app-text('about.translations.quote') }</text>
            <author>{ common:app-text('about.translations.author') }</author>
        </quote>
    </header>

return
    <response 
        xmlns="http://read.84000.co/ns/1.0" 
        model-type="about/translations"
        page-id="about/translations"
        timestamp="{ current-dateTime() }"
        app-id="{ $common:app-id }"
        app-version="{ $common:app-version }"
        user-name="{ common:user-name() }" >
        { $header }
        { $tabs }
        { translations:summary() }
        {
            if($tab eq 'published') then
                translations:filtered-texts($common:published-statuses, 'toh', '0', '', '', false())
            else if ($tab eq 'translated') then
                translations:filtered-texts($common:text-statuses/m:status[@group = ('translated')]/@status-id, 'toh', '0', '', '', false())
            else if ($tab eq 'in-translation') then
                translations:filtered-texts($common:text-statuses/m:status[@group = ('in-translation')]/@status-id, 'toh', '0', '', '', false())
            else
                ()
                
        }
    </response>
