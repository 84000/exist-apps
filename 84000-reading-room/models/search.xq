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
let $resource-suffix := (request:get-parameter('resource-suffix', '')[. = ('xml', 'html')], 'html')[1]

let $search-langs := 
    <search-langs xmlns="http://read.84000.co/ns/1.0">
        <lang id="en" short-code="Eng">English</lang>
        <lang id="bo" short-code="Tib">Tibetan</lang>
        <!--<lang id="bo-selector" short-code="Folio">Select a Passage</lang>-->
    </search-langs>
    
let $search-langs := common:add-selected-children($search-langs, request:get-parameter('search-lang', 'en'))

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else 1

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary' },
        attribute resource-id { $resource-id },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute search-type { request:get-parameter('search-type', '') ! lower-case(.) },
        attribute search-lang { $search-langs//m:lang[@selected]/@id },
        if(request:get-parameter('search-glossary', '') gt '') then
            attribute search-glossary { '1' }
        else (),
        attribute first-record { $first-record },
        attribute max-records { 15 },
        attribute specified-text { request:get-parameter('specified-text', '') },
        $search-langs,
        element search { $search }
    }

let $results := 
    if($request/@search-type eq 'tm' and compare($search, '') gt 0) then
        search:tm-search($search, $request/@search-lang, $request/@first-record, $request/@max-records, if($request/@search-glossary) then true() else false())
    else if(compare($search, '') gt 0) then 
        search:search($search, $request/@specified-text, $request/@first-record, $request/@max-records)
    else ()

let $xml-response :=
    common:response(
        'search',
        $common:app-id,
        (
            $request,
            $results
        )
    )

return

    (: return html data :)
    if($resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/search.xsl"))
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
