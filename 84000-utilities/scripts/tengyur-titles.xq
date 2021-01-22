xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tengyur-bibl := collection($common:translations-path)//tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work = 'UT23703'];

declare function local:data-item($toh as xs:string, $text-id as xs:string, $type as xs:string, $variant as xs:string?, $lang as xs:string?, $value as xs:string?){
    element { QName('http://read.84000.co/ns/1.0', 'item') } {
        element toh { $toh },
        element text-id { $text-id },
        element type { $type },
        element variant { $variant },
        element lang { $lang },
        element value { $value }
    }
};

element { QName('http://read.84000.co/ns/1.0', 'tengyur-data') } {
    for $bibl in $local:tengyur-bibl
        let $tei := $bibl/ancestor::tei:TEI[1]
        let $text-id := tei-content:id($tei)
        let $toh := translation:toh($tei, $bibl/@key)
        let $titles := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
        let $title-Bo-Ltn := $titles[@type eq 'mainTitle'][@xml:lang eq 'Bo-Ltn'][1]/data()
        let $title-Sa-Ltn := $titles[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'][1]/data()
        let $title-en := $titles[@type eq 'mainTitle'][@xml:lang eq 'en'][1]/data()
        let $authors := $bibl/tei:author
        let $author-1 := $authors[1]
        where $text-id
        order by 
            $toh/@number[. gt ''] ! xs:integer(.), 
            $toh/@letter, 
            $toh/@chapter-number[. gt ''] ! xs:integer(.), 
            $toh/@chapter-letter
            
        return (
                (: 3 main titles required :)
                local:data-item($toh/m:full/text(), $text-id, 'title', 'mainTitle', 'Bo-Ltn', $title-Bo-Ltn),
                local:data-item($toh/m:full/text(), $text-id, 'title', 'mainTitle', 'Sa-Ltn', $title-Sa-Ltn),
                local:data-item($toh/m:full/text(), $text-id, 'title', 'mainTitle', 'en', $title-en),
                (: other titles :)
                for $title in $titles[not(data() = ($title-Bo-Ltn, $title-Sa-Ltn, $title-en))]
                return
                    local:data-item($toh/m:full/text(), $text-id, 'title', $title/@type, $title/@xml:lang, $title/data())
                ,
                (: main author required :)
                local:data-item($toh/m:full/text(), $text-id, 'author', $author-1/@role, $author-1/@xml:lang, $author-1/data()),
                (: other authors :)
                for $author in $authors[not(data() = $author-1/data())]
                return
                    local:data-item($toh/m:full/text(), $text-id, 'author', $author/@role, $author/@xml:lang, $author/data())
                ,
                (: blank row between texts :)
                local:data-item('-', '', '', '', '', '')
            )
}
