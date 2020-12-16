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
        <status status-id="0" group="not-started">Not started</status>
        <status status-id="1" group="published" marked-up="true" target-date="true">Published</status>
        <status status-id="1.a" group="published" marked-up="true" target-date="true">Ready to publish</status>
        <status status-id="2" group="translated" marked-up="true" target-date="true">Marked up, awaiting final proofing</status>
        <status status-id="2.a" group="translated" marked-up="true">Markup in process</status>
        <status status-id="2.b" group="translated" target-date="true">Awaiting markup</status>
        <status status-id="2.c" group="translated">Awaiting editor's OK for markup</status>
        <status status-id="2.d" group="translated" target-date="true">Copyediting complete. Preparation for markup</status>
        <status status-id="2.e" group="translated">Being copyedited</status>
        <status status-id="2.f" group="translated" target-date="true">Review complete. Awaiting copyediting</status>
        <status status-id="2.g" group="translated">In editorial review</status>
        <status status-id="2.h" group="translated" target-date="true">Awaiting review</status>
        <status status-id="3" group="in-translation">Current translation projects</status>
        <status status-id="4" group="in-application">Application pending</status>
    </text-statuses>;

declare variable $tei-content:published-status-ids := $tei-content:text-statuses/m:status[@group = ('published')]/@status-id;
declare variable $tei-content:in-progress-status-ids := $tei-content:text-statuses/m:status[@group = ('translated', 'in-translation')]/@status-id;
declare variable $tei-content:marked-up-status-ids := $tei-content:text-statuses/m:status[@marked-up = 'true']/@status-id;
declare variable $tei-content:title-types :=
    <title-types xmlns="http://read.84000.co/ns/1.0">
        <title-type id="mainTitle">Main</title-type>
        <title-type id="longTitle">Long</title-type>
        <title-type id="otherTitle">Other</title-type>
        <title-lang id="en">English</title-lang>
        <title-lang id="bo">Tibetan</title-lang>
        <title-lang id="Bo-Ltn">Wylie</title-lang>
        <title-lang id="Sa-Ltn">Sanskrit</title-lang>
        <title-lang id="zh">Chinese</title-lang>
    </title-types>;

declare function tei-content:id($tei as element(tei:TEI)) as xs:string {
    (: Returns the idno in a given tei doc :)
    $tei//tei:publicationStmt/tei:idno/@xml:id
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string) {
    tei-content:tei($resource-id, $resource-type, '')
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string, $archive-path as xs:string?) as element()? {

    (:
        This is controls the method of looking up the resource-id 
        from the controller and finding the document.
        Current options: 
        1.  UT Number e.g. translation/UT22084-061-013.html
        2.  Tohoku Number e.g. translation/toh739.html
    :)
    
    let $collection := 
        if($archive-path eq 'layout-checks') then
            collection(concat($common:data-path, '/tei/layout-checks'))
        else if($archive-path gt '') then
            collection(concat($common:data-path, '/archived/', $archive-path))
        else if($resource-type = ('section', 'pseudo-section')) then
            $tei-content:sections-collection
        else if($resource-type eq 'knowledgebase') then
            $tei-content:knowledgebase-collection
        else 
            $tei-content:translations-collection
    
    (: based on Tohoku number :)
    let $tei := 
        if($resource-type eq 'translation') then
            let $resource-id := lower-case($resource-id)
            return
                $collection//tei:sourceDesc/tei:bibl[@key eq $resource-id][1]/ancestor::tei:TEI
        else if($resource-type eq 'knowledgebase') then
            let $resource-id := lower-case($resource-id)
            return
                $collection//tei:publicationStmt/tei:idno[@m:kb-id eq $resource-id][1]/ancestor::tei:TEI
        else
            ()
    
    return 
        if(not($tei)) then
            (: Fallback to UT number :)
            let $resource-id := upper-case($resource-id)
            return
                $collection//tei:publicationStmt[tei:idno/@xml:id eq $resource-id]/ancestor::tei:TEI
        else
            $tei
    
};

