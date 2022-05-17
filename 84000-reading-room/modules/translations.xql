xquery version "3.1";

module namespace translations="http://read.84000.co/translations";

declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "sponsorship.xql";
import module namespace source="http://read.84000.co/source" at "source.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace functx="http://www.functx.com";

declare variable $translations:total-kangyur-pages as xs:integer := 70000;
(:declare variable $translations:page-size-ranges := doc(concat($common:app-config, '/', 'page-size-ranges.xml'));:)

declare function translations:work-tei($work as xs:string) as element()* {
    if($work eq 'all') then
        $tei-content:translations-collection//tei:TEI
    else if($work = ($source:ekangyur-work, $source:etengyur-work)) then
        $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location[@work = $work]]
    else ()
};

declare function translations:files($publication-statuses as xs:string*) as element() {

    element { QName('http://read.84000.co/ns/1.0', 'translations') }{
        for $tei in $tei-content:translations-collection//tei:fileDesc/tei:publicationStmt[@status = $publication-statuses]/ancestor::tei:TEI
            let $base-uri := base-uri($tei)
            let $file-name := util:unescape-uri(replace($base-uri, ".+/(.+)$", "$1"), 'UTF-8')
            order by $file-name
        return
            element file {
                attribute id { tei-content:id($tei) },
                attribute document-url { tei-content:document-url($tei) },
                attribute file-name { $file-name },
                concat(string-join($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:ref, ' / '), ' - ', tei-content:title($tei))
            }
    }
    
};

declare function translations:summary($work as xs:string) as element() {
    
    let $tei := translations:work-tei($work)
    
    let $translated-statuses := $tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('translated')]/@status-id
    let $in-translation-statuses := $tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('in-translation')]/@status-id
    let $all-statuses := $tei-content:text-statuses/m:status[@type eq 'translation'][@group = ('published','translated', 'in-translation')]/@status-id
    
    let $published-fileDesc := $tei/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translation:published-status-ids]]
    let $translated-fileDesc := $tei/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translated-statuses]]
    let $in-translation-fileDesc := $tei/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $in-translation-statuses]]
    let $commissioned-fileDesc := $tei/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $all-statuses]]
    let $sponsorship-text-ids := sponsorship:text-ids('sponsored')
    let $sponsored-fileDesc := $tei/tei:teiHeader/tei:fileDesc/id($sponsorship-text-ids)/ancestor::tei:fileDesc(:tei:publicationStmt[tei:idno/@xml:id = $sponsorship-text-ids]:)
    
    let $all-text-count := count($tei/tei:teiHeader/tei:fileDesc)
    let $commissioned-text-count := count($commissioned-fileDesc)
    let $not-started-text-count := $all-text-count - $commissioned-text-count
    
    let $all-text-page-count := sum($tei//tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.))
    let $commissioned-text-page-count := sum($commissioned-fileDesc/tei:sourceDesc/tei:bibl[1]/tei:location/@count-pages ! common:integer(.))
    let $not-started-text-page-count := $all-text-page-count - $commissioned-text-page-count
    
    let $all-toh-count := count($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl)
    let $commissioned-toh-count := count($commissioned-fileDesc/tei:sourceDesc/tei:bibl)
    let $not-started-toh-count := $all-toh-count - $commissioned-toh-count
    
    let $all-toh-page-count := sum($tei//tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
    let $commissioned-toh-page-count := sum($commissioned-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
    let $not-started-toh-page-count := $all-toh-page-count - $commissioned-toh-page-count
    
    (: Current the ekangyur doesn't represent the entire scope of Kangur pages we intend to translate, so we need to increase the totals :)
    let $additional-pages := 
        if($work eq $source:ekangyur-work) then
            $translations:total-kangyur-pages - $all-toh-page-count
        else
            0
    
    let $all-text-page-count := 
        if($work eq $source:ekangyur-work) then
            $all-text-page-count + $additional-pages
        else
            $all-text-page-count
            
    let $all-toh-page-count := 
        if($work eq $source:ekangyur-work) then
            $translations:total-kangyur-pages
        else
            $all-toh-page-count
    
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

declare function translations:texts($status as xs:string*, $resource-ids as xs:string*, $sort as xs:string, $deduplicate as xs:string, $include-downloads as xs:string, $include-folios as xs:boolean) as element(m:texts) {
    
    let $teis := $tei-content:translations-collection//tei:TEI
    
    let $teis :=
        if(count($status[not(. = '')]) gt 0) then
            $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $status]]
        else
            $teis
    
    let $teis :=
        if(count($resource-ids[not(. = '')]) gt 0) then (
            $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = $resource-ids]]
            | $teis[tei:teiHeader/tei:fileDesc/tei:sourceDesc[tei:bibl[@key = $resource-ids]]]
        )
        else
            $teis
    
    let $texts := 
        for $tei in $teis
            let $translation-status-group := tei-content:translation-status-group($tei)
            let $include-downloads := if ($include-downloads eq '' and $translation-status-group eq 'published') then 'all' else $include-downloads
            (: If $sort = 'persist' then sort based on the $resource-ids :)
        return
            if($deduplicate = ('text', 'sponsorship')) then
                translations:filtered-text($tei, '', false(), $include-downloads, $include-folios)
            else
                for $bibl in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                return
                    translations:filtered-text($tei, $bibl/@key, false(), $include-downloads, $include-folios)
    
    return
    
        element { QName('http://read.84000.co/ns/1.0', 'texts') } {
            
            attribute status { string-join($status, ',') },
            attribute resource-ids { string-join($resource-ids, ',') },
            attribute sort { $sort },
            attribute deduplicate { $deduplicate },
            
            (: Sort the result, the sort may be based on the text detail :)
            translations:sorted-texts($texts, $sort)
            
        }

};

