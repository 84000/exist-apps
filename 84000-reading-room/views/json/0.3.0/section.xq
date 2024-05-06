xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace json-types = "http://read.84000.co/json-types" at "types.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:response := request:get-data()/eft:response;
declare variable $local:request := $local:response/eft:request;
declare variable $local:section := $local:response/eft:section;
declare variable $local:environment := $local:response/eft:environment;
declare variable $local:api-version := (request:get-attribute('api-version'),'0.3.0')[1];
declare variable $local:xhtml := transform:transform($local:response, doc(concat($common:app-path, "/views/html/section.xsl")), <parameters/>);

declare function local:section($section as element()*, $parent-section-id as xs:string) as element()* {

    json-types:catalogue-section(
        $local:api-version,
        $section/@id,
        $parent-section-id,
        $section/@sort-index, 
        $section/@type, 
        json-types:title('eft:mainTitle', (), $section/eft:titles/eft:title[text()] ! json-types:label(@xml:lang, string-join(text()), ())),
        local:child-texts($section/eft:texts/eft:text),
        element { QName('http://read.84000.co/ns/1.0', 'publicationsSummary') } {
            $local:section//eft:translation-summary[@section-id eq $section/@id]/eft:publications-summary[@grouping eq'text'][@scope eq 'descendant'] ! local:stats(*)
        },
        (
            if($local:xhtml//xhtml:div[@id eq 'abstract'][*]) then
                json-types:content('eft:abstract', ($local:xhtml//xhtml:div[@id eq 'abstract']/@lang, 'en')[1], $local:xhtml//xhtml:div[@id eq 'abstract']/* ! element { local-name(.) } { serialize(node()) ! replace(., '\s+xmlns=[^\s|>]*', '') })
            else ()
            ,
            if($local:xhtml//xhtml:div[@id eq 'tantra-warning-title'][*]) then
                json-types:content('eft:tantraWarning', ($local:xhtml//xhtml:div[@id eq 'tantra-warning-title']/@lang, 'en')[1], $local:xhtml//xhtml:div[@id eq 'tantra-warning-title']//xhtml:div[matches(@class, '(^|\s)modal\-body(\s|$)')]/xhtml:p ! element { local-name(.) } { serialize(node()) ! replace(., '\s+xmlns=[^\s|>]*', '') })
            else ()
        ),
        if($section[eft:page]) then
            eft-json:annotation-link('eft:knowledgebaseArticleLink', eft-json:id('knowledgebaseId', $section/eft:page/@kb-id))
        else ()
    ),

    for $child-section at $child-section-index in $section/eft:section
    return
        local:section($child-section, $section/@id)

};

declare function local:stats($groups as element()*) {
    for $stat in $groups
    return
        element { 'stat' } {
            attribute json:array {'true'},
            attribute countType { $stat ! local-name(.) },
            $stat/parent::*/@*,
            element { 'values' } {
                for $value in $stat/@*
                let $attribute-name := local-name($value)
                return
                    element { 
                        if($attribute-name eq 'in-translation') then 'inTranslation'
                        else if($attribute-name eq 'not-started') then 'notStarted'
                        else $attribute-name
                    } {
                        attribute json:literal {'true'},
                        $value/number()
                    }
           }
        }
};

declare function local:child-texts($texts as element()*) {

    for $text in $texts
    
    let $start-volume-number := min($text/eft:source/eft:location/eft:volume/@number ! xs:integer(.))
    let $start-volume := $text/eft:source/eft:location/eft:volume[@number ! xs:integer(.) eq $start-volume-number]
    let $start-page-number := min($start-volume/@start-page ! xs:integer(.))
    
    let $titles := (
        json-types:title('eft:mainTitle', (), $text/eft:titles/eft:title[text()] ! json-types:label(@xml:lang, string-join(text()), ())),
        json-types:title('eft:otherTitle', (), $text/eft:title-variants/eft:title[text()] ! json-types:label(@xml:lang, string-join(text()), ()))
    )
    let $bibliographic-scope := 
        if($text/eft:source/eft:location) then
            element { QName('http://read.84000.co/ns/1.0', 'bibliographicScope') } { 
                $text/eft:source/eft:location ! eft-json:copy-nodes(.)/*, 
                element description { string-join($text/eft:source/eft:scope/text()) ! normalize-space() } 
            }
        else ()
    
    let $text-summary := $local:xhtml//xhtml:div[@id eq $text/@resource-id]/descendant::xhtml:div[matches(@class, '(^|\s)summary(\s|$)')][*]
    let $content :=
        if($text-summary) then
            json-types:content('eft:summary', ($text-summary/@lang, 'en')[1], $text-summary/* ! element { local-name(.) } { serialize(node()) ! replace(., '\s+xmlns=[^\s|>]*', '') })
        else ()
    
    let $annotations := (
    
        $text/eft:downloads[@resource-id eq $text/@resource-id]/eft:download[not(@type = ('html', 'rdf', 'cache'))] ! eft-json:annotation-link(concat('eft:', @type, 'File'), eft-json:id('downloadUrl', @download-url)),
        
        $text/eft:publication/eft:publication-date[text()] ! eft-json:annotation('eft:publicationDate', (), (), (), text()),
        
        for $attribution in $text/eft:source/eft:attribution
        let $author := $local:response//eft:instance[@id eq $attribution/@xml:id]/parent::eft:entity
        return
            eft-json:annotation(concat('eft:source', functx:capitalize-first($attribution/@role)), $author/@xml:id ! eft-json:id('xmlId', .), (), (), string-join($attribution/text()))
    
    )
    
    order by 
        $start-volume-number ascending,
        $start-page-number ascending
    return
        json-types:catalogue-work(
            $local:api-version,
            $text/@resource-id,
            $text/@id,
            'eft:translation',
            $start-volume-number,
            $start-page-number,
            $titles,
            $bibliographic-scope,
            $content,
            $annotations
        )
};

declare function local:filters($section as element(eft:section)) as element(eft:filters)* {
    for $group in $section/eft:filters/tei:div[@type eq "filter"][@xml:id][eft:display]
    return
        element { QName('http://json.84000.co/ns/1.0', 'group') } {
            attribute id { $group/@xml:id },
            element label {
                $group/tei:head/data()
            },
            element description {
                eft-json:tei-to-escaped-xhtml($group/tei:p, $local:xhtml-xsl) 
            },
            eft-json:copy-nodes($group/eft:filter)
        }
};

element { 'section' } {
    attribute modelType { 'catalogueSection' },
    attribute apiVersion { $local:api-version },
    attribute url { 
        concat(
            '/section/', $local:section/@id, '.json',
            '?published-only=', xs:boolean($local:request/@published-only),
            '&amp;child-texts-only=', xs:boolean($local:request/@child-texts-only),
            '&amp;api-version=', $local:api-version
        )
    },
    (:$local:request,:)
    (:$local:section:)
    local:section($local:section, $local:section/eft:parent/@id)
}
   
    