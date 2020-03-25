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
        common:normalize-space(
            $tei/tei:text/tei:front/tei:div[@type eq "abstract"]/*
        )
    }
    </abstract>
    
};

declare function section:warning($tei as element(tei:TEI)) as element() {

    <warning xmlns="http://read.84000.co/ns/1.0">
    { 
        common:normalize-space(
            $tei/tei:text/tei:front/tei:div[@type eq "warning"]/*
        )
    }
    </warning>
    
};

declare function section:about($tei as element(tei:TEI)) as element() {

    <about xmlns="http://read.84000.co/ns/1.0">
    { 
        common:normalize-space(
            $tei/tei:text/tei:body/tei:div[@type eq "about"]/*
        )
    }
    </about>
    
};

declare function section:child-sections($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string) as element() {
    section:child-sections($tei, $include-text-stats, $include-texts, 1)
};

declare function section:child-sections($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string, $nest as xs:integer) as element()* {
    
    let $id := upper-case(tei-content:id($tei))
    let $type := $tei/tei:teiHeader/tei:fileDesc/@type
    
    (: Get child-sections recursively so we end up with whole tree :)
    let $child-sections :=
        for $child-section in $section:sections//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
            order by xs:integer($child-section/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index) ascending
        return
            section:child-sections($child-section, $include-text-stats, $include-texts, $nest + 1)
    
    (: Get child texts :)
    let $child-texts := 
        if($id eq 'ALL-TRANSLATED') then
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $tei-content:published-status-ids]]
        else
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
    
    let $child-texts-output := 
        if(($include-texts = ('descendants', 'descendants-published')) or ($include-texts = ('children', 'children-published') and ($nest eq 1 or ($type eq 'grouping' and $nest eq 2)))) then
            (: List child texts :)
            for $tei in 
                
                (: published only :)
                if($include-texts = ('children-published', 'descendants-published')) then
                    $child-texts[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-status-ids]
                else
                    $child-texts
                    
                (: Get the correct Toh for this parent :)
                for $resource-id in 
                    if(not($id eq 'ALL-TRANSLATED')) then
                        $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id = $id]/@key
                    else
                        $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                return
                    section:text($tei, $resource-id, ($id eq 'ALL-TRANSLATED'))
        else
            ()
    
    let $child-texts-fileDesc := $child-texts/tei:teiHeader/tei:fileDesc
    
    (: Get stats on progress :)
    let $text-stats := 
        if($include-text-stats) then
            
            let $count-text-children := 
                if(not($id eq 'ALL-TRANSLATED')) then
                    count($child-texts-fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]) 
                else
                    count($child-texts-fileDesc/tei:sourceDesc/tei:bibl)
                    
            let $count-published-children := 
                if(not($id eq 'ALL-TRANSLATED')) then
                    count($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:published-status-ids]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id])
                else
                    count($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:published-status-ids]/tei:sourceDesc/tei:bibl)
                    
            let $count-in-progress-children := 
                if(not($id eq 'ALL-TRANSLATED')) then
                    count($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-status-ids]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id])
                else
                    count($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-status-ids]/tei:sourceDesc/tei:bibl)
            
            let $sum-pages-text-children := 
                if(not($id eq 'ALL-TRANSLATED')) then
                    sum($child-texts-fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]/tei:location/@count-pages ! common:integer(.)) 
                else
                    sum($child-texts-fileDesc/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
                    
            let $sum-pages-published-children := 
                if(not($id eq 'ALL-TRANSLATED')) then
                    sum($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:published-status-ids]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]/tei:location/@count-pages ! common:integer(.))
                else
                    sum($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:published-status-ids]/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
                    
            let $sum-pages-in-progress-children := 
                if(not($id eq 'ALL-TRANSLATED')) then
                    sum($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-status-ids]/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]/tei:location/@count-pages ! common:integer(.))
                else
                    sum($child-texts-fileDesc[tei:publicationStmt/@status = $tei-content:in-progress-status-ids]/tei:sourceDesc/tei:bibl/tei:location/@count-pages ! common:integer(.))
            
            
            return
                <text-stats xmlns="http://read.84000.co/ns/1.0">
                    <stat type="count-text-children" value="{ $count-text-children }"/>
                    <stat type="count-published-children" value="{ $count-published-children }"/>
                    <stat type="count-in-progress-children" value="{ $count-in-progress-children }"/>
                    <stat type="count-text-descendants" value="{ $count-text-children + sum($child-sections//m:stat[@type = 'count-text-children']/@value ! xs:integer(.)) }"/>
                    <stat type="count-published-descendants" value="{ $count-published-children + sum($child-sections//m:stat[@type = 'count-published-children']/@value ! xs:integer(.)) }"/>
                    <stat type="count-in-progress-descendants" value="{ $count-in-progress-children + sum($child-sections//m:stat[@type = 'count-in-progress-children']/@value ! xs:integer(.)) }"/>
                    <stat type="sum-pages-text-children" value="{ $sum-pages-text-children }"/>
                    <stat type="sum-pages-published-children" value="{ $sum-pages-published-children }"/>
                    <stat type="sum-pages-in-progress-children" value="{ $sum-pages-in-progress-children }"/>
                    <stat type="sum-pages-text-descendants" value="{ $sum-pages-text-children + sum($child-sections//m:stat[@type = 'sum-pages-text-children']/@value ! xs:integer(.)) }"/>
                    <stat type="sum-pages-published-descendants" value="{ $sum-pages-published-children + sum($child-sections//m:stat[@type = 'sum-pages-published-children']/@value ! xs:integer(.)) }"/>
                    <stat type="sum-pages-in-progress-descendants" value="{ $sum-pages-in-progress-children + sum($child-sections//m:stat[@type = 'sum-pages-in-progress-children']/@value ! xs:integer(.)) }"/>
                </text-stats>
            else
                ()
    
    (: Derive last updated from tree :)
    let $last-updated := 
        max((
            (: child texts :)
            $child-texts-fileDesc ! tei-content:last-updated(.), 
            
            (: sub sections :)
            $child-sections/@last-updated ! xs:dateTime(.), 
            
            (: default date :)
            tei-content:last-updated(<empty/>)
        ))
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            attribute id { $id },
            attribute type { $type },
            attribute nesting { $nest },
            attribute uri { base-uri($tei) },
            attribute sort-index { $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            attribute last-updated { $last-updated },
            attribute include-texts { $include-texts },
            section:titles($tei),
            (: avoid duplicate ids :)
            if($nest gt 1) then
                common:strip-ids(section:abstract($tei))
            else
                section:abstract($tei),
            common:strip-ids(section:warning($tei)),
            $text-stats,
            $child-sections,
            element { QName('http://read.84000.co/ns/1.0', 'texts') }{
                attribute published-only { if($include-texts = ('children-published', 'descendants-published')) then '1' else '0' },
                $child-texts-output
            }
        }
        
};

declare function section:text($tei as element(tei:TEI), $resource-id as xs:string, $include-ancestors as xs:boolean) as element() {
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute resource-id { $resource-id },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        attribute uri { base-uri($tei) },
        attribute canonical-html { translation:canonical-html($resource-id) },
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

declare function section:section-tree($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string) as element() {
    
    let $section := section:child-sections($tei, $include-text-stats, $include-texts)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            $section/@*,
            $section/*,
            section:about($tei),
            tei-content:ancestors($tei, '', 1)
        }
        
};

declare function section:texts($section-id as xs:string, $published-only as xs:boolean, $include-descendants as xs:boolean) as element() {
    let $tei := tei-content:tei($section-id, 'section')
    return
        if($include-descendants)then
            if($published-only)then
                section:child-sections($tei, true(), 'descendants-published')
            else
                section:child-sections($tei, true(), 'descendants')
        else
            if($include-descendants)then
                section:child-sections($tei, true(), 'children-published')
            else
                section:child-sections($tei, true(), 'children')
};

