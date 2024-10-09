xquery version "3.0";

(: Variations to json types for version 0.4.0 :)
module namespace json-types = "http://read.84000.co/json-types/0.4.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json = "http://www.json.org";

import module namespace translation = "http://read.84000.co/translation" at "../../../modules/translation.xql";

declare function json-types:work(
    $api-version as xs:string,
    $text-id as xs:string, $work-type as xs:string*,
    $titles as element(eft:title)*, $bibliographic-scope as element(eft:bibliographicScope)?, 
    $content as element(eft:content)*, $annotations as element(eft:annotation)*, $annotate as xs:string
){
    element { QName('http://read.84000.co/ns/1.0', 'work') } {
        attribute json:array {'true'},
        attribute workId { $text-id },
        attribute url { concat('/translation/', $text-id,'.json?api-version=', $api-version, '&amp;annotate=', $annotate) },
        attribute htmlUrl { translation:canonical-html($text-id, (), ()) },
        $work-type ! element workType { attribute json:array {'true'}, . },
        $titles,
        $bibliographic-scope,
        $content,
        $annotations
    }
};