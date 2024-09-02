xquery version "3.0";

module namespace json-types = "http://read.84000.co/json-types";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";

import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "../../modules/section.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";

declare function json-types:catalogue-section (
    $api-version as xs:string,
    $section-id as xs:string, $parent-section-id as xs:string?, $index-in-parent as xs:integer?, $section-type as xs:string,
    $titles as element(eft:title)*, $works as element(eft:catalogueWork)*, $publications-summary as element(eft:publicationsSummary)*, 
    $content as element(eft:content)*, $annotations as element(eft:annotation)*
) {
    element { QName('http://read.84000.co/ns/1.0', 'catalogueSection') } {
        attribute json:array {'true'},
        attribute catalogueSectionId { $section-id },
        attribute url { concat('/section/', $section-id,'.json?api-version=', $api-version) },
        attribute htmlUrl { concat('https://read.84000.co', '/section/', $section-id,'.html') },
        attribute catalogueSectionType { $section-type },
        $parent-section-id ! element parentCatalogueSectionId { . },
        $parent-section-id ! element indexInParentCatalogueSection { attribute json:literal {'true'}, $index-in-parent },
        $titles,
        $works,
        $publications-summary,
        $content,
        $annotations
    }
};

declare function json-types:catalogue-work(
    $work as element(eft:work),
    $source-id as xs:string,
    $start-volume-number as xs:integer, $start-page-number as xs:integer
){
    element { QName('http://read.84000.co/ns/1.0', 'catalogueWork') } {
        $work/@*[not(local-name(.) = ('array', 'catalogueWorkId', 'htmlUrl'))],
        attribute json:array {'true'},
        attribute catalogueWorkId { $source-id },
        attribute htmlUrl { translation:canonical-html($source-id, (), ()) },
        element startVolumeNumber { attribute json:literal {'true'}, $start-volume-number },
        element startVolumeStartPageNumber { attribute json:literal {'true'}, $start-page-number },
        $work/*
    }
};

declare function json-types:work(
    $api-version as xs:string,
    $text-id as xs:string, $work-type as xs:string,
    $titles as element(eft:title)*, $bibliographic-scope as element(eft:bibliographicScope)?, 
    $content as element(eft:content)*, $annotations as element(eft:annotation)*, $annotate as xs:string
){
    element { QName('http://read.84000.co/ns/1.0', 'work') } {
        attribute json:array {'true'},
        attribute workId { $text-id },
        attribute workType { $work-type },
        attribute url { concat('/translation/', $text-id,'.json?api-version=', $api-version, '&amp;annotate=', $annotate) },
        attribute htmlUrl { translation:canonical-html($text-id, (), ()) },
        $titles,
        $bibliographic-scope,
        $content,
        $annotations
    }
};

declare function json-types:title($type as xs:string, $annotations as element(eft:annotation)*, $labels as element(eft:label)*){
    (:element { QName('http://read.84000.co/ns/1.0', 'title') } {
        attribute json:array {'true'},
        attribute titleType { $type },
        $annotations,
        $labels
    }:)
    for $label in $labels
    return
        element { QName('http://read.84000.co/ns/1.0', 'title') } {
            attribute json:array {'true'},
            attribute titleType { $type },
            $label/@*[not(local-name(.) = ('array', 'titleType'))],
            $label/*,
            $annotations
        }
};

declare function json-types:label($lang as xs:string, $value as xs:string, $annotations as element(eft:annotation)*, $title-migration-id as xs:string?) {
    element { QName('http://read.84000.co/ns/1.0', 'label') } {
        attribute json:array {'true'},
        attribute language { $lang },
        element {'content'} { $value },
        $title-migration-id ! element {'titleMigrationId'} { . },
        $annotations
    }
};

declare function json-types:content($type as xs:string, $lang as xs:string, $html-escaped as element()*, $tei-escaped as element()*) {
    element { QName('http://read.84000.co/ns/1.0', 'content') } {
        attribute json:array {'true'},
        attribute contentType { $type },
        attribute language { $lang },
        for $element in $html-escaped
        return
            element { local-name($element) } { attribute json:array {'true'}, element html { $element/text() } }
        ,
        for $element in $tei-escaped
        return
            element { local-name($element) } { attribute json:array {'true'}, element tei { $element/text() } }
    }
};
