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

declare variable $tests:utilities-data-collection := concat($common:data-path, '/config/tests');
declare variable $tests:lucene-tests := doc(concat($tests:utilities-data-collection, '/', 'lucene-tests.xml'))/m:lucene-tests;

declare function tests:translations($translation-id as xs:string) as item(){
    
    (:let $translation-id := 'UT22084-062-012':)
    
    let $schema := doc(concat($common:tei-path, '/schema/current/translation.rng'))
    
    let $selected-translations := 
        if ($translation-id eq 'all') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:marked-up-status-ids]
        else if ($translation-id eq 'published') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-status-ids]
        else if ($translation-id eq 'in-markup') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:marked-up-status-ids[not(. = $tei-content:published-status-ids)]]
        else
            tei-content:tei(lower-case($translation-id), 'translation')
    
    let $test-config := $common:environment//m:test-conf
    
    return
        <results xmlns="http://read.84000.co/ns/1.0">
        {
         for $tei in $selected-translations
            for $toh-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                let $start-time := util:system-dateTime()
                let $html-url := concat($test-config/m:path/text(), '/translation/', $toh-key, '.html?view-mode=tests')
                let $toh-html := 
                    if($test-config) then 
                        httpclient:get(
                            xs:anyURI($html-url), 
                            false(), 
                            if($test-config/m:credentials/text()) then 
                                <headers>
                                    <header name="Authorization" value="{ concat('Basic ', util:base64-encode($test-config/m:credentials/text())) }"/>
                                </headers>
                            else
                                ()
                       )
                    else
                        ()
                let $end-time := util:system-dateTime()
            return
               <translation 
                   id="{ tei-content:id($tei) }" 
                   test-domain="{ $test-config/m:path/text() }" 
                   status="{ tei-content:translation-status($tei) }"
                   status-group="{ tei-content:translation-status-group($tei) }"
                   duration="{ functx:total-seconds-from-duration($end-time - $start-time) }">
                   <title>{ tei-content:title($tei) }</title>
                   { translation:toh($tei, $toh-key) }
                   <tests>
                    {
                        tests:validate-schema($tei, $schema),
                        tests:duplicate-ids($tei),
                        tests:scoped-ids($tei),
                        tests:valid-pointers($tei),
                        tests:titles($toh-html, $tei),
                        tests:outline-context($tei, $toh-key),
                        tests:complete-source($toh-html),
                        tests:translation-tantra-warning($tei, $toh-html),
                        tests:section(
                            $tei//tei:front//tei:div[@type eq 'summary'][not(@xml:lang) or @xml:lang eq 'en'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-summary')], 
                            'summary', 1),
                        tests:section(
                            $tei//tei:front//tei:div[@type eq 'acknowledgment'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-acknowledgment')],
                            'acknowledgment', 1),
                        tests:section(
                            $tei//tei:front//tei:div[@type eq 'preface'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-preface')], 
                            'preface', 0),
                        tests:section(
                            $tei//tei:front//tei:div[@type eq 'introduction'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-introduction')], 
                            'introduction', 1),
                        tests:section(
                            $tei//tei:body//tei:div[@type eq 'prologue'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-prologue')], 
                            'prologue', 0),
                        tests:section(
                            $tei//tei:body//tei:div[@type eq 'homage'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-homage')], 
                            'homage', 0),
                        tests:section(
                            element tei:div {
                                $tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]
                            },
                            element xhtml:div {
                                $toh-html//xhtml:section[common:contains-class(@class, ('part-type-chapter', 'part-type-section'))]
                            }, 
                            'body', 1),
                        tests:section(
                            $tei//tei:body//tei:div[@type eq 'colophon'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-colophon')], 
                            'colophon', 0),
                        tests:section(
                            $tei//tei:back//tei:div[@type eq 'appendix'], 
                            $toh-html//xhtml:section[common:contains-class(@class, 'part-type-appendix')], 
                            'appendix', 0),
                        tests:notes($tei, $toh-html),
                        tests:abbreviations($tei, $toh-html),
                        tests:bibliography($tei, $toh-html),
                        tests:glossary($tei, $toh-html),
                        tests:refs($tei, $toh-html, $toh-key)
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
                        tests:validate-schema($tei, $schema),
                        tests:duplicate-ids($tei),
                        tests:scoped-ids($tei),
                        tests:outline-context($tei, $resource-id),
                        tests:section($tei//tei:front//tei:div[@type eq 'abstract'], $html//*[@id eq 'title']//*[@id eq 'abstract'], 'abstract', 0),
                        tests:section($tei//tei:body//tei:div[@type eq 'about'], $html//*[@id eq 'summary'], 'summary', 0),
                        tests:section-tantra-warning($tei, $html)
                    }
                    </tests>
                </section>
        }
        </results>
};

