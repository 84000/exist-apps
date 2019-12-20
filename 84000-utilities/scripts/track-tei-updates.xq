xquery version "3.1" encoding "UTF-8";

(:
   Tracks recently changed tei files
   Increments the version number
:)

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tei := collection($common:translations-path);

(: select tei where the latest note is not @update="text-version" :)
for $tei in $local:tei//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-068-001", "UT22084-066-016")]:)
(: get notes :)
let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
let $notes := $fileDesc/tei:notesStmt/tei:note
(: get last update :)
let $last-updated-date-time := max($notes/@date-time ! xs:dateTime(.))
(: get notes around that time :)
let $notes-at-last-update :=
    $notes
    [year-from-dateTime(xs:dateTime(@date-time)) eq year-from-dateTime($last-updated-date-time)]
    [month-from-dateTime(xs:dateTime(@date-time)) eq month-from-dateTime($last-updated-date-time)]
    [day-from-dateTime(xs:dateTime(@date-time)) eq day-from-dateTime($last-updated-date-time)]
    [hours-from-dateTime(xs:dateTime(@date-time)) eq hours-from-dateTime($last-updated-date-time)]
    (: filter where there were some non-admin updates but no version update :)
        where
        $notes-at-last-update[not(@user eq 'admin' and @type eq 'lastUpdated')]
        and not($notes-at-last-update[@type eq "updated"][@update eq "text-version"])

let $tei-version-str := translation:version-str($tei)
let $new-version-number-str := translation:version-number-str-increment($tei, 'revision')
let $tei-version-date := translation:version-date($tei)
let $new-editionStmt :=
    element {QName("http://www.tei-c.org/ns/1.0", "editionStmt")} {
        element edition {
            text {'v ' || $new-version-number-str || ' '},
            element date {
                if($tei-version-date) then
                    text { $tei-version-date }
                else
                    format-dateTime(current-dateTime(), '[Y]')
            }
        }
    }
let $add-note :=
    element {QName("http://www.tei-c.org/ns/1.0", "note")} {
        attribute type {'updated'},
        attribute update {'text-version'},
        attribute value { 'v ' || $new-version-number-str },
        attribute date-time {current-dateTime()},
        attribute user {'admin'},
        text {'Automated version increment'}
    }

return
    element debug {
        element text-id {tei-content:id($tei)},
        element last-updated {$last-updated-date-time},
        (:element notes { $notes },:)
        element notes-at-last-update {$notes-at-last-update},
        (:element tei-version-str { $tei-version-str },
        element new-version-str { $new-version-number-str },:)
        $fileDesc/tei:editionStmt,
        $new-editionStmt,
        $add-note,
        (:Update the version number:)
        common:update('text-version', $fileDesc/tei:editionStmt, $new-editionStmt, $fileDesc, $fileDesc/tei:titleStmt),
        (:Add a note about the version update:)
        common:update('add-note', (), $add-note, $tei//tei:fileDesc/tei:notesStmt, ())
    }