declare function translations:filtered-texts(
        $work as xs:string, $status as xs:string*, $sort as xs:string, $pages-min as xs:string, $pages-max as xs:string, 
        $filter as xs:string, $toh-min as xs:string, $toh-max as xs:string, $deduplicate as xs:string, $status-date-start as xs:string, $status-date-end as xs:string
    ) as element(m:texts)? {
    
    (: Status parameter :)
    let $selected-statuses := tei-content:text-statuses-selected($status, 'translation')/m:status
    
    (: Range parameter :)
    let $pages-min :=
        if(functx:is-a-number($pages-min)) then
            xs:integer($pages-min)
        else 0
    
    let $pages-upper := 10000
    let $pages-max :=
        if(functx:is-a-number($pages-max)) then
            xs:integer($pages-max)
        else
            $pages-upper
    
    (: Sponsorship filter :)
    let $selected-sponsorship-group := $sponsorship:sponsorship-groups/m:group[@id eq $filter]
    
    (: Entities filter :)
    let $selected-entities-group := if($filter = ('entities-missing', 'entities-flagged-attention')) then $filter else ''
    
    (: Toh range :)
    let $toh-min := 
        if(functx:is-a-number($toh-min)) then
            xs:integer($toh-min)
        else 0
    
    let $toh-max := 
        if(functx:is-a-number($toh-max)) then
            xs:integer($toh-max)
        else
            $toh-min
    
    (: Check there is some parameter set so we are not getting everything :)
    where 
        $selected-statuses[@selected eq 'selected'] 
        or $pages-min gt 0 
        or $pages-max lt $pages-upper 
        or $selected-sponsorship-group 
        or $selected-entities-group 
        or $toh-min gt 0
        or $status-date-start gt ''
        or $status-date-end gt ''
        
    return
        (: All tei in this section :)
        let $teis := translations:work-tei($work)
        
        let $teis := 
        
            (: Filter by status achieved date - NOTE: do not do normal status filter as status has a different function in this case :)
            if($status-date-start gt '' or $status-date-end gt '') then
                for $tei in $teis 
                    (: We must also weed out cases where the status goes backwards - therefore ignore statuses greater than the current :)
                    let $tei-status := $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status
                    let $tei-selected-status := $selected-statuses[@status-id eq $tei-status]
                    let $tei-selected-valid-status := $selected-statuses[@selected eq 'selected'][@index ! xs:integer(.) le $tei-selected-status/@index ! xs:integer(.)]
                where 
                    $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note
                        [@update eq 'translation-status']
                        [if($status-date-start gt '') then (@date-time ! xs:dateTime(.) ge xs:dateTime(xs:date($status-date-start))) else true()]
                        [if($status-date-end gt '') then (@date-time ! xs:dateTime(.) le xs:dateTime(xs:date($status-date-end))) else true()]
                        [if($selected-statuses[@selected eq 'selected']) then (@value = $tei-selected-valid-status/@status-id) else true()]
                return
                    $tei
            
            (: Filter by current status :)
            else if($selected-statuses[@selected eq 'selected'] ) then
                (
                    (: Add tei with selected statuses :)
                    let $selected-status-ids := $selected-statuses[@selected eq 'selected']/@status-id
                    return
                        $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $selected-status-ids]],
                    
                    (: If status 0 (not started) is selected then add also @status = '' and not(@status) :)
                    if(functx:is-value-in-sequence('0', $status)) then
                        $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = ('', '0') or not(@status)]]
                    else ()
                )
                
            else
                $teis
        
        (: Filter by page sizes :)
        let $teis :=
            if($pages-min gt 0 or $pages-max lt $pages-upper) then
            
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
                            xs:integer($count-pages) ge $pages-min
                            and xs:integer($count-pages) le $pages-max
                        
                    return
                        $tei
                else
                    $teis[
                        tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
                            [tei:location/@count-pages gt '0']/tei:location[@count-pages >= $pages-min][@count-pages <= $pages-max]
                    ]
            else
                $teis
        
        (: Filter :)
        let $teis := 
            (: All tei WITHOUT sponsorship :)
            if($selected-sponsorship-group/@id = 'no-status')then
                let $sponsorship-group-text-ids := sponsorship:text-ids('all')
                let $sponsorship-group-teis := $teis/id($sponsorship-group-text-ids)/self::tei:idno/ancestor::tei:TEI
                return
                    $teis except $sponsorship-group-teis
                    
            (: With the selected sponsorship group :)
            else if($selected-sponsorship-group) then
                let $sponsorship-group-text-ids := sponsorship:text-ids($selected-sponsorship-group/@id)
                return
                    $teis/id($sponsorship-group-text-ids)/ancestor::tei:TEI
            
            (: Has glossaries missing entities :)
            else if($selected-entities-group eq 'entities-missing') then
                let $instance-ids := $entities:entities//m:entity/m:instance/@id
                let $glosses-with-entities := $teis/id($instance-ids)
                return 
                    $teis[tei:text/tei:back//tei:gloss[not(@mode eq 'surfeit')] except $glosses-with-entities]
                
            (: Has glossaries requiring attention :)
            else if($selected-entities-group eq 'entities-flagged-attention') then
                let $instances-requiring-attention := $entities:entities//m:instance[m:flag/@type = 'requires-attention']
                return
                    $teis/id($instances-requiring-attention/@id/string())/ancestor::tei:TEI
                
            (: Get them all :)
            else
                $teis
        
        (: Filter by Toh:)
        let $teis :=
            if($toh-min gt 0) then
                for $tei in $teis
                    let $toh-in-range :=
                        for $toh-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                            let $toh := translation:toh($tei, $toh-key)
                            let $toh-number := $toh/@number ! xs:integer(.)
                        where $toh-number ge $toh-min and $toh-number le $toh-max
                        return
                            $toh
                    where $toh-in-range
                return $tei
            else
                $teis
        
        (: Include sponsors? :)
        let $include-sponsors := not(empty($selected-sponsorship-group))
        
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
        
        (: Max 1024 results in a set - this is an underlying restriction in eXist :)
        let $texts :=
            if(count($texts) gt 1024) then
                subsequence($texts, 1, 1024)
            else
                $texts
        
        return 
            element { QName('http://read.84000.co/ns/1.0', 'texts') } {
            
                attribute work { $work },
                attribute status { string-join($status, ',') },
                attribute sort { $sort },
                attribute pages-min { $pages-min },
                attribute pages-max { $pages-max },
                attribute filter { $filter },
                attribute toh-min { $toh-min },
                attribute toh-max { $toh-max },
                attribute deduplicate { $deduplicate },
                attribute status-date-start { $status-date-start },
                attribute status-date-end { $status-date-end },
                
                (: Sort the result, the sort may be based on the text detail :)
                translations:sorted-texts($texts, $sort)
                
            }
};