declare function tests:validate-schema($tei as element(tei:TEI), $schema as document-node()) as item() {

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

declare function tests:duplicate-ids($tei as element(tei:TEI)) as item() {

    let $ids := $tei//@xml:id/string()
    let $count-ids := count($ids)
    let $distinct-ids := distinct-values($tei//@xml:id/string())
    let $count-distinct-ids := count($distinct-ids)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="duplicate-ids"
            pass="{ if($count-ids eq $count-distinct-ids) then 1 else 0 }">
            <title>Duplicate ID test: The text has no duplicate ids.</title>
            <details>
                {
                    if($count-ids ne $count-distinct-ids) then
                        for $id in $distinct-ids
                        where $ids[. = $id][2]
                        return
                            <detail type="debug">{$ids[. = $id][2]} is duplicated</detail>
                    else ()
                }
            </details>
        </test>
};

declare function tests:scoped-ids($tei as element(tei:TEI)) as item() {

    let $ids := $tei//@xml:id/string()
    let $text-id := tei-content:id($tei)
    let $out-of-scope-ids := $ids[not(starts-with(., $text-id))]
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="duplicate-ids"
            pass="{ if(count($out-of-scope-ids) eq 0) then 1 else 0 }">
            <title>ID scope test: All xml:id attributes are in the scope of the text id e.g. begin with the same UT number.</title>
            <details>
                {
                    for $id in $out-of-scope-ids
                    return
                        <detail type="debug">{$id} does not begin with { $text-id }</detail>
                }
            </details>
        </test>
};

declare function tests:valid-pointers($tei as element(tei:TEI)) as item() {

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

declare function tests:titles($toh-html as element(), $tei as element(tei:TEI)) as item() {
    
    (: Bo-Ltn can be derived from bo or vice versa :)
    (: Max 3: 'en', 'Sa-Ltn' and either 'Bo-Ltn' or  'bo' :)
    let $tei-main-titles := (
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('en', 'Sa-Ltn')][text()],
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('Bo-Ltn', 'bo')][text()][1]
    )
    
    (: Max 4: 'en', 'Sa-Ltn', 'Bo-Ltn' and 'bo' if 'Bo-Ltn' or 'bo'  :)
    let $tei-long-titles := (
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('en', 'Sa-Ltn')][text()],
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('Bo-Ltn', 'bo')][text()][1],
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('Bo-Ltn', 'bo')][text()][1]
    )
    
    let $html-main-titles := $toh-html//*[@id eq 'main-titles']/*[common:contains-class(@class, 'title')][data()]
    let $html-long-titles := $toh-html//*[@id eq 'long-titles']/*[common:contains-class(@class, 'title')][data()]
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="titles" 
            pass="{ if(count($tei-main-titles) eq count($html-main-titles) and count($tei-long-titles) eq count($html-long-titles)) then 1 else 0 }">
            <title>Titles test: The html has the correct number of titles.</title>
            <details>
            { 
                for $title in $html-main-titles
                return 
                    <detail>Main title: {$title/data()}</detail>
                ,
                for $title in $html-long-titles
                return 
                    <detail>Long title: {$title/data()}</detail>
            }
            </details>
        </test>
};

