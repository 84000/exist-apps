xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "/db/apps/84000-reading-room/modules/entities.xql";
import module namespace glossary="http://read.84000.co/glossary" at "/db/apps/84000-reading-room/modules/glossary.xql";
import module namespace translation="http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "/db/apps/84000-operations/modules/update-entity.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:text-id := 'UT22084-045-001';
declare variable $local:toh94 := tei-content:tei($local:text-id, 'translation');
declare variable $local:entity-thousand-buddhas-id := 'entity-28447';
declare variable $local:entity-thousand-buddhas := $entities:entities//m:entity[@xml:id eq $local:entity-thousand-buddhas-id];

(: Assigns the thousand buddha entities to the group entity :)
declare function local:assign-thousand-buddhas() {
    
    let $gloss-thousand-buddhas := $local:toh94//tei:back//tei:gloss[tei:term[@type eq 'definition'][matches(data(), '\d+\samong\sthe\sbuddhas\sof\sthe\sgood\seon\saccording\sto\s', 'i')]]
    
    let $relation-thousand-buddhas :=
        for $gloss in $gloss-thousand-buddhas
        let $entity := $entities:entities//m:entity[m:instance/@id eq $gloss/@xml:id]
        where $entity
        return 
            element { QName('http://read.84000.co/ns/1.0', 'relation') } {
                attribute predicate { 'hasMember' },
                attribute id { $entity/@xml:id },
                common:ws(3),
                $entity/m:label[1],
                common:ws(2)
            }
    
    let $relation-existing := $local:entity-thousand-buddhas/m:relation[@id = $relation-thousand-buddhas/@id]
    
    (: Extend existing entity :)
    let $entity-thousand-buddhas-new := 
        element { node-name($local:entity-thousand-buddhas) } {
            
            $local:entity-thousand-buddhas/@*,
            
            (: Add existing elements :)
            for $element in $local:entity-thousand-buddhas/* except $relation-existing
            return (
                common:ws(2),
                $element
            ),
            
            (: Add new relations :)
            for $relation in $relation-thousand-buddhas
            return (
                common:ws(2),
                $relation
            ),
            
            common:ws(1)
        }
    
    where $local:entity-thousand-buddhas
    return 
        common:update('assign-thousand-buddhas', $local:entity-thousand-buddhas, $entity-thousand-buddhas-new, (), ())
};

declare function local:analyze-thousand-buddhas($update-definition as xs:boolean) {

    (# exist:batch-transaction #) {
    
    (: Thousand buddhas entities :)
    let $thousand-buddhas-entity-ids := $local:entity-thousand-buddhas/m:relation[@predicate eq 'hasMember']/@id
    (: Thousand buddhas glossary ids :)
    let $thousand-buddhas-gloss-ids := $entities:entities//m:entity/id($thousand-buddhas-entity-ids)/m:instance[@type eq 'glossary-item']/@id/string()
    
    (: Parse the html :)
    let $list-of-names-id := 'UT22084-045-001-section-2-A'
    let $list-of-names-html := collection(concat('/db/apps/84000-data/html/translation/toh94/html_en_html_', lower-case($list-of-names-id), '_default_'))//xhtml:section[@id eq $list-of-names-id]
    let $list-of-names-nodes := $list-of-names-html//*[@data-glossary-id = $thousand-buddhas-gloss-ids]
    
    let $list-of-biographies-id := 'UT22084-045-001-section-2-B'
    let $list-of-biographies-html := collection(concat('/db/apps/84000-data/html/translation/toh94/html_en_html_', lower-case($list-of-biographies-id), '_default_'))//xhtml:section[@id eq $list-of-biographies-id]
    let $list-of-biographies-nodes := $list-of-biographies-html//*[@data-glossary-id = $thousand-buddhas-gloss-ids]
    
    let $list-of-occasions-id := 'UT22084-045-001-section-2-C'
    let $list-of-occasions-html := collection(concat('/db/apps/84000-data/html/translation/toh94/html_en_html_', lower-case($list-of-occasions-id), '_default_'))//xhtml:section[@id eq $list-of-occasions-id]
    let $list-of-occasions-nodes := $list-of-occasions-html//*[@data-glossary-id = $thousand-buddhas-gloss-ids]
    
    (: loop the glossary items :)
    for $buddha-gloss-id in $thousand-buddhas-gloss-ids
    let $gloss := $local:toh94//tei:back//tei:gloss/id($buddha-gloss-id)
    
    let $list-of-names-node := $list-of-names-nodes[@data-glossary-id eq $buddha-gloss-id]
    let $list-of-names-index := $list-of-names-node ! functx:index-of-node($list-of-names-nodes, .)
    
    let $list-of-biographies-node := $list-of-biographies-nodes[@data-glossary-id eq $buddha-gloss-id]
    let $list-of-biographies-index := $list-of-biographies-node ! functx:index-of-node($list-of-biographies-nodes, .)
    
    let $list-of-occasions-node := $list-of-occasions-nodes[@data-glossary-id eq $buddha-gloss-id]
    let $list-of-occasions-index := $list-of-occasions-node ! functx:index-of-node($list-of-occasions-nodes, .)
    
    let $definition :=
        string-join ((
            (
                if($list-of-names-index) then
                    $list-of-names-index ! concat('The ', functx:ordinal-number-en(.), ' buddha in the first list,')
                else 'Not listed as a buddha in the first list,'
            ),
            (
                if($list-of-biographies-index) then
                    $list-of-biographies-index ! concat(functx:ordinal-number-en(.),' in the second list,')
                else 'not listed in the second list,'
            ),
            (
                if($list-of-occasions-index) then
                    $list-of-occasions-index ! concat('and ',functx:ordinal-number-en(.), ' in the third list.')
                else 'and not listed in the third list.'
            )
        ), ' ')
    
    where $gloss
    order by $list-of-names-index[1] ! xs:integer(.)
    return 
        element buddha {
        
            attribute name { $gloss/tei:term[1] },
            (:attribute buddha-gloss-id { $buddha-gloss-id },:)
            attribute gloss-id { $gloss/@xml:id },
            attribute position-list-of-names { string-join($list-of-names-index, ',') },
            attribute position-list-of-biographies { string-join($list-of-biographies-index, ',') },
            attribute position-list-of-occasions { string-join($list-of-occasions-index, ',') },
            attribute glossary-definition { $definition },
            if($update-definition)then
            
                let $current-definition := $gloss/tei:term[@type eq 'definition'][1]
                let $new-definition :=
                    element { node-name($current-definition) }{
                        $current-definition/@*,
                        text { $definition }
                    }
                
                return ( 
                    $new-definition,
                    common:update('update-gloss', $current-definition, $new-definition, $gloss, ())
                )
            else ()
        }
    }
};

(:local:assign-thousand-buddhas():)
local:analyze-thousand-buddhas(false())