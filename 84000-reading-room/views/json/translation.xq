xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

let $translation := request:get-data()/m:response/m:translation
let $api-version := '0.1.0'

return
    <translation>
    {
        attribute api-version { $api-version },
        attribute url { concat('/translation/', $translation/m:source/@key,'.json?api-version=', $api-version) },
        attribute canonical-html { $translation/@canonical-html },
        element comment {'We do not currently serve json responses for translations. Please search or browse sections to find urls for translations html.'}
        (: element summary { eft-json:tei-to-escaped-xhtml($translation/m:part[@type eq 'summary']/tei:p, doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"))) } :)
    }
    </translation>