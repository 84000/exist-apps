xquery version "3.1" encoding "UTF-8";

(:
   Tracks recently changed tei files
   Increments the version number
:)

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace update-tei = "http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";

declare variable $local:tei := collection($common:translations-path);

(: select tei where the latest note is not @update="text-version" :)
for $tei in $local:tei//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-068-001", "UT22084-066-016")]:)
(: get notes :)
let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
let $changes := $fileDesc/tei:revisionDesc/tei:change
(: get last update :)
let $last-updated-date-time := max($changes/@when ! xs:dateTime(.))
(: get notes around that time :)
let $changes-at-last-update :=
    $changes
    [year-from-dateTime(xs:dateTime(@when)) eq year-from-dateTime($last-updated-date-time)]
    [month-from-dateTime(xs:dateTime(@when)) eq month-from-dateTime($last-updated-date-time)]
    [day-from-dateTime(xs:dateTime(@when)) eq day-from-dateTime($last-updated-date-time)]
    [hours-from-dateTime(xs:dateTime(@when)) eq hours-from-dateTime($last-updated-date-time)]

(: filter where there were some non-admin updates but no version update :)
where
    $changes-at-last-update[not(@who eq '#admin')]
    and not($changes-at-last-update[@type eq 'text-version'])

return
    element debug {
        element text-id {tei-content:id($tei)},
        element last-updated {$last-updated-date-time},
        element changes-at-last-update {$changes-at-last-update},
        $fileDesc/tei:editionStmt(:,
        (\:Update the version number:\)
        update-tei:minor-version-increment($tei, 'Automated version increment'):)
    }
