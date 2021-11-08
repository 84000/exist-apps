module namespace update-entity = "http://operations.84000.co/update-entity";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace functx="http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function update-entity:new-entity($label-lang as xs:string, $label-text as xs:string, $entity-type as xs:string, $instance-type as xs:string, $instance-id as xs:string, $flag as xs:string) as element()? {
    element { QName('http://read.84000.co/ns/1.0', 'entity') } {
        attribute xml:id { entities:next-id() },
        common:ws(2),
        if($label-lang eq 'bo') then
            element label {
                attribute xml:lang { 'Bo-ltn' },
                text { common:wylie-from-bo($label-text) }
            }
        else 
            element label {
                attribute xml:lang { $label-lang },
                text { $label-text }
            }
        ,
        common:ws(2),
        element type {
            attribute type { $entity-type }
        },
        if($instance-id gt '') then (
            common:ws(2),
            element instance {
                attribute id { $instance-id },
                attribute type { $instance-type }
            }
        )
        else ()
        ,
        if($entities:flags//m:flag[@id eq $flag]) then (
            common:ws(2),
            element flag {
                attribute type { $flag },
                attribute user { common:user-name() },
                attribute timestamp { current-dateTime() }
            }
        )
        else ()
        ,
        common:ws(1)
    }
};

declare function update-entity:create($label-lang as xs:string, $label-text as xs:string, $entity-type as xs:string, $instance-type as xs:string, $instance-id as xs:string, $flag as xs:string) as element()? {
    
    common:update('new-entity', (), update-entity:new-entity($label-lang, $label-text, $entity-type, $instance-type, $instance-id, $flag), $entities:entities, ())
    
};

declare function update-entity:create($gloss as element(tei:gloss), $flag as xs:string) as element()? {
    
    (# exist:batch-transaction #) {
    
        let $label-terms := 
            for $term in $gloss/tei:term[not(@type = ('definition','alternative'))][normalize-space(string-join(text(),''))]
            order by if($term/@xml:lang eq 'Bo-Ltn') then 1 else if($term/@xml:lang eq 'Sa-Ltn') then 2 else 3
            return 
                $term
        
        let $entity-type := $entities:types//m:type[@glossary-type eq $gloss/@type]
        where $label-terms and $entity-type
        return 
            update-entity:create($label-terms[1]/@xml:lang, $label-terms[1]/data(), $entity-type[1]/@id, 'glossary-item', $gloss/@xml:id, $flag)
   
   }
        
};

