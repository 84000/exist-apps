xquery version "3.1";

module namespace tei-content="http://read.84000.co/tei-content";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";

declare variable $tei-content:translations-collection := collection($common:translations-path);
declare variable $tei-content:sections-collection := collection($common:sections-path);
declare variable $tei-content:text-statuses := doc(concat($common:data-path, '/config/text-statuses.xml'))/m:text-statuses;
declare variable $tei-content:published-statuses := $tei-content:text-statuses/m:status[@group = ('published')]/@status-id;
declare variable $tei-content:in-progress-statuses := $tei-content:text-statuses/m:status[@group = ('translated', 'in-translation')]/@status-id;
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

declare function tei-content:id($tei as element()) as xs:string {
    (: Returns the idno in a given tei doc :)
    $tei//tei:publicationStmt/tei:idno/@xml:id
};

declare function tei-content:tei($resource-id as xs:string, $resource-type as xs:string) as element()? {

    (:
        This is controls the method of looking up the resource-id 
        from the controller and finding the document.
        Current options: 
        1.  UT Number e.g. translation/UT22084-061-013.html
            For Tohoku variations this will default to the first.
        2.  Tohoku Number e.g. translation/toh739.html
            Will show variations for that Tohoku key.
    :)
    
    let $collection := 
        if($resource-type eq 'translation')then
            $tei-content:translations-collection
        else if($resource-type = ('section', 'pseudo-section')) then
            $tei-content:sections-collection
        else
            ()
    
    (: based on Tohoku number :)
    let $tei := 
        if($resource-type eq 'translation')then
            $collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]][1]
        else
            ()
    
    return
        if(not($tei)) then
            (: Fallback to UT number :)
            $collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id eq upper-case($resource-id)]]
        else
            $tei
    
};

