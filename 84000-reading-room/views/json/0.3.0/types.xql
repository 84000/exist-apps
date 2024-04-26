xquery version "3.0";

module namespace json-types = "http://read.84000.co/json-types";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";

import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "../../../modules/section.xql";

declare variable $json-types:api-version := '0.3.0';

declare function json-types:catalogue-section (
    $section-id as xs:string, $parent-section-id as xs:string?, $index-in-parent as xs:integer?, $section-type as xs:string,
    $titles as element(eft:title)*, $works as element(eft:catalogueWork)*, $publications-summary as element(eft:publicationsSummary)*, 
    $content as element(eft:content)*, $annotations as element(eft:annotation)*
) {
    element { QName('http://read.84000.co/ns/1.0', 'catalogueSection') } {
        attribute catalogueSectionId { $section-id },
        attribute url { concat('/section/', $section-id,'.json?api-version=', $json-types:api-version) },
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
    $source-id as xs:string, $text-id as xs:string, $work-type as xs:string,
    $start-volume-number as xs:integer, $start-page-number as xs:integer,
    $bibliographic-scope as element(eft:bibliographicScope)?, $annotations as element(eft:annotation)*
){
    element { QName('http://read.84000.co/ns/1.0', 'catalogueWork') } {
        attribute catalogueWorkId { $source-id },
        attribute workId { $text-id },
        attribute workType { $work-type },
        attribute url { concat('/translation/', $text-id,'.json?api-version=', $json-types:api-version) },
        attribute htmlUrl { concat('https://read.84000.co', '/translation/', $source-id,'.html') },
        element startVolumeNumber { attribute json:literal {'true'}, $start-volume-number },
        element startVolumeStartPageNumber { attribute json:literal {'true'}, $start-page-number },
        $bibliographic-scope,
        $annotations
    }
};

declare function json-types:title($type as xs:string, $annotations as element(eft:annotation)*, $labels as element(eft:label)*){
    element { QName('http://read.84000.co/ns/1.0', 'title') } {
        attribute titleType { $type },
        $annotations,
        $labels
    }
};

declare function json-types:label($lang as xs:string, $value as xs:string, $annotations as element(eft:annotation)*) {
    element { QName('http://read.84000.co/ns/1.0', 'label') } {
        attribute language { $lang },
        element {'content'} { $value },
        $annotations
    }
};

declare function json-types:content($type as xs:string, $lang as xs:string, $html-escaped as element()*) {
    element { QName('http://read.84000.co/ns/1.0', 'content') } {
        attribute contentType { $type },
        attribute language { $lang },
        $html-escaped ! element { local-name(.) } { element html { text() } }
    }
};

