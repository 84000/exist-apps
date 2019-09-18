xquery version "3.1";

module namespace section="http://read.84000.co/section";

declare namespace o="http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare variable $section:sections := collection($common:sections-path);
declare variable $section:texts := collection($common:translations-path);

declare function section:titles($tei as element(tei:TEI)) as element() {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'mainTitle')
    }
    </titles>
};

declare function section:abstract($tei as element(tei:TEI)) as element() {

    <abstract xmlns="http://read.84000.co/ns/1.0">
    { 
        common:normalize-space($tei/tei:text/tei:front/tei:div[@type eq "abstract"]/node())
    }
    </abstract>
    
};

declare function section:warning($tei as element(tei:TEI)) as element() {

    <warning xmlns="http://read.84000.co/ns/1.0">
    { 
        common:normalize-space($tei/tei:text/tei:front/tei:div[@type eq "warning"]/node())
    }
    </warning>
    
};

declare function section:about($tei as element(tei:TEI)) as element() {

    <about xmlns="http://read.84000.co/ns/1.0">
    { 
        common:normalize-space($tei/tei:text/tei:body/tei:div[@type eq "about"]/node())
    }
    </about>
    
};

declare function section:text-stats($tei as element(tei:TEI)) as element()* {
    let $descendants := section:descendants($tei, true())
    return
    (
        $descendants/m:text-stats,
        $descendants/m:descendants
    )
};

declare function section:descendants($tei as element(tei:TEI), $include-text-stats as xs:boolean) as element() {
    section:descendants($tei, $include-text-stats, 1)
};

declare function section:descendants($tei as element(tei:TEI), $include-text-stats as xs:boolean, $nest as xs:integer) as element()* {
    
    let $id := upper-case(tei-content:id($tei))
    
    let $descendants :=
        for $child-section in $section:sections//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
            order by xs:integer($child-section/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index) ascending
        return
            section:descendants($child-section, $include-text-stats, $nest + 1)
    
    let $text-fileDesc := $section:texts//tei:fileDesc[tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
    
    let $text-stats := 
        if($include-text-stats) then
        
            let $count-text-children := count($text-fileDesc/tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]) 
            let $count-published-children := count($text-fileDesc[tei:publicationStmt/@status = $tei-content:published-status-ids]/tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id])
            let $count-in-progress-children := count($text-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-status-ids]/tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id])
            
            return
                <text-stats xmlns="http://read.84000.co/ns/1.0">
                    <stat type="count-text-children" value="{ $count-text-children }"/>
                    <stat type="count-published-children" value="{ $count-published-children }"/>
                    <stat type="count-in-progress-children" value="{ $count-in-progress-children }"/>
                    <stat type="count-text-descendants" value="{ $count-text-children + sum($descendants//m:stat[@type = 'count-text-children']/@value ! xs:integer(.)) }"/>
                    <stat type="count-published-descendants" value="{ $count-published-children + sum($descendants//m:stat[@type = 'count-published-children']/@value ! xs:integer(.)) }"/>
                    <stat type="count-in-progress-descendants" value="{ $count-in-progress-children + sum($descendants//m:stat[@type = 'count-in-progress-children']/@value ! xs:integer(.)) }"/>
                </text-stats>
            else
                ()
    
    let $last-updated := 
        max((
            (: child texts :)
            $text-fileDesc ! tei-content:last-updated(.), 
            
            (: sub sections :)
            $descendants/@last-updated ! xs:dateTime(.), 
            
            (: default date :)
            tei-content:last-updated(<empty/>)
        ))
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'descendants') }{
            attribute id { $id },
            attribute nesting { $nest },
            attribute uri { base-uri($tei) },
            attribute sort-index { $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            attribute last-updated { $last-updated },
            element title {
                attribute xml:lang { 'en' },
                tei-content:title($tei)
            },
            $text-stats,
            $descendants
        }
        
};

