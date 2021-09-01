xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tei := collection($common:translations-path);

for $fileDesc in $local:tei//tei:TEI/tei:teiHeader/tei:fileDesc[tei:publicationStmt/@status = $translation:published-status-ids]
    let $year := format-date($fileDesc/tei:publicationStmt/tei:date, '[Y]')
    group by $year
    let $count-pages := sum($fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! xs:integer(.))
    order by $year
return (
    concat($year, ' : ', count($fileDesc), ' publications, ', $count-pages, ' pages'),
    $fileDesc ! concat(' - ', normalize-space(tei:titleStmt/tei:title[@type = "mainTitle"][@xml:lang = "en"]/text()), ' (', sum(tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! xs:integer(.)), ')')
)
    