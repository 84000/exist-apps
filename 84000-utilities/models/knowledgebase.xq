xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $article-types := request:get-parameter('article-type[]', $knowledgebase:article-types//m:type[1]/@id)[. = $knowledgebase:article-types//m:type/@id]

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else 1

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
    
        attribute sort { request:get-parameter('sort', 'latest') },
        attribute article-type { string-join($article-types, ',') },
        attribute first-record { $first-record },
        attribute records-per-page { 50 },
        
        common:add-selected-children($knowledgebase:article-types, $article-types)
        
    }

let $kb-pages := knowledgebase:pages($request/m:article-types/m:type[@selected]/@id, false(), $request/@sort)

return
    common:response(
        'utilities/knowledgebase',
        'utilities',
        (
            
            utilities:request($request),
            
            element { QName('http://read.84000.co/ns/1.0', 'knowledgebase')} {
                attribute count-pages { count($kb-pages) },
                subsequence($kb-pages, $request/@first-record, $request/@records-per-page)
            }
            
        )
    )
