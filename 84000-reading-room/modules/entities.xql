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
import module namespace glossary="http://read.84000.co/glossary" at "glossary.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "knowledgebase.xql";
import module namespace functx="http://www.functx.com";

declare variable $entities:entities := doc(concat($common:data-path, '/operations/entities.xml'))/m:entities;
declare variable $entities:predicates := doc(concat($common:data-path, '/config/entity-predicates.xml'));
declare variable $entities:types := 
    <entity-types xmlns="http://read.84000.co/ns/1.0">
        <type id="eft-term" glossary-type="term">
            <label type="singular">Term</label>
            <label type="plural">Terms</label>
        </type>
        <type id="eft-person" glossary-type="person">
            <label type="singular">Person</label>
            <label type="plural">People</label>
        </type>
        <type id="eft-place" glossary-type="place">
            <label type="singular">Place</label>
            <label type="plural">Places</label>
        </type>
        <type id="eft-text" glossary-type="text">
            <label type="singular">Text</label>
            <label type="plural">Texts</label>
        </type>
        <type id="eft-collection">
            <label type="singular">Collection</label>
            <label type="plural">Collections</label>
        </type>
    </entity-types>;

declare variable $entities:flags := 
    <entity-flags xmlns="http://read.84000.co/ns/1.0">
        <flag id="requires-attention">
            <label>requires attention</label>
        </flag>
    </entity-flags>;

declare variable $entities:instance-types := ('glossary-item');

declare function entities:entities($instance-ids as xs:string*, $validate as xs:boolean, $expand-instances as xs:boolean, $expand-relations as xs:boolean) as element(m:entities) {

    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        
        (: De-dupe instance ids :)
        let $instance-ids := distinct-values($instance-ids)
        
        (: Validate instance ids :)
        let $instance-ids := 
            if($validate) then 
                entities:instance-ids-validated($instance-ids)
            else
                $instance-ids
        
        (: Chunk the ids as there can be very many :)
        let $entities-chunks := local:entities-chunk($instance-ids, $validate, $expand-instances, $expand-relations, 1)
        
        (: Chunking can leave duplicates :)
        for $entity in $entities-chunks/self::m:entity
        let $entity-id := $entity/@xml:id/string()
        group by $entity-id
        return 
            $entity[1]
        
    }
    
};

declare function local:entities-chunk($instance-ids as xs:string*, $validate as xs:boolean, $expand-instances as xs:boolean, $expand-relations as xs:boolean, $chunk as xs:integer) as element(m:entity)* {
    
    let $instance-ids-count := count($instance-ids)
    let $chunk-size := xs:integer(1024)
    let $chunks-count := xs:integer(ceiling($instance-ids-count div $chunk-size))
    let $chunk-start := ($chunk-size * ($chunk - 1)) + 1
    let $chunk-end := ($chunk-start + $chunk-size) - 1
    
    return (
    
        if($chunk-start le $instance-ids-count) then
            let $subsequence := subsequence($instance-ids, $chunk-start, $chunk-size)
            for $entity in $entities:entities//m:entity[m:instance/@id = $subsequence]
            return 
                 entities:entity($entity, $validate, $expand-instances, $expand-relations)
        else (),
        
        if($chunk-end lt $instance-ids-count) then
            local:entities-chunk($instance-ids, $validate, $expand-instances, $expand-relations, $chunk + 1)
        else ()
        
    )
    
                 
};

declare function entities:flagged($type as xs:string, $validate as xs:boolean, $expand-instances as xs:boolean, $expand-relations as xs:boolean) as element(m:entities) {
    
    let $flag := $entities:flags//m:flag[@id eq $type]
    
    where $flag
    return
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        for $entity in $entities:entities//m:entity[m:flag/@type = $flag/@id]
        return 
             entities:entity($entity, $validate, $expand-instances, $expand-relations)
        
    }
    
};

declare function entities:next-id() as xs:string {
    
    let $max-id := max($entities:entities//@xml:id ! substring-after(., 'entity-') ! common:integer(.))
    return
        string-join(('entity', xs:string(sum(($max-id, 1)))), '-')
    
};

declare function entities:instance-ids-validated($instance-ids as xs:string*) as xs:string* {
    let $glossary-ids := $glossary:tei//tei:back//id($instance-ids)[self::tei:gloss]/@xml:id/string()
    let $knowledgebase-ids := $knowledgebase:tei-render//tei:publicationStmt//id($instance-ids)[self::tei:idno]/@xml:id/string()
    return (
        $glossary-ids,
        $knowledgebase-ids
    )
};

declare function entities:entity($entity as element(m:entity)?, $validate as xs:boolean, $expand-instances as xs:boolean, $expand-relations as xs:boolean)  as element(m:entity)? {
    
    if($entity) then
        element { node-name($entity) } {
        
            $entity/@*,
            $entity/*[not(local-name(.) = ('instance','relation','label'))],
            
            (: Instances :)
            let $instance-ids := $entity/m:instance/@id
            
            (: Filter out instance ids that don't exist or are not ready :)
            let $instance-ids :=
                if($validate) then
                    entities:instance-ids-validated($instance-ids)
                else
                    $instance-ids
            
            let $valid-instances := $entity/m:instance[@id = $instance-ids]
            let $valid-instances :=
                (: Expand to include details of the instance: glossary or article :)
                if($expand-instances) then
                    entities:expand-instances($valid-instances)
                else
                    $valid-instances
                    
            return (
            
                $valid-instances,
                
                (: Sort the labels :)
                $entity/m:label[@xml:lang eq 'en'],
                $entity/m:label[@xml:lang eq 'Sa-Ltn'],
                $entity/m:label[@xml:lang eq 'Bo-Ltn'],
                $entity/m:label[not(@xml:lang = ('en', 'Bo-Ltn', 'Sa-Ltn'))],
                
                (: Derive label based on content :)
                if(not($entity/m:label[@derived])) then
                
                    let $terms-sorted := 
                        for $term in 
                            if($valid-instances/m:entry/m:term[@xml:lang eq 'bo']) then
                                $valid-instances/m:entry/m:term[@xml:lang eq 'bo']
                            else if($valid-instances/m:entry/m:term[@xml:lang eq 'Bo-Ltn']) then
                                $valid-instances/m:entry/m:term[@xml:lang eq 'bo']
                            else
                                $valid-instances/m:entry/m:term[@xml:lang eq 'Sa-Ltn']
                                
                        order by string-length($term) descending
                        return
                            $term
                    
                    let $terms-longest := $terms-sorted[1]
                    where $terms-longest
                    return (
                    
                        element label {
                            attribute derived { true() },
                            attribute xml:lang {
                                if($terms-longest[@xml:lang = ('bo', 'Bo-Ltn')]) then
                                    'bo'
                                else
                                    $terms-longest/@xml:lang
                            },
                            text { 
                                if($terms-longest[@xml:lang eq 'Bo-Ltn']) then
                                    common:bo-from-wylie(normalize-space($terms-longest/data()))
                                else
                                    $terms-longest/data()
                            }
                        },
                        
                        if($terms-longest[@xml:lang = ('bo', 'Bo-Ltn')]) then 
                        
                            element label {
                                attribute derived-transliterated { true() },
                                attribute xml:lang { 'Bo-Ltn' },
                                text { 
                                    if($terms-longest[@xml:lang eq 'bo']) then
                                        replace(common:wylie-from-bo(normalize-space($terms-longest/data())), '/$', '')
                                    else
                                        $terms-longest/data()
                                }
                            }
                        
                        else ()
                        
                    )
                else ()
            ),
            
            (: Related entities :)
            (: Include relations in this entity (Don't allow anything pointing to itself) :)
            let $relations := $entity/m:relation[not(@id eq $entity/@xml:id)]
            return
                if($expand-relations) then
                
                    let $reverse-relations := 
                        for $relation in $entities:entities//m:entity/m:relation[@id eq $entity/@xml:id]
                        let $reverse-predicate := $entities:predicates//m:predicate[@xml:id eq $relation/@predicate]/@reverse
                        let $reverse-entity := $relation/parent::m:entity[not(@xml:id = ($entity/@xml:id, $entity/m:relation/@id))]
                        where $reverse-predicate and $reverse-entity
                        return
                        element { node-name($relation) } {
                            attribute predicate { $reverse-predicate },
                            attribute id { $reverse-entity/@xml:id },
                            attribute debug { 'reverse-relation' },
                            (
                                $reverse-entity/m:label[@xml:lang eq 'en'],
                                $reverse-entity/m:label[@xml:lang eq 'Bo-Ltn'],
                                $reverse-entity/m:label[not(@xml:lang = ('en','Bo-Ltn'))]
                            )[1]
                        }
                    
                    let $relations := ($relations | $reverse-relations)
                    
                    where $relations
                    return
                        entities:expand-relations($relations, $validate, true(), false())
                        
                else 
                    $relations
                    
            
        }
    else ()
    
};

declare function entities:expand-instances($instances as element(m:instance)*) as element(m:instance)* {

    let $instance-entries := glossary:entries($instances/@id, true())
    let $instance-pages := knowledgebase:pages($instances/@id, true())
    for $instance in $instances
        let $instance-element := $instance-entries[@id eq $instance/@id]
        let $instance-element :=
            if(not($instance-element)) then
                $instance-pages[@xml:id eq $instance/@id]
            else
                $instance-element
    
    where $instance-element
    return
        element { node-name($instance) } {
            $instance/@*,
            $instance-element
        }
        
};

declare function entities:expand-relations($relations as element(m:relation)*, $validate as xs:boolean, $expand-instances as xs:boolean, $expand-relations as xs:boolean) as element(m:relation)* {
    
    for $relation in $relations
        let $relation-entity := $entities:entities//m:entity/id($relation/@id)
    where $relation-entity
        let $relation-entity := 
            element { node-name($relation-entity) } {
                $relation-entity/@*,
                $relation-entity/* except $relation-entity/m:relation[@id eq $relation-entity/@xml:id]
            }
        let $relation-entity := entities:entity($relation-entity, $validate, $expand-instances, $expand-relations)
    where $relation-entity
    return
        element { node-name($relation) } {
            $relation/@*,
            $relation/m:label,
            $relation-entity
        }
        
};

declare function entities:similar($entity as element(m:entity)?, $search-terms as xs:string*, $exclude-ids as xs:string*) as element(m:entity)* {
    
    let $instance-entries := glossary:entries($entity/m:instance/@id, false())
    
    let $search-terms := distinct-values((
        $search-terms,
        $instance-entries/m:term[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data(),
        $instance-entries/m:alternatives[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data()
    )[not(. = $glossary:empty-term-placeholders)] ! lower-case(.) ! common:normalized-chars(.) (:! replace(.,"’", "'"):))
    
    let $exclude-ids := distinct-values((
        $exclude-ids,
        (: Exclude matched instances :)
        $entity/m:instance/@id/string(), 
        (: Exclude related instances :)
        $entities:entities//m:entity/id($entity/m:relation/@id)/m:instance/@id/string(),
        $entities:entities//m:entity[m:relation[$entity/id(@id)]]/m:instance/@id/string()
    ))
    
    let $search-query :=
        <query>
        {
            for $term in $search-terms
            let $normalized-term := $term
            where $normalized-term gt ''
            return
                <phrase slop="0">{ $normalized-term }</phrase>
        }
        </query>
    
    let $matching-instance-ids := (
        $glossary:tei//tei:back//tei:gloss
            [tei:term
                [ft:query(., $search-query)]
                [not(@type eq 'definition')]
                [@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]
            ]
            [@xml:id]
            [not(@xml:id = $exclude-ids)]
        ,
        $knowledgebase:tei-render//tei:teiHeader/tei:fileDesc
            [tei:titleStmt/tei:title
                [ft:query(., $search-query)]
            ]/tei:publicationStmt/tei:idno
                [@xml:id]
                [not(@xml:id = $exclude-ids)]
    )/@xml:id/string()
    
    let $matching-entity-ids := (
        $glossary:tei//tei:teiHeader//tei:sourceDesc/tei:bibl/tei:author
            [ft:query(., $search-query)][@ref]
        | $glossary:tei//tei:teiHeader//tei:sourceDesc/tei:bibl/tei:editor
            [ft:query(., $search-query)][@ref]
    )/@ref/string() ! replace(., '^eft:', '')
    
    return (
        
        (: debug :)
        (:element m:entity {element debug {$search-query, $matching-entity-ids} },:)
    
        for $similar-entity in (
            if($entity[m:type/@type = $entities:types//m:type[@glossary-type]/@id]) then
                $entities:entities//m:entity
                    [m:instance/@id = $matching-instance-ids]
                    [m:type/@type = $entity/m:type/@type]
            else
                $entities:entities//m:entity
                    [m:instance/@id = $matching-instance-ids]
            | $entities:entities//m:entity/id($matching-entity-ids)
        )
        
        order by if($similar-entity[m:label/text() = $search-terms]) then 1 else 0 descending
        return  
            (: Copy entity expanded to include instance detail :)
            entities:entity($similar-entity, false(), true(), false())
            
        )
};
