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
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace functx="http://www.functx.com";

let $resource-id := request:get-parameter('resource-id', '')[1]
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $view-mode := request:get-parameter('view-mode', 'default')
let $view-mode := $knowledgebase:view-modes/m:view-mode[@id eq $view-mode]

let $tei := tei-content:tei($resource-id, 'knowledgebase')
let $knowledgebase-id := tei-content:id($tei)

let $knowledgebase-content :=
    element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') } {
        knowledgebase:page($tei),
        knowledgebase:publication($tei),
        knowledgebase:taxonomy($tei),
        knowledgebase:article($tei),
        knowledgebase:bibliography($tei),
        knowledgebase:end-notes($tei),
        knowledgebase:related-texts($tei),
        knowledgebase:glossary($tei)
    }

let $glossary-ids := $knowledgebase-content/m:part[@type eq 'glossary']/tei:gloss/@xml:id

let $entities := 
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
    
        let $attribution-ids := $knowledgebase-content/m:part[@type eq 'related-texts']//m:attribution/@ref ! replace(., '^eft:', '')
        let $article-entity := $entities:entities//m:entity[m:instance/@id = $knowledgebase-id]
        let $entity-list := $entities:entities//m:entity/id($attribution-ids)
        let $related := entities:related($article-entity | $entity-list)
        return (
            $entity-list,
            element related { $related }
        )
        
    }

let $caches := tei-content:cache($tei, false())/m:*

let $xml-response := 
    if(not($resource-suffix = ('tei'))) then
        common:response(
            'knowledgebase',
            $common:app-id,
            (
                (: Include request parameters :)
                element { QName('http://read.84000.co/ns/1.0', 'request') } {
                    attribute resource-id { $resource-id },
                    attribute doc-type { request:get-parameter('resource-suffix', 'html') },
                    $view-mode
                },
                
                $knowledgebase-content,
                $caches,
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
        common:html($xml-response, concat($common:app-path, "/views/html/knowledgebase.xsl"))
    
    (: return tei :)
    else if($resource-suffix = ('tei')) then 
        common:serialize-xml($tei)
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
    
