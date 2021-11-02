xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../../84000-operations/modules/update-entity.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:import-texts := collection('/db/apps/84000-data/uploads/tengyur-import');
declare variable $local:tengyur-tei := collection($common:translations-path)//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703']:);

let $import-key := 'tengyur-data-2021-1'

return

(: ENABLE TRIGGER :)
if(not(doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers)) then <warning>{ 'ENABLE TRIGGERS BEFORE RUNNING SCRIPT' }</warning>
else 

(: Look for imported entities without a KB instance :)
for $entity in $entities:entities//m:entity[m:source[matches(@key, concat('^', functx:escape-for-regex($import-key), '#'))]][not(m:instance[@type eq 'knowledgebase-article'])]

let $import-id := $entity/m:source/@key ! replace(., concat('^', functx:escape-for-regex($import-key), '#'), '')
(: Make sure it's attributed somewhere - and only authors for now :)
let $attributions := $local:tengyur-tei/tei:teiHeader//tei:sourceDesc/tei:bibl/tei:author[not(@role)][@ref eq concat('eft:', $entity/@xml:id)]

(:return if(true()) then concat('eft:', $entity/@xml:id) else :)
where $import-id gt '' and $attributions

let $knowledgebase-titles := 
    for $attribution in $local:import-texts//*[@ref eq $import-id]
    let $title-data := $attribution/data()
    group by $title-data
    let $title-lang := common:valid-lang($attribution[1]/@xml:lang)
    (: Prioritise Sanskrit for main title :)
    order by 
        if($title-lang eq 'Sa-Ltn') then 1 else if($title-lang eq 'bo') then 2 else 3 ascending,
        string-length($title-data) ascending
    return 
    (: Skip Bo-Ltn if there's a bo already :)
    if($title-lang eq 'Bo-Ltn' and $attribution[common:valid-lang(@xml:lang) eq 'bo']) then
        ()
    (: Generate Bo-Ltn if there's bo :)
    else if($title-lang eq 'bo') then (
        element { QName('http://www.tei-c.org/ns/1.0', 'title') } {
            attribute xml:lang { 'bo' },
            text { normalize-space($title-data) }
        },
        element { QName('http://www.tei-c.org/ns/1.0', 'title') } {
            attribute xml:lang { 'Bo-Ltn' },
            text { common:wylie-from-bo($title-data) ! replace(., '/$', '') }
        }
    )
    else if($title-lang eq 'Sa-Ltn') then
        element { QName('http://www.tei-c.org/ns/1.0', 'title') } {
            attribute xml:lang { 'Sa-Ltn' },
            text {
                functx:capitalize-first(
                    replace(
                        replace(
                            normalize-space($title-data)    (: Normalize space :)
                        , '^\*', '')                        (: Remove leading * :)
                    , '\-', '­')                            (: Hard to soft-hyphens :)
                )                                           (: Title case :)
            }
        }
    else if($title-lang eq 'en' and $attribution[1][@ref eq 'anon']) then
        element { QName('http://www.tei-c.org/ns/1.0', 'title') } {
            attribute xml:lang { 'en' },
            text { 'Anon' }
        }
    else
        element { QName('http://www.tei-c.org/ns/1.0', 'title') } {
            attribute xml:lang { $title-lang },
            text { normalize-space($title-data) }
        }

(: Prioritise Sanskrit for KB main title :)
let $knowledgebase-titles :=
    for $title at $index in $knowledgebase-titles
    return 
        element { node-name($title) }{
            attribute type { if($index eq 1) then 'mainTitle' else 'otherTitle' },
            $title/@*,
            $title/text()
        }

(: Create an id :)
let $knowledgebase-id := knowledgebase:id($knowledgebase-titles[not(@xml:lang eq 'bo')][1]/text())

(: Check it's not already been created :)
let $knowledgebase-tei := tei-content:tei($knowledgebase-id, 'knowledgebase')

(: Create a KB page :)
let $knowledgebase-add := 
    if(not($knowledgebase-tei)) then
        update-tei:add-knowledgebase($knowledgebase-id, $knowledgebase-titles)
    else ()

let $knowledgebase-tei := 
    if(not($knowledgebase-tei)) then
        tei-content:tei($knowledgebase-id, 'knowledgebase')
    else 
        $knowledgebase-tei

return (

    $entity,
    (:$import-id,:)
    (:$knowledgebase-titles,:)
    
    if($knowledgebase-id) then (
        $knowledgebase-add,
        (: Add instance to entity :)
        update-entity:match-instance($entity/@xml:id, upper-case(concat('eft-kb-', $knowledgebase-id)), 'knowledgebase-article')
    )
    else 'ERROR: ' || $knowledgebase-id
    
)