declare function translations:sorted-texts($texts as element(m:text)*, $sort as xs:string) as element(m:text)* {
    
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
                if ($text/@status = $tei-content:text-statuses/m:status[@type eq 'translation'][not(@status-id = ('0'))]/@status-id) then $text/@status else '4',
                xs:integer($text/m:toh/@number), 
                $text/m:toh/@letter, 
                if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 9999, 
                $text/m:toh/@chapter-letter
        return $text
    
    else if($sort eq 'longest') then
        for $text in $texts
            order by if(functx:is-a-number($text/m:source/m:location/@count-pages)) then xs:integer($text/m:source/m:location/@count-pages) else 1 descending
        return $text
    
    else if($sort eq 'shortest') then
        for $text in $texts
            order by if(functx:is-a-number($text/m:source/m:location/@count-pages)) then xs:integer($text/m:source/m:location/@count-pages) else 1
        return $text
    
    else if($sort eq 'publication-date') then
        for $text in $texts
            order by ($text//m:publication/m:publication-date, current-date())[1] ascending
        return $text
    
    else
        $texts
};

declare function translations:filtered-text($tei as element(tei:TEI), $toh-key as xs:string, $include-sponsors as xs:boolean, $include-downloads as xs:string, $include-folios as xs:boolean) as element(){
    
    let $text-id := tei-content:id($tei)
    let $lang := request:get-parameter('lang', 'en')
    let $toh := translation:toh($tei, $toh-key)
    let $document-url := tei-content:document-url($tei)
    let $file-name := util:unescape-uri(replace($document-url, ".+/(.+)$", "$1"), 'UTF-8')
    let $document-path := substring-before($document-url, concat('/', $file-name))
    let $archive-path := 
        if(contains($document-path, $common:archive-path)) then
            substring-after($document-path, concat($common:archive-path, '/'))
        else ''
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'text') } {
            attribute id { $text-id }, 
            attribute document-url { $document-url },
            attribute file-name { $file-name },
            attribute archive-path { $archive-path },
            attribute last-modified { tei-content:last-modified($tei) },
            attribute locked-by-user { tei-content:locked-by-user($tei) },
            attribute page-url { translation:canonical-html($toh/@key, $archive-path) },
            attribute status { tei-content:translation-status($tei) },
            attribute status-group { tei-content:translation-status-group($tei) },
            $toh,
            translation:titles($tei),
            translation:title-variants($tei),
            (:tei-content:source-bibl($tei, $toh-key),:)
            tei-content:source($tei, $toh-key),
            translation:location($tei, $toh-key),
            tei-content:ancestors($tei, $toh-key, 0),
            translation:publication($tei),
            translation:contributors($tei, false()),
            translation:summary($tei, 'show', (), $lang),
            tei-content:status-updates($tei),
            sponsorship:text-status($text-id, false()),
            if($include-sponsors) then
                translation:sponsors($tei, true())
            else (),
            translation:downloads($tei, $toh/@key, $include-downloads),
            if($include-folios) then
                translation:folios($tei, $toh-key)
            else ()
        }
};

