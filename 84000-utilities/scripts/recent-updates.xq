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
    let $change := $fileDesc/tei:revisionDesc/tei:change
    (: Get updates in given span :)
    let $start-time := current-dateTime() - xs:yearMonthDuration('P1M')
    let $end-time := current-dateTime()
    let $changes-in-span :=
        $change
            [@when ! xs:dateTime(.) ge $start-time]
            [@when ! xs:dateTime(.) le $end-time]
    where $changes-in-span
    return
        element text {
            attribute text-id {tei-content:id($tei)},
            attribute toh-str {translation:toh-str($fileDesc//tei:bibl[@key][1])},
            attribute status { tei-content:publication-status($tei) },
            $changes-in-span
        }


return (
    'New publications:',
    '-----------------',
    for $text in $recent-notes[tei:change[@type = ('translation-status', 'publication-status')][@status = ('1', '1.a')]]
    return (
        '',
        'Toh ' || $text/@toh-str || ' (' || $text/@text-id || ')' ,
        for $change in $text/tei:change[@type = ('translation-status', 'publication-status')][@status = ('1', '1.a')]
        order by $change/@when ! xs:dateTime(.) ascending
        return
            '- ' || 'Status ' || $change/@status || ' set by ' || $change/@who || ' on ' || $change/@when ! format-dateTime(., '[Y0001]-[M01]-[D01]')
    ),
    '',
    'New versions:',
    '-------------',
    for $text in $recent-notes[@status = ('1', '1.a')][tei:change[@type eq 'text-version']]
    return (
        '',
        'Toh ' || $text/@toh-str || ' (' || $text/@text-id || ')' ,
        for $change in $text/tei:change[@type eq 'text-version']
        order by $change/@when ! xs:dateTime(.) ascending
        return (
            '- ' || 'Version ' || $change/@status || ' created by ' || $change/@who || ' on ' || format-dateTime($change/@when, '[Y0001]-[M01]-[D01]'),
            '  ' || string-join($change/descendant::text() ! normalize-space(), '')
        )
    )
)
    
    