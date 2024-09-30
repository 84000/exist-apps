xquery version "3.1";

module namespace tei-content="http://read.84000.co/tei-content";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
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
        <status type="article"      status-id="1.b"  group="published"      marked-up="true"                     >Published without content</status>
        <status type="article"      status-id="2"    group="in-progress"    marked-up="true"                     >Copyediting</status>
        <status type="article"      status-id="2.a"  group="in-progress"    marked-up="true"                     >In review</status>
        <status type="article"      status-id="2.b"  group="in-progress"    marked-up="true"                     >In progress</status>
        <status type="article"      status-id="3"    group="not-started"    marked-up="true"                     >Not started</status>
    </text-statuses>;

declare variable $tei-content:title-types :=
    <title-types xmlns="http://read.84000.co/ns/1.0">
        <title-type id="mainTitle">Main</title-type>
        <title-type id="longTitle">Long</title-type>
        <title-type id="otherTitle">Other</title-type>
        <title-type id="shortcode">Shortcode</title-type>
        <title-type id="articleTitle">Article</title-type>
    </title-types>;

declare function tei-content:id($tei as element(tei:TEI)) as xs:string {
    (: Returns the idno in a given tei doc :)
    $tei//tei:publicationStmt/tei:idno[@xml:id][1]/@xml:id
};

