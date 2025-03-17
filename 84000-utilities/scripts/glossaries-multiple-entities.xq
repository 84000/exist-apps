declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

(: Looking glossaries that are listed twice :)
(:for $instance-id in $entities:entities//m:instance/@id
group by $instance-id
order by $instance-id
let $entities-with-instance := $entities:entities//m:instance[@id eq $instance-id]/parent::m:entity
let $count-matches := count($entities-with-instance)
where $count-matches gt 1
return $instance-id || ' (' || $count-matches || ' instances: ' || string-join($entities-with-instance/@xml:id, ', ') || ')':)

(: Looking for texts that reference the same entity in different glossary entries :)
for $entity in $entities:entities//m:entity
let $glossary-entries := $glossary:tei/id($entity/m:instance/@id)
let $teis := $glossary-entries/ancestor::tei:TEI
where not(count($glossary-entries) eq count($teis))
return 
    element { node-name($entity) } {
        $entity/@*,
        $entity/m:label,
        
        for $glossary-entry in $glossary-entries
        let $tei := $glossary-entry/ancestor::tei:TEI
        let $text-id := tei-content:id($tei)
        group by $text-id
        return 
            if(count($tei) gt 1) then
                let $text-glossary-ids := $tei[1]/id($glossary-entry/@xml:id)/@xml:id
                return
                element tei {
                    attribute id { $text-id },
                    for $instance in $entity/m:instance[@id = $text-glossary-ids]
                    return
                    element instance {
                        $instance/@*,
                        $glossary-entry/id($instance/@id)
                    }
                }
            else ()
    }
    