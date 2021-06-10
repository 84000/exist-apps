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
        <entity-type id="eft-glossary-term" group="glossary-item">Term (gloss.)</entity-type>
        <entity-type id="eft-glossary-person" group="glossary-item">Person (gloss.)</entity-type>
        <entity-type id="eft-glossary-place" group="glossary-item">Place (gloss.)</entity-type>
        <entity-type id="eft-glossary-text" group="glossary-item">Text (gloss.)</entity-type>
        <entity-type id="eft-attribution-person" group="attribution">Person (attr.)</entity-type>
    </entity-types>;
    
declare variable $entities:instance-types := ('glossary-item');

declare function entities:entities($instance-ids as xs:string*) as element() {
    
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        if(count($instance-ids) gt 0) then
            $entities:entities/m:entity[m:instance[@id = $instance-ids]]
        else ()
    }
    
};

declare function entities:next-id() as xs:string {
    
    let $max-id := max($entities:entities//@xml:id ! substring-after(., 'entity-') ! common:integer(.))
    return
        string-join(('entity', xs:string(sum(($max-id, 1)))), '-')
    
};

declare function entities:instances($entity as element(m:entity)?) {

    for $matched-item in glossary:items($entity/m:instance[@type eq 'glossary-item']/@id/string(), true())
    return
        element { node-name($matched-item) } {
            $matched-item/@*,
            $matched-item/node(),
            entities:entities($matched-item/@id)/m:entity[1]
        }
    ,
    
    for $matched-item in knowledgebase:pages(($entity/m:instance[@type eq 'knowledgebase-article']/@id/string(), 'DUMMY'))
    return
        element { node-name($matched-item) } {
            $matched-item/@*,
            $matched-item/node(),
            entities:entities($matched-item/@id)/m:entity[1]
        }
        
};

declare function entities:similar($entity as element(m:entity)?, $search-terms as xs:string*, $exclude-ids as xs:string*)  {
    
    let $instance-items := glossary:items($entity/m:instance/@id, false())
    
    let $search-terms := (
        $search-terms,
        $instance-items/m:term[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data(),
        $instance-items/m:alternatives[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data()
    ) ! distinct-values(.)
    
    let $exclude-ids := (
        $exclude-ids,
        (: Exclude matched instances :)
        $entity/m:instance/@id/string(), 
        (: Exclude related instances :)
        $entities:entities/m:entity[@xml:id/string() = $entity/m:relation/@id/string()]/m:instance/@id/string(),
        $entities:entities/m:entity[m:relation/@id/string() = $entity/@xml:id/string()]/m:instance/@id/string()
    ) ! distinct-values(.)
    
    let $search-query :=
        <query>
        {
            for $term in $search-terms
            let $normalized-term := common:alphanumeric(common:normalized-chars($term))
            where $normalized-term gt ''
            return
                <phrase slop="0">{ $normalized-term }</phrase>
        }
        </query>
    
    let $gloss-matches :=
        $glossary:translations//tei:back//tei:gloss
            [tei:term
                [ft:query(., $search-query)]
                [not(@type eq 'definition')]
                [@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]
            ]
            [not(@xml:id/string() = $exclude-ids)]
    
    let $kb-matches :=
            $knowledgebase:pages//tei:teiHeader/tei:fileDesc
                [tei:titleStmt/tei:title
                    [ft:query(., $search-query)]
                ]/tei:publicationStmt/tei:idno
                    [@xml:id]
                    [not(@xml:id/string() = $exclude-ids)]
    
    for $similar-entity in $entities:entities/m:entity[m:instance[@id/string() = ($gloss-matches/@xml:id | $kb-matches/@xml:id) ! string()]]
    order by if($similar-entity[m:label/text() = $search-terms]) then 1 else 0 descending
    return
        (: Copy entity expanded to include instance detail :)
        element { node-name($similar-entity) } {
            $similar-entity/@*,
            $similar-entity/*[not(self::m:instance)],
            for $instance in $similar-entity/m:instance
            return
                element { node-name($instance) } {
                    $instance/@*,
                    glossary:items($instance/@id, true()),
                    knowledgebase:pages($instance/@id)
                }
        }
};
