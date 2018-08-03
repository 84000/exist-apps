xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace outline-text="http://read.84000.co/outline-text" at "../../84000-reading-room/modules/outline-text.xql";
import module namespace validation="http://exist-db.org/xquery/validation" at "java:org.exist.xquery.functions.validation.ValidationModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $outlines := collection($common:outlines-path)
let $schema := doc(concat($common:data-path, '/schema/1.0/translation.rng'))
let $translation-id := request:get-parameter('translation-id', 'all')

let $selected-translations := 
    if ($translation-id eq 'all') then 
        collection($common:translations-path)
    else
        translation:tei(lower-case($translation-id))

let $test-config := common:test-conf()
let $results := 
    <results xmlns="http://read.84000.co/ns/1.0">
    {
     for $translation in $selected-translations
        let $translation-id := translation:id($translation)
        let $outline-text := outline-text:translation($translation-id, $outlines)
        let $translation-html := 
            if($test-config) then 
                httpclient:get(
                    xs:anyURI(concat($test-config/m:path/text(), '/translation/', $translation-id, '.html')), 
                    false(), 
                    <headers>
                        <header name="Authorization" value="{ concat('Basic ', util:base64-encode($test-config/m:credentials/text())) }"/>
                    </headers>
               )
            else
                ()
     return
        <translation 
            id="{ $translation-id }" 
            status="published">
            <title>{ normalize-space($translation//tei:titleStmt/tei:title[@type='mainTitle'][lower-case(@xml:lang) = ('eng', 'en')]/text()) }</title>
            <tests>
            {
                let $validation-report := validation:jing-report($translation, $schema)
                return
                    <test>
                        <title>Schema: The text validates against the schema.</title>
                        <result>{ if($validation-report//*:status/text() eq 'valid') then 1 else 0 }</result>
                        <details>
                            { 
                            for $message in $validation-report//*:message
                            return 
                                <detail type="debug">{$message/text()}</detail>
                            }
                        </details>
                    </test>
            }
            {
                let $ids := $translation//@xml:id/string()
                let $count-ids := count($ids)
                let $distinct-ids := distinct-values($translation//@xml:id/string())
                let $count-distinct-ids := count($distinct-ids)
                return
                    <test>
                        <title>IDs: The text has no duplicate ids.</title>
                        <result>{ if($count-ids eq $count-distinct-ids) then 1 else 0 }</result>
                        <details>
                            {
                                if($count-ids ne $count-distinct-ids) then
                                    for $id in $distinct-ids
                                    return
                                        if($ids[. = $id][2]) then
                                            <detail type="debug">{$ids[. = $id][2]} is duplicated</detail>
                                        else ()
                                else ()
                            }
                        </details>
                    </test>
            }
            {
                let $invalid-ptrs := $translation//tei:ptr[empty(text())]/@target[not(substring-after(., '#') = ($translation//*/@xml:id))]
                return
                    <test>
                        <title>Pointers: The text has no invalid pointers.</title>
                        <result>{ if(count($invalid-ptrs) eq 0) then 1 else 0 }</result>
                        <details>
                            {
                                for $invalid-ptr in $invalid-ptrs
                                return
                                    <detail type="debug">Target { string($invalid-ptr) } was not found in the text.</detail>
                            }
                        </details>
                    </test>
            }
            {
                let $titles := $translation-html//*[@id eq 'titles']/*[self::xhtml:h1 | self::xhtml:h2 | self::xhtml:h3 | self::xhtml:h4]/text()
                let $long-titles := $translation-html//*[@id eq 'long-titles']/*[self::xhtml:h1 | self::xhtml:h2 | self::xhtml:h3 | self::xhtml:h4]/text()
                return
                    <test>
                        <title>Titles: The text has 4 main titles and 4 long titles.</title>
                        <result>{ if(count($titles) eq 4 and count($long-titles) eq 4) then 1 else 0 }</result>
                        <details>
                        { 
                            for $title in $titles
                            return 
                                <detail>Title: {$title}</detail>
                        }
                        { 
                            for $long-title in $long-titles
                            return 
                                <detail>Long title: {$long-title}</detail>
                        }
                        </details>
                    </test>
            }
            {
                let $ancestors := section:ancestors($outline-text, 1)
                return
                    <test>
                        <title>Outline: The text has a context in the outline.</title>
                        <result>{ if(count($ancestors//parent) > 0) then 1 else 0 }</result>
                        <details>
                        { 
                            for $ancestor in $ancestors//parent
                            order by $ancestor/@nesting descending
                            return 
                                <detail>{$ancestor/title/text()}</detail>
                        }
                        </details>
                    </test>
            }
            {
                let $toh := $translation-html//*[@id eq 'toh']//xhtml:h4/text()
                let $location := $translation-html//*[@id eq 'location']/text()
                let $authours-summary := $translation-html//*[@id eq 'authours-summary']/text()
                let $edition := $translation-html//*[@id eq 'edition']/text()
                let $publication-statement := $translation-html//*[@id eq 'publication-statement']/text()
                let $license := $translation-html//*[@id eq 'license']
                return
                    <test>
                        <title>Source: The text has complete documentation of the source.</title>
                        <result>{ if(
                                $toh
                                and $location
                                and $authours-summary
                                and $edition
                                and $publication-statement
                                and $license/xhtml:p
                                and $license/xhtml:img/@src/string()
                            ) then 1 else 0 }</result>
                        <details>
                            <detail>Toh: {$toh}</detail>
                            <detail>Location: {$location}</detail>
                            <detail>Author summary: {$authours-summary}</detail>
                            <detail>Publication statement: {$publication-statement}</detail>
                            <detail>License: {count($license/xhtml:p)} paragraph(s).</detail>
                            <detail>License image: {$license/xhtml:img}</detail>
                        </details>
                    </test>
            }
            {
                tests:test-section($translation//tei:front//*[@type eq 'summary'], $translation-html//*[@id eq 'summary'], 'summary', 1, false())
            }
            {
                tests:test-section($translation//tei:front//*[@type eq 'acknowledgment'], $translation-html//*[@id eq 'acknowledgements'], 'acknowledgements', 1, false())
            }
            {
                tests:test-section($translation//tei:front//*[@type eq 'introduction'], $translation-html//*[@id eq 'introduction'], 'introduction', 1, false())
            }
            {
                tests:test-section($translation//tei:body//*[@type eq 'prologue' or tei:head/text()[lower-case(.) = "prologue"]], $translation-html//*[@id eq 'prologue'], 'prologue', 0, false())
            }
            {
                tests:test-section($translation//tei:body//*[@type eq 'translation']/*[@type=('section', 'chapter')][not(tei:head/text()[lower-case(.) = "prologue"])], $translation-html//*[@id eq 'translation'], 'translation', 1, true())
            }
            {
                tests:test-section($translation//tei:body//*[@type eq 'colophon'], $translation-html//*[@id eq 'colophon'], 'colophon', 0, false())
            }
            {
                tests:test-section($translation//tei:back//*[@type eq 'appendix'], $translation-html//*[@id eq 'appendix'], 'appendix', 0, false())
            }
            {
                let $notes-count-html := count($translation-html//*[@id eq 'notes']/*/*[contains(@class, 'footnote')])
                let $notes-count-tei := count($translation//tei:text//tei:note)
                return
                    <test>
                        <title>Notes: The text has at least 1 note and the same number of notes are in the TEI and the HTML.</title>
                        <result>{ if(
                                $notes-count-html > 0
                                and $notes-count-html = $notes-count-tei
                            ) then 1 else 0 }</result>
                        <details>
                            <detail>{$notes-count-tei} note(s) in TEI, {$notes-count-html} note(s) in HTML.</detail>
                        </details>
                    </test>
            }
            {
                let $abbreviations-count-html := count($translation-html//*[@id eq 'abbreviations']//xhtml:tr)
                let $abbreviations-count-tei := count($translation//tei:back//tei:list[@type='abbreviations']/tei:item/tei:abbr)
                return
                    <test>
                        <title>Abbreviations: The abbreviations have same number of items are in the TEI and the HTML.</title>
                        <result>{ if(
                                $abbreviations-count-html = $abbreviations-count-tei
                            ) then 1 else 0 }</result>
                        <details>
                            <detail>{$abbreviations-count-tei} items(s) in TEI, {$abbreviations-count-html} items(s) in HTML.</detail>
                        </details>
                    </test>
            }
            {
                let $biblography-count-html := count($translation-html//*[@id eq 'bibliography']//xhtml:p)
                let $biblography-count-tei := count($translation//tei:back/tei:div[@type='listBibl']//tei:bibl)
                return
                    <test>
                        <title>Bibliography: The text has at least 1 bibliography section with at least 1 item  and the same number of items are in the TEI and the HTML.</title>
                        <result>{ if(
                                $biblography-count-html > 0
                                and $biblography-count-html = $biblography-count-tei
                            ) then 1 else 0 }</result>
                        <details>
                            <detail>{$biblography-count-tei} items(s) in TEI, {$biblography-count-html} items(s) in HTML.</detail>
                        </details>
                    </test>
            }
            {
                let $glossary-count-html := count($translation-html//*[@id eq 'glossary']//*[contains(@class, 'glossary-item')])
                let $glossary-count-tei := count($translation//tei:back/tei:div[@type='glossary']//tei:gloss)
                let $tei-terms-raw := $translation//tei:back/tei:div[@type='glossary']//tei:gloss/tei:term[text()][not(tei:ptr)]
                let $tei-terms := 
                    for $tei-term in $tei-terms-raw
                    return 
                        if($tei-term[@xml:lang eq "Bo-Ltn"])then
                            string($tei-term) ! lower-case(.) ! normalize-space() ! common:bo-ltn(.)
                        else
                            string($tei-term) ! lower-case(.) ! normalize-space()
                let $terms-count-tei := count($tei-terms)
                
                let $html-terms-untokenized := $translation-html//*[@id eq 'glossary']//*[contains(@class, 'glossary-item')]//*[self::xhtml:h4 | self::xhtml:p[not(xhtml:a/@class[contains(., 'internal-ref')])]]
                let $html-terms := 
                    for $html-term in $html-terms-untokenized/string(.) ! tokenize(., '·')
                    return 
                        lower-case($html-term) ! normalize-space(.)
                let $terms-count-html := count($html-terms)
                
                let $anomalies := 
                    for $term in $html-terms
                    return
                        let $term-count-tei := count($tei-terms[. = $term])
                        let $term-count-html := count($html-terms[. = $term])
                        return 
                            if(not($term-count-tei = $term-count-html)) then
                                concat($term, ' (', xs:string($term-count-tei), ' occurrence(s) in the TEI and ', xs:string($term-count-html), ' occurrence(s) in the HTML)')
                            else
                                ()
                return
                    <test>
                        <title>Glossary: The text has at least 1 glossary item and there are the same number in the HTML as in the TEI with no anomalies in the counts of each term.</title>
                        <result>{ if(
                                $glossary-count-html > 0
                                and $glossary-count-html = $glossary-count-tei
                                and $terms-count-html = $terms-count-tei
                                and count($anomalies) = 0
                            ) then 1 else 0 }</result>
                        <details>
                            <detail>{$glossary-count-tei} glossary item(s) in the TEI, {$glossary-count-html} glossary item(s) in the HTML.</detail>
                            <detail>{$terms-count-tei} glossary term(s) in the TEI, {$terms-count-html} glossary term(s) in the HTML.</detail>
                            <detail>{ count($anomalies) } anomalies detected.</detail>
                            {
                                for $anomaly in $anomalies
                                return 
                                    <detail type="debug">{ $anomaly }</detail>

                            }
                        </details>
                    </test>
            }
            </tests>
        </translation>
    }
    </results>

return 
    common:response(
        'utilities/test-translations',
        'utilities',
        (
            translations:files(),
            $results
    )
)