declare function tei-content:title($tei as element()) as xs:string {
    (: Returns a standardised title in a given tei doc :)
    
    let $title := normalize-space($tei//tei:fileDesc//tei:title[@type='mainTitle'][@xml:lang eq 'en'][1]/text())
    
    let $title := 
        if(not($title gt ''))then
            normalize-space($tei//tei:fileDesc//tei:title[@xml:lang eq 'en'][1]/text())
        else
            $title
            
    let $title-missing :=
        if(not($title gt ''))then
            concat(normalize-space($tei//tei:fileDesc//tei:title[@xml:lang eq 'Sa-Ltn'][1]/text()), ' (awaiting English title)')
        else
            $title
    
    return
        translate($title-missing, '&#x2003;', '&#x20;')
};

declare function tei-content:title($tei as node(), $type as xs:string?, $lang as xs:string*) as xs:string {
    translate(normalize-space(data($tei//tei:titleStmt/tei:title[@type eq $type][lower-case(@xml:lang) = $lang])), '&#x2003;', '&#x20;')
};

declare function tei-content:titles($tei as element()) as element() {

    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        for $title in $tei//tei:titleStmt/tei:title
        return
            <title 
                xml:lang="{ $title/@xml:lang }"
                type="{ $title/@type }">{
                translate(normalize-space($title/text()), '&#x2003;', '&#x20;') 
            }</title>
    }
    </titles>
    
};

declare function tei-content:title-set($tei as element(), $type as xs:string) as element()* {
    
    let $bo := tei-content:title($tei, $type , 'bo')
    let $bo-ltn := tei-content:title($tei, $type , ('bo-ltn', ''))
    let $en := tei-content:title($tei, $type , ('eng', 'en'))
    let $sa-ltn := tei-content:title($tei, $type , 'sa-ltn')
    
    let $source-bibl := tei-content:source-bibl($tei, '')
    
    return 
    (
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="en">{ $en }</title>,
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="bo">
        {
            if(not($bo) and $bo-ltn) then
                common:bo-from-wylie($bo-ltn)
            else
                $bo
        }
        </title>,
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="bo-ltn">{ $bo-ltn }</title>,
        <title xmlns="http://read.84000.co/ns/1.0" xml:lang="sa-ltn">{ $sa-ltn }</title>,        
        if($source-bibl/@type eq 'chapter') then
            let $parent := tei-content:tei($source-bibl/tei:idno/@parent-id, 'section')
            return
                <parent xmlns="http://read.84000.co/ns/1.0">
                    <title xml:lang="en">
                    {
                        tei-content:title($parent)
                    }
                    </title>
                </parent>
        else
            ()
    )
    
};

declare function tei-content:translation-status($tei as element()) as xs:string {
    (: Returns the status of the text :)
    let $status := $tei//tei:teiHeader//tei:publicationStmt/@status
    return
        if($status) then
            $status
        else
            ''
};

declare function tei-content:translation-status-group($tei as element()) as xs:string? {
    (: Returns the status group of the text :)
    string($tei-content:text-statuses/m:status[@status-id eq tei-content:translation-status($tei)]/@group)
};

declare function tei-content:text-statuses-selected($selected-ids as xs:string*) as element() {
    <text-statuses xmlns="http://read.84000.co/ns/1.0">
    {
        element status 
        { 
            attribute value { '0' },
            if ('0' = $selected-ids) then attribute selected { 'selected' } else '',
            text { '0 / Not started' }
            
        }
    }
    {
        for $status in $tei-content:text-statuses/m:status
        return 
            element status
            { 
                $status/@*,
                attribute value { $status/@status-id },
                if ($status/@status-id = $selected-ids) then attribute selected { 'selected' } else '',
                text { concat($status/@status-id, ' / ', $status/@group, ' / ', $status/text()) }
                
            }
    }
    </text-statuses>
};

declare function tei-content:source-bibl($tei as element(), $resource-id as xs:string) as node()? {
    (: Returns a bibl node based on a resource-id :)
    let $bibl := $tei//tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)][1]
    return
        if(not($bibl)) then
            $tei//tei:sourceDesc/tei:bibl[1]
        else
            $bibl
};

declare function tei-content:source($tei as element(), $resource-id as xs:string) as element() {
    
    (: Returns a source node filtered by resource-id :)
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
    return
        <source xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }">
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
            <location>
                <start volume="{ $bibl/tei:location/tei:start/@volume }" page="{ $bibl/tei:location/tei:start/@page }"/>
                <end volume="{ $bibl/tei:location/tei:end/@volume }" page="{ $bibl/tei:location/tei:end/@page }"/>
            </location>
        </source>
};

declare function tei-content:ancestors($tei as element(), $resource-id as xs:string, $nest as xs:integer) as element()? {
    
    (: Returns an ancestor tree for the translation :)
    
    let $source-bibl := tei-content:source-bibl($tei, $resource-id)
    let $parent-id := $source-bibl/tei:idno/@parent-id
    let $parent-tei := tei-content:tei($parent-id, 'section')
    
    return
        if($parent-tei) then
            <parent xmlns="http://read.84000.co/ns/1.0" id="{ $parent-id }" nesting="{ $nest }" type="{ $parent-tei//tei:teiHeader/tei:fileDesc/@type }">
                <title xml:lang="en">{ tei-content:title($parent-tei) }</title>
                { 
                    tei-content:ancestors($parent-tei, '', $nest + 1) 
                }
            </parent>
         else
            ()
};


declare function tei-content:locked-by-user($tei as element()) as xs:string? {
    
    let $document-uri := base-uri($tei)
    let $document-uri-tokenised := tokenize($document-uri, '/')
    let $document-filename := $document-uri-tokenised[last()]
    let $document-path := substring-before($document-uri, $document-filename)
    return
        xmldb:document-has-lock(concat("xmldb:exist://", $document-path), $document-filename)

};

declare function tei-content:document-url($tei as element()) as xs:string {
    
    let $document-uri := base-uri($tei)
    let $document-uri-tokenised := tokenize($document-uri, '/')
    let $document-filename := $document-uri-tokenised[last()]
    let $document-path := substring-before($document-uri, $document-filename)
    return
        concat($document-path, $document-filename)

};

declare function tei-content:last-updated($fileDesc as element()) as xs:dateTime? {
    xs:dateTime(($fileDesc/tei:notesStmt/tei:note[@type eq "lastUpdated"][@date-time gt ''][1]/@date-time, '2010-01-01T00:00:00')[1])
};

