declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../../84000-operations/modules/update-entity.xql";

declare variable $operations-collection := '/db/apps/84000-data/operations';
declare variable $filename-new := 'entities-2-9-0.xml';
declare variable $teis := collection($common:translations-path)//tei:TEI;

declare variable $corrections :=
    <corrections xmlns="http://read.84000.co/ns/1.0">
        <merge source="entity-18248" target="entity-7072"/>
        <merge source="entity-18455" target="entity-3512"/>
        <merge source="entity-17465" target="entity-29506"/>
        <merge source="entity-17467" target="entity-31953"/>
        <merge source="entity-17460" target="entity-28840"/>
        <merge source="entity-18133" target="entity-10129"/>
        <merge source="entity-18368" target="entity-28464"/>
        <merge source="entity-17569" target="entity-8724"/>
        <merge source="entity-18401" target="entity-29526"/>
        <merge source="entity-17558" target="entity-8406"/>
        <merge source="entity-18618" target="entity-29035"/>
    </corrections>;

declare function local:correct-orphaned-attributions() {

    (# exist:batch-transaction #) {
    
        (: Loop all attribution @refs :)
        for $tei in $teis
        let $text-id := tei-content:id($tei)
        order by $text-id
        (:where $text-id eq 'UT23703-001-002':)
        
        for $attribution in $tei//tei:sourceDesc/tei:bibl/tei:author[@ref] | $tei//tei:sourceDesc/tei:bibl/tei:editor[@ref]
        (: Check the entity exists :)
        let $entity-id := replace($attribution/@ref, '^eft:', '')
        let $merge := $corrections/m:merge[@source eq $entity-id]
        where not($entities:entities//m:entity/id($entity-id))
        return (
            $text-id,
            if($merge) then (
                (: Merge to target :)
                $merge,
                update replace $attribution/@ref with concat('eft:', $merge/@target)
            )
            else
                (: Flag for merge target :)
                $attribution
        )
        
    }
};

declare function local:migrate-entities() {
    
    let $entities-migrated := 
        element { QName('http://read.84000.co/ns/1.0', 'entities') } {
            
            for $entity at $index in $entities:entities//m:entity
            
            (:where $index le 5:)
            
            return (
                common:ws(1),
                element { node-name($entity) } {
                    $entity/@*,
                    for $element in $entity/*
                    let $element-name := local-name($element)
                    order by if($element-name eq 'label') then 1 else if($element-name eq 'type') then 2 else if($element-name eq 'instance') then 3 else 4
                    return 
                        if (local-name($element) eq 'flag') then (
                            (: Drop entity/flag :)
                        )
                        else if (local-name($element) eq 'instance') then (
                            (: Add entity/instance/flag :) 
                            common:ws(2),
                            element { node-name($element) } {
                                $element/@*,
                                $element/node(),
                                for $flag in $entity/m:flag
                                let $flag-type := $flag/@type
                                group by $flag-type
                                return (
                                   common:ws(3),
                                   $flag[1],
                                   common:ws(2)
                                )
                            }
                        )
                        else (
                            (: Copy others :)
                            common:ws(2),
                            $element
                        ),
                    common:ws(1)
                }
            ),
            
            (:for $entity in local:orphaned-attribution-entities()
            return (
                common:ws(1),
                $entity
            ),:)
            
            $common:chr-nl
            
        }
    
    return (
        (:$entities-migrated:)
        xmldb:store(
            $operations-collection,
            $filename-new,
            $entities-migrated
        ),
        (: Set permissions :)
        (
            sm:chown(xs:anyURI(concat($operations-collection, '/', $filename-new)), 'admin'),
            sm:chgrp(xs:anyURI(concat($operations-collection, '/', $filename-new)), 'operations'),
            sm:chmod(xs:anyURI(concat($operations-collection, '/', $filename-new)), 'rw-rw-r--')
        )
        
    )
};

declare function local:orphaned-attribution-entities() {

    (: Loop all attribution @refs :)
    for $attribution in $teis//tei:sourceDesc/tei:bibl/tei:author[@ref] | $teis//tei:sourceDesc/tei:bibl/tei:editor[@ref]
    let $entity-id := replace($attribution/@ref, '^eft:', '')
    group by $entity-id
    (: Check the entity exists :)
    where not($entities:entities//m:entity/id($entity-id))
    return 
        element { QName('http://read.84000.co/ns/1.0', 'entity') } {
            attribute xml:id { $entity-id },
            common:ws(2),
            element type {
                attribute type { 'eft-person' }
            },
            for $single in $attribution
            let $attribution-text := $single/data()
            group by $attribution-text
            return (
                common:ws(2),
                element label {
                    $single[1]/@xml:lang,
                    $attribution-text
                }
           ),
           common:ws(2),
           element content {
                attribute type { 'glossary-notes' },
                attribute user { common:user-name() },
                attribute timestamp { current-dateTime() },
                text { 'Auto-generated from orphaned attribution' }
            },
            common:ws(1)
        }
    
};

local:correct-orphaned-attributions()
(:local:migrate-entities():)


