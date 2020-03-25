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
import module namespace search="http://read.84000.co/search" at "../modules/search.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')

(: Get the tei :)
let $tei := tei-content:tei($resource-id, 'translation')

(: Get the source so we can extract the Toh :)
let $source := tei-content:source($tei, $resource-id)

(: Compile all the translation data :)
let $translation-data :=
    <translation 
        xmlns="http://read.84000.co/ns/1.0" 
        id="{ tei-content:id($tei) }"
        status="{ tei-content:translation-status($tei) }"
        status-group="{ tei-content:translation-status-group($tei) }"
        page-url="{ translation:canonical-html($source/@key) }">
        {(
            translation:titles($tei),
            translation:long-titles($tei),
            $source,
            translation:translation($tei),
            translation:summary($tei),
            translation:acknowledgment($tei),
            if(not($resource-suffix = ('rdf', 'json'))) then(
                tei-content:ancestors($tei, $source/@key, 1),
                translation:downloads($tei, $source/@key, 'any-version'),
                translation:preface($tei),
                translation:introduction($tei),
                translation:prologue($tei),
                translation:body($tei),
                translation:colophon($tei),
                translation:appendix($tei),
                translation:abbreviations($tei),
                translation:notes($tei),
                translation:bibliography($tei),
                translation:glossary($tei)
            )
            else
                ()
        )}
    </translation>

(: Parse the milestones :)
let $translation-data-milestones := 
    transform:transform(
        $translation-data,
        doc(concat($common:app-path, "/xslt/milestones.xsl")), 
        <parameters/>
    )

(: Parse the refs and pointers :)
let $translation-data-internal-refs := 
    transform:transform(
        $translation-data-milestones,
        doc(concat($common:app-path, "/xslt/internal-refs.xsl")), 
        <parameters/>
    )

return
    common:response(
        'translation',
        $common:app-id,
        (
            (: Include request parameters :)
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }"
                doc-type="{ request:get-parameter('resource-suffix', 'html') }"
                view-mode="{ common:view-mode() }" />,
            (: Calculated strings :)
            <replace-text xmlns="http://read.84000.co/ns/1.0">
                <value key="#CurrentDateTime">{ format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }</value>
                <value key="#LinkToPage">{ translation:canonical-html($source/@key) }</value>
            </replace-text>,
            (: Include translation data :)
            $translation-data-internal-refs
        )
    )

    
