xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../../modules/translation.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace json-types = "http://read.84000.co/json-types" at "../types.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := (request:get-attribute('api-version')[. gt ''],'0.4.0')[1];

declare function local:texts-status() as element()* {

    let $texts :=
        for $tei in $tei-content:translations-collection//tei:TEI
        return 
            local:texts($tei)
    
    return
        element { QName('','textsStatus') } {
        
            element status {
                attribute id { 'any' },
                element { 'count' } { attribute json:literal { true() }, count($texts) }
            
            },
            
            for $text-status in $tei-content:text-statuses/eft:status[@type eq 'translation']
            let $text-status-texts-count := count($texts[@publicationStatus eq $text-status/@status-id])
            return
                element status {
                    attribute id { $text-status/@status-id },
                    element { 'count' } { attribute json:literal { true() }, $text-status-texts-count }
                }
            ,
            
            $texts
            
        }
    
};

declare function local:texts($tei as element(tei:TEI)) as element()* {

    let $publication-status := tei-content:publication-status($tei)
    let $publication-version := tei-content:version-number-str($tei)
    
    let $text-outline := 
        if($tei-content:text-statuses/eft:status[@type eq 'translation'][@status-id eq $publication-status][@group eq 'published']) then
            translation:outline-cached($tei)
        else ()
    let $outline-parts := $text-outline/eft:pre-processed[@type eq 'parts']//eft:part[@id]
    let $outline-milestones := $text-outline/eft:pre-processed[@type eq 'milestones']//eft:milestone[@id]
    
    let $parts := 
        for $part in $outline-parts
        let $part-milestones := $outline-milestones[range:eq(@part-id, $part/@id)]
        let $part-milestones-count := count($part-milestones)
        where $part-milestones
        return
            element part { 
                attribute json:array { true() },
                attribute id { $part/@id },
                element passagesCount { attribute json:literal { true() }, $part-milestones-count }
            }
    
    return
        for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
        let $titles := $tei//tei:titleStmt/tei:title[not(@key) or @key eq $bibl/@key][normalize-space()]
        let $title := ($titles[@type eq 'mainTitle'][@xml:lang eq 'en'], $titles[@xml:lang eq 'Sa-Ltn'], $titles)[1]
        let $titles-extended := ($titles, $bibl/tei:ref)
        return
            element { QName('','text') } {
                attribute json:array { true() },
                attribute sourceKey { $bibl/@key },
                attribute publicationStatus { $publication-status },
                attribute publicationVersion { $publication-version },
                element title { string-join($title//text()) ! normalize-space(.) },
                element titlesCount { attribute json:literal { true() }, count($titles-extended) },
                if($parts) then (
                    (:element partsCount { attribute json:literal { true() }, count($parts) },:)
                    $parts
                )
                else ()
            }
            
};

element texts-status {

    attribute modelType { 'texts-status' },
    attribute apiVersion { $local:api-version },
    element url { concat('/rest/texts-status.json?', string-join(('api-version=' || $local:api-version), '&amp;')) },
    
    local:texts-status()
    
}
