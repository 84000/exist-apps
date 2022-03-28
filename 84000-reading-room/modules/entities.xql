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

declare variable $entities:instance-types := ('glossary-item', 'knowledgebase-article');

declare function entities:next-id() as xs:string {
    
    let $max-id := max($entities:entities//@xml:id ! substring-after(., 'entity-') ! common:integer(.))
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
    
    let $matching-instance-ids := (
        $glossary:tei//tei:back//tei:gloss[tei:term[ft:query(., $search-query)][not(@type eq 'definition')][@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]] except $exclude-gloss,
        $knowledgebase:tei-render//tei:teiHeader/tei:fileDesc[tei:titleStmt/tei:title[ft:query(., $search-query)]]/tei:publicationStmt/tei:idno except $exclude-page
    )/@xml:id/string()
    
    let $matching-instance-ids := distinct-values($matching-instance-ids)
    let $matching-instance-ids := subsequence($matching-instance-ids, 1, 1024)
    
    let $matching-entity-ids := (
        $glossary:tei//tei:teiHeader//tei:sourceDesc/tei:bibl/tei:author
            [ft:query(., $search-query)][@ref]
        | $glossary:tei//tei:teiHeader//tei:sourceDesc/tei:bibl/tei:editor
            [ft:query(., $search-query)][@ref]
    )/@ref/string() ! replace(., '^eft:', '')
    
    let $matching-entity-ids := distinct-values($matching-entity-ids)
    let $matching-entity-ids := subsequence($matching-entity-ids, 1, 1024)
    
    return 
        
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
            $similar-entity
           
};

declare function entities:related($entities as element(m:entity)*) as element()* {
    entities:related($entities, false(), 'requires-attention', 'excluded')
};

declare function entities:related($entities as element(m:entity)*, $include-unrelated as xs:boolean, $exclude-flagged as xs:string*, $exclude-status as xs:string*) as element()* {

    (: Related entities :)
    let $related-entities := (
        if($include-unrelated) then (
            $entities:entities//m:entity/id($entities/m:relation/@id)
            | $entities:entities//m:entity[m:relation[@id = $entities/@xml:id]]
        )
        else (
            $entities:entities//m:entity/id($entities/m:relation[not(@predicate eq 'isUnrelated')]/@id)
            | $entities:entities//m:entity[m:relation[not(@predicate eq 'isUnrelated')][@id = $entities/@xml:id]]
        )
    )
    
    (: All the entities we want data about :)
    let $lookup-entities := ($entities | $related-entities)
    let $exclude-instances := $lookup-entities/m:instance[m:flag[@type = $exclude-flagged]]
    let $lookup-instances := $lookup-entities/m:instance except $exclude-instances
    
    return (
    
        $related-entities,
    
        (: Related glossaries - grouped by text :)
        
        for $gloss in $glossary:tei//id($lookup-instances[@type eq 'glossary-item']/@id)/self::tei:gloss
        
        let $tei := $gloss/ancestor::tei:TEI
        let $text-id := tei-content:id($tei)
        let $glossary-status := $tei//tei:div[@type eq 'glossary']/@status
        where not($glossary-status = $exclude-status)
        group by $text-id
        let $text-type := tei-content:type($tei[1])
        return
            element { QName('http://read.84000.co/ns/1.0', 'text') } {
        
                attribute id { $text-id }, 
                attribute type { $text-type },
                $tei//tei:div[@type eq 'glossary']/@status ! attribute glossary-status { . },
                
                tei-content:titles($tei[1]),
                if($text-type eq 'translation') then (
                    translation:toh($tei[1], ''),
                    translation:publication($tei[1])
                )
                else (),
                
                $gloss ! glossary:glossary-entry(., false())
                
            },
        
        (: Related articles :)
        knowledgebase:pages($lookup-instances[@type eq 'knowledgebase-article']/@id, true())
        
    )
};
