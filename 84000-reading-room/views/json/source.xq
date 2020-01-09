xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

let $response := request:get-data()/m:response
let $request := $response/m:request
let $source := $response/m:source
let $translation := $response/m:translation
let $back-link := $response/m:back-link
let $api-version := '0.1.0'

return
    <source>
    {
        attribute api-version { $api-version },
        attribute url { concat('/source/', $request/@resource-id,'.json?page=', $request/@page,'&amp;folio=', $request/@folio,'&amp;api-version=', $api-version) },
        attribute page-url { $source/@page-url },
        element comment {'We do not currently serve json responses for source.'}
    }
    </source>