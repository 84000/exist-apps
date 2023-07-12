module namespace update-entity = "http://operations.84000.co/update-entity";

import module namespace update-tei = "http://operations.84000.co/update-tei" at "update-tei.xql";
import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace functx="http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function update-entity:new-entity($label-lang as xs:string?, $label-text as xs:string, $entity-type as xs:string, $instance-type as xs:string, $instance-id as xs:string, $flag as xs:string) as element()? {
    
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
                if($label-lang gt '') then
                    attribute xml:lang { $label-lang }
                else (),
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
                attribute type { $instance-type },
                
                if($entities:flags//m:flag[@id eq $flag]) then (
                    common:ws(3),
                    element flag {
                        attribute type { $flag },
                        attribute user { common:user-name() },
                        attribute timestamp { current-dateTime() }
                    },
                    common:ws(2)
                )
                else ()
                
            }
        )
        else ()
        ,
        common:ws(1)
    }
    
};

declare function update-entity:create($label-lang as xs:string?, $label-text as xs:string, $entity-type as xs:string, $instance-type as xs:string, $instance-id as xs:string, $flag as xs:string) as element()? {
    
    let $new-entity := update-entity:new-entity($label-lang, $label-text, $entity-type, $instance-type, $instance-id, $flag)
    return
        (:common:update('new-entity', (), $new-entity, $entities:entities, ()):)
        update insert (text{ $common:chr-tab }, $new-entity, text{ $common:chr-nl }) into $entities:entities
    
};

