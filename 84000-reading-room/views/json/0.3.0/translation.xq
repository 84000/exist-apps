xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../../modules/translation.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.3.0';
declare variable $resource-id := request:get-parameter('resource-id', '');
declare variable $local:tei := tei-content:tei($resource-id, 'translation');

(: Convert resource id to UT number :)
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

declare function local:parse-translation() {

    (:
        Edge cases:
        - eft:isCatalogueSectionChapter:    /translation/UT22084-001-001.json?api-version=0.3.0
        - eft:isCommentaryOf:               /translation/UT23703-093-001.json?api-version=0.3.0
    :)
    
    (:$local:translation/tei:bibl[@type eq 'chapter']/tei:idno/@parent-id ! eft-json:annotation('eft:isCatalogueSectionChapter'),:)
    
    (:$local:tei//tei:sourceDesc/tei:link[@type] ! eft-json:annotation-link(concat('eft:', @type), eft-json:id('tohKey', @target)),:)
    
    (:local:translation-project(),:)
    
    local:titles()
    
};

declare function local:titles(){

    (:
        Edge cases:
        - eft:attestationType:               /translation/UT22084-080-002.json?api-version=0.3.0
        - eft:catalogueContext:              /translation/UT22084-101-146.json?api-version=0.3.0
        - eft:prependCatalogueSectionTitle:  /translation/UT22084-001-001.json?api-version=0.3.0
        - shortcode:                         /translation/UT22084-026-001.json?api-version=0.3.0
    :)
    
    for $title in (
        $local:tei//tei:titleStmt/tei:title,
        $local:tei//tei:sourceDesc/tei:bibl/tei:ref
    )[normalize-space()]

    let $title-type := (
        $title[self::tei:title]/@type/string() ! concat('eft:', .), 
        $title[self::tei:ref] ! 'eft:toh'
    )[1]
    
    let $title-key := ($title/@key, $title/parent::tei:bibl/@key, '_any')[1]
    
    let $chapter-bibl := ($local:translation/tei:bibl[@type eq 'chapter'][@key eq $title-key], $local:translation/tei:bibl[@type eq 'chapter'])[1]
    
    let $section-title := $local:translation/eft:parent/eft:titles/eft:title[not(@xml:lang) or @xml:lang eq 'en'][text()]
    
    group by $title-type, $title-key
    
    return (
        element title {
        
            attribute titleType { $title-type },
            
            (:$title-key[not(. eq '_any')] ! eft-json:annotation-link('eft:catalogueContext', eft-json:id('tohKey', .)),:)
            
            for $title-single in $title
            return
                element label {
                    
                    attribute language { ($title-single/@xml:lang, 'en')[1] },
                    
                    element {'content'} { string-join($title-single/text()) ! normalize-space(.) }(:,:)
                    
                    (:$title-single/@rend ! eft-json:annotation-link('eft:attestationType', eft-json:id('attestationTypeId', .)),:)
                    
                    (:$title-single/@*[not(name(.) = ('xml:lang','type','rend','key'))] ! element { name(.) } { . }:)
                    
                }
                
        },
        
        if($title-type eq 'eft:mainTitle' and $chapter-bibl and $section-title) then 
            
            element title {
            
                attribute titleType { 'eft:mainTitleOutsideCatalogueSection' },
            
                (:$title-key[not(. eq '_any')] ! eft-json:annotation-link('eft:catalogueContext', eft-json:id('tohKey', .)),:)
            
                element label {
                    
                    attribute language { 'en' },
                    
                    element {'content'} { string-join(($section-title/text(), $title[not(@xml:lang) or @xml:lang eq 'en']/text()), ', ') ! normalize-space(.) }
                    
                }
                
            }
        else ()
    )
    
};

declare function local:translation-project(){

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
    
};

declare function local:passages(){

    let $xslt := doc(concat($common:app-path, "/views/html/translation.xsl"))
    let $xml-response :=
        common:response(
            'translation',
            $common:app-id,
            $local:translation
        )
    let $xhtml := transform:transform($xml-response, $xslt, <parameters/>)
    let $text-outline := translation:outline-cached($local:tei)
    
    for $node at $text-node-index in (
        $local:translation/eft:part[@type = ('translation')]/descendant::text()[normalize-space(.)][not(ancestor-or-self::*/@key) or ancestor-or-self::*[@key eq $local:toh-key]][not(ancestor::tei:note)][not(ancestor::tei:orig)][not(ancestor::tei:head[@type eq 'translation'])]
        (:| $local:translation/eft:part[@type = ('translation')]/descendant::tei:ref[@cRef]:)
    )
    let $location := eft-json:persistent-location($node)
    let $location-id := ($location/@xml:id, $location/@id)[. gt ''][1]
    let $location-milestone-pre-processed :=$text-outline/eft:pre-processed[@type eq 'milestones']/eft:milestone[@id eq $location-id]
    let $location-milestone-part := $text-outline/eft:pre-processed[@type eq 'parts']//eft:part[@id eq ($location-milestone-pre-processed/@part-id, $location-id)[1]]
    let $location-group := ($node/ancestor-or-self::tei:div[1] | $node/ancestor-or-self::eft:part[1])[1]
    group by $location-id
    order by $text-node-index[1] ascending
    return
        element passage { 
        
            attribute id { $location-id },
            $location-milestone-part[1][@prefix] ! attribute label { concat(@prefix, $location-milestone-pre-processed[1] ! concat('.', (@label, @index)[1])) },
            attribute location-group { ($location-group[1], $location-group[1])[1] ! (@xml:id, @id)[1] },
            ($location-group[1]/ancestor::tei:div[tei:head/@type = @type][1] | $location-group[1]/ancestor::eft:part[tei:head/@type = @type][1])[1] ! attribute location-group-parent { (@xml:id, @id)[1] },
            
            for $element in $xhtml/descendant-or-self::xhtml:*[@data-location-id eq $location-id]/*
            return
                element {'html'} {
                let $parent-node-name := local-name($node[1]/parent::tei:*)
                return
                    attribute tag {
                        if($node/ancestor::tei:lg) then
                            'line-group'
                        else if($parent-node-name eq 'p') then
                            'paragraph'
                        else if($parent-node-name eq 'head') then
                            'heading'
                        else
                            $parent-node-name
                    },
                    $element/@class ! attribute class { . },
                    element {'text'} { string-join($element/descendant::text()) ! normalize-space(.) },
                    $element/descendant::xhtml:a ! eft-json:annotation-substring(text(), (), 'link', eft-json:id('url', @href))(:,
                    element {'html'} { serialize($element) ! replace(., '\s+xmlns=[^\s|>]*', '') ! normalize-space(.) }:)
                }
            (:,
            element {'text'} { 
                replace(
                    replace(
                        replace(
                            string-join(
                                $node ! 
                                    concat(
                                        if(parent::tei:head) then 
                                            replace(., '(^\s+|\s+$)', '') 
                                        else if(self::tei:ref) then 
                                            concat('[', @cRef, ']')
                                        else if(parent::tei:p | parent::tei:l) then 
                                            concat(., ' ')
                                        else ., 
                                        
                                        if(parent::tei:head) then 
                                            '. ' 
                                        else ()
                                    )
                            )
                        ,'[\r\n\t]', '')    (\: Remove returns and tabs :\)        
                    ,'\s+', ' ')            (\: Condense other whitespace :\) 
                , '(^\s+|\s+$)', '')        (\: Remove leading/trailing space :\)
            }:)
        }
};

element translation {
    attribute modelType { 'translation' },
    attribute apiVersion { $local:api-version },
    attribute url { concat('/translation/', $local:text-id,'.json?api-version=', $local:api-version) },
    attribute xmlId { $local:text-id },
    attribute publicationVersion { tei-content:strip-version-number($local:translation/eft:publication/eft:edition/text()[1]) },
    element publicationStatus { attribute json:literal {'true'}, $local:translation/@status/number()},
    element cacheKey { $local:translation/@cache-key/string() },
    element htmlUrl { concat('https://read.84000.co', '/translation/', $local:text-id,'.html') },
    
    local:parse-translation()

}



