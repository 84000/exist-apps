xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";

declare option exist:serialize "method=xml indent=no";
(:
let $translation-id := 'UT22084-044-003'
let $translation := translation:tei($translation-id)
let $test-bo-ltn := $translation//tei:back//*[@type='glossary']//tei:gloss/tei:term[@xml:lang eq 'Bo-Ltn']
:)
let $test-bo-ltn := doc(concat($common:data-path, '/uploads/test-bo-ltn.xml'))//m:bo-ltn

return
    <response 
        xmlns="http://read.84000.co/ns/1.0" 
        model-type="test-conversion"
        timestamp="{current-dateTime()}"
        app-id="{ $common:app-id }"
        user-name="{ common:user-name() }">
    {
        for $bo-ltn in $test-bo-ltn
        return 
            <term>
                {
                    $bo-ltn
                }
                <bo>
                {
                    common:bo-title($bo-ltn/string())
                }
                </bo>
            </term>
    }
    </response>