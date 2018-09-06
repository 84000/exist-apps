xquery version "3.1";

module namespace translations="http://read.84000.co/translations";

declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "section.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace functx="http://www.functx.com";

declare function translations:section-tei($section-id as xs:string) as node()* {
    let $root := tei-content:tei($section-id, 'section')
    let $descendants := section:descendants($root, 1, false())
    let $descendants-ids := $descendants//@id
    return
        collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@parent-id = $descendants-ids]
};

declare function translations:file($translation as node()) as node() {
    let $base-uri := base-uri($translation)
    return
        <file xmlns="http://read.84000.co/ns/1.0"
            uri="{ $base-uri }"
            fileName="{ util:unescape-uri(replace($base-uri, ".+/(.+)$", "$1"), 'UTF-8') }"
            id="{ $translation//tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id }" >
            {
                tei-content:title($translation)
            }
        </file>
};

declare function translations:files() as node() {
    <translations xmlns="http://read.84000.co/ns/1.0">
    {
        for $translation in collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses]
        return
            translations:file($translation)
    }
    </translations>
};

declare function translations:summary() as node() {
    
    let $tei := translations:section-tei('O1JC11494')
    
    let $translated-statuses := $tei-content:text-statuses/m:status[@group = ('translated')]/@status-id
    let $in-translation-statuses := $tei-content:text-statuses/m:status[@group = ('in-translation')]/@status-id
    let $all-statuses := $tei-content:text-statuses/m:status/@status-id
    
    let $fileDescs := $tei/tei:teiHeader/tei:fileDesc
    let $published-fileDesc := $fileDescs[tei:publicationStmt/@status = $tei-content:published-statuses]
    let $translated-fileDesc := $fileDescs[tei:publicationStmt/@status = $translated-statuses]
    let $in-translation-fileDesc := $fileDescs[tei:publicationStmt/@status = $in-translation-statuses]
    let $commissioned-fileDesc := $fileDescs[tei:publicationStmt/@status = $all-statuses]
    let $sponsored-fileDesc := $tei[tei:text/tei:front/tei:div[@type eq 'acknowledgment']/@sponsored = ('full', 'part')]/tei:teiHeader/tei:fileDesc
    
    let $all-text-count := count($fileDescs)
    let $commissioned-text-count := count($commissioned-fileDesc)
    let $not-started-text-count := $all-text-count - $commissioned-text-count
    
    let $all-text-page-count := sum($fileDescs/tei:sourceDesc/tei:bibl[1]/tei:location[functx:is-a-number(@count-pages)]/@count-pages)
    let $commissioned-text-page-count := sum($commissioned-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location[functx:is-a-number(@count-pages)]/@count-pages)
    let $not-started-text-page-count := $all-text-page-count - $commissioned-text-page-count
    
    let $all-toh-count := count($fileDescs/tei:sourceDesc/tei:bibl)
    let $commissioned-toh-count := count($commissioned-fileDesc/tei:sourceDesc/tei:bibl)
    let $not-started-toh-count := $all-toh-count - $commissioned-toh-count
    
    let $all-toh-page-count := sum($fileDescs/tei:sourceDesc/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages)
    let $commissioned-toh-page-count := sum($commissioned-fileDesc/tei:sourceDesc/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages)
    let $not-started-toh-page-count := $all-toh-page-count - $commissioned-toh-page-count
    
    return 
        <outline-summary xmlns="http://read.84000.co/ns/1.0">
            <texts 
                count="{ $all-text-count }" 
                published="{ count($published-fileDesc) }" 
                translated="{ count($translated-fileDesc) }" 
                in-translation="{ count($in-translation-fileDesc) }" 
                commissioned="{ $commissioned-text-count }" 
                not-started="{ $not-started-text-count }"
                sponsored="{ count($sponsored-fileDesc) }" >
                <pages 
                    count="{ $all-text-page-count }" 
                    published="{ sum($published-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" 
                    translated="{ sum($translated-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" 
                    in-translation="{ sum($in-translation-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" 
                    commissioned="{ $commissioned-text-page-count }" 
                    not-started="{ $not-started-text-page-count }"
                    sponsored="{ sum($sponsored-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" />
            </texts>
            <tohs 
                count="{ $all-toh-count }" 
                published="{ count($published-fileDesc/tei:sourceDesc/tei:bibl) }" 
                translated="{ count($translated-fileDesc/tei:sourceDesc/tei:bibl) }" 
                in-translation="{ count($in-translation-fileDesc/tei:sourceDesc/tei:bibl) }" 
                commissioned="{ $commissioned-toh-count }" 
                not-started="{ $not-started-toh-count }"
                sponsored="{ count($sponsored-fileDesc/tei:sourceDesc/tei:bibl) }" >
                <pages 
                    count="{ $all-toh-page-count }" 
                    published="{ sum($published-fileDesc/tei:sourceDesc/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" 
                    translated="{ sum($translated-fileDesc/tei:sourceDesc/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" 
                    in-translation="{ sum($in-translation-fileDesc/tei:sourceDesc/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" 
                    commissioned="{ $commissioned-toh-page-count }" 
                    not-started="{ $not-started-toh-page-count }"
                    sponsored="{ sum($sponsored-fileDesc/tei:sourceDesc/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages) }" />
            </tohs>
            
        </outline-summary>
};

