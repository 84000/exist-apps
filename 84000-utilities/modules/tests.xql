xquery version "3.1";

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

declare function tests:translations($translation-id as xs:string) as element(m:results) {
    
    (:let $translation-id := 'UT22084-062-012':)
    
    let $schema := doc(concat($common:tei-path, '/schema/current/translation.rng'))
    
    let $selected-translations := 
        if ($translation-id eq 'all') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $translation:marked-up-status-ids]
        else if ($translation-id eq 'published') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $translation:published-status-ids]
        else if ($translation-id eq 'in-markup') then 
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $translation:marked-up-status-ids[not(. = $translation:published-status-ids)]]
        else
            tei-content:tei($translation-id, 'translation')
    
    let $test-config := $common:environment//m:test-conf
    let $credentials := $test-config/m:credentials/data() ! tokenize(., ':')
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'results') } {
            for $tei in $selected-translations
            
            let $text-id := tei-content:id($tei)
            let $text-status := tei-content:publication-status($tei)
            let $text-status-group := tei-content:publication-status-group($tei)
            let $test-validate-schema := tests:validate-schema($tei, $schema)
            let $test-duplicate-ids := tests:duplicate-ids($tei)
            let $test-scoped-ids := tests:scoped-ids($tei)
            let $test-valid-pointers := tests:valid-pointers($tei)
            
            return
                for $toh-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                    
                    (: Get all content with view-mode=tests :)
                    let $start-time-test-mode := util:system-dateTime()
                    
                    let $html-url := translation:href($toh-key, (), (), 'view-mode=tests', (), $test-config/m:path/text())
                    
                    let $request := 
                        if(count($credentials) eq 2) then 
                            <hc:request method="GET" href="{ $html-url }" auth-method="basic" username="{ $credentials[1] }" password="{ $credentials[2] }"/>
                        else if($test-config) then 
                            <hc:request method="GET" href="{ $html-url }"/>
                        else ()
                     
                    let $response := if($request) then hc:send-request($request) else ()
                    
                    let $toh-html-test-mode:= $response[2]
                    
                    let $end-time-test-mode := util:system-dateTime()
                    
                    (: Get skeleton content with view-mode=default :)
                    let $start-time-default-mode := util:system-dateTime()
                    
                    let $html-url := translation:href($toh-key, (), (), (), (), $test-config/m:path/text())
                    
                    let $request := 
                        if(count($credentials) eq 2) then 
                            <hc:request method="GET" href="{ $html-url }" auth-method="basic" username="{ $credentials[1] }" password="{ $credentials[2] }"/>
                        else if($test-config) then 
                            <hc:request method="GET" href="{ $html-url }"/>
                        else ()
                     
                    let $response := if($request) then hc:send-request($request) else ()
                    
                    let $toh-html-default-mode:= $response[2]
                    
                    let $end-time-default-mode := util:system-dateTime()
                    
                return
                    element translation { 
                    
                        attribute id { $text-id },
                        attribute test-domain { $test-config/m:path/text() }, 
                        attribute status { $text-status },
                        attribute status-group { $text-status-group },
                        attribute duration-test-mode { functx:total-seconds-from-duration($end-time-test-mode - $start-time-test-mode) },
                        attribute duration-default-mode { functx:total-seconds-from-duration($end-time-default-mode - $start-time-default-mode) },
                    
                        translation:title-element($tei, $toh-key),
                        translation:toh($tei, $toh-key),
                        
                        element tests {
                        
                            $test-validate-schema,
                            $test-duplicate-ids,
                            $test-scoped-ids,
                            $test-valid-pointers,
                            tests:titles($toh-html-test-mode, $tei, $toh-key),
                            tests:outline-context($tei, $toh-key),
                            tests:complete-source($toh-html-test-mode),
                            tests:translation-tantra-warning($tei, $toh-html-test-mode),
                            tests:part(
                                $tei//tei:front//tei:div[@type eq 'summary'][not(@xml:lang) or @xml:lang eq 'en'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-summary')], 
                                $toh-key, 'summary', 1),
                            tests:part(
                                $tei//tei:front//tei:div[@type eq 'acknowledgment'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-acknowledgment')],
                                $toh-key, 'acknowledgment', 1),
                            tests:part(
                                $tei//tei:front//tei:div[@type eq 'preface'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-preface')], 
                                $toh-key, 'preface', 0),
                            tests:part(
                                $tei//tei:front//tei:div[@type eq 'introduction'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-introduction')], 
                                $toh-key, 'introduction', 1),
                            tests:part(
                                $tei//tei:body//tei:div[@type eq 'prologue'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-prologue')], 
                                $toh-key, 'prologue', 0),
                            tests:part(
                                $tei//tei:body//tei:div[@type eq 'homage'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-homage')], 
                                $toh-key, 'homage', 0),
                            tests:part(
                                element tei:div {
                                    $tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')][not(@decls = $tei//tei:bibl[@type eq 'translation-blocks']/tei:citedRange[not(@status = $common:environment/m:render/m:status[@type eq 'translation']/@status-id)]/@xml:id ! concat('#',.))]
                                },
                                element xhtml:div {
                                    $toh-html-test-mode//xhtml:section[common:contains-class(@class, ('part-type-chapter', 'part-type-section'))]
                                }, 
                                $toh-key, 'body', 1),
                            tests:part(
                                $tei//tei:body//tei:div[@type eq 'colophon'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-colophon')], 
                                $toh-key, 'colophon', 0),
                            tests:part(
                                $tei//tei:back//tei:div[@type eq 'appendix'], 
                                $toh-html-test-mode//xhtml:section[common:contains-class(@class, 'part-type-appendix')], 
                                $toh-key, 'appendix', 0),
                            tests:notes($tei, $toh-html-test-mode, $toh-key),
                            tests:abbreviations($tei, $toh-html-test-mode),
                            tests:bibliography($tei, $toh-html-test-mode),
                            tests:glossary($tei, $toh-html-test-mode),
                            tests:refs($tei, $toh-html-test-mode, $toh-key),
                            tests:toc($toh-html-default-mode, $toh-key)
                            
                        }
                    
                    }
                
        }
};

