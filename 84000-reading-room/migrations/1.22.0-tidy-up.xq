xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";

declare variable $local:tei := collection($common:translations-path);

(: Remove the sponsorship status attribute from the TEI file :)
let $remove-tei-sponsored :=
    for $tei in $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/@sponsored]
    return
        common:update(
            'remove-sponsored', 
            $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/@sponsored,
            (),
            (),
            ()
        )

return
    'Tidied up after 1.22.0'