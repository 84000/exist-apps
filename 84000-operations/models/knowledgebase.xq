xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $form-action := request:get-parameter('form-action', '')
let $new-title := request:get-parameter('new-title', '')

let $add-article :=
    if($form-action eq 'new-article' and $new-title gt '') then
        update-tei:add-knowledgebase($new-title)
    else ()

let $pages := knowledgebase:pages()

let $xml-response :=
    common:response(
        'operations/knowledgebase', 
        'operations', 
        (
            (: Include request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request') } {},
            
            (: Details of updates :)
            element { QName('http://read.84000.co/ns/1.0', 'updates') } {
                $add-article
            },
            
            $pages,
            
            tei-content:text-statuses-sorted('article')
            
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/knowledgebase.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
    