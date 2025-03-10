xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "/db/apps/84000-reading-room/modules/section.xql";
import module namespace source = "http://read.84000.co/source" at "/db/apps/84000-reading-room/modules/source.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:root-section-ids := ('O1JC11494','O1JC7630');
declare variable $local:root-section-index := 1;
declare variable $local:request-section-id := if(request:exists()) then request:get-parameter('section-id', $local:root-section-ids[$local:root-section-index]) else $local:root-section-ids[$local:root-section-index];
declare variable $local:lobby-tei := tei-content:tei($local:request-section-id, 'section');
declare variable $local:request-content-mode := if(request:exists()) then request:get-parameter('content', 'section') else 'section';
declare variable $local:content-mode := ('sections', 'works', 'control-data')[. eq ($local:request-content-mode[. gt ''], .)[1]];
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';

declare function local:catalogue-sections($section-tei as element(tei:TEI), $parent-id as xs:string) as element()* {

    let $section-id := tei-content:id($section-tei)
    let $type := ($section-tei/tei:teiHeader/tei:fileDesc/@type, 'section')[1]
    let $label := tei-content:title-any($section-tei)
    let $sort-index := ($section-tei//tei:sourceDesc/@sort-index ! xs:integer(.), 1)[1]
    
    let $titles := local:titles($section-tei)
    let $description := $section-tei//tei:front/tei:div[@type eq 'abstract'][node()] ! helpers:normalize-text(.)
    
    let $descendant-sections := 
        for $child-section-tei in $section:sections//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
        order by $child-section-tei//tei:sourceDesc/@sort-index ! xs:integer(.) ascending
        return
            local:catalogue-sections($child-section-tei, $section-id)
    
    let $child-works := 
        for $text-bibl in $section:texts//tei:TEI/tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $section-id]]
            let $text-tei := $text-bibl/ancestor::tei:TEI
            let $text-id := tei-content:id($text-tei)
            
            (:let $label := tei-content:title-any($text-tei)
            let $titles := ($text-tei//tei:titleStmt/tei:title, $text-tei//tei:sourceDesc/tei:bibl/tei:ref)[normalize-space()]
            let $title-migration-id := helpers:title-migration-id($text-bibl/@key, 'eft:toh', $text-bibl/tei:ref, $titles):)
            
            let $min-volume-number := min($text-bibl/tei:location/tei:volume/@number ! xs:integer(.))
            let $start-volume := $text-bibl/tei:location/tei:volume[@number ! xs:integer(.) eq $min-volume-number]
            let $max-volume-number := max($text-bibl/tei:location/tei:volume/@number ! xs:integer(.))
            let $end-volume := $text-bibl/tei:location/tei:volume[@number ! xs:integer(.) eq $max-volume-number]
            
            order by $start-volume/@number ! xs:integer(.) ascending, $start-volume/@start-page ! xs:integer(.) ascending
            return (
                types:catalogue-work($text-bibl/@key, $section-id, (:$label, $title-migration-id,:) $text-id, $start-volume/@number, $start-volume/@start-page, $end-volume/@number, $end-volume/@end-page, $text-bibl/tei:location/@count-pages)(:,
                types:control-data($section-id, 'work-start-volume', $start-volume/@number ! xs:integer(.)):)
            
            )
    
    return (
        types:catalogue-section($section-id, ($parent-id[not(. eq 'LOBBY')], '')[1], $type, $label, $sort-index, $titles, $description),
        types:control-data($section-id, 'count-child-sections', count($descendant-sections[self::eft:catalogueSection][@parent_xmlid eq $section-id])),
        types:control-data($section-id, 'count-descendant-sections', count($descendant-sections[self::eft:catalogueSection])),
        types:control-data($section-id, 'count-child-works', count($child-works)),
        types:control-data($section-id, 'count-descendant-works', count($descendant-sections[self::eft:catalogueWork] | $child-works)),
        $descendant-sections,
        $child-works
    )
};

declare function local:titles($section-tei as element(tei:TEI)) {
    
    let $titles := $section-tei//tei:titleStmt/tei:title[normalize-space()][not(@type eq 'articleTitle')]
    let $section-id := tei-content:id($section-tei)
    
    for $title in $titles
    let $title-type :=  concat('eft:', $title/@type)
    let $title-language := ($title/@xml:lang, 'en')[1]
    let $title-migration-id := helpers:title-migration-id($section-id, $title-type, $title, $titles)
    return
        types:title($title-migration-id, $title-language, $section-id, $title-type, helpers:normalize-text($title), $title/@rend ! concat('attestation-', .), ())
        
};

let $response := 
    element catalogue {
        
        attribute modelType { 'catalogue' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/catalogue.json?', string-join((concat('api-version=', $types:api-version), $local:request-section-id[. gt ''] ! concat('section-id=', $local:request-section-id), $local:request-content-mode[. gt ''] ! concat('content=', $local:request-content-mode)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        let $catalogue := local:catalogue-sections($local:lobby-tei, '')
        return (
            if($local:content-mode = 'sections') then
                $catalogue[self::eft:catalogueSection]
            else ()
            ,
            if($local:content-mode = 'works') then
                $catalogue[self::eft:catalogueWork]
            else ()
            ,
            if($local:content-mode = 'control-data') then
                $catalogue[self::eft:controlData]
            else ()
        )
        
    }

let $file-name := string-join((($local:request-section-id[. eq 'O1JC11494'] ! 'kangyur', $local:request-section-id[. eq 'O1JC7630'] ! 'tengyur', $response/@modelType)[1], $local:request-content-mode[. gt '']),'-')

return
    if($local:request-store eq 'store') then
        helpers:store($response, concat($file-name, '.json'), ())
    else
        $response