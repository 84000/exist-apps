xquery version "3.1";

module namespace translations="http://read.84000.co/translations";

declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace webflow="http://read.84000.co/webflow-api";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "sponsorship.xql";
import module namespace source="http://read.84000.co/source" at "source.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace store="http://read.84000.co/store" at "store.xql";
import module namespace functx="http://www.functx.com";

declare variable $translations:total-kangyur-pages as xs:integer := 70000;
declare variable $translations:webflow-collection := doc(string-join(($common:data-path, 'local', 'webflow-api.xml'),'/'))//webflow:collection[@id eq 'texts'];

(:declare variable $translations:page-size-ranges := doc(concat($common:app-config, '/', 'page-size-ranges.xml'));:)

declare function translations:work-tei($work as xs:string) as element(tei:TEI)* {

    if($work eq 'all') then
        $tei-content:translations-collection//tei:TEI
    else if($work = ($source:kangyur-work, $source:tengyur-work)) then
        $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location[@work = $work]]
    else ()
    
};

declare function translations:files($publication-statuses as xs:string*) as element(m:translations) {

    element { QName('http://read.84000.co/ns/1.0', 'translations') }{
    
        for $tei in $tei-content:translations-collection//tei:fileDesc/tei:publicationStmt/tei:availability[@status = $publication-statuses]/ancestor::tei:TEI
            let $base-uri := base-uri($tei)
            let $file-name := util:unescape-uri(replace($base-uri, ".+/(.+)$", "$1"), 'UTF-8')
            order by $file-name
        return
            element file {
                attribute id { tei-content:id($tei) },
                attribute document-url { $base-uri },
                attribute file-name { $file-name },
                concat(string-join($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:ref, ' / '), ' - ', tei-content:title-any($tei))
            }
            
    }
    
};

