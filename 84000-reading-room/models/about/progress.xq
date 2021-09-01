xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

let $summary-kangyur := translations:summary($source:ekangyur-work)
let $summary-tengyur := translations:summary($source:etengyur-work)
let $translations-published := translations:translation-status-texts($tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('published')]/@status-id)
let $translations-translated := translations:translation-status-texts($tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('translated')]/@status-id)
let $translations-in-translation := translations:translation-status-texts($tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('in-translation')]/@status-id)

return
common:response(
    "about/progress", 
    $common:app-id,
    (
        <request xmlns="http://read.84000.co/ns/1.0" sharing-url="/about/progress.html"/>,
        <replace-text xmlns="http://read.84000.co/ns/1.0">
            <value key="#commsSiteUrl">{ $common:environment/m:url[@id eq 'communications-site'][1]/text() }</value>
            <value key="#readingRoomSiteUrl">{ $common:environment/m:url[@id eq 'reading-room'][1]/text() }</value>
            <value key="#feSiteUrl">{ $common:environment/m:url[@id eq 'front-end'][1]/text() }</value>
        </replace-text>,
        $summary-kangyur,
        $summary-tengyur,
        element { QName('http://read.84000.co/ns/1.0', 'translations-published') } {
            $translations-published
        },
        element { QName('http://read.84000.co/ns/1.0', 'translations-translated') } {
            $translations-translated
        },
        element { QName('http://read.84000.co/ns/1.0', 'translations-in-translation') } {
            $translations-in-translation
        }
    )
)
