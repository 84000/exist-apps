xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translation-status="http://operations.84000.co/translation-status" at "../modules/translation-status.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

declare option exist:serialize "method=xml indent=no";

(: Request parameters :)
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $section-id := request:get-parameter('work', '')
let $work := request:get-parameter('work', 'all')
let $status := helper:get-status-parameter()
let $sort := request:get-parameter('sort', '')
let $pages-min := request:get-parameter('pages-min', '')
let $pages-max := request:get-parameter('pages-max', '')
let $filter := request:get-parameter('filter', '')
let $deduplicate := request:get-parameter('deduplicate', '')
let $toh-min := request:get-parameter('toh-min', '')
let $toh-max := request:get-parameter('toh-max', '')
let $target-date-type := request:get-parameter('target-date-type', 'target-date')
let $target-date-start := request:get-parameter('target-date-start', '')
let $target-date-end := request:get-parameter('target-date-end', '')

(: Override work with section-id :)
let $work := 
    if($section-id eq 'O1JC11494') then
        $source:kangyur-work
    else if($section-id eq 'O1JC7630') then
        $source:tengyur-work
    else
        $work

(: Is it a date search? :)
let $target-date-search := (($target-date-start gt '' or $target-date-end gt '') and $target-date-type = ('target-date'))

(: List of statuses :)
let $text-statuses-selected := tei-content:text-statuses-selected($status, 'translation')

(: If it's a date search then query translation-statuses based on the dates first :)
let $translation-statuses := 
    if($target-date-search) then
        translation-status:target-date-texts($target-date-start, $target-date-end)
    else ()

(: Get tei data based on date query result or input parameters :)
let $texts := 
    if($target-date-search) then 
        (: Ensure a status is selected on a date search :)
        if($translation-statuses) then
            translations:texts($status, $translation-statuses/@text-id, $sort, $deduplicate, '', false())
        else ()
    else
        translations:filtered-texts($work, $status, $sort, $pages-min, $pages-max, $filter, $toh-min, $toh-max, $deduplicate, $target-date-start, $target-date-end)

(: If not a date query then get the translation-statuses retrospectively :)
let $translation-status := 
    element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
        if(not($target-date-search)) then 
            translation-status:texts($texts/m:text/@id)
        else
            $translation-statuses
    }

let $texts := 
    if($sort eq 'due-date') then
        element { node-name($texts) } {
            $texts/@*,
            for $text in $texts/m:text
                let $target-date-next := $translation-status/m:text[@text-id eq $text/@id]/m:target-date[@next eq 'true'][1]
                order by ($target-date-next/@due-days ! xs:integer(.), 0)[1]
            return 
                $text
        }
    else
        $texts

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request') } {
        attribute work { $work },
        attribute status { string-join($status, ',') },
        attribute sort { $sort },
        attribute pages-min { $pages-min },
        attribute pages-max { $pages-max },
        attribute filter { $filter },
        attribute deduplicate { $deduplicate },
        attribute toh-min { $toh-min },
        attribute toh-max { $toh-max },
        attribute target-date-type { $target-date-type },
        attribute target-date-start { $target-date-start },
        attribute target-date-end { $target-date-end }
    }

let $xml-response :=
    common:response(
        'operations/search', 
        'operations', 
        (
            $request,
            $texts,
            $translation-status,
            $text-statuses-selected,
            $sponsorship:sponsorship-groups,
            if(common:user-in-group('utilities')) then
                element { QName('http://read.84000.co/ns/1.0', 'permission') } {
                    attribute group { 'utilities' }
                }
            else ()
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/search.xsl'))
    )
    
    (: return spreadsheet :)
    else if($resource-suffix eq 'xlsx') then (
        let $spreadsheet-data := translations:texts-spreadsheet($xml-response)
        (:return if(true()) then $spreadsheet-data else :)
        let $spreadsheet-zip := common:spreadsheet-zip($spreadsheet-data)
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || concat($spreadsheet-data/@key/string(), '.xlsx')),
            response:stream-binary($spreadsheet-zip, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        )
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )