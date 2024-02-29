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
        <type id="eft-person" glossary-type="person" provisional="true">
            <label type="singular">Person</label>
            <label type="plural">People</label>
        </type>
        <type id="eft-place" glossary-type="place" provisional="true">
            <label type="singular">Place</label>
            <label type="plural">Places</label>
        </type>
        <type id="eft-text" glossary-type="text" provisional="true">
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
        <flag id="entity-definition" type="computed">
            <label>entity definitions</label>
        </flag>
        <flag id="vinaya">
            <label>Vinaya</label>
        </flag>
    </entity-flags>;

declare variable $entities:instance-types := ('glossary-item', 'knowledgebase-article');

declare function entities:next-id() as xs:string {
    
    (: Ensure we don't use an existing relation/sameAs entity id :)
    let $max-id := max(($entities:entities//@xml:id | $entities:entities//m:relation/@id) ! substring-after(., 'entity-') ! common:integer(.))
    return
        string-join(('entity', xs:string(sum(($max-id, 1)))), '-')
    
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
        $entities:entities//m:entity[m:relation/@id = $entity/@xml:id]/m:instance/@id/string()
        
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
    
    let $exclude-gloss := $glossary:tei//tei:back//tei:gloss/id($exclude-ids)
    let $exclude-page := $knowledgebase:tei-render//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/id($exclude-ids)
    
    let $matching-instances := 
        if($search-query/*) then (
            $glossary:tei//tei:back//tei:gloss[tei:term[ft:query(., $search-query)][@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]] except $exclude-gloss,
            $knowledgebase:tei-render//tei:teiHeader/tei:fileDesc[tei:titleStmt/tei:title[ft:query(., $search-query)]]/tei:publicationStmt/tei:idno except $exclude-page,
            $glossary:tei//tei:teiHeader//tei:sourceDesc/tei:bibl/tei:author[ft:query(., $search-query)][@xml:id],
            $glossary:tei//tei:teiHeader//tei:sourceDesc/tei:bibl/tei:editor[ft:query(., $search-query)][@xml:id]
        )
        else 
            let $search-query :=
                <query>
                {
                    for $term in distinct-values(($instance-entries/m:term/data())[. gt ''][not(. = $glossary:empty-term-placeholders)] ! lower-case(.) ! common:normalized-chars(.))
                    return
                        <phrase slop="0">{ $term }</phrase>
                }
                </query>
            return
                $glossary:tei//tei:back//tei:gloss[tei:term[ft:query(., $search-query)]] except $exclude-gloss
    
    let $matching-instance-ids := distinct-values($matching-instances/@xml:id)
    let $matching-instance-ids := subsequence($matching-instance-ids, 1, 1024)
    
    let $similar-entities := 
        for $similar-entity in $entities:entities//m:entity[m:instance/@id = $matching-instance-ids] except $entity
        order by 
            if($similar-entity[m:label/text() = $search-terms]) then 1 else 0 descending,
            count($similar-entity/m:instance) descending
        return
            $similar-entity
    
    return 
        subsequence($similar-entities, 1, 50)
};

declare function entities:related($entities as element(m:entity)*, $include-unrelated as xs:boolean, $include-related-content as xs:string*, $exclude-flagged as xs:string*, $exclude-status as xs:string*) as element()* {
    
    let $entities-id-chunks := common:ids-chunked($entities/@xml:id)
    
    let $entities-id-relations :=
        for $key in map:keys($entities-id-chunks)
        let $entities-ids-chunk := map:get($entities-id-chunks, $key)
        return
            if($include-unrelated) then 
                $entities:entities//m:entity[m:relation[@id = $entities-ids-chunk]]
            else 
                $entities:entities//m:entity[m:relation[not(@predicate = ('isUnrelated'))][@id = $entities-ids-chunk]]
    
    let $entities-relation-chunks := 
        if($include-unrelated) then 
            common:ids-chunked($entities/m:relation/@id)
        else
            common:ids-chunked($entities/m:relation[not(@predicate = ('isUnrelated'))]/@id)
    
    let $entities-relation-entities := 
        for $key in map:keys($entities-relation-chunks)
        let $entities-relation-chunk := map:get($entities-relation-chunks, $key)
        return
            $entities:entities//m:entity/id($entities-relation-chunk)
    
    let $related-entities := ($entities-id-relations | $entities-relation-entities) except $entities
    
    return (
        
        (: Related entities :)
        $related-entities,
        
        (: Related content :)
        if(count($include-related-content) gt 0) then
            
            local:entities-content($entities | $related-entities, $include-related-content, $exclude-flagged, $exclude-status)
            
        else ()
        
        
    )
};

declare function local:entities-content($entities as element(m:entity)*, $content-types as xs:string*, $exclude-flagged as xs:string*, $exclude-status as xs:string*) as element()* {
    
    (: All the entities we want data about :)
    let $exclude-instances := 
        if($exclude-flagged) then 
            $entities/m:instance[m:flag[@type = $exclude-flagged]] 
        else ()
    
    (: Instances of those entities :)
    let $lookup-instances := $entities/m:instance except $exclude-instances
  
    return (
    
        (: Related articles :)
        (: Just base this on $exclude-status for now :)
        if($content-types = 'knowledgebase' and $lookup-instances[@type eq 'knowledgebase-article']) then
            knowledgebase:pages($lookup-instances[@type eq 'knowledgebase-article']/@id, if(count($exclude-status) gt 0) then true() else false(), ())
        else (),
        
        (: Related glossary entries :)
        if($content-types = 'glossary') then
        
            let $glossary-id-chunks := common:ids-chunked($lookup-instances[@type eq 'glossary-item']/@id)
            
            let $glosses := 
                for $key in map:keys($glossary-id-chunks)
                let $glossary-ids-chunk := map:get($glossary-id-chunks, $key)
                return
                    $glossary:tei/id($glossary-ids-chunk)/self::tei:gloss[not(@mode eq 'surfeit')]
            
            (: Related glossaries - grouped by text :)
            for $gloss in $glosses
            
            let $tei := $gloss/ancestor::tei:TEI
            let $text-id := tei-content:id($tei)
            group by $text-id
            
            let $text-type := tei-content:type($tei[1])
            where $text-type eq 'translation'
            
            let $glossary-status := $tei[1]//tei:div[@type eq 'glossary']/@status
            where not($glossary-status = $exclude-status)
            
            let $text-type := tei-content:type($tei[1])
            let $glossary-cache := glossary:glossary-cache($tei[1], (), false())
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'text') } {
            
                    attribute id { $text-id }, 
                    attribute type { $text-type },
                    (:attribute count-glosses { count($gloss) },:)
                    
                    $tei[1]//tei:div[@type eq 'glossary']/@status ! attribute glossary-status { . },
                    
                    tei-content:titles-all($tei[1]),
                    
                    if($text-type eq 'translation') then 
                        translation:publication($tei[1])
                    else (),
                    
                    (: Add Toh :)
                    for $toh-key in $tei[1]//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                    return
                        (: Must group these in m:bibl to keep track of @key group :)
                        element bibl {
                            translation:toh($tei[1], $toh-key),
                            tei-content:ancestors($tei[1], $toh-key, 1)
                        }
                    ,
                    
                    for $gloss-single in $gloss
                    let $gloss-id := $gloss-single/@xml:id
                    group by $gloss-id
                    return
                        glossary:glossary-entry($gloss-single[1], false())
                    ,
                    
                    element glossary-cache {
                    
                        let $glossary-id-chunks := common:ids-chunked($gloss/@xml:id)
                        for $key in map:keys($glossary-id-chunks)
                        return
                            $glossary-cache/m:gloss[range:eq(@id, map:get($glossary-id-chunks, $key))]
                        
                    }
                    
                }
        else ()
        
    )
};
