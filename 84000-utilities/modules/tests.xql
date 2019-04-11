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

declare variable $tests:tests-collection := concat($common:data-path, '/config');
declare variable $tests:tests-file := 'lucene-tests.xml';
declare variable $tests:lucene-tests := doc(concat($tests:tests-collection, '/', $tests:tests-file))/m:lucene-tests;

declare function tests:translations($translation-id as xs:string) as item(){
    
    (:let $translation-id := 'UT22084-062-012':)
    
    let $schema := doc(concat($common:tei-path, '/schema/current/translation.rng'))
    
    let $selected-translations := 
        if ($translation-id eq 'all') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:text-statuses/m:status[@marked-up = ('true')]/@status-id]
        else if ($translation-id eq 'published') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:text-statuses/m:status[@group = ('published')]/@status-id]
            else if ($translation-id eq 'in-markup') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:text-statuses/m:status[@marked-up = ('true')][not(@group = ('published'))]/@status-id]
        else
            tei-content:tei(lower-case($translation-id), 'translation')
    
    let $test-config := $common:environment//m:test-conf
    
    return
        <results xmlns="http://read.84000.co/ns/1.0">
        {
         for $tei in $selected-translations
            for $toh-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                let $start-time := util:system-dateTime()
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
                let $end-time := util:system-dateTime()
            return
               <translation 
                   id="{ tei-content:id($tei) }" 
                   status="{ $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status }"
                   duration="{ functx:total-seconds-from-duration($end-time - $start-time) }">
                   <title>{ tei-content:title($tei) }</title>
                   { translation:toh($tei, $toh-key) }
                   <tests>
                    {
                        tests:validate-schema($tei, $schema)
                    }
                    {
                        tests:duplicate-ids($tei)
                    }
                    {
                        tests:valid-pointers($tei)
                    }
                    {
                        tests:titles($toh-html, $tei)
                    }
                    {
                        tests:outline-context($tei, $toh-key)
                    }
                    {
                        tests:complete-source($toh-html)
                    }
                    {
                        tests:translation-tantra-warning($tei, $toh-html)
                    }
                    {
                        tests:test-section($tei//tei:front//tei:div[@type eq 'summary'], $toh-html//*[@id eq 'summary'], 'summary', 1, false(), true())
                    }
                    {
                        tests:test-section($tei//tei:front//tei:div[@type eq 'acknowledgment'], $toh-html//*[@id eq 'acknowledgements'], 'acknowledgements', 1, false(), true())
                    }
                    {
                        tests:test-section($tei//tei:front//tei:div[@type eq 'preface'], $toh-html//*[@id eq 'preface'], 'preface', 0, false(), true())
                    }
                    {
                        tests:test-section($tei//tei:front//tei:div[@type eq 'introduction'], $toh-html//*[@id eq 'introduction'], 'introduction', 1, false(), true())
                    }
                    {
                        tests:test-section($tei//tei:body//tei:div[@type eq 'prologue'], $toh-html//*[@id eq 'prologue'], 'prologue', 0, false(), true())
                    }
                    {
                        tests:test-section(<tei:div type='translation'>{$tei//tei:body//tei:div[@type eq 'translation']/*[@type=('section', 'chapter')]}</tei:div>, $toh-html//*[@id eq 'translation'], 'translation', 1, true(), true())
                    }
                    {
                        tests:test-section($tei//tei:body//tei:div[@type eq 'colophon'], $toh-html//*[@id eq 'colophon'], 'colophon', 0, false(), true())
                    }
                    {
                        tests:test-section($tei//tei:back//tei:div[@type eq 'appendix'], $toh-html//*[@id eq 'appendix'], 'appendix', 0, false(), true())
                    }
                    {
                        tests:notes($tei, $toh-html)
                    }
                    {
                        tests:abbreviations($tei, $toh-html)
                    }
                    {
                        tests:bibliography($tei, $toh-html)
                    }
                    {
                        tests:glossary($tei, $toh-html)
                    }
                </tests>
            </translation>
        }
        </results>
};

declare function tests:sections($section-id as xs:string) as item(){

    let $schema := doc(concat($common:tei-path, '/schema/current/section.rng'))
    let $selected-tei := 
        if ($section-id eq 'all') then 
            $section:sections//tei:TEI
        else
            tei-content:tei(lower-case($section-id), 'section')
    
    let $test-config := $common:environment//m:test-conf
    
    return
        <results xmlns="http://read.84000.co/ns/1.0">
        {
            for $tei at $pos in $selected-tei
                let $start-time := util:system-dateTime()
                let $resource-id := tei-content:id($tei)
                let $html := 
                    if($test-config) then 
                        httpclient:get(
                            xs:anyURI(concat($test-config/m:path/text(), '/section/', $resource-id, '.html')), 
                            false(), 
                            <headers>
                                <header name="Authorization" value="{ concat('Basic ', util:base64-encode($test-config/m:credentials/text())) }"/>
                            </headers>
                       )
                    else
                        ()
                 let $end-time := util:system-dateTime()
            return
                <section 
                    id="{ $resource-id }"
                    filename="{ base-uri($tei) }"
                    duration="{ functx:total-seconds-from-duration($end-time - $start-time) }">
                    <title>{ tei-content:title($tei) }</title>
                    <tests>
                    {
                        tests:validate-schema($tei, $schema)
                    }
                    {
                        tests:duplicate-ids($tei)
                    }
                    {
                        tests:outline-context($tei, $resource-id)
                    }
                    {
                        tests:test-section($tei//tei:front//tei:div[@type eq 'abstract'], $html//*[@id eq 'title']//*[@id eq 'abstract'], 'abstract', 0, false(), false())
                    }
                    {
                        tests:test-section($tei//tei:body//tei:div[@type eq 'about'], $html//*[@id eq 'summary'], 'summary', 0, false(), false())
                    }
                    {
                        tests:section-tantra-warning($tei, $html)
                    }
                    </tests>
                </section>
        }
        </results>
};

declare function tests:validate-schema($tei as element(), $schema as node()) as item() {

   let $validation-report := validation:jing-report($tei, $schema)
   
   return
       <test xmlns="http://read.84000.co/ns/1.0" 
            id="schema-validation" 
            pass="{ if($validation-report//*:status/text() eq 'valid') then 1 else 0 }">
           <title>Schema test: The text validates against the schema.</title>
           <details>
               { 
               for $message in $validation-report//*:message
               return 
                   <detail type="debug">{$message/text()}</detail>
               }
           </details>
       </test>
};

declare function tests:duplicate-ids($tei as element()) as item() {

    let $ids := $tei//@xml:id/string()
    let $count-ids := count($ids)
    let $distinct-ids := distinct-values($tei//@xml:id/string())
    let $count-distinct-ids := count($distinct-ids)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="duplicate-ids"
            pass="{ if($count-ids eq $count-distinct-ids) then 1 else 0 }">
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
};

declare function tests:valid-pointers($tei as element()) as item() {

    let $invalid-ptrs := $tei//tei:ptr[empty(text())]/@target[not(substring-after(., '#') = ($tei//*/@xml:id))]
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="valid-pointers" 
            pass="{ if(count($invalid-ptrs) eq 0) then 1 else 0 }">
            <title>Pointers test: The text has no invalid pointers.</title>
            <details>
                {
                    for $invalid-ptr in $invalid-ptrs
                    return
                        <detail type="debug">Target { string($invalid-ptr) } was not found in the text.</detail>
                }
            </details>
        </test>
};

declare function tests:titles($toh-html as element(), $tei as element()) as item() {
    
    (: Bo-Ltn can be derived from bo or vice versa :)
    (: Max 3: 'en', 'Sa-Ltn' and either 'Bo-Ltn' or  'bo' :)
    let $tei-main-titles := 
        (
            $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('en', 'Sa-Ltn')][text()],
            $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('Bo-Ltn', 'bo')][text()][1]
        )
    
    (: Max 4: 'en', 'Sa-Ltn', 'Bo-Ltn' and 'bo' if 'Bo-Ltn' or 'bo'  :)
    let $tei-long-titles := 
        (
            $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('en', 'Sa-Ltn')][text()],
            $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('Bo-Ltn', 'bo')][text()][1],
            $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('Bo-Ltn', 'bo')][text()][1]
        )
    
    let $html-main-titles := $toh-html//*[@id eq 'titles']/*[self::xhtml:h1 | self::xhtml:h2 | self::xhtml:h3 | self::xhtml:h4][text()]
    let $html-long-titles := $toh-html//*[@id eq 'long-titles']/*[self::xhtml:h1 | self::xhtml:h2 | self::xhtml:h3 | self::xhtml:h4][text()]
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="titles" 
            pass="{ if(count($tei-main-titles) eq count($html-main-titles) and count($tei-long-titles) eq count($html-long-titles)) then 1 else 0 }">
            <title>Titles test: The html has the correct number of titles.</title>
            <details>
            { 
                for $title in $tei-main-titles
                return 
                    <detail>Main title: {$title/text()}</detail>
            }
            { 
                for $title in $html-long-titles
                return 
                    <detail>Long title: {$title/text()}</detail>
            }
            </details>
        </test>
};

declare function tests:outline-context($tei as element(), $resource-id as xs:string) as item() {

    let $ancestors := tei-content:ancestors($tei, $resource-id, 1)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="outline-context" 
            pass="{ if($resource-id = ('LOBBY', 'ALL-TRANSLATED', 'O1JC11494', 'O1JC7630') or count($ancestors//parent) > 0) then 1 else 0 }">
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
};

declare function tests:complete-source($toh-html as element()) as item() {

    let $toh := $toh-html//*[@id eq 'toh']//xhtml:h4/text()
    let $location := $toh-html//*[@id eq 'location']/text()
    let $authours-summary := $toh-html//*[@id eq 'authours-summary']/text()
    let $edition := $toh-html//*[@id eq 'edition']/text()
    let $publication-statement := $toh-html//*[@id eq 'publication-statement']/text()
    let $license := $toh-html//*[@id eq 'license']
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
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
};

declare function tests:test-section($section-tei as element()*, $section-html as element()*, $section-name as xs:string, $required-paragraphs as xs:integer, $count-chapters as xs:boolean, $count-milestones as xs:boolean) {

    let $section-count-tei-p := 
        count($section-tei//*[self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl | self::tei:l[ancestor::tei:lg][not(ancestor::tei:note)]])
    let $section-count-html-p := 
        count($section-html//xhtml:p | $section-html//xhtml:div[common:contains-class(@class, 'line')]) 
    
    let $section-count-tei-note := 
        count($section-tei//tei:note)
    let $section-count-html-note := 
        count($section-html//xhtml:a[common:contains-class(@class, 'footnote-link')])
    
    let $section-count-tei-q := 
        count($section-tei//tei:q)
    let $section-count-html-q := 
        count($section-html//xhtml:blockquote | $section-html//xhtml:span[common:contains-class(@class, 'blockquote')])
    
    let $section-count-tei-id := 
        if($section-tei/@type = ('prologue')) then
            count($section-tei//*[@tid][self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl | self::tei:label | self::tei:head[parent::tei:list] | self::tei:lg | self::tei:head[@type = ('chapterTitle', 'section', 'chapter')]][not(ancestor::tei:note)])
        else
            count($section-tei//*[@tid][self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl | self::tei:label | self::tei:head[parent::tei:list] | self::tei:lg | self::tei:head[@type = ('chapterTitle', 'section', 'chapter', 'prologue')]][not(ancestor::tei:note)])
    let $section-count-html-id := 
        count($section-html//*[contains(@id, 'node-')])
    
    let $section-count-tei-list-item := 
        count($section-tei//tei:list[not(ancestor::tei:note)]/tei:item)
    let $section-count-html-list-item := 
        count($section-html//xhtml:div[common:contains-class(@class, 'list-item')])
    
    let $section-count-tei-chapters := 
        count($section-tei//tei:div[@type = ('section', 'chapter')])
    let $section-count-html-chapters := 
        count($section-html//xhtml:section[common:contains-class(@class, 'chapter')] | $section-html//xhtml:div[common:contains-class(@class, 'nested-chapter') or common:contains-class(@class, 'nested-section')])
    
    let $section-count-tei-milestones := 
        count($section-tei//tei:milestone)
    let $section-count-html-milestones := 
        count($section-html//xhtml:a[common:contains-class(@class, 'milestone from-tei')])
    
    let $required-paragraphs-rule := if ($required-paragraphs > 0) then concat(' at least ', $required-paragraphs , ' paragraph(s) and') else ''
    let $count-chapters-rule := if ($count-chapters eq true()) then ', chapters ' else ''
    let $count-milestones-rule := if ($count-chapters eq true()) then ', milestones ' else ''
    
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
                    and ($count-milestones eq false() or $section-count-html-milestones eq $section-count-tei-milestones)
                ) then 1 else 0 }">
            <title>
            {
                concat(functx:capitalize-first($section-name) ,' test: The ', $section-name, ' has', $required-paragraphs-rule, ' the same number of paragraphs, notes, quotes, ids, labels, list items', $count-chapters-rule, $count-milestones-rule, ' in the HTML as in the TEI.')
            }
            </title>
            <details>
                <detail>{$section-count-tei-p} TEI paragraph(s), {$section-count-html-p} HTML paragraph(s).</detail>
                <detail>{$section-count-tei-note} TEI note(s), {$section-count-html-note} HTML note(s).</detail>
                <detail>{$section-count-tei-q} TEI quote(s), {$section-count-html-q} HTML quote(s).</detail>
                <detail>{$section-count-tei-id} TEI id(s), {$section-count-html-id} HTML id(s).</detail>
                <detail>{$section-count-tei-list-item} TEI list item(s), {$section-count-html-list-item} HTML list item(s).</detail>
                {
                    if ($count-chapters eq true()) then
                        <detail>{$section-count-tei-chapters} TEI chapter(s), {$section-count-html-chapters} HTML chapter(s).</detail>
                    else
                        ()
                }
                {
                    if ($count-milestones eq true()) then
                        <detail>{$section-count-tei-milestones} TEI milestone(s), {$section-count-html-milestones} HTML milestone(s).</detail>
                    else
                        ()
                }
            </details>
        </test>
};

declare function tests:notes($tei as element()*, $html as element()*) as item() {

    let $notes-count-html := count($html//*[@id eq 'notes']/*/*[common:contains-class(@class, 'footnote')])
    let $notes-count-tei := count($tei//tei:text//tei:note)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="notes"
            pass="{ if($notes-count-html > 0 and $notes-count-html = $notes-count-tei) then 1 else 0 }">
            <title>Notes test: The text has at least 1 note and the same number of notes are in the TEI and the HTML.</title>
            <result></result>
            <details>
                <detail>{$notes-count-tei} note(s) in TEI, {$notes-count-html} note(s) in HTML.</detail>
            </details>
        </test>
};

declare function tests:abbreviations($tei as element()*, $html as element()*) as item() {

    let $abbreviations-count-html := count($html//*[@id eq 'abbreviations']//xhtml:tr)
    let $abbreviations-count-tei := count($tei//tei:back//tei:list[@type='abbreviations']/tei:item/tei:abbr)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="abbreviations"
            pass="{ if($abbreviations-count-html = $abbreviations-count-tei) then 1 else 0 }">
            <title>Abbreviations: The abbreviations have same number of items are in the TEI and the HTML.</title>
            <details>
                <detail>{$abbreviations-count-tei} items(s) in TEI, {$abbreviations-count-html} items(s) in HTML.</detail>
            </details>
        </test>
};

declare function tests:bibliography($tei as element()*, $html as element()*) as item() {

    let $biblography-count-html := count($html//*[@id eq 'bibliography']//xhtml:p)
    let $biblography-count-tei := count($tei//tei:back/tei:div[@type='listBibl']//tei:bibl)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="bibliography"
            pass="{ if($biblography-count-html > 0 and $biblography-count-html = $biblography-count-tei) then 1 else 0 }">
            <title>Bibliography: The text has at least 1 bibliography section with at least 1 item  and the same number of items are in the TEI and the HTML.</title>
            <details>
                <detail>{$biblography-count-tei} items(s) in TEI, {$biblography-count-html} items(s) in HTML.</detail>
            </details>
        </test>
};

declare function tests:section-tantra-warning($tei as element()*, $html as element()*) as item() {

    let $tantra-warning-count-html := count($html//*[@id eq 'tantra-warning-title']//xhtml:p)
    let $tantra-warning-count-tei := count($tei//tei:front/tei:div[@type='warning']//tei:p)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="section-tantra-warning"
            pass="{ if($tantra-warning-count-html = $tantra-warning-count-tei) then 1 else 0 }">
            <title>Tantra Warning: If the TEI has a tantra warnings so does the HTML.</title>
            <details>
                <detail>{ if($tantra-warning-count-tei) then 'Tantra warning displayed.' else 'No Tantra warning.' }</detail>
            </details>
        </test>
};

declare function tests:translation-tantra-warning($tei as element()*, $html as element()*) as item() {

    let $tantra-warning-count-html := count($html//*[@id eq 'tantric-warning']//xhtml:p)
    let $tantra-warning-count-tei := count($tei//tei:teiHeader//tei:availability/tei:p[@type eq 'tantricRestriction'])
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="section-tantra-warning"
            pass="{ if($tantra-warning-count-html = $tantra-warning-count-tei) then 1 else 0 }">
            <title>Tantra Warning: If the TEI has a tantra warnings so does the HTML.</title>
            <details>
                <detail>{ if($tantra-warning-count-tei) then 'Tantra warning displayed.' else 'No Tantra warning.' }</detail>
            </details>
        </test>
};

declare function tests:glossary($tei as element()*, $html as element()*) as item() {
    
    let $glossary-count-html := count($html//*[@id eq 'glossary']//*[common:contains-class(@class, 'glossary-item')])
    let $glossary-count-tei := count($tei//tei:back/tei:div[@type='glossary']//tei:gloss)
    let $tei-terms-raw := $tei//tei:back/tei:div[@type='glossary']//tei:gloss/tei:term[text()][not(tei:ptr)](:[(not(@xml:lang) and not(@type)) or not(text() = preceding-sibling::tei:term[not(@xml:lang) and not(@type)]/text())]:)
    
    let $tei-terms := 
        for $tei-term in $tei-terms-raw
        return 
            if($tei-term[@xml:lang eq "Bo-Ltn"])then
                string($tei-term) ! lower-case(.) ! normalize-space(.) ! common:bo-ltn(.)
            else
                string($tei-term) ! lower-case(.) ! normalize-space(.)
                
    let $terms-count-tei := count($tei-terms)
    
    let $html-terms-untokenized := 
        $html//*[@id eq 'glossary']//*[common:contains-class(@class, 'glossary-item')]//*[self::xhtml:h4 | self::xhtml:p[not(xhtml:a/@class[common:contains-class(., 'internal-ref')])]]
    
    let $empty-term-placeholders := (common:app-text('glossary.term-empty-sa-ltn'), common:app-text('glossary.term-empty-bo-ltn'))
    
    let $html-terms := 
        for $html-term in $html-terms-untokenized/string(.) ! tokenize(., '·') ! translate(., 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ', 'abcdefghijklmnopqrstuvwxyz')
        return 
            if(not($html-term = $empty-term-placeholders)) then
                lower-case($html-term) ! normalize-space(.)
            else
                ()
            
    let $terms-count-html := count($html-terms)
    
    let $anomalies := 
        for $term in $tei-terms
        return
            let $term-count-tei := count($tei-terms[. = $term])
            let $term-count-html := count($html-terms[. = $term])
            return 
                if(not($term-count-tei = $term-count-html)) then
                    concat($term, ' (', xs:string($term-count-tei), ' occurrence(s) in the TEI and ', xs:string($term-count-html), ' occurrence(s) in the HTML)')
                else
                    ()
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
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
};

declare function tests:structure() as element() {

    let $sections-structure := doc(concat($common:data-path, '/operations/sections-structure.xml'))
    
    let $sections := $section:sections
    let $texts := $section:texts
    
    let $section-ids-unmatched := 
        for $source-id in $sections-structure//m:section/@source-id
        return
            if(not($sections//tei:idno[@xml:id = $source-id])) then
                <detail xmlns="http://read.84000.co/ns/1.0">Section node { xs:string($source-id) } has no associated TEI file.</detail>
            else
                ()
                
    let $text-ids-unmatched := 
        for $source-id in $sections-structure//m:text/@source-id
        return
            if(not($texts//tei:idno[@source-id = $source-id])) then
                <detail xmlns="http://read.84000.co/ns/1.0">Text node { xs:string($source-id) } has no associated TEI file.</detail>
            else
                ()
    
    let $section-tei-unmatched := 
        for $source-id in $sections//tei:idno/@xml:id[not(. = ('LOBBY', 'ALL-TRANSLATED'))]
        return
            if(not($sections-structure//m:section[@source-id = $source-id])) then
                <detail xmlns="http://read.84000.co/ns/1.0">Section TEI { base-uri($source-id) } has no associated outline node.</detail>
            else
                ()

    let $text-tei-unmatched := 
        for $source-id in $texts//tei:idno/@source-id
        return
            if(not($sections-structure//m:text[@source-id = $source-id])) then
                <detail xmlns="http://read.84000.co/ns/1.0">Text TEI { base-uri($source-id) } has no associated outline node.</detail>
            else
                ()
    
    let $unmatched-section-texts := tests:match-text-count($sections-structure/m:sections-structure)
    
    return
        <results xmlns="http://read.84000.co/ns/1.0">
            <structure>
                <test id="unmatched-ids" pass="{ if (count(($section-ids-unmatched | $text-ids-unmatched)) eq 0) then 1 else 0 }">
                    <title>All nodes must have an associated TEI file.</title>
                    {
                        if ($section-ids-unmatched | $text-ids-unmatched) then
                            <details>
                            {
                                $section-ids-unmatched
                            }
                            {
                                $text-ids-unmatched
                            }
                            </details>
                        else
                            ()
                    }
                </test>
                <test id="unmatched-tei" pass="{ if (count(($section-tei-unmatched | $text-tei-unmatched)) eq 0) then 1 else 0 }">
                    <title>All TEI files must have an associated node.</title>
                    {
                        if ($section-tei-unmatched | $text-tei-unmatched) then
                            <details>
                            {
                                $section-tei-unmatched
                            }
                            {
                                $text-tei-unmatched
                            }
                            </details>
                        else
                            ()
                    }
                </test>
                <test id="unmatched-section-texts" pass="{ if (count($unmatched-section-texts) eq 0) then 1 else 0 }">
                    <title>All sections must have the correct number of child texts.</title>
                    {
                        if ($unmatched-section-texts) then
                            <details>
                            {
                                $unmatched-section-texts
                            }
                            </details>
                        else
                            ()
                    }
                </test>
            </structure>
        </results>
        
};

declare function tests:match-text-count($sections-structure) as element()* {

    for $section in $sections-structure/m:section
        let $source-id := xs:string($section/@source-id)
        let $count-texts-in-structure := count($section/m:text)
        let $count-texts-in-tei := count($section:texts//tei:idno[@parent-id eq $source-id])
    return
    (
        if($count-texts-in-structure ne $count-texts-in-tei) then
            <detail xmlns="http://read.84000.co/ns/1.0" ref="section-texts-{ $source-id }">
                Section { $source-id } should have { $count-texts-in-structure } TEI files but has { $count-texts-in-tei }.
            </detail>
        else
            ()
        ,
        if($section/m:section) then
            tests:match-text-count($section)
        else
            ()
    )
};

declare function tests:lucene-test-languages() as element()* {
    <langs xmlns="http://read.84000.co/ns/1.0">
    {
        for $lang in $tests:lucene-tests/m:lang
        return
            <lang xmlns="http://read.84000.co/ns/1.0">
            {
                $lang/@xml:lang,
                $lang/m:label
            }
            </lang>
    }
    </langs>
};

declare function tests:lucene-lang-data($lang as xs:string) as element()* {
    <datas xmlns="http://read.84000.co/ns/1.0">
    {
        $tests:lucene-tests/m:lang[lower-case(@xml:lang) eq $lang]/m:data
    }
    </datas>
};

declare function tests:lucene-tests($lang as xs:string) as element() {
    
    <tests xmlns="http://read.84000.co/ns/1.0">
    {
        for $test in $tests:lucene-tests/m:lang[lower-case(@xml:lang) eq $lang]/m:test
        return
            element test {
                $test/@*,
                $test/m:query,
                element sort {
                    common:normalized-chars($test/m:query)
                },
                tests:lucene-test($lang, $test/@xml:id)
            }
    }
    </tests>
};

declare function tests:search-options() as element() {
    <options>
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

declare function tests:search-query($string as xs:string) as element() {
    <query>
        <phrase>
        {
            normalize-unicode(lower-case($string))
        }
        </phrase>
    </query>
};

declare function tests:lang-field($valid-lang as xs:string) as xs:string {
    if($valid-lang eq 'Sa-Ltn') then
        'sa-ltn-data'
    else if($valid-lang eq 'Bo-Ltn') then
        'bo-ltn-data'
    else if($valid-lang eq 'bo') then
        'bo-data'
    else
        'en-data'
};

declare function tests:lucene-test($lang as xs:string, $test-id as xs:string) as element()* {
    
    let $lang-tests := $tests:lucene-tests/m:lang[@xml:lang = common:valid-lang($lang)]
    let $test := $lang-tests/m:test[@xml:id eq $test-id]
    let $matches := 
        if(lower-case($test-id) eq 'all') then
            $lang-tests/m:data
        else if($test/m:query/text() gt '') then
            $lang-tests/m:data[ft:query-field(tests:lang-field(common:valid-lang($lang)), normalize-unicode(lower-case($test/m:query)), tests:search-options())]
        else
            ()
    
    return
    (
        for $match in $matches
        return
            <result xmlns="http://read.84000.co/ns/1.0">
            {
                if(not($test/m:match[@data-id eq $match/@xml:id])) then
                    attribute invalid { 'should-not' }
                else
                    (),
                util:expand($match, "expand-xincludes=no")
            }
            </result>,
        for $match in $test/m:match[not(@data-id = $matches/@xml:id)]
        return
            <result xmlns="http://read.84000.co/ns/1.0">
            {
                attribute invalid { 'should' },
                $lang-tests/m:data[@xml:id = $match/@data-id]
            }
            </result>
    )
};

declare function tests:next-xmlid($siblings as item()*) as xs:string {
    
    (: Assumes there is already at least one sibling :)
    
    let $node-name := local-name($siblings[1])
    let $next-int := max($siblings/@xml:id ! substring-after(., concat($node-name, '-')) ! xs:integer(concat('0', .))) + 1
    return
        concat($node-name, '-', $next-int)
    
};

declare function tests:add-lucene-test($lang as xs:string, $query as xs:string) as element()? {
    
    let $parent := $tests:lucene-tests/m:lang[@xml:lang eq common:valid-lang($lang)]
    
    let $new-value := 
        <test xmlns="http://read.84000.co/ns/1.0">
        {
            attribute xml:id { tests:next-xmlid($tests:lucene-tests//m:test) },
            element query {
                text { $query }
            }
        }
        </test>
    
    return
        common:update('lucene-test', (), $new-value, $parent, $parent/m:test[last()])
    
};

declare function tests:add-lucene-data($lang as xs:string, $index-string as xs:string) as element()? {
    
    let $parent := $tests:lucene-tests/m:lang[@xml:lang eq common:valid-lang($lang)]
    
    let $new-value := 
        <data xmlns="http://read.84000.co/ns/1.0">
        {
            attribute xml:id { tests:next-xmlid($tests:lucene-tests//m:data) },
            text { $index-string }
        }
        </data>
    
    let $update := common:update('lucene-data', (), $new-value, $parent, $parent/m:data[last()])
    let $reindex := tests:reindex()
    
    return
        $update
    
};

declare function tests:add-test-match($should-match as xs:boolean, $test-id as xs:string, $data-id as xs:string) as element()? {
    
    let $test := $tests:lucene-tests/m:lang/m:test[@xml:id eq $test-id]
    
    let $existing-value := $test/m:match[@data-id eq $data-id]
    
    let $new-value := 
        if($should-match and $data-id gt '') then
            <match xmlns="http://read.84000.co/ns/1.0" data-id="{ $data-id }"/>
        else
            ()
    
    return
        common:update('test-match', $existing-value, $new-value, $test, $test/m:match[last()])
    
};

declare function tests:reindex(){
    xmldb:reindex($tests:tests-collection, $tests:tests-file)
};

