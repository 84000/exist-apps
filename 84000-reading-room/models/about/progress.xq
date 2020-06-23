xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

let $comms-url := $common:environment/m:url[@id eq 'communications-site'][1]/text()

return
    common:response(
        "about/progress", 
        $common:app-id,
        (
            <request xmlns="http://read.84000.co/ns/1.0" sharing-url="/about/progress.html"/>,
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#commsSiteUrl">{ $comms-url }</value>
            </replace-text>,
            translations:summary($source:ekangyur-work),
            translations:summary($source:etengyur-work),
            element { QName('http://read.84000.co/ns/1.0', 'translations-published') } {
                translations:translation-status-texts($tei-content:text-statuses/m:status[@group = ('published')]/@status-id)
            },
            element { QName('http://read.84000.co/ns/1.0', 'translations-translated') } {
                translations:translation-status-texts($tei-content:text-statuses/m:status[@group = ('translated')]/@status-id)
            },
            element { QName('http://read.84000.co/ns/1.0', 'translations-in-translation') } {
                translations:translation-status-texts($tei-content:text-statuses/m:status[@group = ('in-translation')]/@status-id)
            }
        )
    )
