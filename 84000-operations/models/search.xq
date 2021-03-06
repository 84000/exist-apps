xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../modules/translation-status.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)
let $work := request:get-parameter('work', 'UT4CZ5369')
let $status := local:get-status-parameter()
let $sort := request:get-parameter('sort', '')
let $pages-min := request:get-parameter('pages-min', '')
let $pages-max := request:get-parameter('pages-max', '')
let $sponsorship-group := request:get-parameter('sponsorship-group', '')
let $deduplicate := request:get-parameter('deduplicate', '')
let $toh-min := request:get-parameter('toh-min', '')
let $toh-max := request:get-parameter('toh-max', '')
let $target-date-type := request:get-parameter('target-date-type', 'target-date')
let $target-date-start := request:get-parameter('target-date-start', '')
let $target-date-end := request:get-parameter('target-date-end', '')

(: Is it a date search? :)
let $target-date-search := (($target-date-start gt '' or $target-date-end gt '') and $target-date-type = ('target-date'))

(: List of statuses :)
let $text-statuses-selected := tei-content:text-statuses-selected($status)

(: If it's a date search then query translation-statuses based on the dates first :)
let $translation-statuses := 
    if($target-date-search) then
        translation-status:target-date-texts($target-date-start, $target-date-end)
    else
        ()

(: Get tei data based on date query result or input parameters :)
let $texts := 
    if($target-date-search) then 
        (: Make sure zero results in first search is returned :)
        if($translation-statuses) then
            translations:texts($status, $translation-statuses/@text-id, $sort, $deduplicate, '', false())
        else
            ()
    else
        translations:filtered-texts($work, $status, $sort, $pages-min, $pages-max, $sponsorship-group, $toh-min, $toh-max, $deduplicate, $target-date-start, $target-date-end)

(: If not a date query then get the translation-statuses retrospectively :)
let $translation-statuses := 
    if($target-date-search) then 
        $translation-statuses
    else
        translation-status:texts($texts/m:text/@id)

let $texts := 
    if($sort eq 'due-date') then
        
        element { node-name($texts) } {
            $texts/@*,
            for $text in $texts/m:text
                let $target-date-next := $translation-statuses[@text-id eq $text/@id]/m:target-date[@next eq 'true'][1]
                order by ($target-date-next/@due-days ! xs:integer(.), 0)[1]
            return 
                $text
        }
        
    else
        $texts

return
    common:response(
        'operations/search', 
        'operations', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                work="{ $work }" 
                status="{ string-join($status, ',') }"
                sort="{ $sort }"
                pages-min="{ $pages-min }"
                pages-max="{ $pages-max }"
                sponsorship-group="{ $sponsorship-group }"
                deduplicate="{ $deduplicate }"
                toh-min="{ $toh-min }"
                toh-max="{ $toh-max }"
                target-date-type="{ $target-date-type }"
                target-date-start="{ $target-date-start }"
                target-date-end="{ $target-date-end }"/>
            ,
            $texts,
            element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
                $translation-statuses
            },
            $text-statuses-selected,
            $sponsorship:sponsorship-groups,
            if(common:user-in-group('utilities')) then
                element { QName('http://read.84000.co/ns/1.0', 'permission') } {
                    attribute group { 'utilities' }
                }
            else
                ()
        )
    )
