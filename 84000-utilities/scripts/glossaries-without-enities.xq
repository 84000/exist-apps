declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

for $tei in $glossary:tei
let $glossary := $tei//tei:back//tei:gloss
let $glosses-with-entities := $glossary/id($entities:entities//m:entity/m:instance/@id)
let $glosses-without-entities := $glossary except $glosses-with-entities
let $text-id := tei-content:id($tei)
where $glossary and $glosses-without-entities
return
    concat('(', count($glosses-without-entities), ') ', 'https://projects.84000-translate.org/edit-glossary.html?resource-id=', $text-id, '&amp;filter=missing-entities')
