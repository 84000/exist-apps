xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace functx="http://www.functx.com";

let $article-types := request:get-parameter('article-type[]', $knowledgebase:article-types//m:type[1]/@id)[. = $knowledgebase:article-types//m:type/@id]

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else 1

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
    
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute sort { request:get-parameter('sort', 'latest') },
        attribute article-type { string-join($article-types, ',') },
        attribute first-record { $first-record },
        attribute records-per-page { 50 },
        
        common:add-selected-children($knowledgebase:article-types, $article-types)
        
    }

let $kb-pages := knowledgebase:pages($request/m:article-types/m:type[@selected]/@id, false(), $request/@sort)

let $xml-response :=
    common:response(
        'operations/knowledgebase', 
        'operations', 
        (
        
            $request,
            
            element { QName('http://read.84000.co/ns/1.0', 'knowledgebase')} {
                attribute count-pages { count($kb-pages) },
                subsequence($kb-pages, $request/@first-record, $request/@records-per-page)
            }
            
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/knowledgebase.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
    