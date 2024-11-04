xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json = "http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../../modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../../modules/glossary.xql";
import module namespace source = "http://read.84000.co/source" at "../../../modules/source.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace json-types = "http://read.84000.co/json-types" at "../types.xql";
import module namespace json-types-v = "http://read.84000.co/json-types/0.4.0" at "types.xql"; (: variations to json-types for this version :)
import module namespace functx = "http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

(:
    Edge cases:
    - eft:isCatalogueSectionChapter:    /translation/UT22084-001-001.json?api-version=0.4.0
    - eft:isCommentaryOf:               /translation/UT23703-093-001.json?api-version=0.4.0
:)

declare variable $local:api-version := (request:get-attribute('api-version'),'0.4.0')[1];
declare variable $local:resource-id := request:get-parameter('resource-id', '');
declare variable $local:annotate := request:get-parameter('annotate', 'true');
declare variable $local:tei := tei-content:tei($local:resource-id, 'translation');
declare variable $local:html := request:get-data()/xhtml:html;
declare variable $local:text-id := tei-content:id($local:tei);
declare variable $local:translation :=
    element { QName('http://read.84000.co/ns/1.0', 'translation')} {
        
        attribute id { $local:text-id },
        attribute status { tei-content:publication-status($local:tei) },
        attribute status-group { tei-content:publication-status-group($local:tei) },
        attribute cache-key { translation:cache-key($local:tei, ()) },
        
        translation:publication($local:tei),
        for $bibl in $local:tei//tei:sourceDesc/tei:bibl
        return (
            $bibl,
            tei-content:ancestors($local:tei, $bibl/@key, 1)
        )
        
        (:translation:toh($tei, $source/@key),:)
        (:translation:titles($tei, $source/@key),:)
        (:translation:long-titles($tei, $source/@key),:)
        (:translation:other-titles($tei, $source/@key),:)
        (:translation:downloads($tei, $source/@key, 'any-version'):)
        
    };

declare variable $local:contributors := doc(concat($common:data-path, '/operations/contributors.xml'));
declare variable $local:sponsors := doc(concat($common:data-path, '/operations/sponsors.xml'));

