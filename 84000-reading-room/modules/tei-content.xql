xquery version "3.1";

module namespace tei-content="http://read.84000.co/tei-content";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";

declare variable $tei-content:translations-collection := collection($common:translations-path);
declare variable $tei-content:sections-collection := collection($common:sections-path);
declare variable $tei-content:knowledgebase-collection := collection($common:knowledgebase-path);

declare variable $tei-content:text-statuses := 
    <text-statuses xmlns="http://read.84000.co/ns/1.0">
        <!-- Translation statuses -->
        <status type="translation"  status-id="0"    group="not-started"                                         >Not started</status>
        <status type="translation"  status-id="1"    group="published"      marked-up="true"  target-date="true" >Published, and included in the app</status>
        <status type="translation"  status-id="1.a"  group="published"      marked-up="true"  target-date="true" >Published</status>
        <status type="translation"  status-id="2"    group="translated"     marked-up="true"  target-date="true" >Marked up, awaiting final proofing</status>
        <status type="translation"  status-id="2.a"  group="translated"     marked-up="true"                     >Markup in process</status>
        <status type="translation"  status-id="2.b"  group="translated"                       target-date="true" >Awaiting markup</status>
        <status type="translation"  status-id="2.c"  group="translated"                                          >Awaiting editor's OK for markup</status>
        <status type="translation"  status-id="2.d"  group="translated"                       target-date="true" >Copyediting complete. Preparation for markup</status>
        <status type="translation"  status-id="2.e"  group="translated"                                          >Being copyedited</status>
        <status type="translation"  status-id="2.f"  group="translated"                       target-date="true" >Review complete. Awaiting copyediting</status>
        <status type="translation"  status-id="2.g"  group="translated"                                          >In editorial review</status>
        <status type="translation"  status-id="2.h"  group="translated"                       target-date="true" >Awaiting review</status>
        <status type="translation"  status-id="3"    group="in-translation"                                      >Current translation projects</status>
        <status type="translation"  status-id="4"    group="in-application"                                      >Application pending</status>
        <!-- Article statuses -->
        <status type="article"      status-id="1"    group="published"      marked-up="true"                     >Published</status>
        <status type="article"      status-id="1.a"  group="published"      marked-up="true"                     >Published under revision</status>
        <status type="article"      status-id="2"    group="in-progress"    marked-up="true"                     >Proofreading</status>
        <status type="article"      status-id="2.a"  group="in-progress"    marked-up="true"                     >Final Review</status>
        <status type="article"      status-id="2.b"  group="in-progress"    marked-up="true"                     >Copyediting</status>
        <status type="article"      status-id="3"    group="not-started"    marked-up="true"                     >Stub</status>
    </text-statuses>;

declare variable $tei-content:title-types :=
    <title-types xmlns="http://read.84000.co/ns/1.0">
        <title-type id="mainTitle">Main</title-type>
        <title-type id="longTitle">Long</title-type>
        <title-type id="otherTitle">Other</title-type>
    </title-types>;

declare function tei-content:id($tei as element(tei:TEI)) as xs:string {
    (: Returns the idno in a given tei doc :)
    $tei//tei:publicationStmt/tei:idno[@xml:id][1]/@xml:id
};

declare function tei-content:type($tei as element(tei:TEI)) as xs:string {
    
    if($tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@m:kb-id]) then
        'knowledgebase'
    else if($tei/tei:teiHeader/tei:fileDesc/@type = ('section', 'grouping')) then 
        'section'
    else
        'translation'
    
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string) as element(tei:TEI)? {
    tei-content:tei($resource-id, $resource-type, '')
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string, $archive-path as xs:string?) as element(tei:TEI)? {

    let $collection := 
        (: Layout checks :)
        if(lower-case($resource-id) = ('toh00', 'ut22084-000-000', 'toh00c', 'ut23703-000-000')) then
            collection(concat($common:data-path, '/tei/layout-checks'))
        
        (: Archived copy :)
        else if($archive-path gt '') then
            collection(concat($common:archive-path, '/', $archive-path))
        
        (: Section :)
        else if($resource-type = ('section', 'pseudo-section')) then
            $tei-content:sections-collection
        
        (: Knowledge base :)
        else if($resource-type eq 'knowledgebase') then
            $tei-content:knowledgebase-collection
        
        (: Default to translation :)
        else 
            $tei-content:translations-collection
    
    (: Lookup key :)
    let $resource-id-lowercase := lower-case($resource-id)
    let $tei := 
        if($resource-type eq 'translation') then
            $collection//tei:sourceDesc/tei:bibl[@key = $resource-id-lowercase][1]/ancestor::tei:TEI
        else if($resource-type eq 'knowledgebase') then
            $collection//tei:publicationStmt/tei:idno[@m:kb-id eq $resource-id-lowercase][1]/ancestor::tei:TEI
        else ()
    
    (: Fallback to UT number :)
    let $resource-id-uppercase := upper-case($resource-id)
    let $tei := 
        if(not($tei)) then
            $collection//tei:publicationStmt/tei:idno/id($resource-id-uppercase)/ancestor::tei:TEI
        else $tei
        
    return $tei
    
};

