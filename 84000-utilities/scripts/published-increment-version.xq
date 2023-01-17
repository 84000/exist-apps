xquery version "3.0";

(: 
    Force a minor version increment on any published text
    where the last updated date is newer than the last version
    i.e. Find texts that have been updated but no version increment made
    -------------------------------------
    MUCH FASTER IF YOU SWITCH OFF THE TRIGGER
    
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";
import module namespace functx="http://www.functx.com";
    
for $tei in $tei-content:translations-collection//tei:TEI
    [tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $translation:published-status-ids]
    (: Include to limit it to specified texts :)
    (:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-001-001", "UT22084-001-006")]:)

let $id := tei-content:id($tei)
let $version-number-str := tei-content:version-number-str($tei)

let $version-note := 
    for $note in $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@update eq 'text-version'][matches(@value, concat('(^v\s*)?', functx:escape-for-regex($version-number-str)))]
    order by $note/@date-time ! xs:dateTime(.) descending
    return $note

let $lastUpdated-note := $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@type eq 'lastUpdated']
let $version-note-diff := $lastUpdated-note/@date-time ! xs:dateTime(.) - $version-note[1]/@date-time ! xs:dateTime(.)

order by $id

where not($version-note) or functx:total-minutes-from-duration($version-note-diff) ge 5
return (
    $id || ' ' || $version-number-str ||  ' ' || functx:total-hours-from-duration($version-note-diff)(:,
    $version-note:),
    update-tei:minor-version-increment($tei, 'script-increment-version-published')
)
