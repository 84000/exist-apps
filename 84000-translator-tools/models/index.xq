xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $tabs := local:user-tabs()
let $tab := $tabs//m:tab[@id eq request:get-parameter('tab','')]/@id
let $tab := 
    if(not($tab gt ''))then
        $tabs//m:tab[@home]/@id
    else
        $tab

let $xml-section := doc(concat($common:data-path, '/translator-tools/sections/', $tab, '.xml'))

let $type := request:get-parameter('type', 'term')
let $lang := request:get-parameter('lang', 'en')
let $search := request:get-parameter('search', '')
let $volume := request:get-parameter('volume', 1)
let $page := request:get-parameter('page', 1)
let $results-mode := request:get-parameter('results-mode', 'translations')

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else
        1

return

    common:response(
        concat('translator-tools/', $tab),
        'translator-tools',
        (
            <request xmlns="http://read.84000.co/ns/1.0" tab="{ $tab }"/>,
            $tabs,
            if($tab eq 'search' and compare($search, '') gt 0) then 
                search:search($search, $first-record, 15)
            else if($tab eq 'glossary') then 
                glossary:glossary-terms($type, $lang)
            else if($tab eq 'translation-search') then 
                search:translation-search(xs:string($search), xs:integer($volume), xs:integer($page), $results-mode)
            else
                $xml-section
        )
    )