declare function translations:versioned($include-downloads as xs:string, $include-folios as xs:boolean) as element() {

    let $translations := $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/text()]
    
    return
        <translations xmlns="http://read.84000.co/ns/1.0">
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
        for $tei in $tei-content:translations-collection//tei:teiHeader//tei:titleStmt[tei:sponsor]/ancestor::tei:TEI
        return
            translations:filtered-text($tei, '', true(), '', false())
    }
    </sponsored-texts>

};

declare function translations:sponsorship-texts() as element() {
    
    <sponsorship-texts xmlns="http://read.84000.co/ns/1.0">
    {
        let $available-sponsorship-ids := sponsorship:text-ids('available')
        for $tei in $tei-content:translations-collection//tei:teiHeader//tei:idno/id($available-sponsorship-ids)/ancestor::tei:TEI
        return
            translations:filtered-text($tei, '', false(), '', false())
    }
    </sponsorship-texts>

};

declare function translations:translation-status-texts($status as xs:string*) as element() {
    
    <translation-status-texts xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $status]]
            for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        return
            translations:filtered-text($tei, $toh-key, false(), '', false())
    }
    </translation-status-texts>

};

declare function translations:downloads($resource-ids as xs:string*) as element() {

    <translations xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in 
            if($resource-ids = 'versioned') then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition[text()]]
            else if($resource-ids = 'translations') then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $translation:marked-up-status-ids]]
            else if($resource-ids = 'placeholders') then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc[tei:publicationStmt[not(@status = $translation:marked-up-status-ids)]][tei:editionStmt/tei:edition[text()]]]
            else if(count($resource-ids) gt 0) then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key = $resource-ids]]
            else ()
        
        let $text-id := tei-content:id($tei)
        where $text-id
        return
            element { QName('http://read.84000.co/ns/1.0', 'text') }{
                attribute id { $text-id }, 
                attribute document-url { tei-content:document-url($tei) },
                attribute locked-by-user { tei-content:locked-by-user($tei) },
                attribute file-name { util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') },
                attribute translation-status { tei-content:translation-status($tei) },
                for $resource-id in 
                    if($resource-ids = ('versioned', 'translations', 'placeholders')) then
                        $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                    else
                        $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key = $resource-ids]/@key
                return
                    translation:downloads($tei, $resource-id, 'all'),
                    tei-content:status-updates($tei)
            }
    }
    </translations>
    
};

