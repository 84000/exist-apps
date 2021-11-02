xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace source="http://read.84000.co/source" at "../../modules/source.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace entities="http://read.84000.co/entities" at "../../modules/entities.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'about/progress' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

let $cache-timestamp := max(collection($common:tei-path)//tei:TEI//tei:notesStmt/tei:note[@type eq "lastUpdated"]/@date-time ! xs:dateTime(.))
let $cached := common:cache-get($request, $cache-timestamp)
return if($cached) then $cached else

let $summary-kangyur := translations:summary($source:ekangyur-work)
let $summary-tengyur := translations:summary($source:etengyur-work)
let $translations-published := translations:translation-status-texts($tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('published')]/@status-id)
let $translations-translated := translations:translation-status-texts($tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('translated')]/@status-id)
let $translations-in-translation := translations:translation-status-texts($tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('in-translation')]/@status-id)

let $entities := 
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        let $attribution-entity-ids := ($translations-published//m:attribution/@ref, $translations-translated//m:attribution/@ref, $translations-in-translation//m:attribution/@ref) ! replace(., '^eft:', '')
        return 
            $entities:entities/m:entity/id($attribution-entity-ids) ! entities:entity(., true(), true(), false())
    }

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id,
        (
            $request,
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
            },
            $entities
        )
    )

return 
    
    (: return html data :)
    if($request/@resource-suffix = ('html')) then (
        common:html($xml-response, concat($common:app-path, "/views/html/about/progress.xsl"), $cache-timestamp)
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
    