declare function tei-content:title($tei as element(tei:TEI)) as xs:string? {
    (: Returns a standardised title in a given tei doc :)
    
    let $title := $tei//tei:fileDesc/tei:titleStmt/tei:title[@type='mainTitle'][@xml:lang eq 'en'][1]/text() ! normalize-space(.)
    
    let $title := 
        if(not($title gt ''))then
            $tei//tei:fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'en'][1]/text() ! normalize-space(.)
        else
            $title
            
    let $title :=
        if(not($title gt ''))then
            concat($tei//tei:fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'Sa-Ltn'][1]/text() ! normalize-space(.), ' (awaiting English title)')
        else
            $title
    
    return
        $title ! normalize-space(.) ! translate(., '&#x2003;', '&#x20;')
};

declare function tei-content:title($tei as node(), $type as xs:string?, $lang as xs:string*) as xs:string? {
    
    $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq $type][@xml:lang = $lang][1]/text() ! normalize-space(.) ! translate(., '&#x2003;', '&#x20;')
    
};

declare function tei-content:titles($tei as element(tei:TEI)) as element() {

    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        for $title in $tei//tei:fileDesc/tei:titleStmt/tei:title
        return
            <title 
                xml:lang="{ $title/@xml:lang }"
                type="{ $title/@type }">
            {
                $title/text() ! normalize-space(.) ! translate(., '&#x2003;', '&#x20;') 
            }
            </title>
    }
    </titles>
    
};

declare function tei-content:title-set($tei as element(tei:TEI), $type as xs:string) as element()* {
    
    let $bo := tei-content:title($tei, $type , 'bo')
    let $bo-ltn := tei-content:title($tei, $type , ('Bo-Ltn', ''))
    let $en := tei-content:title($tei, $type , ('eng', 'en'))
    let $sa-ltn := tei-content:title($tei, $type , 'Sa-Ltn')
    
    let $source-bibl := tei-content:source-bibl($tei, '')
    
    return (
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="en">{ $en }</title>,
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="bo">
        {
            if(not($bo) and $bo-ltn) then
                common:bo-from-wylie($bo-ltn)
            else
                $bo
        }
        </title>,
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="Bo-Ltn">{ $bo-ltn }</title>,
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="Sa-Ltn">{ $sa-ltn }</title>,        
        if($source-bibl/@type eq 'chapter') then
            <parent xmlns="http://read.84000.co/ns/1.0">
                <titles>
                {
                    tei-content:title-set(
                        tei-content:tei($source-bibl/tei:idno/@parent-id, 'section'), 
                        'mainTitle'
                    )
                }
                </titles>
            </parent>
        else
            ()
    )
    
};

declare function tei-content:translation-status($tei as element(tei:TEI)) as xs:string {
    (: Returns the status of the text :)
    let $status := $tei//tei:teiHeader//tei:publicationStmt/@status/string()
    let $status := 
        if($status le '')then
            '0'
        else
            $status
    
    return
        if($status) then
            $status
        else
            ''
};

declare function tei-content:translation-status-group($tei as element(tei:TEI)) as xs:string? {
    (: Returns the status group of the text :)
    string($tei-content:text-statuses/m:status[@status-id eq tei-content:translation-status($tei)]/@group)
};