declare function translations:recent-updates() as element(m:recent-updates) {
    
    element { QName('http://read.84000.co/ns/1.0', 'recent-updates') } {
        
        (: Get updates in given span :)
        let $start-time := current-dateTime() - xs:yearMonthDuration('P1M')
        let $end-time := current-dateTime()
        return (
            
            attribute start {$start-time},
            attribute end {$end-time},
        
            for $tei in $tei-content:translations-collection//tei:TEI
            (: get notes :)
            let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
            let $notes := $fileDesc/tei:notesStmt/tei:note
            let $translation-status := tei-content:translation-status($tei)
            
            let $notes-in-span := $notes[@type eq "updated"][xs:dateTime(@date-time) ge $start-time][xs:dateTime(@date-time) le $end-time]
            
            where 
                $notes-in-span[@update eq 'translation-status'][@value = ('1', '1.a')]
                or ($translation-status = ('1', '1.a') and $notes-in-span[@update eq 'text-version'])
            
            return 
                element { QName('http://read.84000.co/ns/1.0', 'text') }{
                    attribute id { tei-content:id($tei) }, 
                    attribute last-modified { tei-content:last-modified($tei) },
                    attribute status { tei-content:translation-status($tei) },
                    attribute status-group { tei-content:translation-status-group($tei) },
                    attribute recent-update { if($notes-in-span[@update eq 'translation-status'][@value = ('1', '1.a')]) then 'new-publication' else 'new-version' },
                    translation:titles($tei),
                    for $bibl in $fileDesc/tei:sourceDesc/tei:bibl
                    return
                        translation:toh($tei, $bibl/@key)
                    ,
                    
                    let $notes-in-span-sorted :=
                        for $note in 
                            if($notes-in-span[@update eq 'translation-status'][@value = ('1', '1.a')]) then
                                $notes-in-span[@update eq 'translation-status'][@value = ('1', '1.a')]
                            else
                                $notes-in-span[@update eq 'text-version']
                        order by $note/@date-time ! xs:dateTime(.)
                        return $note
                        
                    return
                        $notes-in-span-sorted[last()]
                        
                }
        )
    }
    
};

