xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id and resource-suffix parameters
    Returns knowledgbase content xml
    -------------------------------------------------------------------
:)

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../modules/knowledgebase.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $view-mode := request:get-parameter('view-mode', 'default')

let $tei := tei-content:tei($resource-id, 'knowledgebase')

return
    (: return tei data :)
    if($resource-suffix = ('tei')) then
        $tei
        
    (: return xml data :)
    else 
        
        let $canonical-html := concat($common:environment/m:url[@id eq 'reading-room'], '/knowledgebase/', $resource-id, '.html')
        
        return
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
                        knowledgebase:end-notes($tei)
                        
                    },
                        
                    (: Include caches :)
                    tei-content:cache($tei, false())/m:*,
                    
                    (: Calculated strings :)
                    element { QName('http://read.84000.co/ns/1.0', 'replace-text') } {
                        element value {
                            attribute key { '#CurrentDateTime' },
                            format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]')
                        },
                        element value {
                            attribute key { '#LinkToSelf' },
                            $canonical-html
                        }
                    }
                    
                )
            )
        

    
