xquery version "3.1";

module namespace translations="http://read.84000.co/translations";

declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace section="http://read.84000.co/section" at "section.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "translation-status.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "sponsorship.xql";
import module namespace functx="http://www.functx.com";

declare function translations:section-tei($section-id as xs:string) as element()* {
    (:
    let $root := tei-content:tei($section-id, 'section')
    let $descendants := section:descendants($root, false())
    let $descendants-ids := $descendants//@id
    :)
    let $sections-structure := doc(concat($common:data-path, '/operations/sections-structure.xml'))
    let $root := $sections-structure//m:section[@source-id eq $section-id]
    let $descendants-ids := $root//m:section/@source-id
    return
        $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno[@parent-id = $descendants-ids]]
    
};

declare function translations:files($text-statuses as xs:string*) as element() {
    <translations xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $text-statuses]
            let $base-uri := base-uri($tei)
        return
            element file {
                attribute uri { $base-uri },
                attribute file-name { util:unescape-uri(replace($base-uri, ".+/(.+)$", "$1"), 'UTF-8') },
                attribute id { tei-content:id($tei) },
                tei-content:title($tei)
            }
    }
    </translations>
};

declare function translations:summary() as element() {
    
    let $tei := translations:section-tei('O1JC11494')
    
    let $translated-statuses := $tei-content:text-statuses/m:status[@group = ('translated')]/@status-id
    let $in-translation-statuses := $tei-content:text-statuses/m:status[@group = ('in-translation')]/@status-id
    let $all-statuses := $tei-content:text-statuses/m:status/@status-id
    
    let $fileDescs := $tei/tei:teiHeader/tei:fileDesc
    let $published-fileDesc := $fileDescs[tei:publicationStmt/@status = $tei-content:published-statuses]
    let $translated-fileDesc := $fileDescs[tei:publicationStmt/@status = $translated-statuses]
    let $in-translation-fileDesc := $fileDescs[tei:publicationStmt/@status = $in-translation-statuses]
    let $commissioned-fileDesc := $fileDescs[tei:publicationStmt/@status = $all-statuses]
    let $sponsorship-text-ids := sponsorship:text-ids('sponsored')
    let $sponsored-fileDesc := $fileDescs[tei:publicationStmt/tei:idno[@xml:id = $sponsorship-text-ids]]
    
    let $all-text-count := count($fileDescs)
    let $commissioned-text-count := count($commissioned-fileDesc)
    let $not-started-text-count := $all-text-count - $commissioned-text-count
    
    let $all-text-page-count := sum($fileDescs/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.))
    let $commissioned-text-page-count := sum($commissioned-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.))
    let $not-started-text-page-count := $all-text-page-count - $commissioned-text-page-count
    
    let $all-toh-count := count($fileDescs/tei:sourceDesc/tei:bibl)
    let $commissioned-toh-count := count($commissioned-fileDesc/tei:sourceDesc/tei:bibl)
    let $not-started-toh-count := $all-toh-count - $commissioned-toh-count
    
    let $all-toh-page-count := sum($fileDescs/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
    let $commissioned-toh-page-count := sum($commissioned-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
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
                    published="{ sum($published-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.)) }" 
                    translated="{ sum($translated-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.)) }" 
                    in-translation="{ sum($in-translation-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.)) }" 
                    commissioned="{ $commissioned-text-page-count }" 
                    not-started="{ $not-started-text-page-count }"
                    sponsored="{ sum($sponsored-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.)) }" />
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
                    published="{ sum($published-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.)) }" 
                    translated="{ sum($translated-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.)) }" 
                    in-translation="{ sum($in-translation-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.)) }" 
                    commissioned="{ $commissioned-toh-page-count }" 
                    not-started="{ $not-started-toh-page-count }"
                    sponsored="{ sum($sponsored-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.)) }" />
            </tohs>
            
        </outline-summary>
};

declare function translations:filtered-texts($section as xs:string, $status as xs:string*, $sort as xs:string, $range as xs:string, $sponsorship-group as xs:string, $search-toh as xs:string, $deduplicate as xs:string) as element() {
    
    (: All tei in this section :)
    let $teis := translations:section-tei($section)
    
    (: Filter by status :)
    let $teis := 
        if(count($status) eq 0 or (count($status) eq 1 and $status[1] eq '')) then
            $teis
        else
        (
            if(functx:is-value-in-sequence('0', $status)) then
                $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = ('', '0') or not(@status)]]
            else
                ()
            ,
            $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $status]]
        )
    
    (: Filter by page sizes :)
    let $page-size-ranges := doc(concat($common:data-path, '/config/page-size-ranges.xml'))
    let $selected-range := $page-size-ranges//m:range[xs:string(@id) eq $range]
    
    let $teis :=
        if($selected-range) then
            (: Some texts are combined into projects so we need the combined page count :)
            if($deduplicate eq 'sponsorship') then
                for $tei in $teis
                    let $text-id := tei-content:id($tei)
                    let $sponsorship-status := sponsorship:text-status($text-id, false())
                    let $count-pages :=
                        if($sponsorship-status//m:cost) then
                            $sponsorship-status//m:cost/@pages
                        else
                            $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages
                            
                    where 
                        xs:integer($count-pages) ge xs:integer($selected-range/@min)
                        and xs:integer($count-pages) le xs:integer($selected-range/@max)
                    
                return
                    $tei
            else
                $teis[
                    tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                        [tei:location/@count-pages gt '0']/tei:location[@count-pages >= xs:integer($selected-range/@min)][@count-pages <= xs:integer($selected-range/@max)]
                ]
        else
            $teis
    
    let $teis := 
        if($sponsorship:sponsorship-groups//m:group[@id eq $sponsorship-group]) then
            let $sponsorship-group-text-ids := sponsorship:text-ids($sponsorship-group)
            return
                $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = $sponsorship-group-text-ids]]
        else if($sponsorship-group eq 'no-status')then
            let $sponsorship-group-text-ids := sponsorship:text-ids('all')
            return
                $teis[not(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = $sponsorship-group-text-ids])]
        else
            $teis
    
    (: Duplicate by Toh if necessary :)
    let $teis := 
        if($deduplicate = ('text', 'sponsorship') and $search-toh eq '') then
            $teis
        else
            for $bibl in $teis/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[contains(@key, $search-toh)]
            return
                $bibl/ancestor::tei:TEI
    
    (: Convert tei into filtered text :)
    let $include-sponsors := not(empty($sponsorship:sponsorship-groups//m:group[@id eq $sponsorship-group]))
    let $texts :=
        for $tei in $teis
            let $include-downloads :=
                if (tei-content:translation-status-group($tei) eq 'published') then
                    'all'
                else
                    ''
        return
            translations:filtered-text($tei, '', $include-sponsors, $include-downloads, false())
    
    let $texts-count := count($texts)
    let $texts-pages-count := sum($texts/tei:bibl/tei:location/@count-pages ! common:integer(.))
    
    let $texts-words-count := sum($texts/@word-count)
    
    (: Max 1024 results in a set - this is an underlying restriction in eXist :)
    let $texts :=
        if($texts-count gt 1024) then
            subsequence($texts, 1, 1024)
        else
            $texts
    
    return 
        <texts xmlns="http://read.84000.co/ns/1.0"
            count="{ $texts-count }" 
            count-pages="{ $texts-pages-count }"  
            count-words="{ $texts-words-count }"  
            section="{ $section }" 
            status="{ $status }" 
            sort="{ $sort }" 
            range="{ $range }" 
            sponsored="{ $sponsorship-group }"
            search-toh="{ $search-toh }"
            deduplicate="{ $deduplicate }">
            {
                $page-size-ranges
            }
            {
                (: Sort the result, the sort may be based on the text detail :)
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
                        order by 
                            if ($text/@status = $tei-content:text-statuses/m:status/@status-id) then $text/@status else '4',
                            xs:integer($text/m:toh/@number), 
                            $text/m:toh/@letter, 
                            if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 9999, 
                            $text/m:toh/@chapter-letter
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


declare function translations:filtered-text($tei as element(), $toh-key as xs:string?, $include-sponsors as xs:boolean, $include-downloads as xs:string, $include-folios as xs:boolean) as element(){
    
    let $text-id := tei-content:id($tei)
    
    return
        <text xmlns="http://read.84000.co/ns/1.0" 
            id="{ $text-id }" 
            uri="{ base-uri($tei) }"
            file-name="{ util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') }"
            status="{ tei-content:translation-status($tei) }"
            status-group="{ tei-content:translation-status-group($tei) }"
            word-count="{ translation-status:word-count($tei) }"
            glossary-count="{ translation-status:glossary-count($tei) }">
            { translation:toh($tei, $toh-key) }
            { translation:titles($tei) }
            { translation:title-variants($tei) }
            { tei-content:source-bibl($tei, $toh-key) }
            { translation:location($tei, $toh-key) }
            { translation:translation($tei) }
            { translation:summary($tei) }
            { sponsorship:text-status($text-id, false()) }
            { 
                if($include-sponsors) then
                    translation:sponsors($tei, true())
                else
                    ()
             }
             {
                if($include-downloads gt '')then
                    translation:downloads($tei, $toh-key, $include-downloads)
                    (: It used to be like this. Not sure why.
                        for $bibl in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                        return
                            translation:downloads($tei, $bibl/@key, 'all')
                    :)
                else
                    ()
            }
            {
                if($include-folios) then
                    translation:folios($tei, $toh-key)
                else
                    ()
            }
        </text>
};

declare function translations:translations($text-statuses as xs:string*, $include-downloads as xs:string, $include-folios as xs:boolean) as element() {

    let $translations := $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $text-statuses]
    
    return
        <translations xmlns="http://read.84000.co/ns/1.0">
        {
            for $text-status-id in $text-statuses
            return
                <text-status id="{ $text-status-id }"/>
        }
        {
            for $toh-key in $translations//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                let $tei := $translations[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($toh-key)]]
            return
                translations:filtered-text($tei, $toh-key, false(), $include-downloads, $include-folios)
        }
        </translations>
    
};

declare function translations:sponsored-texts() as element() {
    
    <sponsored-texts xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = sponsorship:text-ids('sponsored')]]
        return
            translations:filtered-text($tei, '', true(), '', false())
    }
    </sponsored-texts>

};

declare function translations:sponsorship-texts() as element() {
    
    <sponsorship-texts xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = sponsorship:text-ids('available')]]
        return
            translations:filtered-text($tei, '', false(), '', false())
    }
    </sponsorship-texts>

};

declare function translations:translation-status-texts($status as xs:string*) as element() {
    
    <translation-status-texts xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc[tei:publicationStmt/@status = $status]]
        return
            translations:filtered-text($tei, '', false(), '', false())
    }
    </translation-status-texts>

};

declare function translations:downloads($resource-ids as xs:string*) as element() {

    <translations xmlns="http://read.84000.co/ns/1.0">
    {
     for $tei in  $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key = $resource-ids]]
     return
        <translation 
            id="{ tei-content:id($tei) }"
            uri="{ base-uri($tei) }"
            file-name="{ util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') }">
            { 
                for $resource-id in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key = $resource-ids]/@key
                return
                    translation:downloads($tei, $resource-id, 'all')
            }
        </translation>
    }
    </translations>
    
};
