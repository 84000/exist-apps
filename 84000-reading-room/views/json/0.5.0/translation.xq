xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace json-types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace source = "http://read.84000.co/source" at "/db/apps/84000-reading-room/modules/source.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:xml-response := request:get-data();
declare variable $local:translation := $local:xml-response/eft:response/eft:translation;
declare variable $local:text-id := $local:translation/@id/string();
declare variable $local:tei := tei-content:tei($local:text-id, 'translation');
declare variable $local:passages-xslt := doc("passages.xsl");

declare function local:html() {
    let $cache-key := translation:cache-key($local:tei, ())
    let $request-xml := $local:xml-response/eft:response/eft:request
    let $xslt := doc(concat($common:app-path, "/views/html/translation.xsl"))
    let $html := transform:transform($local:xml-response/eft:response, $xslt, <parameters/>)
    (:let $html := common:cache-get($request-xml, $cache-key)
    let $html := 
        if(not($html)) then 
            let $xslt := doc(concat($common:app-path, "/views/html/translation.xsl"))
            let $html := transform:transform($local:xml-response/eft:response, $xslt, <parameters/>)
            let $cache := common:cache-put($request-xml, $html, $cache-key)
            return
                $html
        else $html:)
    return
        $html
};

declare function local:titles() {

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
    
    let $title-migration-id := json-types:title-migration-id($source-key, $title-type, $title, $titles)
    
    return (
    
        json-types:title($title-migration-id, $title-language, $local:text-id, $title-type, json-types:normalize-text($title), $title/@rend ! concat('attestation-', .)),
        
        if($title-type eq 'eft:mainTitle' and $chapter-bibl and $section-title[@xml:lang eq $title-language]) then 
            
            let $title-type := 'eft:mainTitleOutsideCatalogueSection'
            let $title-migration-id := json-types:title-migration-id($source-key, $title-type, $title, $titles)
            return
                json-types:title($title-migration-id, ($title/@xml:lang, 'en')[1], $local:text-id, $title-type, string-join((json-types:normalize-text($section-title), json-types:normalize-text($title)), ', '), ())
        
        else ()
    )
    
};

declare function local:passages() {
    
    let $parameters :=
        <parameters>
            <param name="api-version" value="{ $json-types:api-version }"/>
        </parameters>
    
    let $html := local:html()
    
    return
        transform:transform($html, $local:passages-xslt, $parameters)
    
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

element translation {
    
    attribute modelType { 'translation' },
    attribute apiVersion { $json-types:api-version },
    attribute url { concat('/rest/translation.json?', string-join((concat('api-version=', $json-types:api-version), $local:text-id ! concat('id=', .)), '&amp;')) },
    attribute timestamp { current-dateTime() },
    
    json-types:work(
        $local:text-id,
        (:$local:translation/eft:source/eft:location/@work ! source:work-name(.),:)
        local:titles(),
        if($local:translation/eft:publication/eft:tantric-restriction[tei:p]) then true() else false(),
        tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]),
        $local:translation/eft:publication/eft:edition/tei:date/text(),
        $local:translation/@status/string(),
        $local:translation/eft:publication/eft:publication-date/text()
    ),
    
    local:passages()
    
}