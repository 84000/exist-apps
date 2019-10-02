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
import module namespace source="http://read.84000.co/source" at "source.xql";
import module namespace functx="http://www.functx.com";

declare variable $translations:page-size-ranges := doc(concat($common:data-path, '/config/page-size-ranges.xml'));

declare function translations:work-tei($work as xs:string) as element()* {
    if($work eq 'all') then
        $tei-content:translations-collection//tei:TEI
    else if($work = ($source:ekangyur-work, $source:etengyur-work)) then
        $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location[@work = $work]]
    else
        ()
};

declare function translations:files($text-statuses as xs:string*) as element() {
    element { QName('http://read.84000.co/ns/1.0', 'translations') }{
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $text-statuses]]
            let $base-uri := base-uri($tei)
            let $file-name := util:unescape-uri(replace($base-uri, ".+/(.+)$", "$1"), 'UTF-8')
            order by $file-name
        return
            element file {
                attribute uri { $base-uri },
                attribute file-name { $file-name },
                attribute id { tei-content:id($tei) },
                tei-content:title($tei)
            }
    }
};

declare function translations:summary($work as xs:string) as element() {
    
    let $tei := translations:work-tei($work)
    
    let $translated-statuses := $tei-content:text-statuses/m:status[@group = ('translated')]/@status-id
    let $in-translation-statuses := $tei-content:text-statuses/m:status[@group = ('in-translation')]/@status-id
    let $all-statuses := $tei-content:text-statuses/m:status[not(@status-id = ('0'))]/@status-id
    
    let $fileDescs := $tei/tei:teiHeader/tei:fileDesc
    let $published-fileDesc := $fileDescs[tei:publicationStmt/@status = $tei-content:published-status-ids]
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
        <outline-summary xmlns="http://read.84000.co/ns/1.0" work="{ $work }">
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

declare function translations:filtered-texts($work as xs:string, $status as xs:string*, $sort as xs:string, $range as xs:string, $sponsorship-group as xs:string, $search-toh as xs:string, $deduplicate as xs:string) as element()? {
    
    (: Status parameter :)
    let $selected-statuses := $tei-content:text-statuses//m:status[@status-id = $status]/@status-id
    
    (: Range parameter :)
    let $selected-range := $translations:page-size-ranges//m:range[@id = $range]
    
    (: Sponsorship parameter :)
    let $selected-sponsorship-group := $sponsorship:sponsorship-groups/m:group[@id eq $sponsorship-group]
    
    (: Search parameter :)
    let $search-toh := normalize-space($search-toh)
    
    (: Check there is some parameter set so we are not getting everything :)
    where $selected-statuses or $selected-range or $selected-sponsorship-group or $search-toh gt ''
    return
        (: All tei in this section :)
        let $teis := translations:work-tei($work)
        
        (: Filter by status :)
        let $teis := 
            if($selected-statuses) then
                (
                    (: Add tei with selected statuses :)
                    $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $selected-statuses]],
                    
                    (: If status 0 (not started) is selected then add also @status = '' and not(@status) :)
                    if(functx:is-value-in-sequence('0', $status)) then
                        $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = ('', '0') or not(@status)]]
                    else
                        ()
                )
            else
                $teis
        
        (: Filter by page sizes :)
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
        
        (: Filter by sponsorship :)
        let $teis := 
            if($selected-sponsorship-group/@id = 'no-status')then
                (: Get all tei WITHOUT sponsorship :)
                let $sponsorship-group-text-ids := sponsorship:text-ids('all')
                return
                    $teis[not(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = $sponsorship-group-text-ids])]
            else if($selected-sponsorship-group) then
                (: Get ones with the selected group :)
                let $sponsorship-group-text-ids := sponsorship:text-ids($selected-sponsorship-group/@id)
                return
                    $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = $sponsorship-group-text-ids]]
            else
                (: Get them all :)
                $teis
        
        (: Filter by Toh:)
        let $teis :=
            if($search-toh gt '') then
                $teis[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key eq concat('toh', $search-toh)]
            else
                $teis
        
        (: Include sponsors? :)
        let $include-sponsors := not(empty($sponsorship:sponsorship-groups//m:group[@id eq $sponsorship-group]))
        
        (: Return result per Toh or per text :)
        let $texts := 
            for $tei in $teis
                let $include-downloads := if (tei-content:translation-status-group($tei) eq 'published') then 'all' else ''
            return
                if($deduplicate = ('text', 'sponsorship')) then
                    translations:filtered-text($tei, '', $include-sponsors, $include-downloads, false())
                else
                    for $bibl in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                    return
                        translations:filtered-text($tei, $bibl/@key, $include-sponsors, $include-downloads, false())
        
        (: count of texts :)
        let $texts-count := count($texts)
        (: count of pages :)
        let $texts-pages-count := sum($texts/tei:bibl/tei:location/@count-pages ! common:integer(.))
        (: count of words :)
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
                work="{ $work }" 
                status="{ $status }" 
                sort="{ $sort }" 
                range="{ $range }" 
                sponsorship-group="{ $sponsorship-group }"
                search-toh="{ $search-toh }"
                deduplicate="{ $deduplicate }">
                {
                    (: Sort the result, the sort may be based on the text detail :)
                    translations:sorted-texts($texts, $sort)
                }
            </texts>
};

declare function translations:sorted-texts($texts as element(m:text)*, $sort as xs:string) as element()* {
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
                if ($text/@status = $tei-content:text-statuses/m:status[not(@status-id = ('0'))]/@status-id) then $text/@status else '4',
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
};

declare function translations:filtered-text($tei as element(tei:TEI), $toh-key as xs:string?, $include-sponsors as xs:boolean, $include-downloads as xs:string, $include-folios as xs:boolean) as element(){
    
    let $text-id := tei-content:id($tei)
    let $lang := request:get-parameter('lang', 'en')
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'text') }{
            attribute id { $text-id }, 
            attribute uri { base-uri($tei) },
            attribute file-name { util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') },
            attribute status { tei-content:translation-status($tei) },
            attribute status-group { tei-content:translation-status-group($tei) },
            attribute word-count { translation-status:word-count($tei) },
            attribute glossary-count { translation-status:glossary-count($tei) },
            translation:toh($tei, $toh-key),
            translation:titles($tei),
            translation:title-variants($tei),
            tei-content:source-bibl($tei, $toh-key),
            translation:location($tei, $toh-key),
            translation:translation($tei),
            translation:summary($tei, $lang),
            sponsorship:text-status($text-id, false()),
            if($include-sponsors) then
                translation:sponsors($tei, true())
            else
                (),
            if($include-downloads gt '')then
                translation:downloads($tei, $toh-key, $include-downloads)
            else
                (),
            if($include-folios) then
                translation:folios($tei, $toh-key)
            else
                ()
        }
};

declare function translations:translations($text-statuses as xs:string*, $include-downloads as xs:string, $include-folios as xs:boolean) as element() {

    let $translations := $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $text-statuses]]
    
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
            for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        return
            translations:filtered-text($tei, $toh-key, false(), '', false())
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
