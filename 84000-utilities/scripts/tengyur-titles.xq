xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tengyur-tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

element tengyur-titles {
for $tei in $local:tengyur-tei
let $text-id := tei-content:id($tei)
let $toh := translation:toh($tei, '')
let $titles := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
where $text-id
order by $toh/@number[. gt ''] ! xs:integer(.), $toh/@letter, $toh/@chapter-number[. gt ''] ! xs:integer(.), $toh/@chapter-letter
return
    element text {
        element text-id { $text-id },
        element toh { $toh/m:full/text() },
        element title-main-wy { $titles[@type eq 'mainTitle'][@xml:lang eq 'Bo-Ltn']/text() },
        element title-main-sa { $titles[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn']/text() },
        element title-main-en { $titles[@type eq 'mainTitle'][@xml:lang eq 'en']/text() }
    }
    
}