declare function tei-content:type($tei as element(tei:TEI)) as xs:string {

    if($tei//tei:fileDesc/@type = ('section','grouping','pseudo-section')) then 
        'section'
    
    else if($tei//tei:publicationStmt/tei:idno[@type eq 'eft-kb-id']) then
        'knowledgebase'
    
    else
        'translation'
    
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string) as element(tei:TEI)? {
    tei-content:tei($resource-id, $resource-type, '')
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string, $archive-path as xs:string?) as element(tei:TEI)? {

    let $collection := 
        (: Layout checks :)
        if(lower-case($resource-id) = ('toh00', 'toh00a', 'ut22084-000-000', 'toh00c', 'ut23703-000-000')) then
            collection(concat($common:tei-path, '/layout-checks'))
        
        (: Archived copy :)
        else if($archive-path gt '') then
            collection(concat($common:archive-path, '/', $archive-path))
        
        (: Section :)
        else if($resource-type = ('section','grouping','pseudo-section')) then
            $tei-content:sections-collection
        
        (: Knowledge base :)
        else if($resource-type eq 'knowledgebase') then (
            $tei-content:knowledgebase-collection,
            $tei-content:sections-collection
        )
        
        (: Default to translation :)
        else 
            $tei-content:translations-collection
    
    (: Fallback to UT number :)
    let $resource-id-uppercase := upper-case($resource-id)
    let $tei := $collection/id($resource-id-uppercase)(:[self::tei:idno][1]:)/ancestor::tei:TEI
    
    (: Lookup key :)
    let $resource-id-lowercase := lower-case($resource-id)
    let $tei := 
        if(not($tei) and $resource-type eq 'translation') then
            $collection//tei:sourceDesc/tei:bibl[@key eq $resource-id-lowercase][1]/ancestor::tei:TEI
        else if(not($tei) and $resource-type = ('knowledgebase', 'section')) then
            $collection//tei:publicationStmt/tei:idno[range:eq(., $resource-id-lowercase)][@type eq 'eft-kb-id'][1]/ancestor::tei:TEI
        else 
            $tei
    
    return $tei
    
};

declare function tei-content:title-any($tei as element(tei:TEI)) as xs:string? {
    
    (: Returns a title from the tei :)
    
    let $titles := $tei//tei:fileDesc/tei:titleStmt/tei:title
    
    return (
        $titles[@type eq 'articleTitle'][@xml:lang eq 'en'],
        $titles[@type eq 'mainTitle'][@xml:lang eq 'en'],
        $titles[@xml:lang eq 'en'],
        $titles[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'],
        $titles[not(@xml:lang eq 'en')]
    )[normalize-space(text())][1] ! concat(normalize-space(text()), @xml:lang[not(. eq 'en')] ! ' (awaiting English title)')
    
};

declare function tei-content:title($tei as node(), $type as xs:string?, $lang as xs:string*) as xs:string? {
    
    (: Returns a specific type of title from the tei :)
    
    ($tei//tei:fileDesc/tei:titleStmt/tei:title[@xml:lang = $lang][@type eq $type])[normalize-space(text())][1] ! normalize-space(text())
    
};

declare function tei-content:titles-all($tei as element(tei:TEI)) as element(m:titles) {
    
    (: Returns all titles from the tei :)
    
    element { QName('http://read.84000.co/ns/1.0', 'titles') } {
        for $title in $tei//tei:fileDesc/tei:titleStmt/tei:title
        return
            element title {
                $title/@*,
                $title/text() ! normalize-space(.)
            }
        ,
        (:for $bibl in $tei//tei:sourceDesc/tei:bibl[tei:ref/text()]
        return
            element title {
                attribute type { 'toh' },
                attribute xml:lang { 'en' },
                attribute key { $bibl/@key },
                string-join($bibl/tei:ref//text())
            }
        ,:)
        for $note in $tei//tei:fileDesc/tei:notesStmt/tei:note[@type = ('title','title-internal')]
        return
            element note {
                $note/@*,
                $note/text() ! normalize-space(.)
            }
    }
    
};

declare function tei-content:title-set($tei as element(tei:TEI), $type as xs:string) as element(m:titles) {
    
    (: Returns a set of titles from the tei :)
    
    let $titles := ($tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq $type])[normalize-space(text())]
    
    let $en := $titles[@xml:lang = ('eng', 'en')][1]
    let $bo-ltn := $titles[@xml:lang = ('Bo-Ltn', '')][1]
    let $bo := $titles[@xml:lang eq 'bo'][1]
    let $sa-ltn := $titles[@xml:lang eq 'Sa-Ltn'][1]
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'titles') } {
            element title {
                attribute xml:lang { 'en' },
                $en/@*[not(name(.) = ('xml:lang', 'type'))],
                $en/text() ! normalize-space(.)
            },
            element title {
                attribute xml:lang { 'bo' },
                $en/@*[not(name(.) = ('xml:lang', 'type'))],
                if(not($bo/text()) and $bo-ltn/text()) then
                    common:bo-from-wylie($bo-ltn/text() ! normalize-space(.))
                else
                    $bo/text() ! normalize-space(.)
            },
            element title {
                attribute xml:lang { 'Bo-Ltn' },
                $bo-ltn/@*[not(name(.) = ('xml:lang', 'type'))],
                $bo-ltn/text() ! normalize-space(.)
            },
            element title {
                attribute xml:lang { 'Sa-Ltn' },
                $sa-ltn/@*[not(name(.) = ('xml:lang', 'type'))],
                $sa-ltn/text() ! normalize-space(.)
            }
        }
    
};

declare function tei-content:publication-status($tei as element(tei:TEI)?) as xs:string {

    let $status := $tei//tei:publicationStmt/tei:availability/@status
    return
        if($status[string() gt '']) then $status
        (: No value - return '0' :)
        else if($status)then '0'
        (: No attribute - return '' :)
        else ''
};

declare function tei-content:publication-status-group($tei as element(tei:TEI)) as xs:string? {

    (: Returns the status group of the text :)
    let $translation-status := tei-content:publication-status($tei)
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

declare function tei-content:source-bibl($tei as element(tei:TEI), $resource-id as xs:string?) as element(tei:bibl)? {
    (: Returns a bibl node based on a resource-id :)
    ($tei//tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)], $tei//tei:sourceDesc/tei:bibl)[1]
};

declare function tei-content:source($tei as element(tei:TEI), $resource-id as xs:string) as element(m:source) {
    
    (: Returns a source node filtered by resource-id :)
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
    return
        <source xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }" parent-id="{ $bibl/tei:idno[@parent-id]/@parent-id }">
            <toh>{ normalize-space(string-join($bibl/tei:ref//text(), ' +')) }</toh>
            <scope>{ $bibl/tei:series/node() | $bibl/tei:biblScope/node() | $bibl/tei:citedRange/node() }</scope>
            {
                for $attribution in $bibl/tei:author | $bibl/tei:editor
                return 
                    element { QName('http://read.84000.co/ns/1.0', 'attribution') } {
                        
                        attribute role {
                            if($attribution[@role eq 'translatorTib']) then
                                'translator'
                            else if($attribution[@role eq 'reviser']) then
                                'reviser'
                            else if($attribution[@role eq 'authorContested']) then
                                'author-contested'
                            else 
                                'author'
                        },
                        
                        $attribution/@xml:id,
                        
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
                                replace(
                                    replace(
                                        normalize-space($attribution/text())  (: Normalize space :)
                                    , '^\*', '')                              (: Remove leading * :)
                                , '­', '-')                                   (: Soft to hard-hyphens :)
                                
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
                ,
                
                for $link in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:link[@type eq 'isCommentaryOf']
                let $link-tei := tei-content:tei($link/@target, 'translation')
                let $source-bibl := $link-tei ! tei-content:source-bibl(., $link/@target)
                where $link-tei
                return
                    element isCommentaryOf {
                        attribute toh-key { $source-bibl/@key },
                        attribute text-id { tei-content:id($link-tei) },
                        tei-content:titles-all($link-tei),
                        $source-bibl
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

declare function tei-content:ancestors($tei as element(tei:TEI), $resource-id as xs:string?, $nest as xs:integer) as element(m:parent)? {
    
    (: Returns an ancestor tree for the tei file :)
    
    let $source-bibl := tei-content:source-bibl($tei, $resource-id)
    let $parent-id := ($source-bibl/tei:idno/@parent-id)[1]
    let $parent-tei := tei-content:tei($parent-id, 'section')
    
    return
        if($parent-tei) then
            element { QName('http://read.84000.co/ns/1.0', 'parent') } {
                attribute id { $parent-id },
                $resource-id ! attribute resource-id { . },
                attribute nesting { $nest },
                attribute type {  $parent-tei//tei:teiHeader/tei:fileDesc/@type  },
                tei-content:title-set($parent-tei, 'mainTitle'),
                tei-content:ancestors($parent-tei, (), $nest + 1)
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

declare function tei-content:last-modified($tei as element(tei:TEI)) as xs:dateTime {
    xmldb:last-modified(util:collection-name($tei), util:document-name($tei))
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

declare function tei-content:max-xml-id-int($tei) as xs:integer? {
    let $text-id := tei-content:id($tei)
    return
        max($tei//@xml:id ! substring-after(., concat($text-id, '-')) ! tokenize(., '-')[1][functx:is-a-number(.)] ! common:integer(.))
};

declare function tei-content:next-xml-id($text-id as xs:string, $next-int as xs:integer) as xs:string {
    string-join(($text-id, $next-int ! xs:string(.)), '-')
};

declare function tei-content:next-xml-id($tei as element(tei:TEI)) as xs:string {

    let $text-id := tei-content:id($tei)
    let $max-int := tei-content:max-xml-id-int($tei)
    let $next-int := sum(($max-int, 1))
    where $text-id gt '' and $next-int gt 0
    return
        tei-content:next-xml-id($text-id, $next-int)
    
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

declare function tei-content:end-notes-pre-processed($tei as element(tei:TEI)) as element(m:pre-processed) {
    
    local:elements-pre-processed($tei, 'end-note')
};

declare function tei-content:milestones-pre-processed($tei as element(tei:TEI)) as element(m:pre-processed) {

    local:elements-pre-processed($tei, 'milestone')
    
};

declare function local:elements-pre-processed($tei as element(tei:TEI), $element-name as xs:string) as element(m:pre-processed) {
    
    let $start-time := util:system-dateTime()
    
    let $text-id := tei-content:id($tei)
    let $text-type := tei-content:type($tei)
    
    let $elements := 
        for $part in 
            $tei/tei:text/tei:front/tei:div[@type]
            | $tei/tei:text/tei:body/tei:div[@type = ('translation', 'article')]/tei:div[@type]
            | $tei/tei:text/tei:back/tei:div[@type]
            
            let $part-id := ($part/@xml:id, $part/@type)[1]
            
            return (
                for $element at $index in 
                    if($element-name eq 'milestone') then
                        $part//tei:milestone[@xml:id]
                    else if($element-name eq 'end-note') then
                        $part//tei:note[@place eq 'end'][@xml:id]
                    else ()
                return
                    element { QName('http://read.84000.co/ns/1.0', $element-name) } {
                        attribute id { $element/@xml:id },
                        attribute part-id { $part-id },
                        attribute label-part-id { ($element/ancestor::tei:div[@prefix][1]/@xml:id, $part-id)[1] },
                        attribute index { $index },
                        if($element[@n gt '']) then
                            attribute label { $element/@n }
                        else (),
                        if($element-name eq 'end-note') then
                            $element/ancestor-or-self::*/@key[1]
                        else ()
                    }
            )
    
    let $keys := ($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key, $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'eft-kb-id']/text())
    
    let $elements :=
        (: Index per doc, not per part :)
        if($element-name eq 'end-note') then 
            for $key in $keys
            return
                for $element at $index in $elements[not(@key) or @key eq $key]
                return
                    element { QName('http://read.84000.co/ns/1.0', $element-name) } {
                        $element/@id,
                        $element/@part-id,
                        attribute source-key { $key },
                        attribute index { $index }
                    }
        
        (: Re-label based on pre-labelled elements :)
        else if($element-name eq 'milestone') then
            for $element in $elements
            let $part-id := $element/@label-part-id/string()
            group by $part-id
            return (
                for $element-single at $index in $element[not(@label)]
                return
                    element { QName('http://read.84000.co/ns/1.0', $element-name) } {
                        $element-single/@*,
                        attribute label { $index }
                    }
                ,
                for $element-single in $element[@label]
                return
                    $element-single
            )
        else
            $elements
    
    let $end-time := util:system-dateTime()
    
    let $pre-processed-type :=
        if($element-name eq 'milestone') then
            'milestones'
        else if($element-name eq 'end-note') then
            'end-notes'
        else ()
    
    return
        tei-content:pre-processed(
            $text-id,
            $pre-processed-type,
            functx:total-seconds-from-duration($end-time - $start-time),
            $elements
        )
        
};

declare function tei-content:pre-processed($text-id as xs:string, $type as xs:string, $seconds-to-build as xs:integer, $content as element()*) as element(m:pre-processed) {

    element { QName('http://read.84000.co/ns/1.0', 'pre-processed') } {
            
        attribute text-id { $text-id },
        attribute type { $type },
        attribute timestamp { current-dateTime() },
        attribute seconds-to-build { $seconds-to-build },
        
        $content
        
    }

};

declare function tei-content:status-updates($tei as element()) as element(m:status-updates) {
    
    element {QName('http://read.84000.co/ns/1.0', 'status-updates')} {
        
        let $translation-status := tei-content:publication-status($tei)
        let $tei-version-number-str := tei-content:version-number-str($tei)
        
        (: Returns notes of status updates :)
        for $change in $tei//tei:revisionDesc/tei:change
        return
            element {QName('http://read.84000.co/ns/1.0', 'status-update')} {
            
                $change/@*,
                
                attribute days-from-now { days-from-duration(xs:dateTime($change/@when) - current-dateTime()) },
                
                if ($change[@type = ('translation-status', 'publication-status')] and $change[@status eq $translation-status]) then
                    attribute current-status { true() }
                else ()
                ,
                
                if ($change[@type eq 'text-version'] and $change[@status ! replace(., '[^0-9\.]', '') eq $tei-version-number-str ]) then
                    attribute current-version { true() }
                else ()
                ,
                
                $change/descendant::text()
                
            }
    }
    
};

declare function tei-content:new-section($type as xs:string?) as element(tei:div) {

    if($type eq 'listBibl') then
    
        <div type="section" xmlns="http://www.tei-c.org/ns/1.0">
            <head type="section">Bibliography Section Heading</head>
            <bibl rend="default-text">This is a sample bibliographic reference with a <ref target="https://read.84000.co/translation/toh46">link example</ref>.</bibl>
        </div>
        
    else
    
        <div type="section" xmlns="http://www.tei-c.org/ns/1.0">
            <head type="section">Article Section Heading</head>
            <milestone unit="chunk"/>
            <p rend="default-text">Here's a paragraph to get you started. Replace this as you wish<note place="end">This is a ready-made footnote.</note>.</p>
        </div>
    
};

declare function tei-content:preview-nodes($content-nodes as node()*, $index as xs:integer, $preview as node()*)  {
    
    (: test what there is already :)
    let $preview-length := string-length(string-join($preview, ''))
    where $index le count($content-nodes) and $preview-length lt 500
    return
        (: If more needed return this node :)
        let $content-node := $content-nodes[$index]
        let $preview-text := 
            if($content-node[normalize-space(.)][not(ancestor-or-self::tei:note | ancestor-or-self::tei:orig)]) then
                $content-node
            else ()
        
        return (
            
            (: Return this as preview text :)
            $preview-text,
            
            (: Move to the next :)
            tei-content:preview-nodes($content-nodes, $index + 1, ($preview, $preview-text))
            
        )
    
};

declare function tei-content:preview($content as node()*) {

    let $preview-nodes := tei-content:preview-nodes($content//text(), 1, ())
    
    for $node in $content/tei:div[1]/*
    return
        if(count($node//text() | $preview-nodes) lt (count($node//text()) + count($preview-nodes))) then (
            $node/preceding-sibling::*[1][self::tei:milestone | self::tei:lb]
            | $node/preceding-sibling::*[2][self::tei:milestone | self::tei:lb][following-sibling::*[1][self::tei:milestone | self::tei:lb]],
            $node
        )
        else ()
    
};
