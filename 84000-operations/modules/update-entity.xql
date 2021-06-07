module namespace update-entity = "http://operations.84000.co/update-entity";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace functx="http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: Update an entity posted from glossary form :)
declare function update-entity:glossary-item($entity-id as xs:string?) as element()? {
    
    let $parent := $entities:entities
    
    let $existing-entity := $parent/m:entity[@xml:id eq $entity-id]
    
    let $entity-id :=
        if(not($existing-entity)) then
            entities:next-id()
        else
            $entity-id
    
    let $entity-labels := common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'entity-label-text-')], '-')
    let $glossary-id := request:get-parameter('glossary-id', '')
    let $instance-remove := request:get-parameter('instance-remove', '')
    
    where $entity-id gt '' and count($entity-labels[not(. eq '')]) gt 0
    return
        
        let $new-value := 
            element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                
                attribute xml:id { $entity-id },
                
                (: Labels for the entity :)
                for $label-param in $entity-labels
                let $label-index := substring-after($label-param, 'entity-label-text-')
                let $label-text := request:get-parameter($label-param, '')
                let $label-lang := common:valid-lang(request:get-parameter(concat('entity-label-lang-', $label-index), ''))
                where $label-text gt ''
                return(
                    common:ws(2),
                    element label {
                    
                        (: Lang :)
                        if($label-lang) then
                            attribute xml:lang { $label-lang }
                        else (),
                        
                        (: Text - if Sanskrit parse hyphens :)
                        text {
                            if ($label-lang eq 'Sa-Ltn') then
                                replace($label-text, '\-', '­')
                            else
                                $label-text
                        }
                        
                    }
                ),
                
                (: The type(s) of entity :)
                for $entity-type in request:get-parameter('entity-type[]', '')[. = $entities:types]
                return (
                    common:ws(2),
                    element type {
                        attribute type { $entity-type }
                    }
                ),
                (: Other types :)
                for $entity-type in $existing-entity/m:type[not(@type = ('eft-glossary-term', 'eft-glossary-person', 'eft-glossary-place', 'eft-glossary-text'))]
                return (
                    common:ws(2),
                    $entity-type
                ),
                
                (: Instance(s) of this entity :)
                (: Copy instances except the ones to be removed or added :)
                for $instance in $existing-entity/m:instance[not(@id/string() = ($instance-remove, $glossary-id)[not(. eq '')])]
                return (
                    common:ws(2),
                    $instance
                ),
                (: Add an instance for glossary-id :)
                if($glossary-id gt '' and not($instance-remove eq $glossary-id)) then (
                    
                    common:ws(2),
                    element instance {
                        attribute id { $glossary-id },
                        attribute type { 'glossary-item' }
                    }
                    
                )
                else ()
                ,
                
                (: Copy relations :)
                for $relation in $existing-entity/m:relation
                return (
                    common:ws(2),
                    $relation
                ),
                
                (: Other content :)
                for $content in $existing-entity/m:content[not(@type = ('glossary-definition', 'glossary-notes'))]
                return (
                    common:ws(2),
                    $content
                ),
                
                (: Definition content :)
                for $definition-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'entity-definition-')], '-')
                let $entity-definition := request:get-parameter($definition-param, '')
                where $entity-definition gt '' 
                return (
                    common:ws(2),
                    element content {
                        attribute type { 'glossary-definition' },
                        let $entity-definition-markup := common:markup($entity-definition, 'http://www.tei-c.org/ns/1.0')
                        return
                            if($entity-definition-markup) then 
                                $entity-definition-markup 
                            else 
                                $entity-definition 
                    }
                ),
                
                (: Notes content :)
                for $notes-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'entity-note-')], '-')
                let $entity-notes := request:get-parameter($notes-param, '')
                where $entity-notes gt '' 
                return (
                    common:ws(2),
                    element content {
                        attribute type { 'glossary-notes' },
                        text { $entity-notes }
                    }
                ),
                
                common:ws(1)
            }
        
        where $parent and ($existing-entity or $new-value)
        return
            (: Do the update :)
            common:update('entity', $existing-entity, $new-value, $parent, ())
            
            (:element update-debug {
                attribute entity-id { $entity-id },
                element existing-value { $existing-entity }, 
                element new-value { $new-value }(\:, 
                element parent { $parent }, 
                element insert-following { $insert-following }:\)
            }:)
    
};

