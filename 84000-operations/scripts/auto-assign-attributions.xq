xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace update-entity = "http://operations.84000.co/update-entity" at "/db/apps/84000-operations/modules/update-entity.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace store="http://read.84000.co/store" at "/db/apps/84000-reading-room/modules/store.xql";

(:element results {
    update-entity:auto-assign-attributions('UT22084-001-001'),
    update-entity:auto-assign-attributions('UT22084-001-006'),
    update-entity:auto-assign-attributions('UT22084-029-001'),
    update-entity:auto-assign-attributions('UT22084-031-002'),
    update-entity:auto-assign-attributions('UT22084-034-009')
}:)

let $results :=
    element results {
        for $tei in $tei-content:translations-collection//tei:TEI[descendant::tei:sourceDesc/tei:bibl/tei:*[self::tei:author | self::tei:editor]]
        let $text-id := tei-content:id($tei)
        return
            update-entity:auto-assign-attributions($text-id)
    }

return
    store:file('/db/apps/84000-data/uploads', 'auto-assign-attributions.xml', $results, 'application/xml')