declare function update-entity:create($gloss as element(tei:gloss), $flag as xs:string) as element()? {
    
    let $label-terms := 
        for $term in $gloss/tei:term[not(@type eq 'translationAlternative')][normalize-space(string-join(text(),''))]
        order by if($term/@xml:lang eq 'Bo-Ltn') then 1 else if($term/@xml:lang eq 'Sa-Ltn') then 2 else 3
        return 
            $term
    
    let $entity-type := $entities:types//m:type[@glossary-type eq $gloss/@type]
    where $label-terms and $entity-type
    return 
        update-entity:create($label-terms[1]/@xml:lang, $label-terms[1]/data(), $entity-type[1]/@id, 'glossary-item', $gloss/@xml:id, $flag)

        
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
                (: Add an instance for a knowledgebase-article :)
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

(: Merge entity into target entity :)
declare function update-entity:merge($entity-id as xs:string, $target-entity-id as xs:string) {
    
    let $entity := $entities:entities/id($entity-id)[self::m:entity]
    let $target-entity := $entities:entities/id($target-entity-id)[self::m:entity] except $entity
    
    (: Merge all details into the new entity :)
    let $merged-entity := 
        element { node-name($target-entity) } {
        
            $target-entity/@*,
            
            for $entity-element in functx:distinct-deep(($entity/* | $target-entity/*))[not(./@predicate eq 'sameAs' and ./@id eq $target-entity-id)]
            let $element-name := local-name($entity-element)
            order by 
                if($element-name eq 'label') then 1 
                else if($element-name eq 'type') then 2 
                else if($element-name eq 'instance') then 3 
                else if($element-name eq 'content') then 4
                else if($element-name eq 'relation') then 5 
                else 6
            return (
                common:ws(2),
                $entity-element
            ),
            
            (: Add reference to old entity in new :)
            common:ws(2),
            element { QName('http://read.84000.co/ns/1.0', 'relation') } {
                attribute predicate { 'sameAs' },
                attribute id { $entity-id }
            },
            
            common:ws(1)
        }
    
    where $entity and $target-entity
    return (
    
        (: Update relations to the entity to point to the target :)
        for $relation in $entities:entities//m:relation[@id eq $entity/@xml:id] except ($entity/m:relation | $target-entity/m:relation)
        return 
            update replace $relation/@id with attribute id { $target-entity/@xml:id }
        ,
        (: Update target entity :)
        update replace $target-entity with $merged-entity,
        
        (: Delete entity :)
        update delete $entity
        
    )
        
    
};

declare function update-entity:match-instance($entity-id as xs:string, $instance-id as xs:string, $instance-type as xs:string, $flag as xs:string?) as element()* {
    
    (: Get the entity :)
    let $entity := $entities:entities/m:entity[@xml:id eq $entity-id][1]
    
    (: See if instance already exists (probably not - this is to avoid duplicates) :)
    let $existing-instance := $entity/m:instance[@id eq  $instance-id][1]
    
    (: Define instance :)
    let $new-instance := 
        if($instance-id gt '' and $instance-type gt '') then
            element { QName('http://read.84000.co/ns/1.0', 'instance') } {
                attribute id { $instance-id },
                attribute type { $instance-type },
                $existing-instance/@*[not(local-name(.) = ('id','type'))],
                $existing-instance/node(),
                if(not($existing-instance/m:flag[@type eq $flag]) and $entities:flags/m:flag[@id eq $flag]) then (
                    common:ws(3),
                    element flag {
                        attribute type { $flag },
                        attribute user { common:user-name() },
                        attribute timestamp { current-dateTime() }
                    }
                )
                else ()
            }
        else ()
    
    where $new-instance
    return
        (: Update the entity :)
        (:common:update('entity-match-instance', $existing-instance, $new-instance, $entity, ()):)
        if($existing-instance) then
            update replace $existing-instance with $new-instance
        else 
            update insert (text{ $common:chr-tab } , $new-instance, text{ common:ws(1) }) into $entity
            
};

declare function update-entity:move-instance($instance-id as xs:string, $instance-type as xs:string, $instance-existing as element(m:instance)?, $target-element as element()*) {
    
    let $instance-new :=
        element { QName('http://read.84000.co/ns/1.0','instance') } {
            attribute id { $instance-id },
            attribute type { $instance-type },
            $instance-existing/@*[not(name(.) = ('id','type'))],
            $instance-existing/node()
        }
    
    where 
        (: Adding new instance :)
        not($instance-existing) 
        (: Moving instance :)
        or count($target-element | $instance-existing/parent::m:*) gt 1
        (: Deleting instance :)
        or not($target-element)
        
    return (
        
        (: Insert new instance :)
        if($target-element) then
            update insert (text{ $common:chr-tab }, $instance-new, text{ common:ws(1) }) into $target-element
        else (),
        
        (: Delete existing :)
        if($instance-existing) then
            update delete $instance-existing
        else ()
        
    )
                    
};

declare function update-entity:remove-instance($instance-id as xs:string) as element()* {
    
    let $instance := $entities:entities/m:entity/m:instance[@id eq $instance-id][1]
    let $entity := $instance/parent::m:entity
    
    where $instance
    return (
        
        (: If there are other instances just remove this instance :)
        if($entity/m:instance except $instance) then
            common:update('entity-remove-instance', $instance, (), (), ())
        
        (: Otherwise delete the whole entity :)
        else 
            common:update('entity-remove', $entity, (), (), ())
            
    )
        
};

declare function update-entity:set-flag($instance-id as xs:string, $type as xs:string) as element()* {
    local:set-flag($instance-id, $type, false())
};

declare function update-entity:clear-flag($instance-id as xs:string, $type as xs:string) as element()* {
    local:set-flag($instance-id, $type, true())
};

declare function local:set-flag($instance-id as xs:string, $type as xs:string, $remove as xs:boolean) as element()* {
    
    let $flag := $entities:flags//m:flag[@id eq $type]
    
    for $existing-instance in $entities:entities/m:entity/m:instance[@id eq $instance-id]
    
    let $remove-flag := 
        if($remove) then
            $existing-instance/m:flag[@type eq $type]
        else ()
        
    let $new-instance :=
        element { node-name($existing-instance) } {
            $existing-instance/@*,
            for $element in $existing-instance/* except $remove-flag
            return (
                common:ws(3),
                $element,
                common:ws(2)
            ),
            if(not($remove) and $flag) then (
                common:ws(3),
                element flag {
                    attribute type { $type },
                    attribute user { common:user-name() },
                    attribute timestamp { current-dateTime() }
                },
                common:ws(2)
            )
            else ()
        }
    
    where $existing-instance and $new-instance
    return
        update replace $existing-instance with $new-instance
        (:common:update('set-entity-flag', $existing-instance, $new-instance, (), ()):)
};

(: Auto-assign entities to all glossary entries in a text :)
declare function update-entity:auto-assign-glossary($text-id as xs:string, $create-unmatched as xs:boolean) as element()* {
    
    (# exist:batch-transaction #) {
        
        let $log := util:log('info', concat('update-entity-auto-assign-glossary-started:', $text-id))
        
        let $tei := $glossary:tei/id($text-id)/ancestor::tei:TEI
        let $glosses-with-entities := $tei//tei:back//tei:gloss/id($entities:entities//m:entity/m:instance/@id)
        
        let $merge-glossary :=
            for $gloss in $tei//tei:back//tei:gloss except $glosses-with-entities
            
                (: Is there a matching Sanskrit term? :)
                let $search-terms-sa := distinct-values($gloss/tei:term[@xml:lang eq 'Sa-Ltn']/text() ! normalize-space(.) ! normalize-unicode(.))
                let $search-terms-sa-hyphens := 
                    for $search-term-sa in $search-terms-sa
                    let $string-replaced := replace($search-term-sa, '­', '')
                    let $string-escaped := functx:escape-for-regex($search-term-sa)
                    return
                        (: Only parse for soft-hyphens if not escaped :)
                        if($string-escaped eq $search-term-sa) then
                            string-join((1 to string-length($string-replaced)) ! substring($string-replaced, ., 1), '­?')
                        else
                            $string-escaped
                
                let $regex-sa := string-join($search-terms-sa-hyphens, '|') ! concat('^\s*(', ., ')\s*$')
                let $gloss-candidates-sa := 
                    if(count($search-terms-sa) gt 0) then
                        $glossary:tei//tei:back//tei:term[@xml:lang eq 'Sa-Ltn'][matches(., $regex-sa, 'i')]/parent::tei:gloss except $gloss
                    else ()
                
                (: Is there a matching Tibetan term? :)
                let $search-terms-bo := distinct-values($gloss/tei:term[@xml:lang eq 'Bo-Ltn']/text() ! normalize-space(.)) (:distinct-values(($gloss/tei:term[@xml:lang eq 'Bo-Ltn'][text()], $gloss/tei:term[@xml:lang eq 'bo'][text()] ! common:wylie-from-bo(.))):)
                let $regex-bo := string-join($search-terms-bo ! functx:escape-for-regex(.), '|') ! concat('^\s*(', ., ')\s*$')
                let $gloss-candidates-bo := 
                    if(count($search-terms-bo) gt 0) then
                        $glossary:tei//tei:back//tei:term[@xml:lang eq 'Bo-Ltn'][matches(., $regex-bo, 'i')]/parent::tei:gloss except $gloss
                    else ()
                
                (: Get the associated enities :)
                let $gloss-candidates := ($gloss-candidates-sa | $gloss-candidates-bo)
                let $gloss-candidates-ids := $gloss-candidates/@xml:id/string()
                let $entity-candidates := $entities:entities//m:entity[m:instance/@id = $gloss-candidates-ids]
                
                (: Do more filtering and sorting :)
                let $entity-candidates-sorted := 
                    for $entity-candidate in $entity-candidates
                    
                    (: Get all glosses for this entity of this type :)
                    let $entity-candidate-glosses := $glossary:tei/id($entity-candidate/m:instance/@id)[self::tei:gloss][@type eq $gloss/@type]
                    
                    (: Filter the ones that match this gloss :)
                    let $entity-candidate-glosses-match := 
                        (: For terms just focus on Tibetan :)
                        if($gloss[@type eq 'term']) then
                            $entity-candidate-glosses
                                [@type eq 'term']
                                [tei:term[@xml:lang eq 'Bo-Ltn'][matches(., $regex-bo, 'i')]]
                        (: For other types check for Skt equivalence too :)
                        else
                            $entity-candidate-glosses
                                [@type eq $gloss/@type]
                                [tei:term[@xml:lang eq 'Sa-Ltn'][matches(., $regex-sa, 'i')]]
                                [tei:term[@xml:lang eq 'Bo-Ltn'][matches(., $regex-bo, 'i')]]
                    
                    (: Count of matches :)
                    let $entity-candidate-glosses-count := count($entity-candidate-glosses)
                    let $entity-candidate-glosses-match-count := count($entity-candidate-glosses-match)
                    
                    (: Filter out candidates :)
                    where $entity-candidate-glosses-match
                    
                    (: Order by most matching terms :)
                    order by $entity-candidate-glosses-match-count descending, $entity-candidate-glosses-count ascending
                    return 
                        element { QName('http://read.84000.co/ns/1.0','entity-candidate') } {
                            attribute count-glossaries { count($entity-candidate-glosses) },
                            attribute count-glossary-matches { $entity-candidate-glosses-match-count },
                            $entity-candidate
                        }
                
                (: Match to entity depending on type :)
                let $entity-candidates-first := $entity-candidates-sorted[1]
                let $entity-match := $entity-candidates-first/m:entity
                
                (: flag some matches :)
                let $flag := ''
                    (:if(((\: There is only 1 other matches :\)
                        $entity-candidates-first/@count-glossary-matches ! xs:integer(.) le 1
                        (\: Of more than 5 linked glossaries :\)
                        and $entity-candidates-first/@count-glossaries ! xs:integer(.) ge 5)
                        (\: Or there's not a common type :\)
                        or ($entity-match and not($entities:types/m:type[@id = $entity-match/m:type/@type][@glossary-type eq $gloss/@type]))
                    ) then 
                        'requires-attention'
                    else '':)
                
                (: Do the update :)
                let $do-update := 
                    if($entity-match) then (
                        update-entity:match-instance($entity-match/@xml:id, $gloss/@xml:id, 'glossary-item', $flag)
                        (:,util:log('info', concat('update-entity-auto-assign-glossary-match:', $gloss/@xml:id)):)
                    )
                    else if($create-unmatched) then (
                        update-entity:create($gloss, $flag)
                        (:,util:log('info', concat('update-entity-auto-assign-glossary-create:', $gloss/@xml:id)):)
                    )
                    else ()
                
                return 
                    element update {
                        attribute action { if($entity-match) then 'merge' else if($create-unmatched) then 'create' else 'none' },
                        attribute flag { $flag },
                        $gloss,
                        element match {
                            (:$gloss-matches,:)
                            $entity-match
                        },
                        $do-update,
                        element debug {
                            attribute glossary-editor-url { 'https://projects.84000-translate.org/edit-glossary.html?resource-id=' || $text-id || '&amp;resource-type=translation&amp;max-records=1&amp;glossary-id=' || $gloss/@xml:id },
                            element regex-sa {$regex-sa},
                            element regex-bo {$regex-bo}
                        }
                    }
        
        return (
            $merge-glossary,
            util:log('info', concat('update-entity-auto-assign-glossary-complete:', $text-id))
        )
        
    }
};
