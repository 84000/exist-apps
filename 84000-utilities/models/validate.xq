xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace validation="http://exist-db.org/xquery/validation" at "java:org.exist.xquery.functions.validation.ValidationModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $type := request:get-parameter('type', 'translations')

let $schema := 
    if($type eq 'translations') then
        doc(concat($common:data-path, '/schema/1.0/translation.rng'))
    else if($type eq 'placeholders') then
        doc(concat($common:data-path, '/schema/1.0/placeholder.rng'))
    else if($type eq 'sections') then
        doc(concat($common:data-path, '/schema/1.0/section.rng'))
    else
        ()

let $files := 
    if($type eq 'translations') then
        collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $common:published-statuses]
    else if($type eq 'placeholders') then
        collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/not(@status = $common:published-statuses)]
    else if($type eq 'sections') then
        collection($common:sections-path)//tei:TEI
    else
        ()

let $reading-room-url := $common:environment/m:url[@id eq 'reading-room']/text()
let $results := 
    <results xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $files
            let $id := tei-content:id($tei)
            let $title := tei-content:title($tei)
            let $validation-report := validation:jing-report($tei, $schema)
            let $file-name := util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8')
        return
            <tei-validation id="{ $id }" file-name="{ $file-name }">
                {
                    if($type eq 'translations') then
                        attribute url { concat($reading-room-url, '/translation/', $id, '.tei') }
                    else if($type eq 'placeholders') then
                        attribute url { concat($reading-room-url, '/translation/', $id, '.tei') }
                    else if($type eq 'sections') then
                        attribute url { concat($reading-room-url, '/section/', $id, '.tei') }
                    else
                        ()
                }
                <title>{ $title }</title>
                {
                    <result status="{ $validation-report//*:status/text() }">
                    { 
                        for $error in $validation-report//*:message
                        return 
                            <error line="{ $error/@line }">{ $error/text() }</error>
                    }
                    </result>
                }                
            </tei-validation>
    }
    </results>

return 
    common:response(
        'utilities/validate',
        'utilities',
        (
            <request xmlns="http://read.84000.co/ns/1.0" type="{ $type }"/>,
            $results
        )
    )