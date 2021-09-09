declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace update-entity = "http://operations.84000.co/update-entity" at "../../84000-operations/modules/update-entity.xql";

let $skip-texts := ('UT22084-000-000', 'UT22084-091-071', 'UT22084-045-001')

let $texts-without-entities :=
    for $tei in $glossary:tei
    let $glossary := $tei//tei:back//tei:gloss
    let $glosses-with-entities := $glossary/id($entities:entities//m:entity/m:instance/@id)
    let $text-id := tei-content:id($tei)
    where $glossary and not($glosses-with-entities) and not($text-id = $skip-texts)
    return
        $text-id

where count($texts-without-entities) gt 0
(:return if(true()) then $texts-without-entities else:)

(: Just do one at a time :)
let $next-text-id := $texts-without-entities[1]
return (
    count($texts-without-entities),
    $next-text-id,
    $texts-without-entities[2],
    update-entity:merge-glossary($next-text-id, false())
)