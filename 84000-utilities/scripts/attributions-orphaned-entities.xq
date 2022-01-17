xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

declare variable $teis := collection($common:translations-path)//tei:TEI;

declare function local:texts() {
    (: Loop all attribution @refs :)
    for $tei in $teis
    let $text-id := tei-content:id($tei)
    order by $text-id
    
    let $attribution-issues :=
        for $attribution in $tei//tei:sourceDesc/tei:bibl/tei:author[@ref] | $tei//tei:sourceDesc/tei:bibl/tei:editor[@ref]
        (: Check the entity exists :)
        let $entity-id := replace($attribution/@ref, '^eft:', '')
        where not($entities:entities//m:entity/id($entity-id))
        return $attribution
    
    where $attribution-issues
    return 
        element {'text'} {
            attribute id { $text-id },
            $attribution-issues
        }
};

declare function local:entities() {
    (: Loop all attribution @refs :)
    for $attribution in $teis//tei:sourceDesc/tei:bibl/tei:author[@ref] | $teis//tei:sourceDesc/tei:bibl/tei:editor[@ref]
    let $entity-id := replace($attribution/@ref, '^eft:', '')
    group by $entity-id
    (: Check the entity exists :)
    where not($entities:entities//m:entity/id($entity-id))
    return 
    element { 'entity' } {
        attribute id { $entity-id },
        for $single in $attribution
        return
            element { 'attribution' } {
                attribute text-id {
                    tei-content:id($single/ancestor::tei:TEI[1])
                },
                $single
            }
    }
};

(:local:texts(),:)
local:entities()