declare function translations:sponsored() as node() {
    
    <sponsored-texts xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in collection($common:translations-path)//tei:TEI[tei:text/tei:front/tei:div[@type eq 'acknowledgment']/@sponsored = ('full', 'part')]
        return
            <text 
                status="{ tei-content:translation-status($tei) }" 
                status-group="{ tei-content:translation-status-group($tei) }">
                { translation:toh($tei, '') }
                { translation:titles($tei) }
                { translation:title-variants($tei) }
                { translation:summary($tei) }
                { translation:sponsors($tei, true()) }
                { translation:translation($tei) }
            </text>
    }
    </sponsored-texts>
        
};

declare function translations:filtered-text($tei as node(), $toh-key as xs:string?) as node(){
    <text xmlns="http://read.84000.co/ns/1.0" 
        id="{ tei-content:id($tei) }" 
        status="{ tei-content:translation-status($tei) }"
        status-group="{ tei-content:translation-status-group($tei) }">
        { translation:toh($tei, $toh-key) }
        { translation:titles($tei) }
        { tei-content:source-bibl($tei, $toh-key) }
        { translation:translation($tei) }
        { translation:acknowledgment($tei) }
    </text>
};

declare function translations:filtered-texts($section as xs:string, $status as xs:string*, $sort as xs:string, $range as xs:string, $sponsored as xs:string, $search-toh as xs:string, $deduplicate as xs:boolean) as node() {
    
    let $tei := translations:section-tei($section)
    
    let $status-tei := 
        if(count($status) eq 0 or (count($status) eq 1 and $status[1] eq '')) then
            $tei
        else
        (
            if(functx:is-value-in-sequence('0', $status)) then
                $tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status eq '' or not(@status)]]
            else
                ()
        ,
            $tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $status]]
        )
    
    let $page-size-ranges :=
        <page-size-ranges xmlns="http://read.84000.co/ns/1.0">
            <range id="1" min="0" max="99"/>
            <range id="2" min="100" max="149"/>
            <range id="3" min="150" max="199"/>
            <range id="4" min="200" max="10000"/>
        </page-size-ranges>
    
    let $selected-range := $page-size-ranges//m:range[xs:string(@id) eq $range]
        
    let $page-size-tei :=
        if($selected-range) then
            $status-tei[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@count-pages gt '0']/tei:location/@count-pages[. >= xs:integer($selected-range/@min)][. <= xs:integer($selected-range/@max)]]
        else
            $status-tei
    
    let $sponsor-types :=
        if($sponsored eq 'sponsored')then
            ('full', 'part')
        else if($sponsored eq 'fully-sponsored')then
            ('full')
        else if($sponsored eq 'part-sponsored')then
            ('part')
        else
            ()
    
    let $sponsor-types-tei := 
        if(count($sponsor-types) gt 0) then
            $page-size-tei[tei:text/tei:front/tei:div[@type eq 'acknowledgment'][@sponsored = $sponsor-types]]
        else if($sponsored eq 'not-sponsored')then
            $page-size-tei[tei:text/tei:front[not(tei:div[@type eq 'acknowledgment']) or tei:div[@type eq 'acknowledgment'][not(@sponsored) or @sponsored eq '']]]
        else
            $page-size-tei
    
    let $texts :=
        if($deduplicate and $search-toh eq '') then
            for $tei in $sponsor-types-tei
            return
                translations:filtered-text($tei, '')
         else
            for $bibl in $sponsor-types-tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[contains(@key, $search-toh)]
                let $tei := $bibl/ancestor::tei:TEI
            return
                translations:filtered-text($tei, $bibl/@key)
    
    let $texts-count := count($texts)
    let $texts-pages-count := sum($texts/tei:bibl/tei:location[functx:is-a-number(@count-pages)]/@count-pages)
    
    return 
        <texts xmlns="http://read.84000.co/ns/1.0"
            count="{ $texts-count }" 
            count-pages="{ $texts-pages-count }"  
            section="{ $section }" 
            status="{ $status }" 
            sort="{ $sort }" 
            range="{ $range }" 
            sponsored="{ $sponsored }"
            search-toh="{ $search-toh }"
            deduplicate="{ $deduplicate }">
            {
                $page-size-ranges
            }
            { 
                if($sort = ('toh', '')) then
                    for $text in $texts
                        order by 
                            xs:integer($text/m:toh/@number), 
                            $text/m:toh/@letter, 
                            if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 9999, 
                            $text/m:toh/@chapter-letter
                    return $text
                else if($sort eq 'status') then
                    for $text in $texts
                        order by if ($text/@status gt '') then $text/@status else '4'
                    return $text
                else if($sort eq 'longest') then
                    for $text in $texts
                        order by if(functx:is-a-number($text/tei:bibl/tei:location/@count-pages)) then xs:integer($text/tei:bibl/tei:location/@count-pages) else 1 descending
                    return $text
                else if($sort eq 'shortest') then
                    for $text in $texts
                        order by if(functx:is-a-number($text/tei:bibl/tei:location/@count-pages)) then xs:integer($text/tei:bibl/tei:location/@count-pages) else 1
                    return $text
                else
                    $texts
            }
        </texts>
};

declare function translations:translations($include-stats as xs:boolean, $include-downloads as xs:boolean, $include-folios as xs:boolean) as node() {

    let $translations := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses]
    
    return
        <translations xmlns="http://read.84000.co/ns/1.0">
        {
         for $toh-key in $translations//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
         
            let $tei := $translations[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key eq lower-case($toh-key)]
            
         return
            <translation 
                uri="{ base-uri($tei) }"
                fileName="{ util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') }"
                id="{ tei-content:id($tei) }" 
                wordCount="{ if($include-stats) then translation:word-count($tei) else '' }"
                glossaryCount="{ if($include-stats) then translation:glossary-count($tei) else '' }"
                status="published">
                { translation:toh($tei, $toh-key) }
                { translation:titles($tei) }
                { translation:location($tei, $toh-key) }
                {
                    if($include-downloads)then
                        translation:downloads($tei, $toh-key)
                    else
                        ()
                }
                {
                    if($include-folios) then
                        translation:folios($tei, $toh-key)
                    else
                        ()
                }
            </translation>
        }
        </translations>
    
};
