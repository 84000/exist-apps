xquery version "3.1" encoding "UTF-8";
(:
    Returns the cumulative glossary xml
    -------------------------------------------------------------
:)
module namespace entities="http://read.84000.co/entities";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

declare variable $entities:entities := doc(concat($common:data-path, '/operations/entities.xml'));
declare variable $entities:types := ('eft-glossary-term', 'eft-glossary-person', 'eft-glossary-place', 'eft-glossary-text');
declare variable $entities:instance-types := ('glossary-item');

declare function entities:entities($instance-ids as xs:string*) as element() {
    
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        if(count($instance-ids) gt 0) then
            $entities:entities/m:entities/m:entity[m:instance[@id = $instance-ids]]
        else
            ()
    }
    
};

declare function entities:update-entity($entity-id as xs:string?) as element()? {
    
    let $parent := $entities:entities/m:entities
    
    let $existing-entity := $parent/m:entity[@xml:id eq $entity-id]
    
    let $entity-id :=
        if(not($existing-entity)) then
            entities:next-id()
        else
            $entity-id
    
    let $label-lang := common:valid-lang(request:get-parameter('entity-label-lang', ''))
    let $glossary-id := request:get-parameter('glossary-id', '')
    let $instance-remove := request:get-parameter('instance-remove', '')
    
    let $new-value := 
        element { QName('http://read.84000.co/ns/1.0', 'entity') } {
            
            attribute xml:id { $entity-id },
            
            common:ws(2),
            
            (: A label for the entity :)
            element label {
                if($label-lang) then
                    attribute xml:lang { $label-lang }
                else ()
                ,
                text { request:get-parameter('entity-label', '') }
            },
            
            (: The type(s) of entity :)
            for $entity-type in request:get-parameter('entity-type[]', '')[. = $entities:types]
            return (
                common:ws(2),
                element type {
                    attribute type { $entity-type }
                }
            )
            ,
            
            (: Instance(s) of this entity :)
            if($instance-remove gt '') then
                
                (: remove an instance :)
                for $instance in $existing-entity/m:instance[not(@id = $instance-remove)]
                return (
                    common:ws(2),
                    $instance
                )
                
            else if($glossary-id gt '') then (
                
                (: add an instance :)
                for $instance in $existing-entity/m:instance[not(@id = $glossary-id)]
                return (
                    common:ws(2),
                    $instance
                )
                ,
                common:ws(2),
                element instance {
                    attribute id { $glossary-id },
                    attribute type { 'glossary-item' }
                }
                
            )
            else
                
                (: just copy instances :)
                for $instance in $existing-entity/m:instance
                return (
                    common:ws(2),
                    $instance
                )
                
            ,
            
            (: Copy exclusions :)
            for $exclude in $existing-entity/m:exclude
            return (
                common:ws(2),
                $exclude
            ),
            
            common:ws(1)
        }
    
    let $insert-following := $existing-entity/preceding-sibling::m:entity[1]
    
    where $parent and ($existing-entity or $new-value)
    return
        (: Do the update :)
        common:update('entity', $existing-entity, $new-value, $parent, $insert-following)
        
        (:element update-debug {
            attribute entity-id { $entity-id },
            element existing-value { $existing-entity }, 
            element new-value { $new-value }(\:, 
            element parent { $parent }, 
            element insert-following { $insert-following }:\)
        }:)
    
};

declare function entities:next-id() as xs:string {
    
    let $max-id := max($entities:entities//@xml:id ! substring-after(., 'entity-') ! common:integer(.))
    return
        string-join(('entity', xs:string(sum(($max-id, 1)))), '-')
    
};

declare function entities:match($entity-id as xs:string, $target-entity-id as xs:string) as element()* {
    
    let $parent := $entities:entities/m:entities
    let $entity := $parent/m:entity[@xml:id eq $entity-id]
    let $target-entity := $parent/m:entity[@xml:id eq $target-entity-id]
    
    let $target-entity-new := 
        element { node-name($target-entity) } {
            $target-entity/@*,
            $target-entity/node(),
            for $instance in $entity/m:instance
            return (
                common:ws(2),
                element { node-name($instance) } {
                    $instance/@*,
                    $instance/node()
                }
            )
        }
    
    return (
        
        (: Update target :)
        common:update('entity-match', $target-entity, $target-entity-new, $parent, ()),
        
        (: Delete source :)
        common:update('entity-remove', $entity, (), $parent, ())
        
        (:element update-debug {
            attribute entity-id { $entity-id },
            element existing-value { $target-entity }, 
            element new-value { $target-entity-new }(\:, 
            element parent { $parent }, 
            element insert-following { () }:\)
        }:)
    )
};

declare function entities:exclude($entity-ids as xs:string*) as element()* {
    
    for $target-entity-id in $entity-ids
        let $target-entity := $entities:entities/m:entities/m:entity[@xml:id eq  $target-entity-id]
    where $target-entity
    return
        for $exclude-entity-id in $entity-ids[not(. =  $target-entity-id)]
            let $existing-value := $target-entity/m:exclude[@id eq $exclude-entity-id]
            let $new-value :=
                element { QName('http://read.84000.co/ns/1.0', 'exclude') } {
                    attribute id { $exclude-entity-id }
                }
        where not($existing-value)
        return
            common:update('entity-exclude', $existing-value, $new-value, $target-entity, ())
};

declare function entities:match-instance($entity-id as xs:string, $instance-id as xs:string, $instance-type as xs:string) as element()* {
    
    let $entity := $entities:entities/m:entities/m:entity[@xml:id eq $entity-id][1]
    let $existing-instance := $entity/m:instance[@id eq  $instance-id][1]
    let $new-instance := 
        element { QName('http://read.84000.co/ns/1.0', 'instance') } {
            attribute id { $instance-id },
            attribute type { $instance-type }
        }
    return
        common:update('entity-match-instance', $existing-instance, $new-instance, $entity, ())
    
};

declare function entities:remove-instance($instance-id as xs:string) as element()* {

    let $existing-value := $entities:entities/m:entities/m:entity/m:instance[@id eq  $instance-id][1]
    where $existing-value
    return
        common:update('entity-exclude', $existing-value, (), $existing-value/parent::m:entity, ())
        
};


