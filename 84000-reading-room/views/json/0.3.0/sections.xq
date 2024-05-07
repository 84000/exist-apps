xquery version "3.1";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace section = "http://read.84000.co/section" at "../../../modules/section.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace json-types = "http://read.84000.co/json-types" at "../types.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := (request:get-attribute('api-version'),'0.3.0')[1];

declare function local:parse-sections() {

    (:
        Edge cases:
    :)
    
    local:section('O1JC11494', 1),
    local:section('O1JC7630', 1)
    
};

declare function local:section($section-id as xs:string, $index-in-parent as xs:integer) {
    
    let $tei := tei-content:tei($section-id, 'section')
    
    let $titles := local:titles($tei)
    
    let $child-texts :=
        for $child-text-tei in $section:texts//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
        let $text-id := tei-content:id($child-text-tei)
        return
            for $child-text-tei-bibl in $child-text-tei/tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $section-id]]
            let $source-id := $child-text-tei-bibl/@key
            return
                local:text($child-text-tei, $source-id)
    
    let $child-texts-sorted :=
        sort($child-texts, (), function($item) { $item/m:startVolumeNumber/data() ! xs:integer(.), $item/m:startVolumeStartPageNumber/data() ! xs:integer(.) })
    
    return
        json-types:catalogue-section(
            $local:api-version,
            $section-id,
            $tei/tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno/@parent-id[not(. eq 'LOBBY')],
            $index-in-parent,
            ($tei/tei:teiHeader/tei:fileDesc/@type/string(), 'section')[1],
            $titles,
            $child-texts-sorted,
            (),
            (),
            ()
        )
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

declare function local:titles($section-tei as element(tei:TEI)) as element()* {

    (:
        Edge cases:
    :)
    
    for $title in (
        $section-tei//tei:titleStmt/tei:title
    )[normalize-space()]

    let $title-type := $title/@type/string() ! concat('eft:', .)
    
    group by $title-type
    
    let $labels :=
        for $title-single in $title
        let $title-lang := ($title-single/@xml:lang, 'en')[1]
        let $title-string := string-join($title-single/text()) ! normalize-space(.)
        let $annotations := (
            $title-single/@rend ! eft-json:annotation-link('eft:attestationType', eft-json:id('attestationTypeId', .)),
            $title-single/@*[not(name(.) = ('xml:lang','type','rend'))] ! eft-json:annotation(concat('eft:', local-name(.)), (), (), (), .)
        )
        return (
            
            json-types:label($title-lang, $title-string, $annotations, ()),
            
            if($title-lang eq 'Bo-Ltn' and not($title[@xml:lang eq 'bo'])) then
                json-types:label('bo', common:bo-from-wylie($title-string), $annotations, ())
            else()
            
        )
    return
        json-types:title($title-type, (), $labels)
    
};

declare function local:text($tei as element(tei:TEI), $source-id as xs:string) as element() {
    
    let $text-id := tei-content:id($tei)
    
    let $text-bibl := $tei/tei:teiHeader//tei:sourceDesc/tei:bibl[@key eq $source-id]
    
    let $child-text-start-volume-number := min($text-bibl/tei:location/tei:volume/@number ! xs:integer(.))
    let $child-text-start-volume := $text-bibl/tei:location/tei:volume[@number ! xs:integer(.) eq $child-text-start-volume-number]
    let $child-text-start-page-number := min($child-text-start-volume/@start-page ! xs:integer(.))
    
    let $bibliographic-scope := 
        if($text-bibl/tei:location) then
            element { QName('http://read.84000.co/ns/1.0', 'bibliographicScope') } { 
                (:$text-bibl/tei:location/@*, 
                $text-bibl/tei:location/*, :)
                $text-bibl/tei:location ! eft-json:copy-nodes(.)/*, 
                element description { string-join($text-bibl/tei:biblScope/text()) ! normalize-space() } 
            }
        else ()
    
    let $annotations := (
        $text-bibl/tei:idno[@source-id] ! eft-json:annotation-link('eft:catalogueId', eft-json:id(concat('eft:id', @work), @source-id))
    )
    
    let $work := json-types:work($local:api-version, $text-id, 'eft:translation', (), $bibliographic-scope, (), $annotations, 'true')
    
    return
        json-types:catalogue-work($work, $source-id, $child-text-start-volume-number, $child-text-start-page-number)

};

element sections {
    attribute modelType { 'catalogueSections' },
    attribute apiVersion { $local:api-version },
    attribute url { concat('/sections.json?api-version=', $local:api-version) },
    
    local:parse-sections()

}