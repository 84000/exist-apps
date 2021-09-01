xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

let $reason-for-increment := 'Publication statement updated'

return
    (: exist:batch-transaction should defer triggers until all updates are made :)
    (# exist:batch-transaction #) {
        
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc[normalize-space(tei:editionStmt/tei:edition/text()[1]) gt ''](:/tei:publicationStmt[@status = $translation:published-status-ids]:)(:[tei:idno/@xml:id eq "UT22084-001-001"]:)]
            let $id := tei-content:id($tei)
            order by $id
            
            let $increment-part := 'revision'
            let $version-str := tei-content:version-str($tei)
            let $version-number-str := tei-content:version-number-str($tei)
            let $version-date := tei-content:version-date($tei)
            let $version-number-str-increment := tei-content:version-number-str-increment($tei, $increment-part)
            
            let $editionStmt := 
                element { QName("http://www.tei-c.org/ns/1.0", "editionStmt") }{
                    element edition {
                        text { 'v ' || $version-number-str-increment || ' ' },
                        element date {
                            text { 
                                if($increment-part eq 'major') then 
                                    format-dateTime(current-dateTime(), '[Y]')
                                else
                                    $version-date
                            }
                        }
                    }
                }
            
            let $note :=
                element { QName("http://www.tei-c.org/ns/1.0", "note") }{
                    attribute type { 'updated' },
                    attribute update { 'text-version' },
                    attribute value { 'v ' || $version-number-str-increment },
                    attribute date-time { current-dateTime() },
                    attribute user { common:user-name() },
                    text { $reason-for-increment }
                }
            
            (:
            let $do-update := (
                common:update('text-version', $tei//tei:fileDesc/tei:editionStmt, $editionStmt, (), ()),
                common:update('add-note', (), $note, $tei//tei:fileDesc/tei:notesStmt, ())
            ):)
            
        return 
            $id || ' / ' || $version-number-str || ' -> ' || $version-number-str-increment
            (: $id || ' / ' || $version-str || ' -> ' || tei-content:version-str($tei) :)
    }