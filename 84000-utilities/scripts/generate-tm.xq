xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../../84000-operations/modules/update-tm.xql";

declare variable $local:tei := collection($common:translations-path);
declare variable $local:tm := collection($update-tm:tm-path);
declare variable $local:txt-data-path := concat($common:data-path, '/uploads/linguae-dharmae/aligned/31-10-2022/complete/');
declare variable $local:txt-file-string := '-bo_aligned.txt';

(: Published texts with no TM :)
for $tei in $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $translation:published-status-ids]
let $text-id := tei-content:id($tei)
let $tmx := $local:tm//tmx:tmx[tmx:header/@eft:text-id eq $text-id]
where not($tmx) and $text-id eq 'UT22084-034-009'(:'UT22084-040-002':)(:'UT22084-001-006':)(:'UT22084-042-002':)

(: Generate TM :)
let $filename := concat(translation:filename($tei, ''), '.tmx')
let $tmx := update-tm:new-tmx-from-linguae-dharmae($tei, $local:txt-data-path, $local:txt-file-string)

where $filename and $tmx
return (
    (:$filename,:)
    (:$tmx,:)
    (: Save TM :)
    update-tm:store-tmx($tmx, $filename)
)