declare function translations:texts($status as xs:string*, $resource-ids as xs:string*, $sort as xs:string, $deduplicate as xs:string, $include-downloads as xs:string, $include-folios as xs:boolean) as element(m:texts) {
    
    let $teis := $tei-content:translations-collection//tei:TEI
    
    let $teis :=
        if(count($status[not(. = '')]) gt 0) then
            $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[@status = $status]]
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
            let $publication-status-group := tei-content:publication-status-group($tei)
            let $include-downloads := if ($include-downloads eq '' and $publication-status-group eq 'published') then 'all' else $include-downloads
            (: If $sort = 'persist' then sort based on the $resource-ids :)
        return
            if($deduplicate = ('text', 'sponsorship')) then
                translations:filtered-text($tei, '', false(), $include-downloads, $include-folios)
            else
                for $bibl in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key]
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
    let $selected-sponsorship-filter := $sponsorship:sponsorship-groups/m:group[@id eq $filter]
    
    (: Entities filter :)
    let $selected-entities-filter := $filter[. = ('entities-missing', 'entities-flagged-attention', 'using-entity-definition')]
    
    (: Published files filter :)
    let $selected-published-filter := $filter[. = ('published-files-status', 'published-files-version', 'published-files-timestamp')]
    
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
        or $selected-sponsorship-filter 
        or $selected-entities-filter 
        or $selected-published-filter
        or $toh-max gt 0
        or $status-date-start gt ''
        or $status-date-end gt ''
    
    return
        (: All tei in this section :)
        let $teis := translations:work-tei($work)
        
        let $teis := 
        
            (: Filter by status achieved date - NOTE: do not do normal status filter as status has a different function in this case :)
            if($status-date-start gt '' or $status-date-end gt '') then
                for $tei in $teis 
                    (: We must also account for cases where the status goes backwards - therefore ignore statuses greater than the current :)
                    let $tei-status := $tei//tei:publicationStmt/tei:availability/@status
                    let $tei-selected-status := $selected-statuses[@status-id eq $tei-status]
                    let $tei-selected-valid-status := $selected-statuses[@selected eq 'selected'][@index ! xs:integer(.) ge $tei-selected-status/@index ! xs:integer(.)]
                where 
                    $tei//tei:revisionDesc/tei:change
                        [@type = ('translation-status', 'publication-status')]
                        [if($status-date-start gt '') then (@when ! xs:dateTime(.) ge xs:dateTime(xs:date($status-date-start))) else true()]
                        [if($status-date-end gt '') then (@when ! xs:dateTime(.) le xs:dateTime(xs:date($status-date-end))) else true()]
                        [if($selected-statuses[@selected eq 'selected']) then (@status = $tei-selected-valid-status/@status-id) else true()]
                return
                    $tei
            
            (: Filter by current status :)
            else if($selected-statuses[@selected eq 'selected'] ) then (
            
                (: Add tei with selected statuses :)
                let $selected-status-ids := $selected-statuses[@selected eq 'selected']/@status-id
                return
                    $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[@status = $selected-status-ids]]
                    | $teis[tei:teiHeader//tei:bibl[@type eq 'translation-blocks']/tei:citedRange[@status = $selected-status-ids]]
                ,
                
                (: If status 0 (not started) is selected then add also @status = '' and not(@status) :)
                if(functx:is-value-in-sequence('0', $status)) then
                    $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[@status = ('', '0') or not(@status)]]
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
                                $tei//tei:sourceDesc/tei:bibl/tei:location[$work eq 'all' or @work eq $work][1]/@count-pages
                                
                        where 
                            xs:integer($count-pages) ge $pages-min
                            and xs:integer($count-pages) le $pages-max
                        
                    return
                        $tei
                else
                    $teis[
                        tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location[$work eq 'all' or @work eq $work][@count-pages ! xs:integer(.) ge $pages-min][@count-pages ! xs:integer(.) le $pages-max]
                    ]
            else
                $teis
        
        (: Filter :)
        let $teis := 
            (: All tei WITHOUT sponsorship :)
            if($selected-sponsorship-filter/@id = 'no-status')then
                let $sponsorship-filter-text-ids := sponsorship:text-ids('all')
                let $sponsorship-filter-teis := $teis/id($sponsorship-filter-text-ids)/self::tei:idno/ancestor::tei:TEI
                return
                    $teis except $sponsorship-filter-teis
            
            (: With the selected sponsorship group :)
            else if($selected-sponsorship-filter) then
                let $sponsorship-filter-text-ids := sponsorship:text-ids($selected-sponsorship-filter/@id)
                return
                    $teis/id($sponsorship-filter-text-ids)/ancestor::tei:TEI
            
            (: Has glossaries missing entities :)
            else if($selected-entities-filter eq 'entities-missing') then
                let $instance-ids := $entities:entities//m:entity/m:instance/@id
                let $glosses-with-entities := $teis/id($instance-ids)
                return 
                    $teis[tei:text/tei:back//tei:gloss[not(@mode eq 'surfeit')] except $glosses-with-entities]
            
            (: Has glossaries requiring attention :)
            else if($selected-entities-filter eq 'entities-flagged-attention') then
                let $instances-requiring-attention := $entities:entities//m:instance[m:flag/@type = 'requires-attention']
                return
                    $teis/id($instances-requiring-attention/@id/string())/ancestor::tei:TEI
            
            (: Published files statuses are other than the TEI status :)
            else if($selected-published-filter = ('published-files-status', 'published-files-version', 'published-files-timestamp')) then
    
                for $tei in $teis[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability]
                let $file-mismatches := local:file-mismatches($tei, $selected-published-filter)
                where 
                    $file-mismatches
                return
                    $tei
            
            (: Return them all :)
            else
                $teis
        
        (: Filter by Toh:)
        let $teis :=
            if($toh-max gt 0) then
                for $tei in $teis
                    let $toh-in-range :=
                        for $toh-key in $tei//tei:sourceDesc/tei:bibl[tei:location[$work eq 'all' or @work eq $work]]/@key
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
        let $include-sponsors := not(empty($selected-sponsorship-filter))
        
        (: Return result per Toh or per text :)
        let $texts := 
            for $tei in $teis
            let $publication-status := tei-content:publication-status($tei)
            (:let $include-downloads := if ($common:environment/m:render/m:status[@type eq 'translation'][@status-id eq $publication-status]) then 'all' else '':)
            return
                if($deduplicate = ('text', 'sponsorship')) then
                    translations:filtered-text($tei, '', $include-sponsors, 'all', false())
                else
                    for $bibl in $tei//tei:sourceDesc/tei:bibl[tei:location[$work eq 'all' or @work eq $work]]
                    return
                        translations:filtered-text($tei, $bibl/@key, $include-sponsors, 'all', false())
        
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

declare function local:file-mismatches($tei as element(tei:TEI), $selected-published-filter as xs:string){

    let $text-id := tei-content:id($tei)
    let $source-keys := $tei//tei:sourceDesc/tei:bibl/@key
    let $tei-status := $tei//tei:publicationStmt/tei:availability/@status
    let $tei-version := tei-content:version-str($tei)
    let $tei-timestamp := tei-content:last-modified($tei)
    let $file-name-variants := 
        for $resource-id in ($text-id, $source-keys)
        return
            for $file-type in ('pdf', 'epub', 'rdf', 'xml', 'json')
            return
                string-join(($resource-id, $file-type), '.')
    let $file-name-regex := concat('^(',string-join(($text-id, $source-keys) ! functx:escape-for-regex(.), '|'),')\.')
    return (
        if($selected-published-filter eq 'published-files-status') then (
            $store:file-versions/m:file-version[range:field('file-version-name', 'eq', $file-name-variants)][not(range:field('file-version-status', 'eq', $tei-status))],
            $translations:webflow-collection/webflow:item[range:field('webflow-item-id', 'eq', $source-keys)][not(range:field('webflow-item-status', 'eq', $tei-status))]
        )
        else if($selected-published-filter eq 'published-files-version') then (
            $store:file-versions/m:file-version[range:field('file-version-name', 'eq', $file-name-variants)][not(range:field('file-version-version', 'eq', $tei-version))],
            $translations:webflow-collection/webflow:item[range:field('webflow-item-id', 'eq', $source-keys)][not(range:field('webflow-item-version', 'eq', $tei-version))]
        )
        else if($selected-published-filter eq 'published-files-timestamp') then (
            $store:file-versions/m:file-version[range:field('file-version-name', 'eq', $file-name-variants)][range:field('file-version-timestamp', 'lt', $tei-timestamp)],
            $translations:webflow-collection/webflow:item[range:field('webflow-item-id', 'eq', $source-keys)][range:field('webflow-item-timestamp', 'lt', $tei-timestamp)]
        )
        else ()
    )
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
    let $document-url := base-uri($tei)
    let $file-name := util:unescape-uri(replace($document-url, ".+/(.+)$", "$1"), 'UTF-8')
    let $document-path := substring-before($document-url, concat('/', $file-name))
    let $archive-path := 
        if(contains($document-path, $common:archive-path)) then
            substring-after($document-path, concat($common:archive-path, '/'))[. gt '']
        else ()
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'text') } {
            attribute id { $text-id }, 
            attribute document-url { $document-url },
            attribute resource-type { 'translation' },
            attribute file-name { $file-name },
            attribute archive-path { $archive-path },
            attribute last-modified { tei-content:last-modified($tei) },
            attribute locked-by-user { tei-content:locked-by-user($tei) },
            (:attribute page-url { translation:canonical-html($toh/@key, $archive-path ! concat('id=', .)) },:)
            attribute status { tei-content:publication-status($tei) },
            attribute status-group { tei-content:publication-status-group($tei) },
            $toh,
            tei-content:source($tei, $toh-key),
            tei-content:ancestors($tei, $toh-key, 0),
            translation:titles($tei, $toh/@key),
            translation:title-variants($tei, $toh/@key),
            translation:publication($tei),
            translation:publication-status($tei//tei:sourceDesc/tei:bibl[@key eq $toh/@key], ()),
            translation:contributors($tei, false()),
            translation:summary($tei, 'show', (), $lang),
            tei-content:status-updates($tei),
            translation:downloads($tei, $toh/@key, $include-downloads),
            translation:api-status($tei),
            sponsorship:text-status($text-id, false()),
            if($include-sponsors) then
                translation:sponsors($tei, true())
            else (),
            if($include-folios) then
                translation:folios($tei, $toh-key)
            else ()
        }
};

