xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace source = "http://read.84000.co/source" at "/db/apps/84000-reading-room/modules/source.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "/db/apps/84000-reading-room/modules/glossary.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:text-id := if(request:exists()) then request:get-parameter('resource-id', '') else 'UT22084-034-007';
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else 'store';
declare variable $local:tei := tei-content:tei($local:text-id, 'translation');
declare variable $local:xml-response := local:xml-response($local:text-id, ());
declare variable $local:translation-xml := $local:xml-response/eft:translation;
declare variable $local:html := helpers:translation-html($local:xml-response);
declare variable $local:passage-parts-exclude := ('titles','imprint','toc','bibliography','glossary','citation-index');

declare function local:xml-response($resource-id as xs:string, $commentary-key as xs:string?) as element(eft:response)* {

    helpers:get(concat('/translation/', $resource-id, '.xml?', string-join(('view-mode=app', $commentary-key[. gt ''] ! concat('commentary=', .)), '&amp;')))/eft:response
    
};

declare function local:titles() as element(eft:title)* {

    (:
        Edge cases:
        - eft:attestationType:               /rest/translation.json?id=UT22084-080-002
        - eft:catalogueContext:              /rest/translation.json?id=UT22084-101-146
        - eft:prependCatalogueSectionTitle:  /rest/translation.json?id=UT22084-001-001
        - shortcode:                         /rest/translation.json?id=UT22084-026-001
    :)
    
    let $titles := ($local:tei//tei:titleStmt/tei:title, $local:tei//tei:sourceDesc/tei:bibl/tei:ref)[normalize-space()]
    
    for $title in $titles

    let $title-type := (
        $title[self::tei:title]/@type ! concat('eft:', .), 
        $title[self::tei:ref] ! 'eft:toh'
    )[1]
    
    let $title-key := ($title/@key, $title/parent::tei:bibl/@key, '_any')[1]
    
    let $title-language := ($title/@xml:lang, 'en')[1]
    
    let $section-title := $local:translation-xml/eft:parent/eft:titles/eft:title[not(@xml:lang) or @xml:lang eq 'en'][text()]
    let $chapter-bibl := ($local:tei//tei:sourceDesc/tei:bibl[@type eq 'chapter'][@key eq $title-key], $local:tei//tei:sourceDesc/tei:bibl[@key][@type eq 'chapter'])[1]
    
    let $source-key := ($title/@key, $title/parent::tei:bibl/@key, $local:tei//tei:sourceDesc/tei:bibl/@key, ($section-title/ancestor::eft:parent)[1]/@id, $local:text-id)[1]
    
    let $title-migration-id := helpers:title-migration-id($source-key, $title-type, $title, $titles)
    
    return (
    
        types:title($title-migration-id, $title-language, $local:text-id, $title-type, helpers:normalize-text($title), $title/@rend ! concat('attestation-', .), $title-key[not(. eq '_any')]),
        
        if($title-type eq 'eft:mainTitle' and $chapter-bibl and $section-title[@xml:lang eq $title-language]) then 
            
            let $title-type := 'eft:mainTitleOutsideCatalogueSection'
            let $title-migration-id := helpers:title-migration-id($source-key, $title-type, $title, $titles)
            return
                types:title($title-migration-id, ($title/@xml:lang, 'en')[1], $local:text-id, $title-type, string-join((helpers:normalize-text($section-title), helpers:normalize-text($title)), ', '), (), $title/@key)
        
        else ()
    )
    
};

let $commentary-keys := $local:translation-xml/eft:part[@type eq 'citation-index'] ! translation:commentary-keys($local:tei, tei:ptr)

let $html-sections := 
    element { QName('http://read.84000.co/ns/1.0','html-sections') } {
    
        attribute text-id { $local:text-id },
        
        (: Default rendering :)
        element { QName('http://read.84000.co/ns/1.0','default') } {
            attribute source-key { $local:xml-response/eft:request/@resource-id },
            $local:html//xhtml:section[not(@data-part-type = $local:passage-parts-exclude)]
        },
        
        (: Toh variants :)
        for $bibl in $local:tei//tei:sourceDesc/tei:bibl[@key]
        where $bibl[not(@key/string() eq $local:xml-response/eft:request/@resource-id/string())]
        let $xml-response-variant := local:xml-response($bibl/@key, ())
        let $html-variant := helpers:translation-html($xml-response-variant)
        return
            element { QName('http://read.84000.co/ns/1.0','variant') } {
                attribute source-key { $bibl/@key },
                $html-variant//xhtml:section[not(@data-part-type = $local:passage-parts-exclude)]
            }
        ,
        
        (: Commentary variants for each toh :)
        for $commentary-key in $commentary-keys
        return
            for $bibl in $local:tei//tei:sourceDesc/tei:bibl[@key]
            let $xml-response-variant := local:xml-response($bibl/@key, $commentary-key)
            let $html-variant := helpers:translation-html($xml-response-variant)
            return
                element { QName('http://read.84000.co/ns/1.0','variant') } {
                    attribute source-key { $bibl/@key },
                    attribute commentary-key { $commentary-key },
                    $html-variant//xhtml:section[not(@data-part-type = $local:passage-parts-exclude)]
                }
                
    }

let $passages := helpers:passages($html-sections)

let $response := 
    element translation {
        
        attribute modelType { 'translation' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/translation.json?', string-join((concat('api-version=', $types:api-version), $local:text-id ! concat('id=', .)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        types:work(
            $local:text-id,
            local:titles(),
            if($local:translation-xml/eft:publication/eft:tantric-restriction[tei:p]) then true() else false(),
            if($local:tei//tei:back/tei:div[@type eq 'glossary'][@status eq 'excluded']) then true() else false(),
            tei-content:strip-version-number($local:translation-xml/eft:publication/eft:edition/text()[1]),
            $local:translation-xml/eft:publication/eft:edition/tei:date/text(),
            $local:translation-xml/@status/string(),
            $local:translation-xml/eft:publication/eft:publication-date/text()
        ),
        
        $passages,
        
        helpers:glossaries($local:tei, $local:html),
        
        types:control-data($local:text-id, 'work-count-titles', count(($local:tei//tei:titleStmt/tei:title, $local:tei//tei:sourceDesc/tei:bibl/tei:ref)[normalize-space()])),
        types:control-data($local:text-id, 'work-count-passages', count(distinct-values($html-sections/descendant::xhtml:*[@data-location-id][not(descendant::*/@data-location-id)]/@data-location-id))),
        types:control-data($local:text-id, 'work-count-passage-annotations', count($passages/eft:annotation)),
        types:control-data($local:text-id, 'work-count-glossary-entries', count($local:tei//tei:back/tei:div[@type eq 'glossary']/descendant::tei:gloss[@xml:id])),
        types:control-data($local:text-id, 'work-count-glossary-names', count($local:tei//tei:back/tei:div[@type eq 'glossary']/descendant::tei:gloss[@xml:id]/tei:term[not(@xml:lang eq 'bo' and @n)][text() ! normalize-space()])),
        types:control-data($local:text-id, 'work-count-bibliography-entries', count($local:xml-response//eft:part[@type eq 'bibliography']/descendant::tei:bibl)),
        types:control-data($local:text-id, 'work-count-source-authors', count($local:translation-xml//eft:attribution))
        
    }

return
    helpers:store($local:request-store, $response, concat(($local:tei ! $local:text-id, concat('unknown-', $local:text-id))[1], '.json'), 'translations')

