xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json = "http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../modules/common.xql";
import module namespace search = "http://read.84000.co/search" at "../modules/search.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../views/json/eft-json.xql";
import module namespace functx = "http://www.functx.com";

(: TO DO: deprecate 's' search parameter :)
let $search := request:get-parameter('search', request:get-parameter('s', ''))
let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else 1

let $xml-response :=
    common:response(
        'search',
        $common:app-id,
        if(compare($search, '') gt 0) then 
            search:search($search, $resource-id, $first-record, 15)
        else ()
    )

return
    (: return html data :)
    if($resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/search.xsl"))
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
