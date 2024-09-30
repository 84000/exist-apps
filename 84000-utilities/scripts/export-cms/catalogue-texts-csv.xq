xquery version "3.1";

(: Export catalogue texts as CSV for importing into CMS :)

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "/db/apps/84000-reading-room/modules/section.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace webflow = "http://read.84000.co/webflow-api" at "/db/apps/84000-operations/modules/webflow-api.xql";
import module namespace functx = "http://www.functx.com";

declare variable $local:section-work-id := (:'UT4CZ5369':)'UT23703';
declare variable $local:section-tei := collection($common:translations-path)//tei:TEI(:[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = $local:section-work-id]:);

(:declare function local:text($tei as element(tei:TEI), $source-id as xs:string) as element(eft:catalogueWork) {
    
    let $text-id := tei-content:id($tei)
    
    let $tei-bibl := $tei/tei:teiHeader//tei:sourceDesc/tei:bibl[@key eq $source-id]
    let $text-toh := translation:toh($tei, $source-id)
    let $titles := translation:titles($tei, $source-id)
    let $summary := translation:summary($tei)
    let $publication-status := translation:publication-status($tei-bibl, ())
    
    (\:'Published', 'Partially Published', 'In Progress', 'Application Pending', 'Not Begun':\)
    let $status-label := 
        if($publication-status[@status-group eq 'published']) then
            if($publication-status[not(@status-group eq 'published')]) then
                'Partially Published'
            else
                'Published'
        else if ($publication-status[@status-group = ('translated', 'in-translation')]) then
            'In Progress'
        else if ($publication-status[@status-group eq 'in-application']) then
            'Application Pending'
        else
            'Not Begun'
    
    let $downloads := translation:downloads($tei, $source-id, 'any-version')
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'catalogueWork') } {
            element toh-sort { concat($text-toh/@number, $text-toh/@letter ! local:letter-to-integer(.) ! concat('.', .), $text-toh/@chapter-number[. gt ''] ! concat('.', .), $text-toh/@chapter-letter ! local:letter-to-integer(.) ! concat('.', .)) },
            element toh-string { $text-toh/eft:full/text() },
            element toh-bibliography-references { ($text-toh/eft:duplicates/eft:full/text(), $text-toh/eft:full/text())[1] },
            element slug { translation:filename($tei, $source-id) },
            element count-pages { sum($publication-status/@count-pages ! xs:integer(.)) },
            element count-pages-published { sum($publication-status[@status-group eq 'published']/@count-pages ! xs:integer(.)) },
            element name { $titles/eft:title[@xml:lang eq 'en'] ! concat('"', ., '"') },
            element sanskrit-title { $titles/eft:title[@xml:lang eq 'Sa-Ltn'] },
            element tibetan-title { $titles/eft:title[@xml:lang eq 'bo'] },
            element section-description { $summary ! string-join(tei:p/descendant::text()) ! normalize-space(.) ! concat('"', ., '"') },
            element status { $status-label },
            element reading-room-link { $downloads/eft:download[@type eq 'html']/@url/string()  },
            element download-pdf-link { $downloads/eft:download[@type eq 'pdf']/@download-url/string() },
            element download-epub-link { $downloads/eft:download[@type eq 'epub']/@download-url/string() }(\:,
            element in-catalogue-section { $webflow:conf//webflow:item[@id eq $tei-bibl/tei:idno/@parent-id/string()]/@webflow-id/string() }:\)
        }

};:)

(:declare function local:letter-to-integer($letter as xs:string) as xs:integer? {
    $letter[. gt ''] ! lower-case(.) ! fn:string-to-codepoints(.)[1] ! . - 96
};:)

let $text-items := 
    for $tei in $local:section-tei[not(descendant::tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'][text()])]
    return
        for $bibl in $tei/descendant::tei:sourceDesc/tei:bibl[@key](:[tei:location[@work = $local:section-work-id]]:)(:[@key = ('toh1691','toh1648','toh2656','toh3749','toh2657','toh2887','toh2214','toh3063','toh3785','toh2739')]:)
        return
            element item {
                element item-id { $webflow:conf//webflow:item[@id eq $bibl/@key]/@webflow-id/string() },
                element toh-key { $bibl/@key/string() },
                element sanskrit-title { '' }
            }

return (

    (:$text-items:)
    
    string-join($text-items[1]/* ! local-name(.), ','),
    
    for $text-item in $text-items
    return
        string-join($text-item/* ! concat('"', replace(string(), '"', '""'), '"'), ',')

)
