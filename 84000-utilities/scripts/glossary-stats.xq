xquery version "3.1";
(:
Date             Glossary count       Glossaries to do    Completed
------------------------------------------------------------------------
2021-11-19       35,542               12,012              66.20%        
2021-11-26       36,058               12,483              65.38%        
2021-12-06       36,084               11,998              66.75%        
2021-12-10       36,112               11,601              67.87%     
2021-12-17       36,111               11,600              67.88%    
2021-12-31       36,170               11,084              69.36%        
2022-01-14       36,288                7,842              78.39%        
2022-01-28       36,311                7,423              79.56%        
2022-02-04       36,336                7,394              79.65%        
2022-02-11       40,482               11,509              71.57%        
:)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace glossary="http://read.84000.co/glossary" at "/db/apps/84000-reading-room/modules/glossary.xql";
import module namespace translation="http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "/db/apps/84000-reading-room/modules/entities.xql";

let $glossaries := collection($common:translations-path)//tei:TEI//tei:back//tei:gloss[@xml:id]
let $glossaries-count := count($glossaries)

let $glossaries-resolved := 
    for $gloss in $glossaries
    (: It must have an entity, but not a flagged one :)
    let $entity-not-flagged := $entities:entities//m:instance[@id eq $gloss/@xml:id][not(m:flag/@type = 'requires-attention')]
    where $entity-not-flagged
    return $gloss

let $glossaries-resolved-count := count($glossaries-resolved)

return concat(
    format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]'), '       ',
    format-number($glossaries-count, '#,##0'), '               ',
    format-number(($glossaries-count - $glossaries-resolved-count), '#,##0'), '              ',
    format-number((($glossaries-resolved-count div $glossaries-count) * 100), '0.00'), '%', '        '
)

