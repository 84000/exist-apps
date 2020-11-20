xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')

let $pdf-config := $common:environment//m:store-conf[@type eq 'master']/m:pdfs
let $tei := tei-content:tei($resource-id, 'translation')

where $pdf-config and $tei
return
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    {
        for $part in ('front', 'body', 'back')
        return
        <url>
            <loc>{ concat($pdf-config/m:html-source-url, '/translation/', $resource-id, '.html', '?view-mode=pdf', '&amp;part=', $part) }</loc>
        </url>
    }
    </urlset>