(: Resolve the relationship between entities :)
declare function update-entity:resolve($entity-id as xs:string, $target-entity-id as xs:string, $predicate as xs:string) as element()* {
    
    (: Merge into same entity :)
    if($predicate eq 'sameAs')then
        update-entity:merge($entity-id, $target-entity-id)
    
    (: Set the predicate for the relationship :)
    else if($entities:predicates//m:predicate[@xml:id = $predicate]) then
    
        let $parent := $entities:entities
        let $entity := $parent/id($entity-id)[self::m:entity]
        let $target-entity := $parent/id($target-entity-id)[self::m:entity]
        
        let $entity-updated := 
            element { node-name($entity) } {
                $entity/@*,
                for $entity-node in $entity/*
                return (
                    common:ws(2),
                    $entity-node
                ),
                element { QName('http://read.84000.co/ns/1.0', 'relation') } {
                    attribute predicate { $predicate },
                    attribute id { $target-entity-id },
                    $target-entity/m:label[1]
                }
            }
        
        where $entity and $target-entity
        return
            (: Update target :)
            common:update('entity-merge', $entity, $entity-updated, (), ())
    
    else ()
    
};

(: Merge entities together :)
declare function update-entity:merge($entity-id as xs:string, $target-entity-id as xs:string) as element()* {
    
    let $parent := $entities:entities
    let $entity := $parent/id($entity-id)[self::m:entity]
    let $target-entity := $parent/id($target-entity-id)[self::m:entity]
    
    let $target-entity-new := 
        element { node-name($target-entity) } {
            $target-entity/@*,
            for $entity-node in functx:distinct-deep(($entity/* | $target-entity/*))
            return (
                common:ws(2),
                $entity-node
            )
        }
    
    where $entity and $target-entity
    return (
        
        (: Update target :)
        common:update('entity-merge', $target-entity, $target-entity-new, $parent, ()),
        
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

(:declare function update-entity:exclude($entity-ids as xs:string*) as element()* {

    let $exclusions :=
        for $entity-id in $entity-ids
        let $entity := $entities:entities/id($entity-id)[self::m:entity]
        return
            element { QName('http://read.84000.co/ns/1.0', 'exclude') } {
                attribute id { $entity-id },
                $entity/m:label[1]
            }
    
    for $entity-id in $entity-ids
    let $existing-entity := $entities:entities/id($entity-id)[self::m:entity]
    where $existing-entity
    return
        let $new-entity := 
            element { node-name($existing-entity) } {
                $existing-entity/@*,
                for $entity-node in $existing-entity/*
                return (
                    common:ws(2),
                    $entity-node
                ),
                (\: Add exclusions that are not this id and not already there :\)
                for $exclude in $exclusions[not(@id/string() = ($existing-entity/@xml:id/string(), $existing-entity/m:exclude/@id/string()))]
                return (
                    common:ws(2),
                    $exclude
                )
            }
        return
            common:update('entity-exclude', $existing-entity, $new-entity, (), ())
};:)

declare function update-entity:match-instance($entity-id as xs:string, $instance-id as xs:string, $instance-type as xs:string) as element()* {
    
    let $entity := $entities:entities/m:entity[@xml:id eq $entity-id][1]
    let $existing-instance := $entity/m:instance[@id eq  $instance-id][1]
    let $new-instance := 
        element { QName('http://read.84000.co/ns/1.0', 'instance') } {
            attribute id { $instance-id },
            attribute type { $instance-type }
        }
    
    where $instance-id gt '' and $instance-type gt ''
    return
        common:update('entity-match-instance', $existing-instance, $new-instance, $entity, ())
    
};

declare function update-entity:remove-instance($instance-id as xs:string) as element()* {

    let $existing-value := $entities:entities/m:entity/m:instance[@id eq  $instance-id][1]
    where $existing-value
    return
        common:update('entity-exclude', $existing-value, (), $existing-value/parent::m:entity, ())
        
};
