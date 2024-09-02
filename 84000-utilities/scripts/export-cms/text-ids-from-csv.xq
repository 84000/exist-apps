declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";

declare variable $local:section-work-id := 'UT4CZ5369'(:'UT23703':);
declare variable $local:section-tei := collection($common:translations-path)//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = $local:section-work-id]:);

let $data := util:binary-doc('/db/apps/84000-data/uploads/webflow-text-item-ids.csv')
let $rows := util:binary-to-string($data) !  tokenize(., '&#10;')
let $csv-items :=
    for $row at $index in $rows[. gt '']
    let $columns := tokenize($row, ',')
    order by $columns[3] ! xs:integer(.), $columns[4], $columns[5][. gt ''] ! xs:integer(.)
    where $index gt 1
    return
        element item { 
            attribute id { string-join((concat($columns[3], $columns[4]), $columns[5][. gt '']), '-') },
            attribute webflow-id { $columns[2] }
        }
return
    for $source-key in $local:section-tei//tei:sourceDesc/tei:bibl[tei:location/@work = $local:section-work-id]/@key
    let $csv-item := $csv-items[@id = replace($source-key, '^toh', '')]
    return
        element item { 
            attribute id { $source-key },
            $csv-item/@webflow-id
        }
        