declare function tei-content:text-statuses-sorted() as element(m:text-statuses) {

    element { QName('http://read.84000.co/ns/1.0', 'text-statuses') } { 
        let $sorted-statuses :=
            for $status in $tei-content:text-statuses/m:status
                let $status-tokenized := tokenize($status/@status-id, '\.')
                order by 
                    if($status/@status-id eq '0') then
                        1
                    else
                        0, 
                    if(count($status-tokenized) gt 0 and functx:is-a-number($status-tokenized[1])) then 
                        xs:integer($status-tokenized[1])
                    else
                        99,
                    if(count($status-tokenized) gt 1) then 
                        $status-tokenized[2]
                    else
                        ''
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

declare function tei-content:text-statuses-selected($selected-ids as xs:string*) as element(m:text-statuses) {

    element { QName('http://read.84000.co/ns/1.0', 'text-statuses') } { 
        for $status in tei-content:text-statuses-sorted()/m:status
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

declare function tei-content:source-bibl($tei as element(tei:TEI), $resource-id as xs:string) as node()? {
    (: Returns a bibl node based on a resource-id :)
    let $bibl := $tei//tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)][1]
    return
        if(not($bibl)) then
            $tei//tei:sourceDesc/tei:bibl[1]
        else
            $bibl
};

declare function tei-content:source($tei as element(tei:TEI), $resource-id as xs:string) as element() {
    
    (: Returns a source node filtered by resource-id :)
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
    return
        <source xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }" parent-id="{ $bibl/tei:idno[@parent-id]/@parent-id }">
            <toh>{ normalize-space(string-join($bibl/tei:ref//text(), ' +')) }</toh>
            <series>{ normalize-space(data($bibl/tei:series)) }</series>
            <scope>{ normalize-space(data($bibl/tei:biblScope)) }</scope>
            <range>{ normalize-space(data($bibl/tei:citedRange)) }</range>
            <authors>
            {
                for $author in $bibl/tei:author
                return 
                    <author>{ normalize-space($author/text()) }</author>
            }
            </authors>
            {
                tei-content:location($bibl)
            }
        </source>
};

declare function tei-content:location($bibl as element(tei:bibl)) as element() {
    <location xmlns="http://read.84000.co/ns/1.0" 
        key="{ $bibl/@key }" 
        work="{ $bibl/tei:location/@work }" 
        count-pages="{common:integer($bibl/tei:location/@count-pages)}"
        folio-sort-attribute="{ $bibl/tei:location/@folio-sort-attribute }">
    { 
        for $volume in $bibl/tei:location/tei:volume
        return
            <volume number="{ $volume/@number }" start-page="{ $volume/@start-page }" end-page="{ $volume/@end-page }"/>
    }
    </location>
};

declare function tei-content:ancestors($tei as element(tei:TEI), $resource-id as xs:string, $nest as xs:integer) as element()? {
    
    (: Returns an ancestor tree for the tei file :)
    
    let $source-bibl := tei-content:source-bibl($tei, $resource-id)
    let $parent-id := $source-bibl/tei:idno/@parent-id
    let $parent-tei := tei-content:tei($parent-id, 'section')
    
    return
        if($parent-tei) then
            <parent xmlns="http://read.84000.co/ns/1.0" id="{ $parent-id }" nesting="{ $nest }" type="{ $parent-tei//tei:teiHeader/tei:fileDesc/@type }">
                <titles>
                {
                    tei-content:title-set($parent-tei, 'mainTitle')
                }
                </titles>
                { 
                    tei-content:ancestors($parent-tei, '', $nest + 1) 
                }
            </parent>
         else
            ()
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
    
    let $document-uri := base-uri($tei)
    let $document-uri-tokenised := tokenize($document-uri, '/')
    let $document-filename := $document-uri-tokenised[last()]
    let $document-path := substring-before($document-uri, $document-filename)
    return
        concat($document-path, $document-filename)

};

declare function tei-content:last-updated($fileDesc as element()?) as xs:dateTime {
    xs:dateTime(($fileDesc/tei:notesStmt/tei:note[@type eq "lastUpdated"][@date-time gt ''][1]/@date-time, '2010-01-01T00:00:00')[1])
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
declare function tei-content:version-number($version-number-str as xs:string) as xs:integer* {
    
    (: Split the numbers :)
    let $version-number-split := tokenize(tei-content:strip-version-number($version-number-str), '\.')
    
    return (
        if(count($version-number-split) gt 0 and functx:is-a-number($version-number-split[1])) then
            xs:integer($version-number-split[1])
        else
            0
        ,
        if(count($version-number-split) gt 1 and functx:is-a-number($version-number-split[2])) then
            xs:integer($version-number-split[2])
        else
            0
        ,
        if(count($version-number-split) gt 2 and functx:is-a-number($version-number-split[3])) then
            xs:integer($version-number-split[3])
        else
            0
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


