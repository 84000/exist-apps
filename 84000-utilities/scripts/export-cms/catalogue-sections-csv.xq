xquery version "3.1";

(: Export catalogue sections as CSV for importing into CMS :)

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "/db/apps/84000-reading-room/modules/section.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace functx = "http://www.functx.com";

declare function local:section($section-id as xs:string, $index-in-parent as xs:integer) {
    
    let $tei := tei-content:tei($section-id, 'section')
    
    let $child-texts :=
        for $child-text-tei in $section:texts//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
        let $text-id := tei-content:id($child-text-tei)
        return
            for $child-text-tei-bibl in $child-text-tei/tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $section-id]]
            let $source-id := $child-text-tei-bibl/@key
            return
                local:text($child-text-tei, $source-id)
    
    let $child-sections :=
        let $child-sections-tei := 
            for $child-section-tei in $section:sections//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
            order by $child-section-tei/tei:teiHeader//tei:sourceDesc/@sort-index ! xs:integer(.) ascending
            return
                $child-section-tei
        
        for $child-section-tei at $child-section-index in $child-sections-tei
        let $child-section-id := tei-content:id($child-section-tei)
        return
            local:section($child-section-id, $child-section-index)
    
    let $title-bo := string-join(($tei//tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'bo'])[1]/text()) ! normalize-space(.)
    let $title-wy := (
        string-join(($tei//tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'Bo-Ltn'])[1]/text())[. gt ''] ! normalize-space(.),
        string-join(($tei//tei:titleStmt/tei:title[@type eq 'otherTitle'][@xml:lang eq 'Bo-Ltn'])[1]/text()[. gt '']) ! normalize-space(.)
    )[1]
    
    let $title-bo := 
        if(not($title-bo) and $title-wy) then
            common:bo-from-wylie($title-wy)
        else
            $title-bo
    
    return (
        element { QName('http://read.84000.co/ns/1.0', 'row') } {
            element name { string-join(($tei//tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'en'])[1]/text()) ! normalize-space(.) ! concat('"', ., '"') },
            element tibetan-title { $title-bo },
            element sanskrit-title { string-join(($tei//tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'])[1]/text()) ! normalize-space(.) },
            element section-description { string-join($tei//tei:div[@type eq 'abstract']/tei:p/text()) ! normalize-space(.) ! concat('"', ., '"') },
            (:element impact-description { },:)
            element slug { $tei//tei:publicationStmt/tei:idno[@type eq 'eft-kb-id']/text() },
            element child-texts-count { count($child-texts) },
            element texts-count { count($child-texts) + sum($child-sections/eft:child-texts-count/text() ! xs:integer(.)) },
            element child-texts-published { count($child-texts[@publicationStatusGroup = ('published')]) },
            element texts-published { count($child-texts[@publicationStatusGroup = ('published')]) + sum($child-sections/eft:child-texts-published/text() ! xs:integer(.)) },
            element child-texts-in-progress { count($child-texts[@publicationStatusGroup = ('translated','in-translation')]) },
            element texts-in-progress { count($child-texts[@publicationStatusGroup = ('translated','in-translation')]) + sum($child-sections/eft:child-texts-in-progress/text() ! xs:integer(.)) },
            element child-texts-not-begun { count($child-texts[not(@publicationStatusGroup = ('published','translated','in-translation'))]) },
            element texts-not-begun { count($child-texts[not(@publicationStatusGroup = ('published','translated','in-translation'))]) + sum($child-sections/eft:child-texts-not-begun/text() ! xs:integer(.))  },
            element toh-first { min(($child-texts/@toh-number | $child-sections/eft:toh-first/text()) ! xs:integer(.)) },
            element toh-last { max(($child-texts/@toh-number | $child-sections/eft:toh-last/text()) ! xs:integer(.)) }
        },
        
        $child-sections
        
    )
    
};

declare function local:text($tei as element(tei:TEI), $source-id as xs:string) as element() {
    
    let $text-id := tei-content:id($tei)
    
    let $text-bibl := $tei/tei:teiHeader//tei:sourceDesc/tei:bibl[@key eq $source-id]
    let $text-toh := translation:toh($tei, $source-id)
    
    let $child-text-start-volume-number := min($text-bibl/tei:location/tei:volume/@number ! xs:integer(.))
    let $child-text-start-volume := $text-bibl/tei:location/tei:volume[@number ! xs:integer(.) eq $child-text-start-volume-number]
    let $child-text-start-page-number := min($child-text-start-volume/@start-page ! xs:integer(.))
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'catalogueWork') } {
            attribute catalogueWorkId { $source-id },
            attribute toh-number { $text-toh/@number },
            attribute startVolumeNumber { $child-text-start-volume-number },
            attribute startVolumeStartPageNumber { $child-text-start-page-number },
            attribute publicationStatusGroup { tei-content:publication-status-group($tei) }
        }

};

let $catalogue-sections := (
    (:local:section('O1JC11494', 1),:)
    local:section('O1JC7630', 1)
)

return (

    (:$catalogue-sections,:)
    
    string-join($catalogue-sections[1]/* ! local-name(.), ','),
    
    for $catalogue-section in $catalogue-sections
    return
        string-join($catalogue-section/*/string(), ',')

)