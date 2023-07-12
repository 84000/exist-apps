xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

declare variable $local:source-collection := $common:knowledgebase-path;
declare variable $local:target-collection := concat($common:knowledgebase-path, '/authors');

let $knowledgebase-author-ids := 
    for $attribution in collection($common:translations-path)//tei:TEI//tei:sourceDesc/tei:bibl/tei:author[@xml:id]
    let $attribution-entity := $entities:entities//m:instance[@id eq $attribution/@xml:id]/parent::m:entity
    return
        $attribution-entity/m:instance[@type eq 'knowledgebase-article']/@id

let $move-ids := distinct-values($knowledgebase-author-ids) (:('EFT-KB-JAYASENA'):)

for $tei in collection($local:source-collection)//tei:TEI
let $current-path := base-uri($tei)
let $file-name := $current-path ! tokenize(., '/')[last()]
let $target-path := concat($local:target-collection, '/', $file-name)
let $text-id := tei-content:id($tei)
where 
    $text-id = $move-ids
    and not($current-path eq $target-path)
return (
    $text-id || ' to ' || $target-path,
    xmldb:move($local:source-collection, $local:target-collection, $file-name)
)