declare function tei-content:title($tei as element(tei:TEI)) as xs:string? {
    (: Returns a standardised title in a given tei doc :)
    
    let $title := $tei//tei:titleStmt/tei:title[@xml:lang eq 'en'][normalize-space(text())]
    
    return
        if(not($title))then
            concat($tei//tei:titleStmt/tei:title[@xml:lang eq 'Sa-Ltn'][normalize-space(text())][1] ! normalize-space(text()), ' (awaiting English title)')
        else
            $title[1] ! normalize-space(text())
    
};

declare function tei-content:title($tei as node(), $type as xs:string?, $lang as xs:string*) as xs:string? {
    
    $tei//tei:fileDesc/tei:titleStmt/tei:title[@xml:lang = $lang][@type eq $type][normalize-space(text())][1] ! normalize-space(text())
    
};

declare function tei-content:titles($tei as element(tei:TEI)) as element(m:titles) {

    element { QName('http://read.84000.co/ns/1.0', 'titles') } {
        for $title in $tei//tei:fileDesc/tei:titleStmt/tei:title
        return
            element title {
                $title/@*,
                $title/text() ! normalize-space(.)
            }
        ,
        for $note in $tei//tei:fileDesc/tei:notesStmt/tei:note[@type = ('title','title-internal')]
        return
            element note {
                $note/@*,
                $note/text() ! normalize-space(.)
            }
    }
    
};

declare function tei-content:title-set($tei as element(tei:TEI), $type as xs:string) as element()* {
    
    let $titles := $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq $type][normalize-space(text())]
    
    let $source-bibl := tei-content:source-bibl($tei, '')
    
    let $en := $titles[@xml:lang = ('eng', 'en')][1]
    let $bo-ltn := $titles[@xml:lang = ('Bo-Ltn', '')][1]
    let $bo := $titles[@xml:lang eq 'bo'][1]
    let $sa-ltn := $titles[@xml:lang eq 'Sa-Ltn'][1]
    
    return (
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'en' },
            $en/@*[not(name(.) = ('xml:lang', 'type'))],
            $en/text() ! normalize-space(.)
        },
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'bo' },
            $en/@*[not(name(.) = ('xml:lang', 'type'))],
            if(not($bo/text()) and $bo-ltn/text()) then
                common:bo-from-wylie($bo-ltn/text() ! normalize-space(.))
            else
                $bo/text() ! normalize-space(.)
        },
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'Bo-Ltn' },
            $bo-ltn/@*[not(name(.) = ('xml:lang', 'type'))],
            $bo-ltn/text() ! normalize-space(.)
        },
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'Sa-Ltn' },
            $sa-ltn/@*[not(name(.) = ('xml:lang', 'type'))],
            $sa-ltn/text() ! normalize-space(.)
        },
        if($source-bibl[@type eq 'chapter']) then
            let $parent-id := $source-bibl/tei:idno/@parent-id
            let $parent-tei := tei-content:tei($parent-id, 'section')
            return
                element { QName('http://read.84000.co/ns/1.0', 'parent') }{
                    element titles {
                        tei-content:title-set($parent-tei, 'mainTitle')
                    }
                }
        else ()
    )
    
};

declare function tei-content:translation-status($tei as element(tei:TEI)?) as xs:string {

    let $status := $tei//tei:teiHeader//tei:publicationStmt/@status
    return
        if($status[string() gt '']) then $status
        (: No value - return '0' :)
        else if($status)then '0'
        (: No attribute - return '' :)
        else ''
};

declare function tei-content:translation-status-group($tei as element(tei:TEI)) as xs:string? {

    (: Returns the status group of the text :)
    let $translation-status := tei-content:translation-status($tei)
    let $status-type := if(tei-content:type($tei) eq 'translation') then 'translation' else 'article'
    
    return
        $tei-content:text-statuses/m:status[@type eq $status-type][@status-id eq $translation-status]/@group ! string()
};