declare function tests:outline-context($tei as element(tei:TEI), $resource-id as xs:string) as item() {

    let $ancestors := tei-content:ancestors($tei, $resource-id, 1)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="outline-context" 
            pass="{ if($resource-id = ('LOBBY', 'ALL-TRANSLATED', 'O1JC11494', 'O1JC7630') or count($ancestors//parent) > 0) then 1 else 0 }">
            <title>Outline test: The text has a context in the outline.</title>
            <details>
            { 
                for $ancestor in $ancestors//m:parent
                order by $ancestor/@nesting descending
                return 
                    <detail>{ $ancestor/m:titles/m:title[@xml:lang eq 'en']/text() }</detail>
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

declare function tests:section($section-tei as element()*, $section-html as element()*, $section-name as xs:string, $required-paragraphs as xs:integer) {
    
    let $section-tei-type := $section-tei/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/@type
    
    let $section-count-tei-p := 
        count($section-tei//*[self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl])
    let $section-count-html-p := 
        count($section-html//xhtml:p) 
        
    let $section-count-tei-line := 
        count($section-tei//tei:l[parent::tei:lg][not(ancestor::tei:note)])
    let $section-count-html-line := 
        count($section-html//xhtml:div[common:contains-class(@class, 'line')]) 
    
    let $section-count-tei-note := 
        count($section-tei//tei:note[@place eq 'end'][@xml:id])
    let $section-count-html-note := 
        count($section-html//xhtml:a[common:contains-class(@class, 'footnote-link')])
        
    let $section-count-tei-q := 
        count($section-tei//tei:q)
    let $section-count-html-q := 
        count($section-html//xhtml:blockquote | $section-html//xhtml:span[common:contains-class(@class, 'blockquote')])
    
    let $section-count-tei-id := 
        count($section-tei//*[@tid][not(ancestor::tei:note)])
    let $section-count-html-id := 
        count($section-html//*[matches(@id, '^node\-')])
    
    let $section-count-tei-list-item := 
        count($section-tei//tei:list[not(ancestor::tei:note)]/tei:item)
    let $section-count-html-list-item := 
        count($section-html//xhtml:div[common:contains-class(@class, 'list-item')])
    
    (:let $section-count-tei-sections := 
        count($section-tei//tei:div[@type][tei:head[@type eq parent::tei:div/@type]])
    let $section-count-html-sections := 
        count($section-html//xhtml:section[common:contains-class(@class, 'part-type-chapter') or common:contains-class(@class, 'part-type-section')] | $section-html//xhtml:div[common:contains-class(@class, 'nested-section')])
    :)
    
    let $section-count-tei-milestones := 
        if(not($section-tei-type eq 'section')) then count($section-tei//tei:milestone) else 0
    let $section-count-html-milestones := 
        count($section-html//xhtml:a[common:contains-class(@class, 'milestone from-tei')])
    
    let $required-paragraphs-rule := if ($required-paragraphs > 0) then concat(' at least ', $required-paragraphs , ' paragraph(s) and') else ''
    
    return
        <test 
            xmlns="http://read.84000.co/ns/1.0"
            id="{ concat('valid-', $section-name, '-section') }"
            pass="{ if(
                    $section-count-html-p ge $required-paragraphs
                    and $section-count-html-p eq $section-count-tei-p
                    and $section-count-html-line eq $section-count-tei-line
                    and $section-count-html-note eq $section-count-tei-note
                    and $section-count-html-q eq $section-count-tei-q
                    and $section-count-html-id eq $section-count-tei-id
                    and $section-count-html-list-item eq $section-count-tei-list-item
                    (:and $section-count-html-sections eq $section-count-tei-sections:)
                    and $section-count-html-milestones eq $section-count-tei-milestones
                ) then 1 else 0 }">
            <title>
            {
                concat(
                    functx:capitalize-first($section-name),
                    ' test: The ', $section-name,
                    ' has', $required-paragraphs-rule, ' the same number of paragraphs, notes, quotes, ids, labels, list items, sections and milestones in the HTML as in the TEI.'
                )
            }
            </title>
            <details>
                <detail>{$section-count-tei-p} TEI paragraph(s), {$section-count-html-p} HTML paragraph(s).</detail>
                <detail>{$section-count-tei-line} TEI line(s), {$section-count-html-line} HTML line(s).</detail>
                <detail>{$section-count-tei-note} TEI note(s), {$section-count-html-note} HTML note(s).</detail>
                <detail>{$section-count-tei-q} TEI quote(s), {$section-count-html-q} HTML quote(s).</detail>
                <detail>{$section-count-tei-id} TEI id(s), {$section-count-html-id} HTML id(s).</detail>
                <detail>{$section-count-tei-list-item} TEI list item(s), {$section-count-html-list-item} HTML list item(s).</detail>
                <!--<detail>{$section-count-tei-sections} TEI section(s), {$section-count-html-sections} HTML section(s).</detail>-->
                <detail>{$section-count-tei-milestones} TEI milestone(s), {$section-count-html-milestones} HTML milestone(s).</detail>
                {
                    if(not($section-count-html-note eq $section-count-tei-note)) then
                        <detail>
                        {
                            let $section-tei-note-ids := 
                                $section-tei//tei:note[@place eq 'end'][@xml:id]/@xml:id/string()
                            let $section-html-note-ids := 
                                $section-html//xhtml:a[common:contains-class(@class, 'footnote-link')]/@id/string()
                            return
                                'Note anomalies: '
                                || string-join(($section-tei-note-ids[not(. = $section-html-note-ids)], $section-html-note-ids[not(. = $section-tei-note-ids)]), ', ')
                        }
                        </detail>
                    else ()
                    ,
                    if(not($section-count-html-id eq $section-count-tei-id)) then
                        <detail>
                        {
                            let $section-tei-ids := 
                                $section-tei//*[@tid][not(ancestor::tei:note)]/@tid/string()
                            let $section-html-ids := 
                                $section-html//*[matches(@id, '^node\-')]/replace(@id, '^node\-', '')
                            return
                                'Id anomalies: '
                                || string-join(($section-tei-ids[not(. = $section-html-ids)], $section-html-ids[not(. = $section-tei-ids)]), ', ')
                        }
                        </detail>
                    else ()
                    
                }
                
            </details>
        </test>
};

declare function tests:notes($tei as element(tei:TEI)*, $html as element()*) as item() {
    
    let $notes-count-tei := count($tei//tei:text//tei:note[@place eq 'end'][@xml:id])
    let $notes-count-html := count($html//xhtml:section[@id eq 'end-notes']/*[common:contains-class(@class, 'footnote')])
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="notes"
            pass="{ if($notes-count-html > 0 and $notes-count-html eq $notes-count-tei) then 1 else 0 }">
            <title>Notes test: The text has at least 1 note and the same number of notes are in the TEI and the HTML.</title>
            <result></result>
            <details>
                <detail>{$notes-count-tei} note(s) in TEI, {$notes-count-html} note(s) in HTML.</detail>
            </details>
        </test>
};

declare function tests:abbreviations($tei as element(tei:TEI)*, $html as element()*) as item() {

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

declare function tests:bibliography($tei as element(tei:TEI)*, $html as element()*) as item() {

    let $biblography-count-html := count($html//*[@id eq 'bibliography']//xhtml:p[common:contains-class(@class, 'bibl')])
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

declare function tests:section-tantra-warning($tei as element(tei:TEI)*, $html as element()*) as item() {

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

declare function tests:translation-tantra-warning($tei as element(tei:TEI)*, $html as element()*) as item() {

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

declare function tests:glossary($tei as element(tei:TEI)*, $html as element()*) as item() {
    
    let $glossary-count-tei := count($tei//tei:back/tei:div[@type='glossary']//tei:gloss)
    let $glossary-count-html := count($html//*[@id eq 'glossary']/*[common:contains-class(@class, 'glossary-item')])
    
    let $tei-terms-raw := $tei//tei:back/tei:div[@type='glossary']//tei:gloss[@xml:id]/tei:term[not(@type = 'definition')][not(@xml:lang) or @xml:lang = ('Sa-Ltn', 'bo', 'Bo-Ltn', 'en')][normalize-space(string-join(data(), ''))](:[not(tei:ptr)]:)
    let $empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'))
    
    let $tei-terms := (
        $tei-terms-raw[@xml:lang eq "Bo-Ltn"] ! data(.) ! lower-case(.) ! tests:normalize-whitespace(.) ! common:bo-ltn(.),
        $tei-terms-raw[not(@xml:lang eq "Bo-Ltn")] ! data(.) ! lower-case(.) ! tests:normalize-whitespace(.)
    )
    
    let $html-term-elements := 
        $html//*[@id eq 'glossary']/*[common:contains-class(@class, 'glossary-item')]//*[common:contains-class(@class, 'term')][normalize-space(string-join(data(), ''))](:[not(xhtml:a[common:contains-class(@class, 'pointer')])]:)
    
    let $html-terms := 
        $html-term-elements[not(. = $empty-term-placeholders)] ! data(.) (:! tokenize(., '·'):) ! translate(., 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ', 'abcdefghijklmnopqrstuvwxyz') ! lower-case(.) ! tests:normalize-whitespace(.)
    
    let $tei-terms-not-found := $tei-terms[not(. = $html-terms)]
    let $html-terms-not-found := $html-terms[not(. = $tei-terms)]

    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="glossary"
            pass="{ 
                if(
                    $glossary-count-html > 0 
                    and $glossary-count-html = $glossary-count-tei 
                    and count($html-terms) = count($tei-terms) 
                    and (count($tei-terms-not-found) + count($html-terms-not-found)) = 0
                ) then 1 else 0 
            }">
            <title>Glossary: The text has at least 1 glossary item and there are the same number in the HTML as in the TEI with no anomalies in the counts of each term.</title>
            <details>
                <detail>{ $glossary-count-tei } glossary item(s) in the TEI, { $glossary-count-html } glossary item(s) in the HTML.</detail>
                <detail>{ count($tei-terms) } glossary term(s) in the TEI, { count($html-terms) } glossary term(s) in the HTML.</detail>
                <detail>{ (count($tei-terms-not-found) + count($html-terms-not-found)) } anomalies detected.</detail>
                {
                    for $term-not-found in $tei-terms-not-found
                    return 
                        <detail type="debug">{ concat('TEI term "', $term-not-found, '" not found in HTML.') }</detail>
                    ,
                    for $term-not-found in $html-terms-not-found
                    return 
                        <detail type="debug">{ concat('HTML term "', $term-not-found, '" not found in TEI.') }</detail>
                }
            </details>
        </test>
};

declare function tests:refs($tei as element(tei:TEI)*, $html as element()*, $toh-key as xs:string){
    
    let $tei-folios := translation:folios($tei, $toh-key)//m:folio[not(@rend eq 'blank')]
    let $html-refs := $html//xhtml:a[common:contains-class(@class, 'ref')]
    
    let $folio-count-tei := count($tei-folios)
    let $ref-count-html := count($html-refs)
    
    let $html-folio-equivalents := $html-refs ! lower-case(text())
    
    let $anomalies := 
        for $tei-folio in $tei-folios
            let $tei-folio-equivalent := concat('[', lower-case($tei-folio/@tei-folio), ']')
            where not($tei-folio-equivalent = $html-folio-equivalents)
        return 
            concat('Volume ', $tei-folio/@volume, ' page ', $tei-folio/@page-in-volume, ' not found.' )
    
    let $pass := if($ref-count-html gt 0 and $ref-count-html eq $folio-count-tei and count($anomalies) eq 0) then 1 else 0
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" 
            id="refs"
            pass="{ $pass }">
            <title>Refs: The text has at least 1 ref, there are the same number in the HTML as in the TEI with no anomalies.</title>
            <details>
                <detail>{ $folio-count-tei } refs(s) in the TEI, { $ref-count-html } refs(s) in the HTML.</detail>
                {
                    for $anomaly in $anomalies
                    return
                        <detail>{ $anomaly }</detail>
                }
                {
                    if($pass eq 0) then
                        <detail>For more information visit the "Folios" utility.</detail>
                    else
                        ()
                }
            </details>
        </test>
};

declare function tests:normalize-whitespace($string as xs:string) as xs:string {
    fn:replace(fn:replace(normalize-space($string),'\s+(,|\.|\))', '$1'),'(\()\s+', '$1')
};

declare function tests:structure() as element() {

    let $sections-structure := doc(concat($common:data-path, '/config/tests/sections-structure.xml'))
    
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
    
    let $text-tei-duplicated := 
        for $text-id in $texts//tei:idno/@xml:id
        return
            if(count($texts//tei:idno[@xml:id  eq $text-id]) gt 1) then
                <detail xmlns="http://read.84000.co/ns/1.0">Text { data($text-id) } is duplicated.</detail>
            else
                ()
    
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
                <test id="text-tei-duplicated" pass="{ if (count($text-tei-duplicated) eq 0) then 1 else 0 }">
                    <title>There should be no duplicate text ids.</title>
                    {
                        if ($text-tei-duplicated) then
                            <details>
                            {
                                $text-tei-duplicated
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
            element { QName('http://read.84000.co/ns/1.0', 'result') } {
                attribute score { ft:score($match) },
                if(not($test/m:match[@data-id eq $match/@xml:id])) then
                    attribute invalid { 'should-not' }
                else
                    (),
                util:expand($match, "expand-xincludes=no")
            },
        for $match in $test/m:match[not(@data-id = $matches/@xml:id)]
        return
            element { QName('http://read.84000.co/ns/1.0', 'result') } {
                attribute invalid { 'should' },
                $lang-tests/m:data[@xml:id = $match/@data-id]
            }
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
        (:<debug>{ $existing-value, $new-value, $test, $test/m:match[last()] }</debug>:)
    
};

declare function tests:reindex(){
    xmldb:reindex($tests:utilities-data-collection)
};

