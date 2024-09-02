declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace webflow="http://read.84000.co/webflow-api";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "/db/apps/84000-reading-room/modules/section.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace functx = "http://www.functx.com";

declare variable $local:filters-tei := tei-content:tei('ALL-TRANSLATED', 'section');
declare variable $webflow:conf := doc(concat($common:data-path, '/local/webflow-api.xml'));

let $filters :=
    for $filter in $local:filters-tei//tei:div[@type eq 'filter']
    let $webflow-item := $webflow:conf//webflow:item[@id eq $filter/@xml:id/string()]
    return
        element { QName('http://read.84000.co/ns/1.0', 'publicationsFilter') } {
            element xmlId { $filter/@xml:id/string() },
            element name { string-join($filter/tei:head/text()) ! normalize-space(.) ! concat('"', ., '"') },
            element description { string-join($filter/tei:p/text()) ! normalize-space(.) ! concat('"', ., '"') },
            element itemId { $webflow-item/@webflow-id/string() },
            element slug { $webflow-item/@slug/string() }
        }
        
return (

    (:$filters:)
    
    string-join($filters[1]/* ! local-name(.), ','),
    
    for $filter in $filters
    return
        string-join($filter/*/string(), ',')

)