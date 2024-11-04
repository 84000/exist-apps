xquery version "3.0" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace eft = "http://read.84000.co/ns/1.0";

import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";

let $tei-restricted := $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/descendant::tei:p[@type eq 'tantricRestriction']]

return
    concat("('", string-join($tei-restricted ! tei-content:id(.), "','"), "')")
    