declare function tests:sections($section-id as xs:string) as element(m:results) {

    let $schema := doc(concat($common:tei-path, '/schema/current/section.rng'))
    let $selected-tei := 
        if ($section-id eq 'all') then 
            $section:sections//tei:TEI
        else
            tei-content:tei(lower-case($section-id), 'section')
    
    let $test-config := $common:environment//m:test-conf
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'results') } {
            for $tei at $pos in $selected-tei
            
                let $start-time := util:system-dateTime()
                
                let $resource-id := tei-content:id($tei)
                
                let $html-url := concat($test-config/m:path/text(), '/section/', $resource-id, '.html')
                
                let $credentials := $test-config/m:credentials/data() ! tokenize(., ':')
                
                let $request := 
                    if(count($credentials) eq 2) then 
                        <hc:request method="GET" href="{ $html-url }" auth-method="basic" username="{ $credentials[1] }" password="{ $credentials[2] }"/>
                    else if($test-config) then 
                        <hc:request method="GET" href="{ $html-url }"/>
                    else ()
                
                let $response := if($request) then hc:send-request($request) else ()
                
                let $html := $response[2]
                
            (:return if(true()) then $html else :)
                
                let $end-time := util:system-dateTime()
                
            return
                <section 
                    id="{ $resource-id }"
                    filename="{ base-uri($tei) }"
                    duration="{ functx:total-seconds-from-duration($end-time - $start-time) }">
                    <title>{ tei-content:title-any($tei) }</title>
                    <tests>
                    {
                        tests:validate-schema($tei, $schema),
                        tests:duplicate-ids($tei),
                        tests:scoped-ids($tei),
                        tests:outline-context($tei, $resource-id),
                        tests:part($tei//tei:front//tei:div[@type eq 'abstract'], $html//*[@id eq 'abstract'], '', 'abstract', 0),
                        tests:part($tei//tei:body//tei:div[@type eq 'about'], $html//*[@id eq 'about'], '', 'about', 0),
                        tests:section-tantra-warning($tei, $html)
                    }
                    </tests>
                </section>
        }
};

declare function tests:validate-schema($tei as element(tei:TEI), $schema as document-node()) as element(m:test) {

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
                   <detail type="debug">{ string-join(($message/@line ! concat('line:', ., ' '), $message//text())) }</detail>
               }
           </details>
       </test>
};

declare function tests:duplicate-ids($tei as element(tei:TEI)) as element(m:test) {

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

declare function tests:scoped-ids($tei as element(tei:TEI)) as element(m:test) {

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

declare function tests:valid-pointers($tei as element(tei:TEI)) as element(m:test) {
    
    let $text-id := tei-content:id($tei)
    let $invalid-ptrs := 
        for $pointer in $tei//tei:ptr[matches(@target, concat('^#', functx:escape-for-regex($text-id)))]
        let $target := replace($pointer/@target, '^#', '') ! replace(., '^bibliography$', 'listBibl') ! replace(., '^abbreviations$', 'notes')
        where not($tei/id($target)) and not($tei//tei:div[@type = $target])
        return
            $pointer
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="valid-pointers" 
            pass="{ if(count($invalid-ptrs) eq 0) then 1 else 0 }">
            <title>Pointers test: The text has no invalid pointers.</title>
            <details>
                {
                    for $invalid-ptr in $invalid-ptrs
                    return
                        <detail type="debug">Target { string($invalid-ptr/@target) } was not found in the text.</detail>
                }
            </details>
        </test>
};

declare function tests:titles($html as document-node(), $tei as element(tei:TEI), $toh-key as xs:string) as element(m:test) {
    
    let $tei-main-titles := (
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('en', 'Sa-Ltn')][not(@key) or @key eq $toh-key][text()],
        ($tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('Bo-Ltn', 'bo')][not(@key) or @key eq $toh-key][text()])[1]
    )
    
    (: Max 4: 'en', 'Sa-Ltn', 'Bo-Ltn' and 'bo' if 'Bo-Ltn' or 'bo'  :)
    let $tei-long-titles := (
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('en', 'Sa-Ltn')][not(@key) or @key eq $toh-key][text()],
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('Bo-Ltn', 'bo')][not(@key) or @key eq $toh-key][text()][1],
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][@xml:lang = ('Bo-Ltn', 'bo')][not(@key) or @key eq $toh-key][text()][1]
    )
    
    let $tei-long-titles := 
        if(count($tei-long-titles) gt 1 or $tei-long-titles[@xml:lang eq 'Bo-Ltn']) then
            $tei-long-titles
        else 
            ($tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang = ('Bo-Ltn')][not(@key) or @key eq $toh-key][text()])[1]
    
    let $html-main-titles := $html//*[@id eq 'main-titles']/descendant::*[common:contains-class(@class, 'title')][data()]
    let $html-long-titles := $html//*[@id eq 'long-titles']/descendant::*[common:contains-class(@class, 'title')][data()]
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="titles" 
            pass="{ if(count($tei-main-titles) eq count($html-main-titles) and count($tei-long-titles) eq count($html-long-titles)) then 1 else 0 }">
            <title>Titles test: The html has the correct number of titles.</title>
            <details>
            { 
                for $title in $tei-main-titles
                return 
                    <detail>TEI main title: {$title/data()}</detail>
                ,
                for $title in $html-main-titles
                return 
                    <detail>HTML main title: {$title/data()}</detail>
                ,
                for $title in $tei-long-titles
                return 
                    <detail>TEI long title: {$title/data()}</detail>
                ,
                for $title in $html-long-titles
                return 
                    <detail>HTML long title: {$title/data()}</detail>
            }
            </details>
        </test>
};

