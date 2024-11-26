declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

for $entity in $entities:entities//m:entity[not(count(distinct-values(m:relation/@id)) eq count(m:relation))]
let $entity-depuped-relations :=
    element { node-name( $entity ) } {
    
        $entity/@*,
        
        for $element in $entity/*[not(local-name(.) eq 'relation')]
        return
            ( common:ws(2), $element )
        ,
        
        for $relation in $entity/m:relation
        let $relation-id := $relation/@id
        let $relation-predicate := $relation/@predicate
        group by $relation-id, $relation-predicate 
        return
            ( common:ws(2), $relation[1] )
        ,
        common:ws(1)
    }
return (
    $entity-depuped-relations,
    update replace $entity with $entity-depuped-relations
)