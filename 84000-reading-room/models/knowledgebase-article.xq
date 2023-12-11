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
import module namespace glossary = "http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace section="http://read.84000.co/section" at "../modules/section.xql";
import module namespace functx="http://www.functx.com";

let $resource-id := request:get-parameter('resource-id', '')[1]
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $view-mode := request:get-parameter('view-mode', 'default')
let $view-mode-validated := $knowledgebase:view-modes/m:view-mode[@id eq $view-mode]

let $tei := tei-content:tei($resource-id, 'knowledgebase')
let $knowledgebase-id := tei-content:id($tei)

(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request') } {
        attribute model { 'knowledgebase-article' },
        attribute resource-id { $resource-id },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute view-mode { $view-mode-validated/@id },
        $view-mode-validated
    }

let $cache-key := 
    if($view-mode-validated[@cache eq 'use-cache']) then
        let $tei-timestamp := tei-content:last-modified($tei)
        let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
        where $tei-timestamp instance of xs:dateTime and $entities-timestamp instance of xs:dateTime
        return 
            lower-case(
                string-join((
                    $tei-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $common:app-version ! replace(., '\.', '-')
                ),'-')
            )
    else ()

let $cached := common:cache-get($request, $cache-key)

return 
    (: Cached html :)
    if($cached) then  $cached 
    
    (: tei :)
    else if($resource-suffix = ('tei')) then $tei
    
    (: Compile response :)
    else

        let $knowledgebase-content :=
            element { QName('http://read.84000.co/ns/1.0', 'article') } {
                knowledgebase:page($tei),
                knowledgebase:publication($tei),
                knowledgebase:taxonomy($tei),
                knowledgebase:abstract($tei),
                knowledgebase:article($tei),
                knowledgebase:bibliography($tei),
                knowledgebase:end-notes($tei),
                knowledgebase:related-texts($tei),
                knowledgebase:glossary($tei),
                $tei[tei:teiHeader/tei:fileDesc[@type eq 'section']] ! (
                    section:child-sections(., 'none'),
                    element parent-section {
                        section:ancestors($tei, 1)
                    }
                )
            }
        
        let $glossary-ids := $knowledgebase-content/m:part[@type eq 'glossary']/tei:gloss/@xml:id
        
        let $exclude-flagged := if($view-mode-validated[@id eq 'editor']) then () else 'requires-attention'
        let $exclude-status := if(not($view-mode-validated[@id eq 'editor'])) then 'excluded' else ''
        
        let $entities := 
            element { QName('http://read.84000.co/ns/1.0', 'entities') }{
                
                let $article-entity := $entities:entities//m:entity[m:instance/@id = $knowledgebase-id]
                let $attribution-ids := $knowledgebase-content/m:part[@type eq 'related-texts']//m:attribution/@xml:id
                let $attribution-entities := $entities:entities//m:instance[@id = $attribution-ids]/parent::m:entity
                let $glossary-entities := $entities:entities//m:instance[@id = $glossary-ids]/parent::m:entity
                let $entities-combined := $article-entity | $attribution-entities | $glossary-entities
                let $related := entities:related($entities-combined, false(), ('glossary','knowledgebase'), $exclude-flagged, $exclude-status)
                return (
                    $entities-combined,
                    element related { $related }
                )
                
            }
        
        let $outline := knowledgebase:outline($tei)
        let $glossary-cache := glossary:glossary-cache($tei, (), false())
        
        let $xml-response := 
            if(not($resource-suffix = ('tei'))) then
                common:response(
                    $request/@model,
                    $common:app-id,
                    (
                        (: Include request parameters :)
                        $request,
                        
                        $knowledgebase-content,
                        $outline,
                        $glossary-cache,
                        $entities,
                        
                        (: Calculated strings :)
                        element { QName('http://read.84000.co/ns/1.0', 'replace-text') } {
                            element value {
                                attribute key { '#CurrentDateTime' },
                                format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]')
                            },
                            element value {
                                attribute key { '#LinkToSelf' },
                                concat($common:environment/m:url[@id eq 'reading-room'], '/knowledgebase/', $resource-id, '.html')
                            }
                        }
                        
                    )
                )
            else ()
        
        return
            
            (: return html :)
            if($resource-suffix = ('html')) then
                common:html($xml-response, concat($common:app-path, "/views/html/knowledgebase-article.xsl"), $cache-key)
            
            (: return xml data :)
            else 
                common:serialize-xml($xml-response)
    
