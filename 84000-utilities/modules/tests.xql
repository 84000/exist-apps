xquery version "3.0";

module namespace tests="http://utilities.84000.co/tests";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace validation="http://exist-db.org/xquery/validation" at "java:org.exist.xquery.functions.validation.ValidationModule";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace m="http://read.84000.co/ns/1.0";

declare function tests:translations($translation-id as xs:string) as item(){
    
    (:let $translation-id := 'UT22084-062-012':)
    
    let $outlines := collection($common:outlines-path)
    let $schema := doc(concat($common:data-path, '/schema/1.0/translation.rng'))
    let $selected-translations := 
        if ($translation-id eq 'all') then 
            collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $common:published-statuses]
        else
            tei-content:tei(lower-case($translation-id), 'translation')
    
    let $test-config := common:test-conf()
    
    return
        <results xmlns="http://read.84000.co/ns/1.0">
        {
         for $tei in $selected-translations
            for $toh-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                let $toh-html := 
                    if($test-config) then 
                        httpclient:get(
                            xs:anyURI(concat($test-config/m:path/text(), '/translation/', $toh-key, '.html')), 
                            false(), 
                            <headers>
                                <header name="Authorization" value="{ concat('Basic ', util:base64-encode($test-config/m:credentials/text())) }"/>
                            </headers>
                       )
                    else
                        ()
             
            return
               <translation 
                   id="{ $toh-key }" 
                   status="published">
                   <title>{ tei-content:title($tei) }</title>
                   <tests>
                   {
                       let $validation-report := validation:jing-report($tei, $schema)
                       return
                           <test id="schema-validation" pass="{ if($validation-report//*:status/text() eq 'valid') then 1 else 0 }">
                               <title>Schema test: The text validates against the schema.</title>
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
                        let $ids := $tei//@xml:id/string()
                        let $count-ids := count($ids)
                        let $distinct-ids := distinct-values($tei//@xml:id/string())
                        let $count-distinct-ids := count($distinct-ids)
                        return
                            <test id="duplicate-ids" pass="{ if($count-ids eq $count-distinct-ids) then 1 else 0 }">
                                <title>ID test: The text has no duplicate ids.</title>
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
                        let $invalid-ptrs := $tei//tei:ptr[empty(text())]/@target[not(substring-after(., '#') = ($tei//*/@xml:id))]
                        return
                            <test id="valid-pointers" pass="{ if(count($invalid-ptrs) eq 0) then 1 else 0 }">
                                <title>Pointers test: The text has no invalid pointers.</title>
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
                        let $titles := $toh-html//*[@id eq 'titles']/*[self::xhtml:h1 | self::xhtml:h2 | self::xhtml:h3 | self::xhtml:h4]/text()
                        let $long-titles := $toh-html//*[@id eq 'long-titles']/*[self::xhtml:h1 | self::xhtml:h2 | self::xhtml:h3 | self::xhtml:h4]/text()
                        return
                            <test id="all-titles" pass="{ if(count($titles) eq 4 and count($long-titles) eq 4) then 1 else 0 }">
                                <title>Titles test: The text has 4 main titles and 4 long titles.</title>
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
                        let $ancestors := tei-content:ancestors($tei, $toh-key, 1)
                        return
                            <test id="outline-context" pass="{ if(count($ancestors//parent) > 0) then 1 else 0 }">
                                <title>Outline test: The text has a context in the outline.</title>
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
                        let $toh := $toh-html//*[@id eq 'toh']//xhtml:h4/text()
                        let $location := $toh-html//*[@id eq 'location']/text()
                        let $authours-summary := $toh-html//*[@id eq 'authours-summary']/text()
                        let $edition := $toh-html//*[@id eq 'edition']/text()
                        let $publication-statement := $toh-html//*[@id eq 'publication-statement']/text()
                        let $license := $toh-html//*[@id eq 'license']
                        return
                            <test 
                                id="complete-source" 
                                pass="{ if($toh and $location and $authours-summary and $edition and $publication-statement and $license/xhtml:p and $license/xhtml:img/@src/string()) then 1 else 0 }">
                                <title>Source test: The text has complete documentation of the source.</title>
                                <details>
                                    <detail>Toh: {$toh}</detail>
                                    <detail>Location: {$location}</detail>
                                    <detail>Author summary: {$authours-summary}</detail>
                                    <detail>Publication statement: {$publication-statement}</detail>
                                    <!--<detail>License: { count($license/xhtml:p) } paragraph(s).</detail>-->
                                    <!--<detail>License image: {$license/xhtml:img}</detail>-->
                                </details>
                            </test>
                    }
                    {
                        tests:test-translation-section($tei//tei:front//*[@type eq 'summary'], $toh-html//*[@id eq 'summary'], 'summary', 1, false())
                    }
                    {
                        tests:test-translation-section($tei//tei:front//*[@type eq 'acknowledgment'], $toh-html//*[@id eq 'acknowledgements'], 'acknowledgements', 1, false())
                    }
                    {
                        tests:test-translation-section($tei//tei:front//*[@type eq 'introduction'], $toh-html//*[@id eq 'introduction'], 'introduction', 1, false())
                    }
                    {
                        tests:test-translation-section($tei//tei:body//*[@type eq 'prologue' or tei:head/text()[lower-case(.) = "prologue"]], $toh-html//*[@id eq 'prologue'], 'prologue', 0, false())
                    }
                    {
                        tests:test-translation-section($tei//tei:body//*[@type eq 'translation']/*[@type=('section', 'chapter')][not(tei:head/text()[lower-case(.) = "prologue"])], $toh-html//*[@id eq 'translation'], 'translation', 1, true())
                    }
                    {
                        tests:test-translation-section($tei//tei:body//*[@type eq 'colophon'], $toh-html//*[@id eq 'colophon'], 'colophon', 0, false())
                    }
                    {
                        tests:test-translation-section($tei//tei:back//*[@type eq 'appendix'], $toh-html//*[@id eq 'appendix'], 'appendix', 0, false())
                    }
                    {
                        let $notes-count-html := count($toh-html//*[@id eq 'notes']/*/*[contains(@class, 'footnote')])
                        let $notes-count-tei := count($tei//tei:text//tei:note)
                        return
                            <test 
                                id="notes"
                                pass="{ if($notes-count-html > 0 and $notes-count-html = $notes-count-tei) then 1 else 0 }">
                                <title>Notes test: The text has at least 1 note and the same number of notes are in the TEI and the HTML.</title>
                                <result></result>
                                <details>
                                    <detail>{$notes-count-tei} note(s) in TEI, {$notes-count-html} note(s) in HTML.</detail>
                                </details>
                            </test>
                    }
                    {
                        let $abbreviations-count-html := count($toh-html//*[@id eq 'abbreviations']//xhtml:tr)
                        let $abbreviations-count-tei := count($tei//tei:back//tei:list[@type='abbreviations']/tei:item/tei:abbr)
                        return
                            <test
                                id="abbreviations"
                                pass="{ if($abbreviations-count-html = $abbreviations-count-tei) then 1 else 0 }">
                                <title>Abbreviations: The abbreviations have same number of items are in the TEI and the HTML.</title>
                                <details>
                                    <detail>{$abbreviations-count-tei} items(s) in TEI, {$abbreviations-count-html} items(s) in HTML.</detail>
                                </details>
                            </test>
                    }
                    {
                        let $biblography-count-html := count($toh-html//*[@id eq 'bibliography']//xhtml:p)
                        let $biblography-count-tei := count($tei//tei:back/tei:div[@type='listBibl']//tei:bibl)
                        return
                            <test
                                id="bibliography"
                                pass="{ if($biblography-count-html > 0 and $biblography-count-html = $biblography-count-tei) then 1 else 0 }">
                                <title>Bibliography: The text has at least 1 bibliography section with at least 1 item  and the same number of items are in the TEI and the HTML.</title>
                                <details>
                                    <detail>{$biblography-count-tei} items(s) in TEI, {$biblography-count-html} items(s) in HTML.</detail>
                                </details>
                            </test>
                    }
                    {
                        let $glossary-count-html := count($toh-html//*[@id eq 'glossary']//*[contains(@class, 'glossary-item')])
                        let $glossary-count-tei := count($tei//tei:back/tei:div[@type='glossary']//tei:gloss)
                        let $tei-terms-raw := $tei//tei:back/tei:div[@type='glossary']//tei:gloss/tei:term[text()][not(tei:ptr)]
                        
                        let $tei-terms := 
                            for $tei-term in $tei-terms-raw
                            return 
                                if($tei-term[@xml:lang eq "Bo-Ltn"])then
                                    string($tei-term) ! lower-case(.) ! normalize-space() ! common:bo-ltn(.)
                                else
                                    string($tei-term) ! lower-case(.) ! normalize-space()
                                    
                        let $terms-count-tei := count($tei-terms)
                        
                        let $html-terms-untokenized := 
                            $toh-html//*[@id eq 'glossary']//*[contains(@class, 'glossary-item')]//*[self::xhtml:h4 | self::xhtml:p[not(xhtml:a/@class[contains(., 'internal-ref')])]]
                        
                        let $empty-term-placeholders := (common:app-text('glossary.term-empty-sa-ltn'), common:app-text('glossary.term-empty-bo-ltn'))
                        
                        let $html-terms := 
                            for $html-term in $html-terms-untokenized/string(.) ! tokenize(., '·')
                            return 
                                if(not($html-term = $empty-term-placeholders)) then
                                    lower-case($html-term) ! normalize-space(.)
                                else
                                    ()
                                
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
                            <test
                                id="glossary"
                                pass="{ if($glossary-count-html > 0 and $glossary-count-html = $glossary-count-tei and $terms-count-html = $terms-count-tei and count($anomalies) = 0) then 1 else 0 }">
                                <title>Glossary: The text has at least 1 glossary item and there are the same number in the HTML as in the TEI with no anomalies in the counts of each term.</title>
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
};

declare function tests:test-translation-section($section-tei as element()*, $section-html as element()*, $section-name as xs:string, $required-paragraphs as xs:integer, $count-chapters as xs:boolean)
{
    let $section-count-tei-p := count($section-tei//*[self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl | self::tei:l[parent::tei:lg[not(ancestor::tei:note)]]])
    let $section-count-html-p := count($section-html//xhtml:p | $section-html//xhtml:div[contains(@class, 'line ')]) 
    (: This needs attention: we can't rely on a space after the class 'line' :)
    
    let $section-count-tei-note := count($section-tei//tei:note)
    let $section-count-html-note := count($section-html//xhtml:a[contains(@class, 'footnote-link')])
    
    let $section-count-tei-q := count($section-tei//tei:q)
    let $section-count-html-q := count($section-html//xhtml:blockquote | $section-html//xhtml:span[contains(@class, 'blockquote')])
    
    let $section-count-tei-id := count($section-tei//*[@tid][not(ancestor::tei:note)])
    let $section-count-html-id := count($section-html//*[contains(@id, 'node-')])
    
    let $section-count-tei-list-item := count($section-tei//tei:list[not(ancestor::tei:note)]/tei:item)
    let $section-count-html-list-item := count($section-html//xhtml:div[contains(@class, 'list-item')])
    
    let $section-count-tei-chapters := count($section-tei//tei:div[@type = ('section', 'chapter')])
    let $section-count-html-chapters := count($section-html//xhtml:section[contains(@class, 'chapter')])
    
    let $section-count-tei-milestones := count($section-tei//tei:milestone)
    let $section-count-html-milestones := count($section-html//xhtml:a[contains(@class, 'milestone from-tei')])
    
    let $required-paragraphs-rule := if ($required-paragraphs > 0) then concat(' at least ', $required-paragraphs , ' paragraph(s) and') else ''
    let $count-chapters-rule := if ($count-chapters eq true()) then ', chapters' else ''
    
    return
        <test 
            xmlns="http://read.84000.co/ns/1.0"
            id="{ concat('valid-', $section-name, '-section') }"
            pass="{ if(
                    $section-count-html-p ge $required-paragraphs
                    and $section-count-html-p eq $section-count-tei-p
                    and $section-count-html-note eq $section-count-tei-note
                    and $section-count-html-q eq $section-count-tei-q
                    and $section-count-html-id eq $section-count-tei-id
                    and $section-count-html-list-item eq $section-count-tei-list-item
                    and ($count-chapters eq false() or $section-count-tei-chapters eq 0 or $section-count-html-chapters eq $section-count-tei-chapters)
                    and $section-count-html-milestones eq $section-count-tei-milestones
                ) then 1 else 0 }">
            <title>
            {
                concat(functx:capitalize-first($section-name) ,' test: The ', $section-name, ' has', $required-paragraphs-rule, ' the same number of paragraphs, notes, quotes, ids, labels, list items', $count-chapters-rule, ' and milestones  in the HTML as in the TEI.')
            }
            </title>
            <details>
                <detail>{$section-count-tei-p} TEI paragraph(s), {$section-count-html-p} HTML paragraph(s).</detail>
                <detail>{$section-count-tei-note} TEI note(s), {$section-count-html-note} HTML note(s).</detail>
                <detail>{$section-count-tei-q} TEI quote(s), {$section-count-html-q} HTML quote(s).</detail>
                <detail>{$section-count-tei-id} TEI id(s), {$section-count-html-id} HTML id(s).</detail>
                <detail>{$section-count-tei-list-item} TEI list item(s), {$section-count-html-list-item} HTML list item(s).</detail>
                <detail>{$section-count-tei-milestones} TEI milestone(s), {$section-count-html-milestones} HTML milestone(s).</detail>
                {
                    if ($count-chapters eq true()) then
                        <detail>{$section-count-tei-chapters} TEI chapter(s), {$section-count-html-chapters} HTML chapter(s).</detail>
                    else
                        ()
                }
            </details>
        </test>
};