declare function section:texts($section-id as xs:string, $published-only as xs:boolean, $include-descendants as xs:boolean) as element() {
    
    (:
        $include-descendants
        -------------------------------
        false() (default) returns only direct children
        true() includes all descendants
    :)
    
    let $section-ids := 
        if($include-descendants) then
            let $tei := tei-content:tei($section-id, 'section')
            let $descendants :=  section:descendants($tei, false())
            let $descendants-ids := ($section-id, $descendants//m:descendants/@id)
            return 
                $descendants-ids
        else
            ($section-id)
    
    let $section-texts := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@parent-id = $section-ids]
    
    let $published-texts := 
        if($published-only) then
            $section-texts[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-status-ids]
        else
            $section-texts
    
    let $texts := 
        for $tei in $published-texts
            for $resource-id in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id = $section-ids]/@key
            return
                section:text($tei, $resource-id, false())
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'texts') }{
            attribute section-id { $section-id },
            attribute published-only { if($published-only) then '1' else '0' },
            for $text in $texts
            order by 
                xs:integer($text/m:toh/@number), 
                $text/m:toh/@letter, 
                if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 0, 
                $text/m:toh/@chapter-letter
            return
                $text
        }
        
};

declare function section:all-translated-texts() as element() {
    element { QName('http://read.84000.co/ns/1.0', 'texts') }{
        for $tei in collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-status-ids]
            for $resource-id in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        return
            section:text($tei, $resource-id, true())
    }
};

declare function section:text($tei as element(tei:TEI), $resource-id as xs:string, $include-ancestors as xs:boolean) as element() {
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute resource-id { $resource-id },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        attribute uri { base-uri($tei) },
        attribute last-updated { tei-content:last-updated($tei//tei:fileDesc) },
        tei-content:source($tei, $resource-id),
        if($include-ancestors) then 
            tei-content:ancestors($tei, $resource-id, 1)
        else 
            (),
        translation:toh($tei, $resource-id),
        translation:titles($tei),
        translation:title-variants($tei),
        translation:translation($tei),
        translation:downloads($tei, $resource-id, 'any-version'),
        translation:summary($tei)
    }
};

declare function section:base-section($tei as element(tei:TEI), $published-only as xs:boolean, $include-text-stats as xs:boolean) as element() {
    
    let $id := tei-content:id($tei)
    
    let $stats := 
        if($include-text-stats) then
            section:text-stats($tei)
        else
            ()
    
    let $texts := 
        if(lower-case($id) eq 'all-translated') then
            section:all-translated-texts()
        else
            section:texts($id, $published-only, false())
    
    let $subsections := 
        for $sub-section in $section:sections//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@parent-id eq upper-case($id)]
            order by 
                xs:integer($sub-section//tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index),
                $sub-section//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "en"][1]
        return
            section:sub-section($sub-section, $published-only)
            
    let $last-updated := max((
        
        (: Last time a child text was updated :)
        $texts/m:text[@last-updated gt '']/@last-updated ! xs:dateTime(.),
        
        (: Last time a descendant was updated :)
        $stats[@last-updated gt '']/@last-updated ! xs:dateTime(.)
        
    ))
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            attribute id { $id },
            attribute last-updated { $last-updated },
            section:titles($tei),
            section:abstract($tei),
            section:warning($tei),
            section:about($tei),
            tei-content:ancestors($tei, '', 1),
            $stats,
            $texts,
            $subsections
        }
        
};

declare function section:sub-section($tei as element(tei:TEI), $published-only as xs:boolean) as element() {
    
    let $id := tei-content:id($tei)
    let $type := $tei//tei:teiHeader/tei:fileDesc/@type
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'sub-section') }{
            attribute id { $id },
            attribute type { $type },
            attribute sort-index { $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            section:titles($tei),
            common:strip-ids(section:abstract($tei)),
            section:warning($tei),
            if($type eq 'grouping') then
                section:texts($id, $published-only, false())
            else
                ()
        }
    
};

