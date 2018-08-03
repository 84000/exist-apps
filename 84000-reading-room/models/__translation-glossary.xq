xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter
    Returns the glossary xml for a trsnalstion
    -------------------------------------------------------------
:)

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace outline-text="http://read.84000.co/outline-text" at "../modules/outline-text.xql";

declare option exist:serialize "method=xml indent=no omit-xml-declaration=no";

let $resource-id := request:get-parameter('resource-id', '')
let $translation := translation:tei($resource-id)
let $translation-id := translation:id($translation)
let $outlines := collection($common:outlines-path)
let $outline-text := outline-text:translation($translation-id, $outlines)
let $view-mode := request:get-parameter('view-mode', '')

return
    <response 
        xmlns="http://read.84000.co/ns/1.0" 
        model-type="translation-glossary"
        timestamp="{ current-dateTime() }"
        doc-type="www"
        view-mode="{ $view-mode }"
        app-id="{ $common:app-id }"
        app-version="{ $common:app-version }"
        user-name="{ common:user-name() }" >
            <translation-glossary 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $translation-id }"
                status="{ outline-text:status-str(outline-text:translation($translation-id, $outlines)) }">
                <title>
                {
                    translation:title($translation)
                }
                </title>
                { glossary:translation-glossary($translation) }
            </translation-glossary>
    </response>
    