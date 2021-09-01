declare namespace tei="http://www.tei-c.org/ns/1.0";
for $tei in collection('/db/apps/84000-data/tei/translations')//tei:TEI
let $first-ref-container := $tei/tei:text/tei:body//tei:*[tei:ref[@type eq 'folio']][1]
where not($first-ref-container/self::tei:p)
return
    $first-ref-container