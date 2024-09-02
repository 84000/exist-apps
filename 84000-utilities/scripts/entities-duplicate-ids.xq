declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

(
    for $entity in $entities:entities//m:entity
    let $entity-id := $entity/@xml:id
    group by $entity-id
    order by $entity-id
    where count($entity) gt 1
    return $entity-id || ' (' || count($entity) || ')'
   ,
   
   for $instance in $entities:entities//m:instance
   let $instance-id := $instance/@id
   group by $instance-id
   order by $instance-id
   where count($instance) gt 1
   return $instance-id || ' (' || count($instance) || ')'

)
