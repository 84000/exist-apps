xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter
    Returns the translation xml
    -------------------------------------------------------------
    This does most of the processing of the TEI into a simple xml
    format. This should then be transformed into json/html/pdf/epub
    or other formats.
:)

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../modules/knowledgebase.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')

let $reading-room-path := $common:environment/m:url[@id eq 'reading-room']/text()

(: Get the tei :)
let $tei := tei-content:tei($resource-id, 'knowledgebase')

let $canonical-html := concat($reading-room-path, '/knowledgebase/', $resource-id, '.html')

return
    common:response(
        'knowledgebase',
        $common:app-id,
        (
            (: Include request parameters :)
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }"
                doc-type="{ request:get-parameter('resource-suffix', 'html') }"
                view-mode="{ common:view-mode() }" />,
            (: Calculated strings :)
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#CurrentDateTime">{ format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }</value>
                <value key="#LinkToSelf">{ $canonical-html }</value>
            </replace-text>,
            <knowledgebase xmlns="http://read.84000.co/ns/1.0" 
                id="{ tei-content:id($tei) }"
                status="{ tei-content:translation-status($tei) }"
                status-group="{ tei-content:translation-status-group($tei) }"
                page-url="{ $canonical-html }">
                {
                    tei-content:titles($tei)
                }
            </knowledgebase>
        )
    )

    
