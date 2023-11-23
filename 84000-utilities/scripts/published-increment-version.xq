xquery version "3.0";

(: 
    Force a minor version increment on any published text
    where the last updated date is newer than the last version
    i.e. Find texts that have been updated but no version increment was made
    -------------------------------------
    MUCH FASTER IF YOU SWITCH OFF THE TRIGGER
    
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";
import module namespace functx="http://www.functx.com";

(: Minutes to allow between file timestamp and version update change to still be the same :)
(: This is necessary as the script takes time, and timestamps are often pre-calculated :)
let $tolerance-mins := 15

(: Ensure trigger is disabled :)
let $xconf-path := concat('/db/system/config',$common:tei-path, '/collection.xconf')
let $trigger := doc($xconf-path)/ex:collection/ex:triggers/ex:trigger

return
    
    if($trigger) then 
        <warning>{ 'DISABLE TRIGGERS - ' || $xconf-path }</warning>
    else 
        
        for $tei in $tei-content:translations-collection//tei:TEI
            (: Include to limit it to published only :)
            [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids]
            (: Include to limit it to specified texts :)
            (:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-001-001", "UT22084-001-006")]:)
        
        let $id := tei-content:id($tei)
        let $version-number-str := tei-content:version-number-str($tei)
        
        let $version-change := 
            for $change in $tei//tei:revisionDesc/tei:change[@type eq 'text-version'][matches(@status, concat('(^v\s*)?', functx:escape-for-regex($version-number-str)))]
            order by $change/@when ! xs:dateTime(.) descending
            return $change
        
        let $file-last-modified := tei-content:last-modified($tei)
        let $version-change-diff := $file-last-modified - $version-change[1]/@when ! xs:dateTime(.)
        
        order by $id
        where not($version-change) or functx:total-minutes-from-duration($version-change-diff) ge $tolerance-mins
        return (
            string-join((
                'ID:' || $id,
                'Version:' || $version-number-str,
                'Version updated:' || format-dateTime($version-change[1]/@when, '[Y0001]-[M01]-[D01]_[H01]-[m01]-[s01]'),
                'File changed:' || format-dateTime($file-last-modified, '[Y0001]-[M01]-[D01]_[H01]-[m01]-[s01]'), 
                format-number(functx:total-minutes-from-duration($version-change-diff) ! xs:integer(.), '#,###') || ' mins between last version and last update',
                'Version note(s): ' || string-join($version-change/tei:desc/text(), ', ')
            ), ', ')
            (:, update-tei:minor-version-increment($tei, 'script-increment-version-published'):)
        )
