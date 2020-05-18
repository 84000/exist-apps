xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace local="http://translator-tools.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $tabs := local:user-tabs()
let $tab := $tabs//m:tab[@id eq request:get-parameter('tab','')]/@id
let $tab := 
    if(not($tab gt ''))then
        if($tabs//m:tab[@home][1]) then
            $tabs//m:tab[@home][1]/@id
        else
            $tabs//m:tab[1]/@id
    else
        $tab

let $xml-section := doc(concat($common:data-path, '/translator-tools/sections/', $tab, '.xml'))

let $type := request:get-parameter('type', if($tab eq 'tm-search') then 'folio' else 'term')
let $search := request:get-parameter('search', if($tab eq 'glossary') then 'a' else '')
let $lang := request:get-parameter('lang', if($tab eq 'tm-search') then 'bo' else 'en')
let $work := request:get-parameter('work', $source:ekangyur-work)
let $volume := request:get-parameter('volume', 1)
let $page := request:get-parameter('page', 1)
let $resource-id := request:get-parameter('resource-id', '')
let $glossary-sort := request:get-parameter('glossary-sort', '')

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else
        1

let $etext-page :=  source:etext-page($work, $volume, $page, true())

(:
let $search := 
    if($type eq 'folio') then
        normalize-space(string-join($etext-page//tei:p[@class eq "selected"]/text(), ' '))
    else
        $search
:)
return

    common:response(
        concat('translator-tools/', $tab),
        'translator-tools',
        (
            <request xmlns="http://read.84000.co/ns/1.0" tab="{ $tab }" lang="{ $lang }" type="{ $type }" volume="{ $volume }" page="{ $page }" glossary-sort="{ $glossary-sort }">
                <search>{ $search }</search>
            </request>,
            $tabs,
            if($tab eq 'search' and compare($search, '') gt 0) then 
                search:search($search, $resource-id, $first-record, 15)
            else if($tab eq 'glossary') then 
                glossary:glossary-terms($type, $lang, $search, true())
            else if($tab eq 'tm-search') then 
            (
                $etext-page,
                search:tm-search($search, $lang, $first-record, 10),
                source:etext-volumes($work, xs:integer($volume)),
                contributors:persons(false())
            )
            else if($tab eq 'translations') then 
                translations:translations($tei-content:published-status-ids, (), '', false())
            else
                $xml-section
        )
    )