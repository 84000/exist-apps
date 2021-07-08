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

let $resource-id := request:get-parameter('resource-id', '')[1]
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $view-mode := request:get-parameter('view-mode', 'default')

let $tei := tei-content:tei($resource-id, 'knowledgebase')
let $glossary := knowledgebase:glossary($tei)

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
                    $knowledgebase:view-modes/m:view-mode[@id eq $view-mode]
                },
                
                (: Knowledgebase content :)
                element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') } {
                
                    knowledgebase:page($tei),
                    knowledgebase:publication($tei),
                    knowledgebase:taxonomy($tei),
                    knowledgebase:article($tei),
                    knowledgebase:bibliography($tei),
                    knowledgebase:end-notes($tei),
                    $glossary
                    
                },
                
                (: Include caches :)
                tei-content:cache($tei, false())/m:*,
                
                (: Entities :)
                entities:entities($glossary//tei:gloss/@xml:id/string(), true()),
                
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
    
    (: return html data :)
    if($resource-suffix = ('html')) then (
        common:html($xml-response, concat($common:app-path, "/views/html/knowledgebase.xsl"))
    )
    
    (: return tei data :)
    else if($resource-suffix = ('tei')) then (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $tei
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
    
