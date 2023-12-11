import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $teis := subsequence(collection('/db/apps/84000-data/tei/translations')//tei:fileDesc[tei:publicationStmt/tei:availability/@status gt ''][not(tei:editionStmt)]/ancestor::tei:TEI, 1,5)
for $tei in $teis
return (
    string-join($tei//tei:fileDesc/tei:sourceDesc/tei:bibl/tei:ref/data(), ' / '),
    update-tei:minor-version-increment($tei, 'script-increment-version-published')
)