declare function translations:versioned($include-downloads as xs:string, $include-folios as xs:boolean) as element() {

    let $translations := $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/text()]
    
    return
        element { QName('http://read.84000.co/ns/1.0','translations') } {
            for $toh-key in $translations//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                let $tei := $translations[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($toh-key)]]
            return
                translations:filtered-text($tei, $toh-key, false(), $include-downloads, $include-folios)
        }
    
};

declare function translations:sponsored-texts() as element() {
    
    element { QName('http://read.84000.co/ns/1.0','sponsored-texts') } {
        for $tei in $tei-content:translations-collection//tei:teiHeader//tei:titleStmt[tei:sponsor]/ancestor::tei:TEI
        return
            translations:filtered-text($tei, '', true(), '', false())
    }

};

declare function translations:sponsorship-texts() as element() {
    
    element { QName('http://read.84000.co/ns/1.0','sponsorship-texts') } {
        let $available-sponsorship-ids := sponsorship:text-ids('available')
        for $tei in $tei-content:translations-collection//tei:teiHeader//tei:idno/id($available-sponsorship-ids)/ancestor::tei:TEI
        return
            translations:filtered-text($tei, '', false(), '', false())
    }

};

declare function translations:translation-status-texts($status as xs:string*) as element() {
    
    element { QName('http://read.84000.co/ns/1.0','translation-status-texts') } {
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[@status = $status]]
            for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        return
            translations:filtered-text($tei, $toh-key, false(), '', false())
    }

};

