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

declare function section:titles($tei as element()) as element() {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'mainTitle')
    }
    </titles>
};

declare function section:abstract($tei as element()) as element() {

    <abstract xmlns="http://read.84000.co/ns/1.0">
    { 
        $tei/tei:text/tei:front/tei:div[@type eq "abstract"]/*
    }
    </abstract>
    
};

declare function section:warning($tei as element()) as element() {

    <warning xmlns="http://read.84000.co/ns/1.0">
    { 
        $tei/tei:text/tei:front/tei:div[@type eq "warning"]/*
    }
    </warning>
    
};

declare function section:about($tei as element()) as element() {

    <about xmlns="http://read.84000.co/ns/1.0">
    { 
        $tei/tei:text/tei:body/tei:div[@type eq "about"]/*
    }
    </about>
    
};

declare function section:descendants($tei as element(), $nest as xs:integer, $include-text-stats as xs:boolean) as element() {
    let $id := upper-case(tei-content:id($tei))
    return
        <child xmlns="http://read.84000.co/ns/1.0" id="{ $id }" nesting="{ $nest }" uri="{ base-uri($tei) }">
            <title xml:lang="en">{ tei-content:title($tei) }</title>
            {
                if($include-text-stats) then
                    section:text-stats($tei)
                else
                    ()
            }
            {
                for $child-section in $section:sections//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@parent-id eq $id]
                order by xs:integer($child-section/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index) ascending
                return
                    section:descendants($child-section, $nest + 1, $include-text-stats)
            }
        </child>
};

declare function section:text-stats($tei as element()) as element() {
    
    let $id := upper-case(tei-content:id($tei))
    let $children-fileDesc := collection($common:translations-path)//tei:fileDesc[tei:sourceDesc/tei:bibl/tei:idno/@parent-id eq $id]
    let $descendants :=  section:descendants($tei, 1, false())
    let $descendants-ids := $descendants//m:child/@id
    let $descendants-fileDesc := collection($common:translations-path)//tei:fileDesc[tei:sourceDesc/tei:bibl/tei:idno/@parent-id = ($id, $descendants-ids)](::)
    
    return 
        <text-stats xmlns="http://read.84000.co/ns/1.0">
            <stat type="count-text-children">
            { 
                count($children-fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]) 
            }
            </stat>
            <stat type="count-published-children">
            { 
                count($children-fileDesc[tei:publicationStmt/@status = $tei-content:published-statuses]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id])
            }
            </stat>
            <stat type="count-in-progress-children">
            { 
                count($children-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-statuses]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id])
            }
            </stat>
            <stat type="count-text-descendants">
            { 
                count($descendants-fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id = ($id, $descendants-ids)]) 
            }
            </stat>
            <stat type="count-published-descendants">
            { 
                count($descendants-fileDesc[tei:publicationStmt/@status = $tei-content:published-statuses]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id = ($id, $descendants-ids)])
            }
            </stat>
            <stat type="count-in-progress-descendants">
            { 
                count($descendants-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-statuses]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id = ($id, $descendants-ids)])
            }
            </stat>
        </text-stats>
        
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
            let $descendants :=  section:descendants($tei, 1, false())
            let $descendants-ids := ($section-id, $descendants//m:child/@id)
            return 
                $descendants-ids
        else
            ($section-id)
    
    let $section-texts := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@parent-id = $section-ids]
    
    let $published-texts := 
        if($published-only) then
            $section-texts[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses]
        else
            $section-texts
    
    let $texts := 
        for $tei in $published-texts
            for $resource-id in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id = $section-ids]/@key
            return
                <text xmlns="http://read.84000.co/ns/1.0" resource-id="{ $resource-id }" status="{ tei-content:translation-status($tei) }" uri="{ base-uri($tei) }">
                    { tei-content:source($tei, $resource-id) }
                    { translation:toh($tei, $resource-id) }
                    { translation:titles($tei) }
                    { translation:title-variants($tei) }
                    { translation:downloads($tei, $resource-id, 'any-version') }
                    { translation:summary($tei) }
                </text>
    
    return
        <texts xmlns="http://read.84000.co/ns/1.0" section-id="{ $section-id }" published-only="{ if($published-only) then '1' else '0' }">
        {
            for $text in $texts
            order by 
                xs:integer($text/m:toh/@number), 
                $text/m:toh/@letter, 
                if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 0, 
                $text/m:toh/@chapter-letter
            return
                $text
        }
        </texts>
        
};

declare function section:all-translated-texts() as element() {
    
    <texts xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses]
            for $resource-id in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        return
            <text resource-id="{ $resource-id }" status="{ tei-content:translation-status($tei) }">
                { tei-content:source($tei, $resource-id) }
                { translation:toh($tei, $resource-id) }
                { translation:titles($tei) }
                { translation:title-variants($tei) }
                { tei-content:ancestors($tei, $resource-id, 1) }
                { translation:downloads($tei, $resource-id, 'any-version') }
                { translation:summary($tei) }
            </text>
        
    }
    </texts>
        
};

declare function section:sections($id as xs:string, $published-only as xs:boolean) as element() {
    
    <sections xmlns="http://read.84000.co/ns/1.0">
    {
        for $section in $section:sections//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@parent-id eq upper-case($id)]
            order by 
                xs:integer($section//tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index),
                $section//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "en"][1]
        return
            section:section($section, $published-only)
    }
    </sections>
    
};

declare function section:section($tei as node(), $published-only as xs:boolean) as element() {

    let $id := tei-content:id($tei)
    let $type := $tei//tei:teiHeader/tei:fileDesc/@type
    return
        <section xmlns="http://read.84000.co/ns/1.0" 
            id="{ $id }" 
            type="{ $type }" 
            sort-index="{ $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index }">
            { section:titles($tei) }
            { section:abstract($tei) }
            { section:warning($tei) }
            { section:about($tei) }
            { section:text-stats($tei) }
            {
                if($type eq 'grouping') then
                    section:texts($id, $published-only, false())
                else
                    ()
            }
        </section>
    
};