declare function translations:texts-spreadsheet($response as element(m:response)) as element(m:spreadsheet-data) {

    element { QName('http://read.84000.co/ns/1.0', 'spreadsheet-data') } {
    
        attribute key { concat('84000-report-', format-dateTime(current-dateTime(), '[H01]-[m01]-[D01]-[M01]-[Y0001]'))},
        
        for $text in $response/m:texts/m:text
        let $next-target := $response/m:translation-status/m:text[@text-id eq $text/@id]/m:target-date[@next eq 'true']
        order by
            $text/m:toh[1]/@number[. gt ''] ! xs:integer(.),
            $text/m:toh[1]/@chapter-number[. gt ''] ! xs:integer(.)
        return 
            element row {
                element ID { 
                    $text/@id/string() 
                },
                element Toh { 
                    attribute width { '10' },
                    string-join($text/m:toh/m:base, ' ') 
                },
                element Status { 
                    attribute width { '10' },
                    $text/@status/string() 
                },
                element Pages { 
                    attribute width { '10' },
                    attribute type { 'number' },
                    $text/m:source/m:location/@count-pages/string() 
                },
                element Title { 
                    attribute width { '80' },
                    $text/m:titles/m:title[1]/text() 
                },
                element Team { 
                    attribute width { '60' },
                    $text/m:contributors/m:team[1]/m:label/text()
                },
                element Target { 
                    attribute width { '10' },
                    $next-target/@status-id/string() 
                },
                element Target_Date { 
                    $next-target/@date-time ! format-dateTime(., '[D01]-[M01]-[Y0001]') 
                },
                element Published {
                    if($text/@status/string() = $translation:published-status-ids) then
                        $text/m:publication/m:publication-date[. gt ''] ! format-date(., '[D01]-[M01]-[Y0001]')
                    else ()
                }
            }
        ,
        element row {
            element empty { '' }
        },
        element row {
            element parameters { 'Parameters' }
        },
        for $attribute in $response/m:request/@*[string() gt '']
        return
            element row {
                element parameter { local-name($attribute) },
                element value { $attribute/string() }
            }
    }
};

declare function translations:recent-updates-spreadsheet($recent-updates as element(m:recent-updates)) as element(m:spreadsheet-data) {

    element { QName('http://read.84000.co/ns/1.0', 'spreadsheet-data') } {
    
        attribute key { concat('84000-recent-updates-', format-dateTime($recent-updates/@start, '[D01]-[M01]-[Y0001]'), '-', format-dateTime($recent-updates/@end, '[D01]-[M01]-[Y0001]'))},
        
        for $text in $recent-updates//m:text
        order by 
            if($text/@recent-update eq 'new-publication') then '0' else '1',
            $text/m:toh[1]/@number[. gt ''] ! xs:integer(.),
            $text/m:toh[1]/@chapter-number[. gt ''] ! xs:integer(.)
        return
            element row {
                element Update { $text/@recent-update/string() },
                element ID { $text/@id/string() },
                element Toh { 
                    attribute width { '10' },
                    string-join($text/m:toh/m:base, ' ') 
                },
                element Title { 
                    attribute width { '80' },
                    $text/m:titles/m:title[1]/text() 
                },
                element Updated { $text/@last-modified ! format-dateTime(., '[D01]-[M01]-[Y0001]') },
                element Version { string-join($text/tei:note[@update="text-version"]/@value, ' ') },
                element Note {
                    attribute width { '80' }, 
                    string-join($text/tei:note[@update="text-version"]/descendant::text(), ' ') 
                }
            }
        ,
        element row {
            element empty { '' }
        },
        element row {
            element parameters { 'Parameters' }
        },
        element row {
            element parameter { 'Start date' },
            element value { format-dateTime($recent-updates/@start, '[D1o] [MNn] [Y0001]') }
        },
        element row {
            element parameter { 'End date' },
            element value { format-dateTime($recent-updates/@end, '[D1o] [MNn] [Y0001]') }
        }
    }
    
};
