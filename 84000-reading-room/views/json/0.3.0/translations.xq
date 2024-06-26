xquery version "3.1";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace json-types = "http://read.84000.co/json-types" at "../types.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := (request:get-attribute('api-version'),'0.3.0')[1];

element translations {

    attribute modelType { 'translations' },
    attribute apiVersion { $local:api-version },
    attribute url { concat('/translations.json?api-version=', $local:api-version) },
    
    for $tei in collection($common:translations-path)//tei:TEI
    let $text-id := tei-content:id($tei)
    let $work := json-types:work($local:api-version, $text-id, 'eft:translation', (), (), (), (), 'true')
    
    order by $text-id
    return
        
        element { local-name($work) } {
            $work/@*,
            element catalogueWorkIds { string-join($tei/tei:teiHeader//tei:sourceDesc/tei:bibl[@key]/@key, ',') },
            $work/*
        }

}