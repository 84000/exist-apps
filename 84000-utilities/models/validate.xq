xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

import module namespace validation="http://exist-db.org/xquery/validation" at "java:org.exist.xquery.functions.validation.ValidationModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $type := request:get-parameter('type', 'translations')
let $work := request:get-parameter('work', 'all')

let $schema-path := 
    if($type = ('translations', 'placeholders')) then
        concat($common:tei-path, '/schema/current/translation.rng')
    else
        concat($common:tei-path, '/schema/current/section.rng')

let $schema := 
    if($schema-path gt '') then
        doc($schema-path)
    else ()

let $work-tei := translations:work-tei($work)
let $files := 
    if($type eq 'placeholders') then
        $work-tei[not(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids)]
    else if($type eq 'translations') then
        $work-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids]
    else
        collection($common:sections-path)//tei:TEI

let $reading-room-url := $common:environment/m:url[@id eq 'reading-room']/text()
let $results := 
    <results xmlns="http://read.84000.co/ns/1.0" type="{ $type }" schema="{ $schema-path }" work="{ $work }">
    {
        for $tei in $files
            let $id := tei-content:id($tei)
            let $title := tei-content:title-any($tei)
            let $validation-report := validation:jing-report($tei, $schema)
            let $file-name := util:unescape-uri(base-uri($tei), 'UTF-8')
        return
            <tei-validation id="{ $id }" file-name="{ $file-name }">
                {
                    if($type eq 'translations') then
                        attribute url { concat($reading-room-url, '/translation/', $id, '.tei') }
                    else if($type eq 'placeholders') then
                        attribute url { concat($reading-room-url, '/translation/', $id, '.tei') }
                    else if($type eq 'sections') then
                        attribute url { concat($reading-room-url, '/section/', $id, '.tei') }
                    else ()
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
            utilities:request(),
            $results
        )
    )