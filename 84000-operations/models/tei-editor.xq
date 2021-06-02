xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";

declare option exist:serialize "method=xml indent=no";

let $type := request:get-parameter('type', '')
let $resource-id := request:get-parameter('resource-id', '')
let $section-id := request:get-parameter('section-id', '')
let $sibling-id := request:get-parameter('sibling-id', '')
let $markdown := request:get-parameter('markdown', '')
let $form-action := request:get-parameter('form-action', '')

let $tei := 
    if($type = ('knowledgebase')) then
        tei-content:tei($resource-id, $type)
    else ()

let $update-tei :=
    if($type = ('knowledgebase') and $tei and $form-action eq 'update-tei') then 
        update-tei:markup($tei, $markdown, $section-id, $sibling-id)
    else ()

(: Switch to new section-id if updated :)
let $section-id := 
    if($section-id eq '' and $sibling-id gt '') then 
        $tei//*[@xml:id eq $sibling-id]/following-sibling::*[@xml:id][1]/@xml:id
    else 
        $section-id

let $schema := doc(concat($common:tei-path, '/schema/current/knowledgebase.rng'))
let $validation-report := validation:jing-report($tei, $schema)

return
    common:response(
        'operations/tei-editor',
        'operations', 
        (
            (: Include request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request') } {
                attribute type { $type },
                attribute resource-id { $resource-id },
                attribute section-id { $section-id },
                attribute sibling-id { $sibling-id }
            },
            
            element { QName('http://read.84000.co/ns/1.0', 'updates') } {
                $update-tei
            },
            
            element { QName('http://read.84000.co/ns/1.0', 'validation') } {
                $validation-report
            },
            
            (: Restrict to knowledgebase only for now :)
            if($tei and $type eq 'knowledgebase') then (
                
                element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') } {
                    
                    attribute document-url { tei-content:document-url($tei) },
                    attribute locked-by-user { tei-content:locked-by-user($tei) },
                
                    knowledgebase:page($tei),
                    knowledgebase:article($tei),
                    knowledgebase:bibliography($tei)
                    
                },
                
                element { QName('http://read.84000.co/ns/1.0', 'default-markup') } {
                    knowledgebase:new-section($tei//*[@xml:id eq $sibling-id]/ancestor-or-self::*[@type][last()]/@type)/*
                }
            )
            else ()
        )
    )