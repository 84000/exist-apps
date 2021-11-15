declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

for $instance-id in $entities:entities//m:instance/@id
group by $instance-id
let $entities-with-instance := $entities:entities//m:instance[@id eq $instance-id]/parent::m:entity
let $count-matches := count($entities-with-instance)
where $count-matches gt 1
return $instance-id || ' (' || $count-matches || ' instances: ' || string-join($entities-with-instance/@xml:id, ', ') || ')'