(: Update labels, types and content :)
declare function update-entity:headers($entity-id as xs:string?) as element()? {
    
    let $parent := $entities:entities
    
    let $existing-entity := $parent/m:entity[@xml:id eq $entity-id]
    
    let $entity-id :=
        if(not($existing-entity)) then
            entities:next-id()
        else
            $entity-id
    
    let $entity-labels := common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'entity-label-text-')], '-')
    let $glossary-id := request:get-parameter('glossary-id', '')
    let $knowledgebase-id := request:get-parameter('knowledgebase-id', '')
    let $instance-new := ($glossary-id, $knowledgebase-id)[not(. eq '')]
    let $instance-remove := request:get-parameter('instance-remove', '')
    let $instance-existing := $existing-entity/m:instance[@id eq $instance-new]
    let $entity-types := $entities:types/m:type
    let $entity-flags := $entities:flags/m:flag
    
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
                                replace($label-text, '\-', '­'(: This is a soft-hyphen :))
                            else
                                $label-text
                        }
                        
                    }
                ),
                
                (: Copy existing entity entity type(s) that are in the post :)
                for $entity-type in $existing-entity/m:type[@type = request:get-parameter('entity-type[]', '')]
                return (
                    common:ws(2),
                    $entity-type
                ),
                
                (: Add other posted entity type(s) :)
                for $entity-type in request:get-parameter('entity-type[]', '')[not(. = ($existing-entity/m:type/@type/string(), ''))]
                return (
                    common:ws(2),
                    element type {
                        attribute type { $entity-type }
                    }
                ),
                
                (: Copy existing entity flag(s) that are in the post - this retains the user / timestamp :)
                for $entity-flag in $existing-entity/m:flag[@type = request:get-parameter('entity-flag[]', '')]
                return (
                    common:ws(2),
                    $entity-flag
                ),
                
                (: Add other posted entity flag(s) :)
                for $flag-type in request:get-parameter('entity-flag[]', '')[not(. = ($existing-entity/m:flag/@type/string(), ''))]
                return (
                    common:ws(2),
                    element flag {
                        attribute type { $flag-type },
                        attribute user { common:user-name() },
                        attribute timestamp { current-dateTime() }
                    }
                ),
                
                (: Instance(s) of this entity :)
                (: Copy instances except the ones to be removed or added :)
                for $instance in $existing-entity/m:instance[not(@id/string() = ($instance-remove, $instance-new)[not(. eq '')])]
                return (
                    common:ws(2),
                    $instance
                ),
                
                (: Add an instance for glossary-id :)
                if($glossary-id gt '' and not($instance-remove eq $glossary-id)) then (
                    common:ws(2),
                    if(not($instance-existing)) then
                        element instance {
                            attribute id { $glossary-id },
                            attribute type { 'glossary-item' }
                        }
                    else
                        $instance-existing
                )
                else if($knowledgebase-id gt '' and not($instance-remove eq $knowledgebase-id)) then (
                    common:ws(2),
                    if(not($instance-existing)) then
                        element instance {
                            attribute id { $knowledgebase-id },
                            attribute type { 'knowledgebase-article' }
                        }
                    else
                        $instance-existing
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
                        attribute user { common:user-name() },
                        attribute timestamp { current-dateTime() },
                        text { $entity-notes }
                    }
                ),
                
                common:ws(1)
            }
        
        where $parent and ($existing-entity or $new-value)
        return 
            (: Do the update :)
            common:update('entity', $existing-entity, $new-value, (), $entities:entities//m:entity[last()])
            
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
    
    (: Remove a relation :)
    else if($predicate eq 'removeRelation')then
        
        let $relation := $entities:entities/id($entity-id)[self::m:entity]/m:relation[@id eq $target-entity-id][1]
        (: Account for reverse relations :)
        let $relation := 
            if(not($relation)) then
                $entities:entities/id($target-entity-id)[self::m:entity]/m:relation[@id eq $entity-id][1]
            else
                $relation
        return
            common:update('entity-resolve', $relation, (), (), ())
    
    (: Set the predicate for the relationship :)
    else if($entities:predicates//m:predicate[@xml:id = $predicate]) then
    
        let $entity := $entities:entities/id($entity-id)[self::m:entity]
        let $target-entity := $entities:entities/id($target-entity-id)[self::m:entity]
        let $existing-relation := $entity/m:relation[@id eq $target-entity-id]
        let $new-relation :=
            element { QName('http://read.84000.co/ns/1.0', 'relation') } {
                attribute predicate { $predicate },
                attribute id { $target-entity-id },
                (
                    $target-entity/m:label[@xml:lang eq 'en'],
                    $target-entity/m:label[@xml:lang eq 'Bo-Ltn'],
                    $target-entity/m:label[not(@xml:lang = ('en','Bo-Ltn'))]
                )[1]
            }
        
        where $entity and $target-entity
        return
            (: Update target :)
            common:update('entity-resolve', $existing-relation, $new-relation, $entity, ())
    
    else ()
    
};

(: Merge entities together :)
declare function update-entity:merge($entity-id as xs:string, $target-entity-id as xs:string) as element()* {
    
    (# exist:batch-transaction #) {
    
        let $parent := $entities:entities
        let $entity := $parent/id($entity-id)[self::m:entity]
        let $target-entity := $parent/id($target-entity-id)[self::m:entity]
        
        let $entity-new := 
            element { node-name($entity) } {
                $entity/@*,
                for $entity-node in functx:distinct-deep(($entity/* | $target-entity/*))
                return (
                    common:ws(2),
                    $entity-node
                )
            }
        
        where $entity and $target-entity
        return (
            
            (: Update entity :)
            common:update('entity-merge', $entity, $entity-new, (), ()),
            
            (: Update target references :)
            for $relation in $entities:entities//m:relation[@id eq $target-entity-id]
            return 
                common:update('entity-merge-relation', $relation/@id, attribute id { $entity-id }, (), ())
            ,
            
            (: Delete target :)
            common:update('entity-remove', $target-entity, (), (), ())
            
            (:element update-debug {
                attribute entity-id { $entity-id },
                element existing-value { $target-entity }, 
                element new-value { $target-entity-new }(\:, 
                element parent { $parent }, 
                element insert-following { () }:\)
            }:)
        )
        
    }
    
};

(:declare function update-entity:exclude($entity-ids as xs:string*) as element()* {

    let $exclusions :=
        for $entity-id in $entity-ids
        let $entity := $entities:entities/id($entity-id)[self::m:entity]
        return
            element { QName('http://read.84000.co/ns/1.0', 'exclude') } {
                attribute id { $entity-id },
                $entity/m:label[not(@derived) and not(@derived-transliterated)][1]
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
        if($instance-id gt '' and $instance-type gt '') then
            element { QName('http://read.84000.co/ns/1.0', 'instance') } {
                attribute id { $instance-id },
                attribute type { $instance-type }
            }
        else ()
    
    where $new-instance
    return
        common:update('entity-match-instance', $existing-instance, $new-instance, $entity, ())
    
};

(: Add the glossary of a text to the entities :)
declare function update-entity:merge-glossary($text-id as xs:string, $create as xs:boolean) as element()* {
    
    let $tei := $glossary:tei/id($text-id)/ancestor::tei:TEI
    let $glosses-with-entities := $tei//tei:back//tei:gloss/id($entities:entities//m:entity/m:instance/@id)
    
    for $gloss in $tei//tei:back//tei:gloss except $glosses-with-entities
    
        (: Is there a matching Sanskrit term? :)
        let $search-terms-sa := $gloss/tei:term[@xml:lang eq 'Sa-Ltn'][text()]
        let $regex-sa := concat('^\s*(', string-join($search-terms-sa ! functx:escape-for-regex(.), '|'), ')\s*$')
        let $matches-sa := 
            if(count($search-terms-sa) gt 0) then
                $glossary:tei//tei:back//tei:gloss
                    [tei:term[@xml:lang eq 'Sa-Ltn'][matches(., $regex-sa, 'i')]]
                    [not(@xml:id eq $gloss/@xml:id)]
            else ()
        
        (: Is there a matching Tibetan term? :)
        let $search-terms-bo := distinct-values(($gloss/tei:term[@xml:lang eq 'Bo-Ltn'][text()], $gloss/tei:term[@xml:lang eq 'bo'][text()] ! common:wylie-from-bo(.)))
        let $regex-bo := concat('^\s*(', string-join($search-terms-bo ! functx:escape-for-regex(.), '|'), ')\s*$')
        let $matches-bo := 
            if(count($search-terms-bo) gt 0) then
                $glossary:tei//tei:back//tei:gloss
                    [
                        tei:term[@xml:lang eq 'Bo-Ltn']
                        [matches(., $regex-bo, 'i')]
                    ]
                    [not(@xml:id eq $gloss/@xml:id)]
            else ()
        
        (: Does it match both Tibetan, Sanskrit and type? :)
        let $matches-full := $matches-sa[@xml:id = $matches-bo/@xml:id][@type eq $gloss/@type]
        
        (: Does it have an entity? :)
        let $matches-full-ids := $matches-full/@xml:id/string()
        let $matches-entity := $entities:entities//m:entity[m:instance/@id = $matches-full-ids]
        
        (: If it's an unambigous, full match, with an entity (and a term) then merge :)
        let $action :=
            if($gloss[@type eq 'term'] and count($matches-entity) eq 1) then
                'merge'
            else
                'create'
        
        (: If there is some match then it requires some attention :)
        let $flag := if(count($matches-sa[@type eq $gloss/@type] | $matches-bo[@type eq $gloss/@type]) gt 0) then 'requires-attention' else ''
        
        (: Do the update :)
        let $do-update := 
            if($action eq 'merge') then
                update-entity:match-instance($matches-entity/@xml:id, $gloss/@xml:id, 'glossary-item')
            else if($create) then
                update-entity:create($gloss, $flag)
            else ()
        
        return 
            element update {
                attribute action { $action },
                attribute flag { $flag },
                $gloss,
                element match {
                    (:$matching-gloss,:)
                    $matches-entity
                },
                $do-update,
                element debug {
                    attribute glossary-editor-url { 'https://projects.84000-translate.org/edit-glossary.html?resource-id=' || $text-id || '&amp;resource-type=translation&amp;max-records=1&amp;glossary-id=' || $gloss/@xml:id },
                    element regex-sa {$regex-sa},
                    element regex-bo {$regex-bo}
                }
            }

};

declare function update-entity:remove-instance($instance-id as xs:string) as element()* {

    let $instance := $entities:entities/m:entity/m:instance[@id eq $instance-id][1]
    (: Check instance exists and it's not the only one in the entity :)
    where $instance and $instance/parent::m:entity/m:instance[not(@id eq $instance-id)]
    return
        common:update('entity-remove-instance', $instance, (), (), ())
        
};

declare function update-entity:update-instance($instance-id as xs:string) as element()* {
    
    let $use-definition := request:get-parameter('use-definition', 'no-value-submitted')
    
    where not($use-definition eq 'no-value-submitted')
    let $existing-value := $entities:entities/m:entity/m:instance[@id eq  $instance-id][1]
    
    let $new-value :=
        element { QName('http://read.84000.co/ns/1.0', 'instance') } {
            $existing-value/@*[not(local-name(.) eq 'use-definition')],
            if($use-definition gt '') then
                attribute use-definition { $use-definition }
            else ()
        }
    
    where $existing-value and $new-value
    return
        common:update('entity-update-instance', $existing-value, $new-value, (), ())
        
};

declare function update-entity:set-flag($entity-id as xs:string, $type as xs:string) as element()* {
    local:set-flag($entity-id, $type, false())
};

declare function update-entity:clear-flag($entity-id as xs:string, $type as xs:string) as element()* {
    local:set-flag($entity-id, $type, true())
};

declare function local:set-flag($entity-id as xs:string, $type as xs:string, $remove as xs:boolean) as element()* {

    let $existing-entity := $entities:entities/m:entity[@xml:id eq $entity-id]
    
    let $flag := $entities:flags//m:flag[@id eq $type]
    
    let $new-entity :=
        element { node-name($existing-entity) } {
            $existing-entity/@*,
            $existing-entity/*[not(local-name(.) eq 'flag' and @type eq $type)],
            if(not($remove) and $flag) then
                element flag {
                    attribute type { $type },
                    attribute user { common:user-name() },
                    attribute timestamp { current-dateTime() }
                }
            else ()
        }
    
    where $existing-entity and $new-entity
    return
        common:update('set-entity-flag', $existing-entity, $new-entity, (), ())
};
