xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../modules/translation.xql";

declare option exist:serialize "method=xml indent=no";

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'widget/download-dana' },
        attribute resource-id { request:get-parameter('resource-id', '') },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() }
    }

let $tei := tei-content:tei($request/@resource-id, 'translation')

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id,
        (
            $request,
            translation:title-element($tei, $request/@resource-id)
        )
    )

return
        (: return html :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/widget/download-dana.xsl"))
    
    (: return xml data :)
    else 
        common:serialize-xml($xml-response)