declare function local:titles(){

    (:
        Edge cases:
        - eft:attestationType:               /translation/UT22084-080-002.json?api-version=0.4.0
        - eft:catalogueContext:              /translation/UT22084-101-146.json?api-version=0.4.0
        - eft:prependCatalogueSectionTitle:  /translation/UT22084-001-001.json?api-version=0.4.0
        - shortcode:                         /translation/UT22084-026-001.json?api-version=0.4.0
    :)
    
    let $titles := ($local:tei//tei:titleStmt/tei:title, $local:tei//tei:sourceDesc/tei:bibl/tei:ref)[normalize-space()]
    
    for $title in $titles

    let $title-type := (
        $title[self::tei:title]/@type/string() ! concat('eft:', .), 
        $title[self::tei:ref] ! 'eft:toh'
    )[1]
    
    let $title-key := ($title/@key, $title/parent::tei:bibl/@key, '_any')[1]
    
    let $chapter-bibl := ($local:translation/tei:bibl[@type eq 'chapter'][@key eq $title-key], $local:translation/tei:bibl[@type eq 'chapter'])[1]
    
    let $section-title := $local:translation/eft:parent/eft:titles/eft:title[not(@xml:lang) or @xml:lang eq 'en'][text()]
    
    group by $title-type, $title-key
    
    let $annotations := 
        if(not($local:annotate eq 'false')) then (
            $title-key[not(. eq '_any')] ! eft-json:annotation-link('eft:catalogueContext', eft-json:id('tohKey', .))
        )
        else ()
    
    return (
    
        local:title($title, $title-type, $title-key, $titles, (), $annotations),
        
        if($title-type eq 'eft:mainTitle' and $chapter-bibl and $section-title) then 
            
            local:title($title[not(@xml:lang) or @xml:lang eq 'en'], 'eft:mainTitleOutsideCatalogueSection', $title-key, $titles, $section-title[1], $annotations)
        
        else ()
    )
    
};

declare function local:title($titles as element()*, $title-type as xs:string, $title-key as xs:string, $all-titles as element()*, $section-title as element()?, $annotations as element(eft:annotation)*) as element(eft:title)* {
    
    let $labels := 
        
        for $title in $titles
        
        let $language := ($title/@xml:lang, 'en')[1]
        let $source-key := ($title/@key, $title/parent::tei:bibl/@key, $title/ancestor::tei:TEI//tei:sourceDesc/tei:bibl/@key, ($section-title/ancestor::eft:parent)[1]/@id, $local:text-id)[1]
        let $similar-titles := $all-titles[@xml:lang eq $title/@xml:lang][@type eq $title/@type][@key eq $title/@key]
        let $index-in-similar-titles := (functx:index-of-node($similar-titles, $title), 1)[1]
        let $title-migration-id := eft-json:title-migration-id($source-key, $title-type, $title, $all-titles)
        let $annotations :=
            if(not($local:annotate eq 'false')) then (
            
                $title/@rend ! eft-json:annotation-link('eft:attestationType', eft-json:id('attestationTypeId', .)),
                
                $title/@*[not(name(.) = ('xml:lang','type','rend','key'))] ! eft-json:annotation(local-name(.), (), (), (), .)
                
            )
            else ()
        
        return
            json-types:label($language, string-join(($section-title/text(), $title/text()), ', ') ! normalize-space(.), $annotations, $title-migration-id)
        
    return
        json-types:title($title-type, $annotations, $labels)
    
};

declare function local:translation-project(){

    if(not($local:annotate eq 'false')) then (
    
        $local:contributors//eft:instance[@type eq "translation-contribution"][@id = $local:tei//tei:titleStmt/tei:author[@role eq 'translatorMain']/@xml:id]/parent::eft:team !  eft-json:annotation-link('eft:translationTeam', eft-json:id('xmlId', @xml:id)),
        
        for $attribution in $local:tei//tei:titleStmt/tei:author[@role eq 'translatorEng']
        let $person := $local:contributors//eft:instance[@type eq "translation-contribution"][@id = $attribution/@xml:id]/parent::eft:person
        return
            eft-json:annotation(concat('eft:author', functx:capitalize-first($attribution/@role)), eft-json:id('xmlId', $person/@xml:id), (), (), string-join($attribution/text()))
        ,
        
        for $attribution in $local:tei//tei:titleStmt/tei:consultant
        let $person := $local:contributors//eft:instance[@type eq "translation-contribution"][@id = $attribution/@xml:id]/parent::eft:person
        return
            eft-json:annotation(concat('eft:consultant', functx:capitalize-first($attribution/@role)), eft-json:id('xmlId', $person/@xml:id), (), (), string-join($attribution/text()))
        ,
        
        for $attribution in $local:tei//tei:titleStmt/tei:editor
        let $person := $local:contributors//eft:instance[@type eq "translation-contribution"][@id = $attribution/@xml:id]/parent::eft:person
        return
            eft-json:annotation(concat('eft:editor', functx:capitalize-first($attribution/@role)), eft-json:id('xmlId', $person/@xml:id), (), (), string-join($attribution/text()))
        ,
        
        for $sponsorship in $local:tei//tei:titleStmt/tei:sponsor
        let $sponsor := $local:sponsors//eft:instance[@type eq "translation-sponsor"][@id = $sponsorship/@xml:id]/parent::eft:sponsor
        return
            eft-json:annotation('eft:translationSponsor', eft-json:id('xmlId', $sponsor/@xml:id), (), (), string-join($sponsorship/text()))
        ,
        
        $local:tei//tei:publicationStmt/tei:date ! eft-json:annotation('eft:publicationDate', (), (), (), .),
        $local:tei//tei:editionStmt/tei:edition/tei:date ! eft-json:annotation('eft:editionDate', (), (), (), .)
        
    )
    else ()

};

declare function local:passages(){
    
    let $parameters :=
        <parameters>
            <param name="annotate" value="{ $local:annotate }"/>
            <param name="api-version" value="{ $local:api-version }"/>
        </parameters>
    
    return
        transform:transform($local:html, doc("passages.xsl"), $parameters)
    
};

let $work-titles := local:titles()

let $work-annotations := 
    if(not($local:annotate eq 'false')) then (
    
        $local:translation/tei:bibl[@type eq 'chapter']/tei:idno/@parent-id ! eft-json:annotation('eft:isCatalogueSectionChapter'),
        
        $local:tei//tei:sourceDesc/tei:link[@type] ! eft-json:annotation-link(concat('eft:', @type), eft-json:id('tohKey', @target)),
        
        $local:translation/eft:publication/eft:tantric-restriction[tei:p] ! eft-json:annotation('eft:tantricRestriction')
        
    )
    else ()

let $source-works := $local:translation/tei:bibl/tei:location/@work ! source:work-name(.)

let $tantric-restriction := if($local:tei//tei:publicationStmt/descendant::tei:p[@type eq 'tantricRestriction']) then true() else false()

let $work := json-types-v:work($local:api-version, $local:text-id, $source-works, $work-titles, (), $tantric-restriction, (), $work-annotations, $local:annotate)

return
    element translation {
    
        attribute modelType { 'translation' },
        attribute apiVersion { $local:api-version },
        (:attribute url { concat('/translation/', $local:text-id,'.json?api-version=', $local:api-version, '&amp;annotate=', $local:annotate) },:)
        
        element publicationVersion { tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]) },
        element publicationStatus { $local:translation/@status/string() },
        element publicationDate { $local:translation/eft:publication/eft:publication-date/text() },
        element cacheKey { $local:translation/@cache-key/string() },
        
        $work,
        local:translation-project(),
        
        if($local:translation[@status-group eq 'published']) then
            local:passages()
        else ()
        
    }
