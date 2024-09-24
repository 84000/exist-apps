declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace webflow = "http://read.84000.co/webflow-api";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace section = "http://read.84000.co/section" at "/db/apps/84000-reading-room/modules/section.xql";

declare variable $local:section-work-id := 'UT4CZ5369'(:'UT23703':);
declare variable $local:section-tei := collection($common:translations-path)//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = $local:section-work-id]:);

let $webflow-api-config := doc('/db/apps/84000-data/local/webflow-api.xml')
let $webflow-items := $webflow-api-config//webflow:item
let $webflow-text-items := $webflow-api-config//webflow:collection[@id eq "texts"]/webflow:item[@webflow-id gt '']
let $source-keys := $local:section-tei//tei:sourceDesc/tei:bibl/@key

(:let $data := util:binary-doc('/db/apps/84000-data/uploads/webflow-text-item-ids2.csv')
let $rows := util:binary-to-string($data) !  tokenize(., '&#10;')
let $csv-items :=
    for $row at $index in $rows[. gt '']
    let $columns := tokenize($row, ',')
    order by $columns[4] ! xs:integer(.), $columns[5], $columns[6][. gt ''] ! xs:integer(.)
    where $index gt 1
    return
        element item { 
            (\:attribute id { string-join((concat($columns[4], $columns[5]), $columns[6][. gt '']), '-') },:\)
            attribute id { $columns[3] },
            attribute webflow-id { $columns[2] }
        }:)
(:return :)
    (:$local:section-tei//tei:sourceDesc/tei:bibl[@key][not(@key = $webflow-text-items/@id)]:)
    (:$webflow-api-config//webflow:collection[@id eq "texts"]/webflow:item[not(@id = $source-keys)]:)
    (:for $source-key in $source-keys
    let $csv-item := $csv-items[@id = replace($source-key, '^toh', '')]
    return
        element item { 
            attribute id { $source-key },
            $csv-item/@webflow-id
        }:)
        
for $source-key in $source-keys[not(. = $webflow-text-items/@id)]
let $tei := tei-content:tei($source-key, 'translation')
return
    element item { 
        attribute id { $source-key },
        attribute slug { translation:filename($tei, $source-key) },
        element title { translation:title($tei, $source-key) }(:,
        element title { section:ancestors($tei, 1) }:)
    }