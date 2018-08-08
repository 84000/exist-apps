xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";

declare option exist:serialize "method=xml indent=no";

let $additional-tabs := doc('../config/additional-tabs.xml')
let $tab := request:get-parameter('tab', $additional-tabs//m:tab[@home]/@id)
let $additional-content := doc(concat('../config/sections/', $tab, '.xml'))

let $type := request:get-parameter('type', 'term')
let $search := request:get-parameter('search', '')
let $volume := request:get-parameter('volume', 1)
let $page := request:get-parameter('page', 1)
let $results-mode := request:get-parameter('results-mode', 'translations')

return

    common:response(
        concat('translator-tools/', $tab),
        'translator-tools',
        (
            <request xmlns="http://read.84000.co/ns/1.0" tab="{ $tab }"/>,
            $additional-tabs,
            if($tab eq 'search') then 
                search:search($search)
            else if($tab eq 'glossary') then 
                glossary:glossary-terms($type)
            else if($tab eq 'translation-search') then 
                search:translation-search(xs:string($search), xs:integer($volume), xs:integer($page), $results-mode)
            else
                $additional-content
        )
    )