declare function tei-content:text-statuses-sorted($type as xs:string) as element(m:text-statuses) {

    element { node-name($tei-content:text-statuses) } { 
        let $sorted-statuses :=
            for $status in $tei-content:text-statuses/m:status[@type eq $type]
                let $status-tokenized := tokenize($status/@status-id, '\.')
                order by 
                    if($status/@status-id eq '0') then 1
                    else 0, 
                    if(count($status-tokenized) gt 0 and functx:is-a-number($status-tokenized[1])) then 
                        xs:integer($status-tokenized[1])
                    else 99,
                    if(count($status-tokenized) gt 1) then 
                        $status-tokenized[2]
                    else ''
            return 
                $status
        
        for $status at $status-index in $sorted-statuses
        return 
            element { node-name($status) } { 
                $status/@*,
                attribute index { $status-index },
                $status/node()
            }
    }
    
};

declare function tei-content:text-statuses-selected($selected-ids as xs:string*, $type as xs:string) as element(m:text-statuses) {

    element { node-name($tei-content:text-statuses) } { 
        for $status in tei-content:text-statuses-sorted($type)/m:status
        return 
            element { node-name($status) } { 
                $status/@*,
                attribute value { $status/@status-id },
                if ($status/@status-id = $selected-ids) then 
                    attribute selected { 'selected' } 
                else 
                    (),
                $status/node()
            }
    }
    
};

declare function tei-content:source-bibl($tei as element(tei:TEI), $resource-id as xs:string) as element(tei:bibl)? {
    (: Returns a bibl node based on a resource-id :)
    let $resource-id := lower-case($resource-id)
    let $bibl := $tei//tei:sourceDesc/tei:bibl[@key eq $resource-id][1]
    return
        if(not($bibl)) then
            $tei//tei:sourceDesc/tei:bibl[1]
        else
            $bibl
};

declare function tei-content:source($tei as element(tei:TEI), $resource-id as xs:string) as element(m:source) {
    
    (: Returns a source node filtered by resource-id :)
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
    return
        <source xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }" parent-id="{ $bibl/tei:idno[@parent-id]/@parent-id }">
            <toh>{ normalize-space(string-join($bibl/tei:ref//text(), ' +')) }</toh>
            <series>{ normalize-space(data($bibl/tei:series)) }</series>
            <scope>{ normalize-space(data($bibl/tei:biblScope)) }</scope>
            <range>{ normalize-space(data($bibl/tei:citedRange)) }</range>
            {
                for $attribution in $bibl/tei:author | $bibl/tei:editor
                return 
                    element { QName('http://read.84000.co/ns/1.0', 'attribution') } {
                        attribute role {
                            if($attribution[@role eq 'translatorTib']) then
                                'translator'
                            else if($attribution[@role eq 'reviser']) then
                                'reviser'
                            else 
                                'author'
                        },
                        $attribution/@ref,
                        if($attribution[@xml:lang eq 'bo']) then
                            attribute xml:lang {'Bo-Ltn'}
                        else
                            $attribution/@xml:lang
                        ,
                        $attribution/@revision,
                        $attribution/@key,
                        text {
                            if($attribution[@xml:lang eq 'bo']) then
                                replace(common:wylie-from-bo(normalize-space($attribution/text())), '/$', '')
                            else if($attribution[@xml:lang eq 'Sa-Ltn']) then
                                functx:capitalize-first(
                                    replace(
                                        replace(
                                            normalize-space($attribution/text())  (: Normalize space :)
                                        , '^\*', '')                              (: Remove leading * :)
                                    , '­', '-')                                   (: Soft to hard-hyphens :)
                                )                                                 (: Title case :)
                            else
                                normalize-space($attribution/text())
                        }
                    }
                ,
                
                tei-content:location($bibl),
                
                for $note in 
                    $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@type = ('author', 'translator', 'reviser')]
                    | $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@update = ('author', 'translator', 'reviser')]
                return
                    element {QName('http://read.84000.co/ns/1.0', 'note')} {
                        $note/@*,
                        $note/node()
                    }
            }
        </source>
};

