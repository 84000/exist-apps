declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

for $tei in $glossary:tei
let $text-id := tei-content:id($tei)
where not($text-id = ('UT22084-000-000', ''))
return
    for $gloss in $tei//tei:back//tei:gloss[tei:term[@xml:lang eq 'Sa-Ltn'][@type eq 'attestedSource']]
    group by $text-id
    order by $text-id
    return element translation {
        attribute text-id { $text-id },
        attribute toh { string-join($tei//tei:sourceDesc/tei:bibl/tei:ref, ' ') },
        $gloss
    }