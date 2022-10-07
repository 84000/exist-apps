xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')

let $tei := tei-content:tei($resource-id, 'translation')
let $status-id := tei-content:translation-status($tei)
let $pdf-config := $common:environment//m:store-conf[@type eq 'master']/m:pdfs

return
    if($pdf-config and $tei and $common:environment/m:render/m:status[@type eq 'translation'][@status-id = $status-id]) then 
        
        let $parts := translation:parts($tei, (), $translation:view-modes/m:view-mode[@id eq 'pdf'], ())
        let $body-parts := $parts[@type eq 'translation']/m:part/@id/string()
        let $back-parts := $parts[@type = ('appendix', 'abbreviations', 'end-notes', 'bibliography', 'glossary')]/@id/string()
        
        return
            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {
                for $part in ('front', 'body-title', $body-parts, $back-parts)
                return
                <url>
                    <loc>{ concat($pdf-config/m:html-source-url, '/translation/', $resource-id, '.html', '?part=', $part, '&amp;view-mode=pdf') }</loc>
                </url>
            }
            </urlset>
    
    else if(not($tei)) then 
        <error xmlns="http://read.84000.co/ns/1.0">
            <message>No TEI found for this resource id</message>
        </error>
    
    else if(not($common:environment/m:render/m:status[@type eq 'translation'][@status-id = $status-id])) then 
        <error xmlns="http://read.84000.co/ns/1.0">
            <message>This text is not ready for publication</message>
        </error>
    
    else
        <error xmlns="http://read.84000.co/ns/1.0">
            <message>This environment does not have store configuration</message>
        </error>