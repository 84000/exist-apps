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

(: 
    If there are no statuses selected, and it's a date range then pass all positive statuses
    Logically there will be no dates for zero statuses anyway
:)
let $text-statuses-selected := tei-content:text-statuses-selected($status)
let $status := 
    if(count($text-statuses-selected//m:status[@selected eq 'selected']) eq 0 and ($target-date-start gt '' or $target-date-end gt '')) then
        $text-statuses-selected//m:status[not(@group eq 'not-started')]/@status-id/string()
    else
        $status
(: Show these as selected as feedback to the user :)
let $text-statuses-selected := 
    if(count($text-statuses-selected//m:status[@selected eq 'selected']) eq 0 and count($status) gt 0) then
        tei-content:text-statuses-selected($status)
    else
        $text-statuses-selected

(: Get tei data :)
let $filtered-texts := translations:filtered-texts($work, $status, $sort, $pages-min, $pages-max, $sponsorship-group, $toh-min, $toh-max, $deduplicate)

(: Get operations data per tei :)
let $translation-statuses := translation-status:texts($filtered-texts/m:text/@id)

(: Sort / filter based on operations data :)
let $target-date-start-days := 
    if($target-date-start gt '') then
        days-from-duration(xs:date($target-date-start) - current-date())
    else
        if($target-date-type eq 'target-date') then
            min($translation-statuses/m:target-date[@next eq 'true']/@due-days ! xs:integer(.))
        else
            min($translation-statuses/m:status-update[@update eq 'translation-status'][@value eq parent::m:text/@translation-status]/@days-from-now ! xs:integer(.))

let $target-date-end-days := 
    if($target-date-end gt '') then
        days-from-duration(xs:date($target-date-end) - current-date())
    else
        if($target-date-type eq 'target-date') then
            max($translation-statuses/m:target-date[@next eq 'true']/@due-days ! xs:integer(.))
        else
            max($translation-statuses/m:status-update[@update eq 'translation-status'][@value eq parent::m:text/@translation-status]/@days-from-now ! xs:integer(.))

let $filtered-texts :=
    if($filtered-texts and ($sort eq 'due-date' or $target-date-start gt '' or $target-date-end gt '')) then
        element { node-name($filtered-texts) }{
            $filtered-texts/@*,
            for $filtered-text in $filtered-texts/m:text
                
                (: Get the related translation-statuses node :)
                let $translation-status := $translation-statuses[@text-id eq $filtered-text/@id]
                
                (: Derive the days to the next target :)
                let $target-date-next := $translation-status/m:target-date[@next eq 'true'][1]
                
                (: Derive the days from when the translation status was reached :)
                let $current-status := $translation-status/m:status-update[@update eq 'translation-status'][@value eq parent::m:text/@translation-status][1]
                
                let $current-status-days := 
                    if($current-status[@days-from-now]) then
                        xs:integer($current-status/@days-from-now)
                    else
                        (: If there is no date then consider it old :)
                        $target-date-start-days - 1
                
            where (
                    ( $target-date-type eq 'target-date' and $target-date-next[@due-days] )
                    and ( if($target-date-start gt '') then ( $target-date-next/@due-days ! xs:integer(.) ge $target-date-start-days ) else true() )
                    and ( if($target-date-end gt '') then ( $target-date-next/@due-days ! xs:integer(.) le $target-date-end-days ) else true() )
                )
                or (
                    ( $target-date-type eq 'status-date' )
                    and ( if($target-date-start gt '') then ( $current-status-days ge $target-date-start-days ) else true() )
                    and ( if($target-date-end gt '') then ( $current-status-days le $target-date-end-days ) else true() )
                )
            order by if($sort eq 'due-date' and $target-date-next[@due-days]) then $target-date-next/@due-days ! xs:integer(.) else 0
            return 
                element { node-name($filtered-text) }{
                    $filtered-text/@*,
                    attribute current-status-days { $current-status-days },
                    attribute target-date-start-days { $target-date-start-days },
                    attribute target-date-end-days { $target-date-end-days },
                    $filtered-text/node()
                }
        }
        
    else
        $filtered-texts

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
            $filtered-texts,
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
