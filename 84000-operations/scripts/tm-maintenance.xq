xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../modules/update-tm.xql";

declare variable $local:text-id external;

declare variable $local:tm := collection($update-tm:tm-path);

let $tei := tei-content:tei($local:text-id, 'translation')

let $tmx := $local:tm//tmx:tmx[tmx:header/@eft:text-id eq $local:text-id]

where $tei and $tmx

return 
    update-tm:apply-revisions($tei, $tmx)