declare function translations:downloads($resource-ids as xs:string*) as element() {

    element { QName('http://read.84000.co/ns/1.0','translations') } {
        for $tei in 
            if($resource-ids = 'versioned') then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition[text()]]
            else if($resource-ids = 'translations') then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[@status = $translation:marked-up-status-ids]]
            else if($resource-ids = 'placeholders') then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:availability[not(@status = $translation:marked-up-status-ids)]][tei:editionStmt/tei:edition[text()]]]
            else if(count($resource-ids) gt 0) then
                $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key = $resource-ids]]
            else ()
        
        let $text-id := tei-content:id($tei)
        let $publication-status := tei-content:publication-status($tei)
        where $text-id
        return
            element { QName('http://read.84000.co/ns/1.0', 'text') }{
                attribute id { $text-id }, 
                attribute document-url { base-uri($tei) },
                attribute locked-by-user { tei-content:locked-by-user($tei) },
                attribute file-name { util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') },
                attribute publication-status { $publication-status },
                for $source-key in 
                    if($resource-ids = ('versioned', 'translations', 'placeholders')) then
                        $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                    else
                        $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key = $resource-ids]/@key
                return
                    translation:downloads($tei, $source-key, 'all')
                ,
                tei-content:status-updates($tei)
            }
    }
    
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
            
            (: get changes :)
            let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
            let $changes := $fileDesc/tei:revisionDesc/tei:change
            let $publication-status := tei-content:publication-status($tei)
            let $changes-in-span := $changes[xs:dateTime(@when) ge $start-time][xs:dateTime(@when) le $end-time]
            
            let $recent-update-type :=
                if($publication-status = $translation:published-status-ids and $changes-in-span[@type = ('translation-status', 'publication-status')][@status = $translation:published-status-ids]) then 
                    'new-publication'
                else if($publication-status = $translation:published-status-ids and $changes-in-span[@type eq 'text-version']) then 
                    'new-version'
                else ()
            
            where $recent-update-type = ('new-publication', 'new-version')
            return 
                element { QName('http://read.84000.co/ns/1.0', 'text') }{
                    attribute id { tei-content:id($tei) }, 
                    attribute last-modified { tei-content:last-modified($tei) },
                    attribute status { tei-content:publication-status($tei) },
                    attribute status-group { tei-content:publication-status-group($tei) },
                    attribute recent-update { $recent-update-type },
                    
                    translation:titles($tei, ()),
                    
                    for $bibl in $fileDesc/tei:sourceDesc/tei:bibl[@key]
                    return
                        translation:toh($tei, $bibl/@key)
                    ,
                    
                    let $changes-in-span-display := (
                        if($recent-update-type eq 'new-publication') then
                            $changes-in-span[@type = ('translation-status', 'publication-status')][@status = $translation:published-status-ids]
                        else if($recent-update-type eq 'new-version') then
                            $changes-in-span[@type eq 'text-version']
                        else()
                    )
                    
                    let $changes-in-span-sorted :=
                        for $change in $changes-in-span-display
                        order by $change/@date-time ! xs:dateTime(.)
                        return $change
                    return
                        $changes-in-span-sorted[last()]
                        
                }
        )
    }
    
};