declare function tei-content:location($bibl as element(tei:bibl)?) as element(m:location) {
    <location xmlns="http://read.84000.co/ns/1.0" 
        key="{ $bibl/@key }" 
        work="{ $bibl/tei:location/@work }" 
        count-pages="{ common:integer($bibl/tei:location/@count-pages) }">
    { 
        for $volume in $bibl/tei:location/tei:volume
        return
            <volume number="{ $volume/@number }" start-page="{ $volume/@start-page }" end-page="{ $volume/@end-page }"/>
    }
    </location>
};

declare function tei-content:ancestors($tei as element(tei:TEI), $resource-id as xs:string, $nest as xs:integer) as element(m:parent)? {
    
    (: Returns an ancestor tree for the tei file :)
    
    let $source-bibl := tei-content:source-bibl($tei, $resource-id)
    let $parent-id := $source-bibl/tei:idno/@parent-id
    let $parent-tei := tei-content:tei($parent-id, 'section')
    
    return
        if($parent-tei) then
            element { QName('http://read.84000.co/ns/1.0', 'parent') } {
                attribute id { $parent-id },
                attribute nesting { $nest },
                attribute type {  $parent-tei//tei:teiHeader/tei:fileDesc/@type  },
                element titles {
                    tei-content:title-set($parent-tei, 'mainTitle')
                },
                tei-content:ancestors($parent-tei, '', $nest + 1)
            }
         else ()
};

declare function tei-content:locked-by-user($tei as element(tei:TEI)) as xs:string? {
    
    let $document-uri := base-uri($tei)
    let $document-uri-tokenised := tokenize($document-uri, '/')
    let $document-filename := $document-uri-tokenised[last()]
    let $document-path := substring-before($document-uri, $document-filename)
    return
        xmldb:document-has-lock(concat("xmldb:exist://", $document-path), $document-filename)

};

declare function tei-content:document-url($tei as element(tei:TEI)) as xs:string {
    
    (:let $document-uri := base-uri($tei)
    let $document-uri-tokenised := tokenize($document-uri, '/')
    let $document-filename := $document-uri-tokenised[last()]
    let $document-path := substring-before($document-uri, $document-filename)
    return
        concat($document-path, $document-filename):)
    base-uri($tei)

};

declare function tei-content:last-updated($fileDesc as element()?) as xs:dateTime {
    xs:dateTime(($fileDesc/tei:notesStmt/tei:note[@type eq "lastUpdated"][@date-time gt ''][1]/@date-time, '2010-01-01T00:00:00')[1])
};

declare function tei-content:last-modified($tei as element(tei:TEI)) as xs:dateTime {
    let $document-uri := base-uri($tei)
    let $document-uri-tokenised := tokenize($document-uri, '/')
    let $document-filename := $document-uri-tokenised[last()]
    let $document-path := substring-before($document-uri, $document-filename)
    return
        xmldb:last-modified(concat("xmldb:exist://", $document-path), $document-filename)
};

declare function tei-content:valid-xml-id($tei as element(tei:TEI), $xml-id as xs:string) as xs:boolean {

    let $translation-id := tei-content:id($tei)
    let $leading-string := concat($translation-id, '-')
    let $trailing-integer := substring-after($xml-id, $leading-string)
    return (
        starts-with($xml-id, $leading-string)
        and functx:is-a-number($trailing-integer)
    )
    
};

declare function tei-content:next-xml-id($tei as element(tei:TEI)) as xs:string {

    let $translation-id := tei-content:id($tei)
    let $max-id := max($tei//@xml:id ! substring-after(., $translation-id) ! substring(., 2) ! common:integer(.))
    return
        string-join(($translation-id, xs:string(sum(($max-id, 1)))), '-')
    
};

(: Just the version number part of the edition as string :)
declare function tei-content:version-number-str($tei as element(tei:TEI)) as xs:string {
    (: Remove all but the numbers and points :)
    tei-content:strip-version-number($tei/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/text()[1])
};

declare function tei-content:strip-version-number($version-str as xs:string?) as xs:string {
    (: Remove all but the numbers and points :)
    replace($version-str,'[^0-9\.]','')
};

(: Just the version number part of the edition as numbers e.g. (1,2,3) :)
declare function tei-content:version-number($version-number-str as xs:string?) as xs:integer* {
    
    (: Split the numbers :)
    let $version-number-split := tokenize(tei-content:strip-version-number($version-number-str), '\.')
    
    return (
        if(count($version-number-split) gt 0 and functx:is-a-number($version-number-split[1])) then
            xs:integer($version-number-split[1])
        else 0
        ,
        if(count($version-number-split) gt 1 and functx:is-a-number($version-number-split[2])) then
            xs:integer($version-number-split[2])
        else 0
        ,
        if(count($version-number-split) gt 2 and functx:is-a-number($version-number-split[3])) then
            xs:integer($version-number-split[3])
        else 0
    )
};

(: Compare 2 version number strings - result of strip-version-number() e.g. '0.1.2' :)
declare function tei-content:is-current-version($tei-version-number-str as xs:string?, $other-version-number-str as xs:string?) as xs:boolean {
    
    let $tei-version-number := tei-content:version-number($tei-version-number-str)
    let $other-version-number := tei-content:version-number($other-version-number-str)
    
    return
        deep-equal($tei-version-number, $other-version-number)
};

(: Increment specific parts of the version number :)
declare function tei-content:version-number-str-increment($tei as element(tei:TEI), $part as xs:string) as xs:string {
    
    let $version-number-str := tei-content:version-number-str($tei)
    let $version-number := tei-content:version-number($version-number-str)
    
    return string-join((
        if($part eq 'major') then
            $version-number[1] + 1
        else
            $version-number[1]
        ,
        if($part eq 'minor') then
            $version-number[2] + 1
        else if($part eq 'major') then
            0
        else
            $version-number[2]
        ,
        if($part eq 'revision') then
            $version-number[3] + 1
        else if($part = ('major', 'minor')) then
            0
        else
            $version-number[3]
    ), '.')
};

(: Just the date part of the edition :)
declare function tei-content:version-date($tei as element(tei:TEI)) as xs:string {
    (: Remove all but the numbers :)
    replace($tei/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/tei:date/text(),'[^0-9]','')
};

(: The full version string :)
declare function tei-content:version-str($tei as element(tei:TEI)) as xs:string {
    replace(
        replace(
            normalize-space(
                string-join(
                    $tei/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition//text()   (: Get all text :)
                , ' ')                                          (: Make sure they don't concatenate :)
            )                                                   (: Normalize the whitespace :)
        , '[^a-zA-Z0-9\s\.]', '')                               (: Remove all but the alpanumeric, points and spaces :)
    , '\s', '-')                                                (: Replace the spaces with hyphens :)
};

declare function tei-content:cache($tei as element(tei:TEI), $create-if-unavailable as xs:boolean?) as element(m:cache)? {
    
    let $text-id := tei-content:id($tei)
    let $cache-collection := concat($common:data-path, '/', 'cache')
    let $cache-file := concat($text-id, '.cache')
    let $cache-uri := concat($cache-collection, '/', $cache-file)
    let $cache := doc($cache-uri)/m:cache
    let $cache-empty := <cache xmlns="http://read.84000.co/ns/1.0"/>
    
    let $cache := 
        if(not(doc-available($cache-uri))) then 
            if($create-if-unavailable and $tei/tei:text//tei:div) then 
                let $cache-create := xmldb:store($cache-collection, $cache-file, $cache-empty, 'application/xml')
                let $set-permissions := (
                    sm:chown(xs:anyURI($cache-uri), 'admin'),
                    sm:chgrp(xs:anyURI($cache-uri), 'tei'),
                    sm:chmod(xs:anyURI($cache-uri), 'rw-rw-r--')
                )
                return
                    doc($cache-uri)/m:cache
            else 
                $cache-empty
        else 
            $cache
    
    return
        $cache
};

declare function tei-content:notes-cache($tei as element(tei:TEI), $refresh as xs:boolean?, $create-if-unavailable as xs:boolean?) as element(m:notes-cache) {
    
    let $cache := tei-content:cache($tei, $create-if-unavailable)
    
    return
        if($cache[m:notes-cache] and not($refresh)) then
            $cache/m:notes-cache
        else
            
            let $start-time := util:system-dateTime()
            
            let $end-notes :=
            
                for $note at $index in $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
                    (: Lowest level @typed part, except root :)
                    let $part := $note/ancestor::tei:div[@type][not(@type = ('translation', 'appendix'))][last()]
                return (
                    common:ws(2),
                    element { QName('http://read.84000.co/ns/1.0', 'end-note') } {
                        attribute id { $note/@xml:id },
                        attribute part-id { ($part/@xml:id, $part/@type)[1] },
                        attribute index { $index }
                    }
                )
            
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'notes-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) },
                    
                    $end-notes,
                    
                    common:ws(1)
                }
};

declare function tei-content:milestones-cache($tei as element(tei:TEI), $refresh as xs:boolean?, $create-if-unavailable as xs:boolean?) as element(m:milestones-cache) {
    
    let $cache := tei-content:cache($tei, $create-if-unavailable)
    
    return
        if($cache[m:milestones-cache] and not($refresh)) then
            $cache/m:milestones-cache
        else
            
            let $start-time := util:system-dateTime()
            
            let $milestones := 
                for $part in 
                    $tei/tei:text/tei:front/tei:div[@type]
                    | $tei/tei:text/tei:body/tei:div[@type = ('translation', 'article')]/tei:div[@type]
                    | $tei/tei:text/tei:back/tei:div[@type eq 'appendix']/tei:div[@type]
                    | $tei/tei:text/tei:back/tei:div[not(@type eq 'appendix')]
                    for $milestone at $index in $part//tei:milestone[@xml:id]
                    return (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'milestone') } {
                            attribute id { $milestone/@xml:id },
                            attribute part-id { ($part/@xml:id, $part/@type)[1] },
                            attribute index { $index }
                        }
                    )
                    
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'milestones-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) },
                    
                    $milestones,
                    
                    common:ws(1)
                }
};

