xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id and resource-suffix parameters
    Returns knowledgbase content xml
    -------------------------------------------------------------------
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../modules/knowledgebase.xql";
import module namespace functx="http://www.functx.com";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $article-types := request:get-parameter('article-type[]', $knowledgebase:article-types//m:type[1]/@id)[. = $knowledgebase:article-types//m:type/@id]

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else 1

let $view-mode := request:get-parameter('view-mode', 'default')
let $view-mode-validated := $knowledgebase:view-modes/m:view-mode[@id eq $view-mode]

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'knowledgebase' },
        attribute resource-id { 'index' },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute sort { request:get-parameter('sort', 'latest') },
        attribute view-mode { $view-mode-validated/@id },
        attribute article-type { string-join($article-types, ',') },
        attribute first-record { $first-record },
        attribute records-per-page { 20 },
        
        common:add-selected-children($knowledgebase:article-types, $article-types),
        
        $view-mode-validated
        
    }

let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache']) then
        let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
        where $entities-timestamp instance of xs:dateTime
        return
            lower-case(
                string-join((
                    current-dateTime() ! format-dateTime(., "[Y0001]-[M01]-[D01]"),
                    $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $common:app-version ! replace(., '\.', '-')
                ),'-')
            )
    else ()


let $cached := common:cache-get($request, $cache-key)

return 
    (: Cached html :)
    if($cached) then  $cached 
    
    (: Compile response :)
    else
        
        let $kb-pages := knowledgebase:pages($request/m:article-types/m:type[@selected]/@id, if($request/m:view-mode[@id eq 'editor']) then false() else true(), $request/@sort)
        
        let $xml-response :=
            common:response(
                $request/@model,
                $common:app-id,
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
            if($resource-suffix = ('html')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/knowledgebase.xsl"), $cache-key)
            
            (: return xml data :)
            else 
                common:serialize-xml($xml-response)
                
        