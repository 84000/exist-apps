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

let $version-change := 
    for $change in $tei//tei:revisionDesc/tei:change[@type eq 'text-version'][matches(@status, concat('(^v\s*)?', functx:escape-for-regex($version-number-str)))]
    order by $change/@when ! xs:dateTime(.) descending
    return $change/tei:desc/text()

let $version-change-diff := tei-content:last-modified($tei) - $version-change[1]/@when ! xs:dateTime(.)

order by $id

where not($version-change) or functx:total-minutes-from-duration($version-change-diff) ge 5
return (
    $id || ' ' || $version-number-str ||  ' ' || functx:total-hours-from-duration($version-change-diff),
    $version-change(:,
    update-tei:minor-version-increment($tei, 'script-increment-version-published'):)
)
