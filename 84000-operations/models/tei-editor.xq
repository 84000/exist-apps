xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $resource-type := request:get-parameter('resource-type', '')
let $passage-id := request:get-parameter('passage-id', '')
let $form-action := request:get-parameter('form-action', '')
(:let $markdown := request:get-parameter('markdown', ''):)
let $content-escaped := request:get-parameter('content-escaped', '')
let $content-hidden := request:get-parameter('content-hidden', '')
let $add-milestone := request:get-parameter('add-milestone', '')
let $new-element-name := request:get-parameter('new-element-name', '')
let $comment := request:get-parameter('comment', '')
let $callback-url := request:get-parameter('callback-url', '')

let $tei := tei-content:tei($resource-id, $resource-type)

let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') } {
        attribute resource-type { $resource-type },
        attribute resource-id { $resource-id },
        attribute passage-id { $passage-id }
    }

let $updates :=
    element { QName('http://read.84000.co/ns/1.0', 'updates') } {
    
        if($resource-type = ('knowledgebase') and $tei and $form-action eq 'update-tei') then 
            update-tei:update-content($tei, $content-escaped, $passage-id, ($content-hidden gt ''), ($add-milestone gt ''))
            
        else if($resource-type = ('knowledgebase') and $tei and $form-action eq 'add-element') then 
            update-tei:add-element($tei, $passage-id, $new-element-name)
            
        else if($resource-type = ('knowledgebase') and $tei and $form-action eq 'comment-tei') then 
            update-tei:comment($tei, $passage-id, $comment)
            
        (:else if($resource-type = ('knowledgebase') and $tei and $form-action eq 'lock-tei') then 
            xmldb:lock-document()
        else if($resource-type = ('knowledgebase') and $tei and $form-action eq 'unlock-tei') then 
            xmldb:clear-lock():)
            
        else ()
        
    }
return
    if(request:get-parameter('return', '') eq 'none') then (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $updates
    )

    else 
        let $validation-report := 
            element { QName('http://read.84000.co/ns/1.0', 'validation') } {
            
                let $schema := 
                    if($resource-type eq 'knowledgebase') then
                        doc(concat($common:tei-path, '/schema/current/knowledgebase.rng'))
                    else
                        doc(concat($common:tei-path, '/schema/current/translation.rng'))
                
                return
                    validation:jing-report($tei, $schema)
                    
            }
        
        let $response-data :=
            (: Restrict to knowledgebase only for now :)
            if($tei and $resource-type eq 'knowledgebase') then 
                element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') } {
                    
                    knowledgebase:page($tei),
                    knowledgebase:article($tei),
                    knowledgebase:bibliography($tei)
                    
                }
            else ()
        
        let $xml-response :=
            common:response(
                'operations/tei-editor',
                'operations', 
                (
                    (: Include request parameters :)
                    $request,
                    (: Feedback updates :)
                    $updates,
                    (: Schema validation :)
                    $validation-report,
                    (: Data :)
                    $response-data
                )
            )
        
        return
        
            (: return html data :)
            if($resource-suffix eq 'html') then (
                common:html($xml-response, concat(helper:app-path(), '/views/tei-editor.xsl'))
            )
            
            (: return xml data :)
            else (
                util:declare-option("exist:serialize", "method=xml indent=no"),
                $xml-response
            )
    