declare function tests:outline-context($tei as element(tei:TEI), $resource-id as xs:string) as element(m:test) {

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

declare function tests:complete-source($html as document-node()) as element(m:test) {

    let $toh := $html//*[@id eq 'toh']/descendant::text()
    let $location := $html//*[@id eq 'location']/descendant::text()
    (:let $authours-summary := $toh-html-test-mode//*[@id eq 'authours-summary']/descendant::text():)
    let $edition := $html//*[@id eq 'edition']/descendant::text()
    let $publication-statement := $html//*[@id eq 'publication-statement']/descendant::text()
    let $license := $html//*[@id eq 'license']
    
    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="complete-source" 
            pass="{ if($toh and $location and $edition and $publication-statement and $license/xhtml:p and $license/xhtml:img/@src/string()) then 1 else 0 }">
            <title>Source test: The text has complete documentation of the source.</title>
            <details>
                <detail>Toh: {$toh}</detail>
                <detail>Location: {$location}</detail>
                <!--<detail>Author summary: {$authours-summary}</detail>-->
                <detail>Publication statement: {$publication-statement}</detail>
                <!--<detail>License: { count($license/xhtml:p) } paragraph(s).</detail>-->
                <!--<detail>License image: {$license/xhtml:img}</detail>-->
            </details>
        </test>
};

declare function tests:part($section-tei as element()*, $section-html as element()*, $toh-key as xs:string, $section-name as xs:string, $required-paragraphs as xs:integer) as element(m:test) {
    
    let $section-tei-type := $section-tei/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/@type
    
    let $section-tei-p := 
        $section-tei//*[self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl][not(ancestor::tei:note)][not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])]
    let $section-html-p := 
        $section-html//xhtml:p[not(common:contains-class(@class, ('ref-prologue', 'table-as-list-row', 'table-note')))]
        
    let $section-tei-line := 
        $section-tei//tei:l[not(ancestor::tei:note)][not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])]
    let $section-html-line := 
        $section-html//xhtml:div[common:contains-class(@class, 'line')]
    
    let $section-tei-note := 
        $section-tei//tei:note[@place eq 'end'][@xml:id][not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])]
    let $section-html-note := 
        $section-html//xhtml:a[common:contains-class(@class, 'footnote-link')]
        
    let $section-tei-q := 
        $section-tei//tei:q[not(ancestor::tei:note)][not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])]
    let $section-html-q := 
        $section-html//xhtml:blockquote | $section-html//xhtml:span[common:contains-class(@class, ('quote'))]
    
    let $section-tei-id := 
        $section-tei//*[@tid][not(ancestor::tei:note)][not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])]/@tid/string() ! concat('node-',.)
    let $section-html-id := 
        $section-html//*[matches(@id, '^node\-')]/@id/string()
    
    let $section-tei-list-item := 
        $section-tei//tei:list[not(ancestor::tei:note)]/tei:item[not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])]
    let $section-html-list-item := 
        $section-html//xhtml:div[common:contains-class(@class, 'list-item')]
    
    (:let $section-tei-sections := 
        $section-tei//tei:div[@type][tei:head[@type eq parent::tei:div/@type]]
    let $section-html-sections := 
        $section-html//xhtml:section[common:contains-class(@class, 'part-type-chapter') or common:contains-class(@class, 'part-type-section')] | $section-html//xhtml:div[common:contains-class(@class, 'nested-section')]
    :)
    
    let $section-tei-milestones := 
        if(not($section-tei-type eq 'section')) then $section-tei//tei:milestone[not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])] else ()
    let $section-html-milestones := 
        $section-html//xhtml:a[common:contains-class(@class, 'milestone from-tei')]
    
    let $required-paragraphs-rule := if ($required-paragraphs > 0) then concat(' at least ', $required-paragraphs , ' paragraph(s) and') else ''
    
    return
        <test 
            xmlns="http://read.84000.co/ns/1.0"
            id="{ concat('valid-', $section-name, '-section') }"
            pass="{ if(
                    count($section-html-p) ge $required-paragraphs
                    and count($section-html-p) eq count($section-tei-p)
                    and count($section-html-line) eq count($section-tei-line)
                    and count($section-html-note) eq count($section-tei-note)
                    and count($section-html-q) eq count($section-tei-q)
                    and count($section-html-id) eq count($section-tei-id)
                    and count($section-html-list-item) eq count($section-tei-list-item)
                    (:and count($section-html-sections) eq count($section-tei-sections):)
                    and count($section-html-milestones) eq count($section-tei-milestones)
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
                <detail>{count($section-tei-p)} TEI paragraph(s), {count($section-html-p)} HTML paragraph(s).</detail>
                <detail>{count($section-tei-line)} TEI line(s), {count($section-html-line)} HTML line(s).</detail>
                <detail>{count($section-tei-note)} TEI note(s), {count($section-html-note)} HTML note(s).</detail>
                <detail>{count($section-tei-q)} TEI quote(s), {count($section-html-q)} HTML quote(s).</detail>
                <detail>{count($section-tei-id)} TEI id(s), {count($section-html-id)} HTML id(s).</detail>
                <detail>{count($section-tei-list-item)} TEI list item(s), {count($section-html-list-item)} HTML list item(s).</detail>
                <!--<detail>{count($section-tei-sections)} TEI section(s), {count($section-html-sections)} HTML section(s).</detail>-->
                <detail>{count($section-tei-milestones)} TEI milestone(s), {count($section-html-milestones)} HTML milestone(s).</detail>
                {
                    if(not(count($section-html-note) eq count($section-tei-note))) then
                        <detail>
                        {
                            'Note anomalies: '
                            || string-join(($section-tei-note/@xml:id/string()[not(. = $section-html-note/@id/string())], $section-html-note/@id/string()[not(. = $section-tei-note/@xml:id/string())]), ', ')
                        }
                        </detail>
                    else ()
                    ,
                    if(not(count($section-html-id) eq count($section-tei-id))) then
                        <detail>
                        {
                            'Id anomalies: '
                            || string-join(($section-tei-id[not(. = $section-html-id)], $section-html-id[not(. = $section-tei-id)]), ', ')
                        }
                        </detail>
                    else ()
                    ,
                    if(not(count($section-html-milestones) eq count($section-tei-milestones))) then
                        <detail>
                        {
                            'Milestone anomalies: '
                            || string-join($section-tei-milestones/@xml:id/string()[not(. = $section-html//xhtml:div/@id/string())], ', ')
                        }
                        </detail>
                    else ()
                }
                
            </details>
        </test>
};

declare function tests:notes($tei as element(tei:TEI)*, $html as document-node()*, $toh-key as xs:string) as element(m:test) {
    
    let $notes-count-tei := count($tei//tei:text//tei:note[@place eq 'end'][@xml:id][not($toh-key gt '') or not(ancestor-or-self::tei:*[@key][not(@key eq $toh-key)])])
    let $notes-count-html := count($html//xhtml:section[@data-part-type eq 'end-notes']/*[common:contains-class(@class, 'footnote')])
    
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

declare function tests:abbreviations($tei as element(tei:TEI)*, $html as document-node()*) as element(m:test) {

    let $abbreviations-count-tei := count($tei//tei:back//tei:list[@type='abbreviations']/tei:item/tei:abbr)
    let $abbreviations-count-html := count($html//*[@data-part-type eq 'abbreviations']//xhtml:tr)
    
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

declare function tests:bibliography($tei as element(tei:TEI)*, $html as document-node()*) as element(m:test) {

    let $biblography-count-tei := count($tei//tei:back/tei:div[@type='listBibl']//tei:bibl)
    let $biblography-count-html := count($html//*[@data-part-type eq 'bibliography']//xhtml:p[common:contains-class(@class, 'bibl')])
    
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

declare function tests:section-tantra-warning($tei as element(tei:TEI)*, $html as document-node()*) as element(m:test) {

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

declare function tests:translation-tantra-warning($tei as element(tei:TEI)*, $html as document-node()*) as element(m:test) {

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

declare function tests:glossary($tei as element(tei:TEI)*, $html as document-node()*) as element(m:test) {
    
    let $glossary-count-tei := count($tei//tei:back/tei:div[@type='glossary']//tei:gloss[not(@mode eq 'surfeit')])
    let $glossary-count-html := count($html//*[@data-part-type eq 'glossary']/*[common:contains-class(@class, 'glossary-item')])
    
    let $tei-terms-raw := $tei//tei:back//tei:gloss[@xml:id][not(@mode eq 'surfeit')]/tei:term[not(@xml:lang) or @xml:lang = ('Sa-Ltn', 'bo', 'Bo-Ltn', 'en', 'zh', 'Pi-Ltn')][not(@type eq 'translationAlternative')][normalize-space(string-join(descendant::text(), ''))](:[not(tei:ptr)]:)
    let $empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'))
    
    let $tei-terms := (
        $tei-terms-raw[@xml:lang eq "Bo-Ltn"] ! data(.) ! lower-case(.) ! tests:normalize-whitespace(.) ! common:bo-ltn(.),
        $tei-terms-raw[not(@xml:lang eq "Bo-Ltn")] ! data(.) ! lower-case(.) ! tests:normalize-whitespace(.)
    )
    
    let $html-term-elements := 
        $html//xhtml:div[common:contains-class(@class, 'glossary-item')]//*[common:contains-class(@class, 'term')][normalize-space(string-join(descendant::text(), ''))](:[not(xhtml:a[common:contains-class(@class, 'pointer')])]:)
    
    let $html-terms := 
        $html-term-elements[not(. = $empty-term-placeholders)] ! normalize-space(string-join(descendant::text(), '')) (:! tokenize(., '·'):) ! translate(., 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ', 'abcdefghijklmnopqrstuvwxyz') ! lower-case(.) ! tests:normalize-whitespace(.)
    
    let $tei-terms-not-found := $tei-terms[not(. = $html-terms)]
    let $html-terms-not-found := $html-terms[not(. = $tei-terms)]

    return
        <test xmlns="http://read.84000.co/ns/1.0"
            id="glossary"
            pass="{ 
                if(
                    $glossary-count-html > 0 
                    and $glossary-count-html eq $glossary-count-tei 
                    and count($html-terms) eq count($tei-terms) 
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

declare function tests:refs($tei as element(tei:TEI)*, $html as document-node()*, $toh-key as xs:string) as element(m:test) {
    
    let $tei-folios := translation:folios($tei, $toh-key)//m:folio[not(@rend = ('blank', 'hidden'))][@ref-id gt '']
    let $html-refs := $html//xhtml:a[common:contains-class(@class, 'ref')]
    
    let $folio-count-tei := count($tei-folios)
    let $ref-count-html := count($html-refs)
    
    let $html-folio-equivalents := $html-refs ! lower-case(text())
    
    let $anomalies := 
        for $tei-folio in $tei-folios
            let $tei-folio-equivalent := concat('[', lower-case($tei-folio/@tei-folio), ']')
            where not($tei-folio-equivalent = $html-folio-equivalents)
        return 
            concat('Volume ', $tei-folio/@volume, ' page ', $tei-folio/@page-in-volume, ' ', $tei-folio-equivalent, ' not found.' )
    
    let $pass := if($ref-count-html gt 0 and $ref-count-html eq $folio-count-tei and count($anomalies) eq 0) then 1 else 0
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" id="refs" pass="{ $pass }">
            <title>Refs: The text has at least 1 ref, there are the same number in the HTML as in the TEI with no anomalies.</title>
            <details>
                <detail>{ $folio-count-tei } refs(s) in the TEI, { $ref-count-html } refs(s) in the HTML.</detail>
                {
                    for $anomaly in $anomalies
                    return
                        <detail>{ $anomaly }</detail>
                    ,
                    if($pass eq 0) then
                        <detail>For more information visit the "Folios" utility.</detail>
                    else
                        ()
                }
            </details>
        </test>
};

declare function tests:toc($html as document-node()*, $toh-key as xs:string) as element(m:test) {
    
    let $html-ids :=  $html//@id/string()
    let $partial-part-ids := ($html/descendant::xhtml:aside[common:contains-class(@class, 'partial')]/@id/string(), 'index') (: Add index to weed out commentaries :)
    let $part-map-script := $html/descendant::xhtml:script[matches(text(), 'var\s+partMap')] ! string-join(text()) ! normalize-space(.)
    let $part-map-json := replace($part-map-script, '^var\s+partMap\s+=\s+(\{[^\}]*\})(.*)', '$1', 'i')
    let $parts-map := $part-map-json ! fn:parse-json(.)
    
    (: If href="#*" then check the fragment id is in the html doc :)
    let $id-links := $html/descendant::xhtml:a[matches(@href, '^#.+')][not(@data-bookmark)]
    let $id-links-dead := 
        for $link in $id-links
        let $link-id-valid := local:link-id-valid($link, $html-ids, $parts-map)
        where not($link-id-valid)
        return
            $link
    
    (: If href="/translation/{toh-key}/{part-id}*" then check the part-id is a root part in the TEI :)
    let $part-links := $html/descendant::xhtml:a[matches(@href, concat('^/translation/', functx:escape-for-regex($toh-key), '/.+'))]
    let $part-links-dead := 
        for $link in $part-links
        let $link-target-part := replace($link/@href, concat('^/translation/', functx:escape-for-regex($toh-key), '/([^/#]+)(.*)'), '$1')
        let $partial-part-id := $partial-part-ids[. eq $link-target-part]
        let $link-id-valid := local:link-id-valid($link, $html-ids, $parts-map)
        where not($partial-part-id) or not($link-id-valid)
        return
            $link
    
    let $dead-links := ($id-links-dead, $part-links-dead)
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" id="toc" pass="{ if(count($dead-links) eq 0) then 1 else 0 }">
            <title>Table of contents test: the table of contents links correctly to the parts.</title>
            <details>
                <detail>{ format-number(count($id-links), '#,###') } link(s) to ids in the HTML.</detail>
                <detail>{ format-number(count($part-links), '#,###') } link(s) to other sections of the publication.</detail>
                <detail>{ format-number(count($dead-links), '#,###') } dead link(s).</detail>
                {
                    for $dead-link in $dead-links
                    return
                        <detail>Dead link: { $dead-link/@href/string() }</detail>
                }
            </details>
        </test>
        
};

declare function local:link-id-valid($link as element(xhtml:a), $html-ids as xs:string*, $parts-map as map(*)) as xs:boolean? {
    
    let $link-id := tokenize($link/@href, '#')[last()] ! tokenize(., '/')[1]
    let $link-id-valid := $html-ids[. eq $link-id]
    let $link-id-valid := 
        if(not($link-id-valid)) then
            if($parts-map($link-id)) then
                $link-id
            else ()
        else
            $link-id-valid
    
    return
        if($link-id-valid) then true() else false()
        
};

declare function tests:normalize-whitespace($string as xs:string) as xs:string {
    fn:replace(fn:replace(normalize-space($string),'\s+(,|\.|\))', '$1'),'(\()\s+', '$1')
};

declare function tests:structure() as element(m:results) {

    let $sections-structure := doc(concat($common:data-path, '/config/tests/sections-structure.xml'))
    
    let $tei-section-ids := $section:sections//tei:idno/@xml:id/string()[not(. = ('ALL-TRANSLATED'))]
    let $structure-section-ids := $sections-structure//m:section/@source-id/string()
    let $tei-text-source-ids := $section:texts//tei:idno/@source-id/string()
    let $structure-text-ids := $sections-structure//m:text/@source-id/string()
    
    let $structure-section-ids-unmatched := 
    for $source-id in $structure-section-ids[not(. = $tei-section-ids)]
    return
        <detail xmlns="http://read.84000.co/ns/1.0">Section source-id={ xs:string($source-id) } has no associated TEI file</detail>
    
    let $structure-text-ids-unmatched := 
    for $source-id in $structure-text-ids[not(. = $tei-text-source-ids)]
    return
        <detail xmlns="http://read.84000.co/ns/1.0">Text source-id={ xs:string($source-id) } has no associated TEI file</detail>
    
    let $tei-section-unmatched := 
    for $section-id in $tei-section-ids[not(. = $structure-section-ids)]
    return
        <detail xmlns="http://read.84000.co/ns/1.0">Section TEI source-id={ $section-id } has no reference in the sections structure</detail>
    
    let $tei-text-unmatched := 
    for $text-source-id in $tei-text-source-ids[not(. = $structure-text-ids)]
    return
        <detail xmlns="http://read.84000.co/ns/1.0">Text TEI source-id={ $text-source-id } has no reference in the sections structure</detail>
    
    let $unmatched-section-texts := tests:match-text-count($sections-structure/m:sections-structure)
     
    (:let $structure-text-ids-duplicated := 
    for $text-id in $structure-text-ids
    where count($structure-text-ids[. eq $text-id]) gt 1
    return
        <detail xmlns="http://read.84000.co/ns/1.0">Text source-id={ data($text-id) } occurs more than once in the sections structure</detail>:)
    
    let $tei-text-ids-duplicated := 
    for $text-id in $tei-text-source-ids
    where count($tei-text-source-ids[. eq $text-id]) gt 1
    return
        <detail xmlns="http://read.84000.co/ns/1.0">Text source-id={ data($text-id) } occurs more than once in the TEI</detail>
    
    let $tei-text-unsorted-count := count(collection(concat($common:translations-path, '/unsorted'))//tei:TEI)
    
    return
        <results xmlns="http://read.84000.co/ns/1.0">
            <structure>
            {
                let $details := ($structure-section-ids-unmatched | $structure-text-ids-unmatched)
                return
                    <test id="unmatched-ids" pass="{ if (count($details) eq 0) then 1 else 0 }">
                        <title>All sections structure nodes must have a TEI file</title>
                        { if($details) then <details>{ $details }</details> else () }
                    </test>
                ,
                let $details := ($tei-section-unmatched | $tei-text-unmatched)
                return
                    <test id="unmatched-tei" pass="{ if (count($details) eq 0) then 1 else 0 }">
                        <title>All TEI files must be referenced in the sections structure</title>
                        { if($details) then <details>{ $details }</details> else () }
                    </test>
                ,
                let $details := $unmatched-section-texts
                return
                    <test id="unmatched-section-texts" pass="{ if (count($details) eq 0) then 1 else 0 }">
                        <title>All sections must have the correct number of child texts</title>
                        { if($details) then <details>{ $details }</details> else () }
                    </test>
                ,
                (:let $details := $structure-text-ids-duplicated
                return
                    <test id="tei-text-duplicated" pass="{ if (count($details) eq 0) then 1 else 0 }">
                        <title>There should be no duplicate source-ids in the sections structure</title>
                        { if($details) then <details>{ $details }</details> else () }
                    </test>
                ,:)
                let $details := $tei-text-ids-duplicated
                return
                    <test id="tei-text-duplicated" pass="{ if (count($details) eq 0) then 1 else 0 }">
                        <title>There should be no duplicate source-ids in the TEI</title>
                        { if($details) then <details>{ $details }</details> else () }
                    </test>
                ,
                <test id="tei-text-unsorted-count" pass="{ if ($tei-text-unsorted-count eq 0) then 1 else 0 }">
                    <title>There should be no TEI files in the sorted folder</title>
                    { if($tei-text-unsorted-count gt 0) then <details><detail>There is/are { $tei-text-unsorted-count } unsorted TEI files</detail></details> else () }
                </test>
            }
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
                Section { $source-id } should have { $count-texts-in-structure } TEI files but has { $count-texts-in-tei }
            </detail>
        else ()
        ,
        if($section/m:section) then
            tests:match-text-count($section)
        else ()
    )
};

declare function tests:search-options() as element() {
    <options>
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
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

declare function tests:next-xmlid($siblings as item()*) as xs:string {
    
    (: Assumes there is already at least one sibling :)
    
    let $node-name := local-name($siblings[1])
    let $next-int := max($siblings/@xml:id ! substring-after(., concat($node-name, '-')) ! xs:integer(concat('0', .))) + 1
    return
        concat($node-name, '-', $next-int)
    
};

declare function tests:reindex() {
    xmldb:reindex($tests:utilities-data-collection)
};

