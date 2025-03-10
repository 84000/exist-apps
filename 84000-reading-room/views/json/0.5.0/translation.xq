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

declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:xml-response := request:get-data()/eft:response;
declare variable $local:translation := $local:xml-response/eft:translation;
declare variable $local:text-id := $local:translation/@id/string();
declare variable $local:tei := tei-content:tei($local:text-id, 'translation');
declare variable $local:html := helpers:translation-html($local:xml-response);

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
    
    let $section-title := $local:translation/eft:parent/eft:titles/eft:title[not(@xml:lang) or @xml:lang eq 'en'][text()]
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

(:declare function local:bibliographic-scope() as element(eft:bibliographicScope)* {
    for $bibl in $local:tei//tei:sourceDesc/tei:bibl[@key]
    return
        element { QName('http://read.84000.co/ns/1.0', 'bibliographicScope') } { 
            attribute toh-key { $bibl/@key },
            $bibl/tei:location ! json-types:copy-nodes(.)/*, 
            element description { json-types:normalize-text($bibl/tei:biblScope) } 
        }
};:)

let $html-sections := $local:html//xhtml:section[not(@data-part-type = ('titles','imprint','toc','bibliography','glossary','abbreviations','citation-index'))]

let $passages := helpers:passages($html-sections)

let $response := 
    element translation {
        
        attribute modelType { 'translation' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/translation.json?', string-join((concat('api-version=', $types:api-version), $local:text-id ! concat('id=', .)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        types:work(
            $local:text-id,
            (:$local:translation/eft:source/eft:location/@work ! source:work-name(.),:)
            local:titles(),
            if($local:translation/eft:publication/eft:tantric-restriction[tei:p]) then true() else false(),
            tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]),
            $local:translation/eft:publication/eft:edition/tei:date/text(),
            $local:translation/@status/string(),
            $local:translation/eft:publication/eft:publication-date/text()
        ),
        
        $passages,
        
        helpers:glossaries($local:tei, $local:html),
        
        types:control-data($local:text-id, 'work-count-titles', count(($local:tei//tei:titleStmt/tei:title, $local:tei//tei:sourceDesc/tei:bibl/tei:ref)[normalize-space()])),
        types:control-data($local:text-id, 'work-count-passages', count(distinct-values($html-sections/descendant::xhtml:*[@data-location-id][not(descendant::*/@data-location-id)]/@data-location-id))),
        (:types:control-data($local:text-id, 'work-count-milestones', count($local:xml-response/eft:text-outline/eft:pre-processed[@type eq 'milestones'][@text-id eq $local:text-id]/eft:milestone)),:)
        types:control-data($local:text-id, 'work-count-passage-annotations', count($passages/eft:annotation)),
        types:control-data($local:text-id, 'work-count-glossary-entries', count($local:tei//tei:back/tei:div[@type eq 'glossary']/descendant::tei:gloss[@xml:id])),
        types:control-data($local:text-id, 'work-count-glossary-names', count($local:tei//tei:back/tei:div[@type eq 'glossary']/descendant::tei:gloss[@xml:id]/tei:term[not(@xml:lang eq 'bo' and @n)])),
        types:control-data($local:text-id, 'work-count-bibliography-entries', count($local:xml-response//eft:part[@type eq 'bibliography']/descendant::tei:bibl)),
        types:control-data($local:text-id, 'work-count-source-authors', count($local:translation//eft:attribution))
        
    }

return
    if($local:request-store eq 'store') then
        helpers:store($response, concat(($local:tei ! $local:text-id, concat('unknown-', $local:text-id))[1], '.json'), 'translation')
    else
        $response
