xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";

declare variable $local:tei := (
    collection($common:translations-path)//tei:TEI
    | collection(concat($common:tei-path, '/layout-checks'))//tei:TEI
);

(: Attributions without entities 
    NOTE: there are lots of these as not all attributions have been assigned :)
declare function local:texts-with-issues() {

    for $attribution in $local:tei//tei:sourceDesc/tei:bibl/tei:author[@xml:id][not(@role eq 'translatorMain')] | $local:tei//tei:sourceDesc/tei:bibl/tei:editor[@xml:id]
    let $attribution-instances := $entities:entities//m:instance[@id = $attribution/@xml:id]
    let $text-id := tei-content:id($attribution/ancestor::tei:TEI)
    where not($attribution-instances)
    order by $text-id
    return 
        $attribution
        
};

(: Entities without attributions :)
declare function local:entities-with-issues() {
    
    for $attribution-instance in $entities:entities//m:instance[@type eq 'source-attribution']
    let $entity := $attribution-instance/parent::m:entity
    let $entity-id := $entity/@xml:id
    let $text-attributions := $local:tei/id($attribution-instance/@id)[self::tei:author | self::tei:editor][not(@role eq 'translatorMain')]
    where count($attribution-instance) gt count($text-attributions)
    group by $entity-id
    return
        element { 'entity' } {
            attribute id { $entity-id },
            $attribution-instance[not(@id = $text-attributions/@xml:id)]
        }
    
};

(: Entities without pages :)
declare function local:authors-without-pages() {
    
    for $attribution in $local:tei//tei:sourceDesc/tei:bibl/tei:author[not(@role eq 'translatorTib')]
    let $attribution-entity := $entities:entities//m:instance[@id eq $attribution/@xml:id]/parent::m:entity
    where not($attribution-entity/m:instance[@type eq 'knowledgebase-article'])
    return 
        element { 'id' } {
            attribute id { $attribution/@xml:id },
            element { 'attribution' } {
                attribute text-id { tei-content:id($attribution/ancestor::tei:TEI[1]) },
                $attribution
            },
            $attribution-entity  
        }
        
};

(: Contribution instances without contributions :)
declare function local:contribution-instances-orphaned() {
    
    for $contribution-instance in $contributors:contributors//m:instance[@type eq 'translation-contribution']
    where 
        count($local:tei/id($contribution-instance/@id)[self::tei:author | self::tei:editor | self::tei:consultant]) ne 1
        and not(matches($contribution-instance/@id, '^UT22084\-000\-000'))
    return
        $contribution-instance
    
};

(:local:texts-with-issues():)
(:local:entities-with-issues():)
(:local:authors-without-pages():)
local:contribution-instances-orphaned()