declare function tei-content:quotes-cache($tei as element(tei:TEI), $refresh as xs:boolean?, $create-if-unavailable as xs:boolean?) as element(m:notes-cache) {
    
    let $cache := tei-content:cache($tei, $create-if-unavailable)
    
    return
        if($cache[m:quotes-cache] and not($refresh)) then
            $cache/m:quotes-cache
        else
            
            let $start-time := util:system-dateTime()
            
            let $quotes :=
            
                for $quote-ref in $tei//tei:q/@ref
                let $quote := collection($common:tei-path)//id($quote-ref)
                let $quote-tei := $quote/ancestor::tei:TEI
                let $quote-bibl := tei-content:source-bibl($quote-tei, '')[1]
                where $quote-bibl
                return (
                    common:ws(2),
                    element { QName('http://read.84000.co/ns/1.0', 'quote') } {
                        attribute id { $quote-ref },
                        attribute resource-id { $quote-bibl/@key/string() },
                        attribute resource-type { tei-content:type($quote-tei) },
                        attribute label { $quote-bibl/tei:ref/text() }
                    }
                )
            
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'quotes-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) },
                    
                    $quotes,
                    
                    common:ws(1)
                }
};

declare function tei-content:status-updates($tei as element()) as element(m:status-updates) {
    
    element {QName('http://read.84000.co/ns/1.0', 'status-updates')} {
        
        let $translation-status := tei-content:translation-status($tei)
        let $tei-version-number-str := tei-content:version-number-str($tei)
        
        (: Returns notes of status updates :)
        for $status-update in $tei/tei:teiHeader//tei:notesStmt/tei:note[@update = ('file-created', 'text-version', 'translation-status', 'publication-status')]
        let $status-update-version-number-str := replace($status-update/@value, '[^0-9\.]', '')
        return
            element {QName('http://read.84000.co/ns/1.0', 'status-update')} {
                $status-update/@update,
                $status-update/@value,
                $status-update/@date-time,
                $status-update/@user,
                attribute days-from-now { days-from-duration(xs:dateTime($status-update/@date-time) - current-dateTime()) },
                if ($status-update[@update = ('translation-status', 'publication-status')] and $status-update[@value eq $translation-status]) then
                    attribute current-status { true() }
                else
                    ()
                ,
                if ($status-update[@update eq 'text-version'] and $status-update-version-number-str eq $tei-version-number-str) then
                    attribute current-version { true() }
                else
                    ()
                ,
                $status-update/text()
            }
    }
    
};

declare function tei-content:new-section($type as xs:string?) as element(tei:div) {

    if($type eq 'listBibl') then
    
        <div type="section" xmlns="http://www.tei-c.org/ns/1.0">
            <head type="section" rend="default-text">Bibliography Section Heading</head>
            <bibl rend="default-text">This is a sample bibliographic reference with a <ref target="https://read.84000.co/translation/toh46.html">link example</ref>.</bibl>
        </div>
        
    else
    
        <div type="section" xmlns="http://www.tei-c.org/ns/1.0">
            <head type="section" rend="default-text">Article Section Heading</head>
            <milestone unit="chunk"/>
            <p rend="default-text">Here's a paragraph to get you started. Replace this as you wish<note place="end">This is a ready-made footnote.</note>.</p>
        </div>
    
};
