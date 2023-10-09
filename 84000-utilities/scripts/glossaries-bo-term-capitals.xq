declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace functx="http://www.functx.com";

(:
for $bo-term in $glossary:tei//tei:back//tei:gloss/tei:term[@xml:lang eq 'bo']
let $bo-term-wylie := common:wylie-from-bo($bo-term) ! replace(., '/$', '')
where matches($bo-term-wylie, '[A-Z]')
let $gloss := $bo-term/parent::tei:gloss
let $wy-term := string-join($gloss/tei:term[@xml:lang eq 'Bo-Ltn'][@n eq $bo-term/@n]/text()) ! normalize-space(.)
where not(matches($wy-term, functx:escape-for-regex($bo-term-wylie)))
return
    element mismatch {
        attribute bo-term { $bo-term },
        attribute bo-term-wylie { $bo-term-wylie },
        attribute wy-term { $wy-term },
        $gloss
    }
:)

(:
let $requests := collection('/db/apps/84000-data/uploads/glossaries-bo-term-capitals')

(:return if (true()) then count($requests//m:parameters) else:)

for $parameters in $requests//m:parameters[m:parameter[@name eq 'form-action'][text() eq 'update-glossary']]

return
    $parameters
:)

let $archive-tei := collection('/db/apps/84000-data/archived/tei/2.19.0/translations')
(:return if (true()) then count($archive-tei//tei:back//tei:gloss/tei:term[@xml:lang eq 'Bo-Ltn'][matches(text(), '[A-Z]')]) else:)

for $wy-term-archived in $archive-tei//tei:back//tei:gloss/tei:term[@xml:lang eq 'Bo-Ltn'][matches(text(), '[A-Z]')]
let $gloss-archived := $wy-term-archived/parent::tei:gloss
let $gloss-current := $glossary:tei//tei:back//tei:gloss/id($gloss-archived/@xml:id)
where $gloss-current[not(tei:term[@xml:lang eq 'Bo-Ltn'][matches(normalize-space(text()), functx:escape-for-regex(normalize-space($wy-term-archived)))])]
return 
    element mismatch {
        attribute wy-term-archived { normalize-space($wy-term-archived) },
        attribute bo-term-regenerated { common:bo-term(normalize-space($wy-term-archived)) },
        attribute wy-term-archived-replaces-n { $gloss-current/tei:term[@xml:lang eq 'Bo-Ltn'][matches(normalize-space(text()), functx:escape-for-regex(normalize-space($wy-term-archived)), 'i')]/@n },
        $gloss-current
    }