xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter
    Returns the translation xml
    -------------------------------------------------------------
    This does most of the processing of the TEI into a simple xml
    format. This should then be transformed into json/html/pdf/epub
    or other formats.
:)

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')

(: Get the tei :)
let $tei := tei-content:tei($resource-id, 'translation')

(: Get the source so we can extract the Toh :)
let $source := tei-content:source($tei, $resource-id)

(: Set the canonical url :)
let $page-url := concat('http://read.84000.co/translation/', $source/@key, '.html')

(: Compile all the translation data :)
let $translation-data :=
    <translation 
        xmlns="http://read.84000.co/ns/1.0" 
        id="{ tei-content:id($tei) }"
        status="{ tei-content:translation-status($tei) }"
        page-url="{ $page-url }"
        ekangyur-work="{ $common:ekangyur-work }">
        { tei-content:ancestors($tei, $resource-id, 1) }
        { translation:titles($tei) }
        { translation:long-titles($tei) }
        { $source }
        { translation:translation($tei) }
        { translation:downloads($tei, $resource-id, 'any-version') }
        { translation:summary($tei) }
        { translation:acknowledgment($tei) }
        { translation:preface($tei) }
        { translation:introduction($tei) }
        { translation:prologue($tei) }
        { translation:body($tei) }
        { translation:colophon($tei) }
        { translation:appendix($tei) }
        { translation:abbreviations($tei) }
        { translation:notes($tei) }
        { translation:bibliography($tei) }
        { translation:glossary($tei) }
    </translation>

(: Parse the milestones :)
let $translation-data-milestones := transform:transform($translation-data, doc(concat($common:app-path, "/xslt/milestones.xsl")), <parameters/>)

(: Parse the internal refs :)
let $translation-data-internal-refs := transform:transform($translation-data-milestones, doc(concat($common:app-path, "/xslt/internal-refs.xsl")), <parameters/>)

return
    common:response(
        'translation',
        $common:app-id,
        (
            (: Include request parameters :)
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                doc-type="{ request:get-parameter('resource-suffix', 'www') }"
                view-mode="{ request:get-parameter('view-mode', '') }" />,
                
            (: Include translation data :)
            $translation-data-internal-refs,
            
            (: If it's html include app texts :)
            if(request:get-parameter('resource-suffix', '') = ('html', 'epub', 'azw3')) then
                common:app-texts(
                    'translation',
                    <replace xmlns="http://read.84000.co/ns/1.0">
                        <value key="#CurrentDateTime">{ format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }</value>
                        <value key="#LinkToPage">{ $page-url }</value>
                    </replace>
                )
            else
                ()
        )
    )

    