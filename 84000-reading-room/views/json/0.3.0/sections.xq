xquery version "3.1";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace section = "http://read.84000.co/section" at "../../../modules/section.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.3.0';

declare function local:parse-sections() {

    (:
        Edge cases:
    :)
    
    local:section('O1JC11494', 1),
    local:section('O1JC7630', 1)
    
};

declare function local:section($section-id as xs:string, $index-in-parent as xs:integer) {
    
    let $section-tei := tei-content:tei($section-id, 'section')
    return
        element section {
            attribute catalogueSectionId { $section-id },
            (:attribute uri { concat('/section/', $section-id,'.json?api-version=', $api-version) },:)
            (:attribute cacheKey { $cache-key },:)
            attribute htmlUrl { concat('https://read.84000.co', '/section/', $section-id,'.html') },
            
            $section-tei/tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno/@parent-id[not(. eq 'LOBBY')] ! (
                attribute parentSectionId { . },
                attribute indexInParentSection { $index-in-parent }
            ),
            
            local:titles($section-tei),
            
            let $child-texts :=
                for $child-text-tei in $section:texts//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
                let $text-id := tei-content:id($child-text-tei)
                return
                    for $child-text-tei-bibl in $child-text-tei/tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $section-id]]
                    let $source-id := $child-text-tei-bibl/@key
                    return
                        local:text($child-text-tei, $source-id)
            return
                sort($child-texts, (), function($item) { $item/@startVolumeNumber  ! xs:integer(.), $item/@startVolumeStartPageNumber ! xs:integer(.) })
            
        }
    ,
    
    let $child-sections-tei := 
        for $child-section-tei in $section:sections//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
        order by $child-section-tei/tei:teiHeader//tei:sourceDesc/@sort-index ! xs:integer(.) ascending
        return
            $child-section-tei
    
    for $child-section-tei at $child-section-index in $child-sections-tei
    let $child-section-id := tei-content:id($child-section-tei)
    return
        local:section($child-section-id, $child-section-index)
    
};

declare function local:titles($section-tei as element(tei:TEI)){

    (:
        Edge cases:
    :)
    
    for $title in (
        $section-tei//tei:titleStmt/tei:title
    )[normalize-space()]

    let $title-type := $title/@type/string() ! concat('eft:', .)
    
    group by $title-type
    return
        element title {
        
            attribute type { $title-type },
            
            for $title-single in $title
            
            let $title-lang := ($title-single/@xml:lang, 'en')[1]
            
            return
                element label {
                    
                    attribute xmlLang { $title-lang },
                    element {'value'} { string-join($title-single/text()) ! normalize-space(.) },
                    
                    $title-single/@rend ! eft-json:annotation-link('eft:attestationType', eft-json:id('attestationTypeId', .)),
                    
                    $title-single/@*[not(name(.) = ('xml:lang','type','rend'))] ! element { name(.) } { . }
                    
                }
                    
        }
    
};

declare function local:text($text-tei as element(tei:TEI), $source-id as xs:string){
    
    let $text-id := tei-content:id($text-tei)
    let $text-bibl := $text-tei/tei:teiHeader//tei:sourceDesc/tei:bibl[@key eq $source-id]
    let $child-text-start-volume-number := min($text-bibl/tei:location/tei:volume/@number ! xs:integer(.))
    let $child-text-start-volume := $text-bibl/tei:location/tei:volume[@number ! xs:integer(.) eq $child-text-start-volume-number]
    return
        element catalogueWork {
            attribute catalogueWorkId { $source-id },
            attribute workId { $text-id },
            attribute workType { 'eft:translation' },
            attribute url { concat('/translation/', $text-id,'.json?api-version=', $local:api-version) },
            attribute htmlUrl { concat('https://read.84000.co', '/translation/', $source-id,'.html') },
            attribute startVolumeNumber { $child-text-start-volume-number },
            attribute startVolumeStartPageNumber { min($child-text-start-volume/@start-page ! xs:integer(.)) },
            (: Add toh specific TEI header information :)
            $text-bibl/tei:location ! element bibliographicScope { ./@*, ./*, element description { string-join($text-bibl/tei:biblScope/text()) } },
            $text-bibl/tei:idno[@source-id] ! eft-json:annotation-link('eft:catalogueId', eft-json:id(concat('eft:id', @work), @source-id))
        }
};

element sections {
    attribute modelType { 'catalogueSections' },
    attribute apiVersion { $local:api-version },
    attribute url { concat('/sections.json?api-version=', $local:api-version) },
    
    local:parse-sections()

}