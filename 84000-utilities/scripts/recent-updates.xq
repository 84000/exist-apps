xquery version "3.1" encoding "UTF-8";

(:
   Tracks recently changed tei files
:)

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tei := collection($common:translations-path);

let $recent-notes :=  
    (: select tei where the latest note is not @update="text-version" :)
    for $tei in $local:tei//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-068-001", "UT22084-066-016")]:)
    let $text-id := tei-content:id($tei)
    (: get notes :)
    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    let $notes := $fileDesc/tei:notesStmt/tei:note
    (: Get updates in given span :)
    let $start-time := current-dateTime() - xs:yearMonthDuration('P1M')
    let $end-time := current-dateTime()
    let $notes-in-span :=
        $notes
            [@type eq "updated"]
            [xs:dateTime(@date-time) ge $start-time]
            [xs:dateTime(@date-time) le $end-time]
    where $notes-in-span
    return
        element text {
            attribute text-id {tei-content:id($tei)},
            attribute toh-str {translation:toh-str($fileDesc//tei:bibl[1])},
            attribute status { tei-content:translation-status($tei) },
            $notes-in-span
        }


return (
    'New publications:',
    '-----------------',
    for $text in $recent-notes[tei:note[@update eq 'translation-status'][@value = ('1', '1.a')]]
    return (
        '',
        'Toh ' || $text/@toh-str || ' (' || $text/@text-id || ')' ,
        for $note in $text/tei:note[@update eq 'translation-status'][@value = ('1', '1.a')]
        order by $note/@date-time ! xs:dateTime(.) ascending
        return
            '- ' || 'Status ' || $note/@value || ' set by ' || $note/@user || ' on ' || format-dateTime($note/@date-time, '[Y0001]-[M01]-[D01]')
    ),
    '',
    'New versions:',
    '-------------',
    for $text in $recent-notes[@status = ('1', '1.a')][tei:note[@update eq 'text-version']]
    return (
        '',
        'Toh ' || $text/@toh-str || ' (' || $text/@text-id || ')' ,
        for $note in $text/tei:note[@update eq 'text-version']
        order by $note/@date-time ! xs:dateTime(.) ascending
        return (
            '- ' || 'Version ' || $note/@value || ' created by ' || $note/@user || ' on ' || format-dateTime($note/@date-time, '[Y0001]-[M01]-[D01]'),
            '  ' || string-join($note/descendant::text() ! normalize-space(), '')
        )
    )
)
    
    