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
    </entity-types>;

declare variable $entities:instance-types := ('glossary-item');

declare function entities:entities($instance-ids as xs:string*, $validate as xs:boolean, $expand as xs:boolean) as element(m:entities) {
    
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        
        (: Check that the instance target exists :)
        let $instance-ids := 
            if($validate) then 
                entities:instance-ids-validated($instance-ids)
            else
                $instance-ids
        
        return
            $entities:entities/m:entity[m:instance/@id/string() = $instance-ids] ! entities:entity(., $validate, $expand)
        
    }
    
};

declare function entities:next-id() as xs:string {
    
    let $max-id := max($entities:entities//@xml:id ! substring-after(., 'entity-') ! common:integer(.))
    return
        string-join(('entity', xs:string(sum(($max-id, 1)))), '-')
    
};

declare function entities:instance-ids-validated($instance-ids as xs:string*) as xs:string* {
    (
        $glossary:tei//tei:back//id($instance-ids)[self::tei:gloss]/@xml:id/string(),
        $knowledgebase:tei-published//tei:publicationStmt//id($instance-ids)[self::tei:idno]/@xml:id/string()
    )
};

(: Validates and expands an entity :)
declare function entities:entity($entity as element(m:entity)?, $validate as xs:boolean, $expand as xs:boolean)  as element(m:entity)? {
    
    if($entity) then
        element { node-name($entity) } {
        
            $entity/@*,
            $entity/*[not(self::m:label or self::m:instance)],
            
            (: If there's no primary label assign one :)
            if($expand and not($entity/m:label[@primary eq 'true'])) then
                for $label at $index in $entity/m:label
                return (
                    element { node-name($label) } {
                        $label/@*,
                        if($index eq 1) then
                            attribute primary { true() }
                        else (),
                        $label/node()
                    },
                    if($index eq 1) then
                        if($label[@xml:lang eq 'bo']) then
                            element label {
                                attribute xml:lang { 'Bo-Ltn' },
                                attribute primary-transliterated { true() },
                                text {
                                    common:wylie-from-bo(normalize-space($label/text())) ! replace(., '/$', '')
                                }
                            }
                        else if($label[@xml:lang eq 'Bo-Ltn']) then
                            element label {
                                attribute xml:lang { 'bo' },
                                attribute primary-transliterated { true() },
                                text {
                                    common:bo-from-wylie(normalize-space($label/text()))
                                }
                            }
                        else ()
                    else ()
                )
            
            (: Otherwise copy labels :)
            else 
                $entity/m:label
            ,
            
            (: Check that the instance target exists :)
            let $instance-ids := $entity/m:instance/@id/string()
            
            let $instance-ids :=
                if($validate) then
                    entities:instance-ids-validated($entity/m:instance/@id/string())
                else
                    $instance-ids
                    
            let $valid-instances := $entity/m:instance[@id/string() = $instance-ids]
            
            return
                if($expand) then
                
                    for $instance in $valid-instances
                    let $instance-element := glossary:items($instance/@id, true())
                    let $instance-element :=
                        if(not($instance-element)) then
                            knowledgebase:pages($instance/@id, true())
                        else
                            $instance-element
                    where $instance-element
                    return
                        element { node-name($instance) } {
                            $instance/@*,
                            $instance-element
                        }
                        
                else
                    $valid-instances
                
        }
    else ()
    
};

declare function entities:similar($entity as element(m:entity)?, $search-terms as xs:string*, $exclude-ids as xs:string*)  {
    
    let $instance-items := glossary:items($entity/m:instance/@id, false())
    
    let $search-terms := distinct-values((
        $search-terms,
        $instance-items/m:term[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data(),
        $instance-items/m:alternatives[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]/data()
    ) ! common:alphanumeric(common:normalized-chars(lower-case(.))))
    
    let $exclude-ids := distinct-values((
        $exclude-ids,
        (: Exclude matched instances :)
        $entity/m:instance/@id/string(), 
        (: Exclude related instances :)
        $entities:entities/m:entity/@xml:id[. = $entity/m:relation/@id]/m:instance/@id/string(),
        $entities:entities/m:entity[m:relation/@id[. = $entity/@xml:id]]/m:instance/@id/string()
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
    
    let $matches := (
        $glossary:tei//tei:back//tei:gloss
            [tei:term
                [ft:query(., $search-query)]
                [not(@type eq 'definition')]
                [@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]
            ][@xml:id][not(@xml:id = $exclude-ids)]
        ,
        $knowledgebase:tei//tei:teiHeader/tei:fileDesc
            [tei:titleStmt/tei:title
                [ft:query(., $search-query)]
            ]/tei:publicationStmt/tei:idno[@xml:id][not(@xml:id = $exclude-ids)]
    )/@xml:id/string()
    
    for $similar-entity in $entities:entities/m:entity[m:instance/@id[. = $matches]]
    order by if($similar-entity[m:label/text() = $search-terms]) then 1 else 0 descending
    return 
        (: Copy entity expanded to include instance detail :)
        entities:entity($similar-entity, false(), true())
};