declare function translations:texts-spreadsheet($response as element(m:response)) as element(m:spreadsheet-data) {
    
    let $text-statuses := $response/m:text-statuses/m:status
    let $selected-statuses := $text-statuses[@selected eq 'selected']
    let $status-date-start := $response/m:request/@target-date-start[not(. eq '')] ! xs:date(.) ! xs:dateTime(.)
    let $status-date-end := $response/m:request/@target-date-end[not(. eq '')] ! xs:date(.) ! xs:dateTime(.)
    let $target-date-type := $response/m:request/@target-date-type
    
    return
    element { QName('http://read.84000.co/ns/1.0', 'spreadsheet-data') } {
    
        attribute key { concat('84000-report-', format-dateTime(current-dateTime(), '[H01]-[m01]-[D01]-[M01]-[Y0001]'))},
        
        for $text in $response/m:texts/m:text
        
        let $next-target := $response/m:translation-status/m:text[@text-id eq $text/@id]/m:target-date[@next eq 'true']
        
        let $text-status-index := $text-statuses[@status-id eq $text/@status]/@index ! xs:integer(.)
        let $status-updates := $text/m:status-updates/m:status-update[@type = ('translation-status', 'publication-status')][empty($status-date-start) or @when ! xs:dateTime(.) ge $status-date-start][empty($status-date-end) or @when ! xs:dateTime(.) le $status-date-end][empty($selected-statuses) or @status = $selected-statuses[@index ! xs:integer(.) ge $text-status-index]/@status-id]
        let $status-updates-block-ids := $status-updates/@target ! replace(., '^#', '')
        
        let $text-pages := $text/m:source/m:location/@count-pages ! xs:integer(.)
        let $status-pages := 
            if($selected-statuses and $target-date-type eq 'status-date' and (not(empty($status-date-start)) or not(empty($status-date-end)))) then
                sum($text/m:publication-status[@block-id = ($status-updates-block-ids, $text/@id)]/@count-pages ! xs:integer(.))
            else 
                sum($text/m:publication-status[@status = $selected-statuses/@status-id]/@count-pages ! xs:integer(.))
        
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
                    if($status-pages) then
                        $status-pages
                    else
                        $text-pages
                },
                element Title { 
                    attribute width { '80' },
                    $text/m:titles/m:title[1]/text() 
                },
                element Wylie_Title { 
                    attribute width { '50' },
                    $text/m:titles/m:title[@xml:lang eq 'Bo-Ltn'][1]/text() 
                },
                element Sanskrit_Title { 
                    attribute width { '50' },
                    $text/m:titles/m:title[@xml:lang eq 'Sa-Ltn'][1]/text() 
                },
                element Team { 
                    attribute width { '50' },
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
                element Version { string-join($text/tei:change[@type eq "text-version"]/@status, '; ') },
                element Note {
                    attribute width { '80' }, 
                    string-join($text/tei:change[@type eq "text-version"]/descendant::text()[normalize-space()] ! normalize-space(), ' ') 
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
