xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/progress", 
    $common:app-id,
    (
        translations:summary(),
        element { QName('http://read.84000.co/ns/1.0', 'translations-published') } {
            translations:translation-status-texts($tei-content:published-statuses)
        },
        element { QName('http://read.84000.co/ns/1.0', 'translations-translated') } {
            translations:translation-status-texts($tei-content:text-statuses/m:status[@group = ('translated')]/@status-id)
        },
        element { QName('http://read.84000.co/ns/1.0', 'translations-in-translation') } {
            translations:translation-status-texts($tei-content:text-statuses/m:status[@group = ('in-translation')]/@status-id)
        }
    )
)
