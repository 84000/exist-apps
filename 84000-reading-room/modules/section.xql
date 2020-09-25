xquery version "3.1";

module namespace section="http://read.84000.co/section";

(:declare namespace o="http://www.tbrc.org/models/outline";:)
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare variable $section:sections := collection($common:sections-path);
declare variable $section:texts := collection($common:translations-path);

declare function section:titles($tei as element(tei:TEI)) as element() {
    
    element { QName('http://read.84000.co/ns/1.0', 'titles') } {
        tei-content:title-set($tei, 'mainTitle')
    }
    
};

declare function section:abstract($tei as element(tei:TEI)) as element() {

    element { QName('http://read.84000.co/ns/1.0', 'abstract') } {
        common:normalize-space(
            $tei/tei:text/tei:front/tei:div[@type eq "abstract"]/*
        )
    }
    
};

declare function section:warning($tei as element(tei:TEI)) as element() {

    element { QName('http://read.84000.co/ns/1.0', 'warning') } { 
        common:normalize-space(
            $tei/tei:text/tei:front/tei:div[@type eq "warning"]/*
        )
    }
    
};

declare function section:about($tei as element(tei:TEI)) as element() {

    element { QName('http://read.84000.co/ns/1.0', 'about') } { 
        common:normalize-space(
            $tei/tei:text/tei:body/tei:div[@type eq "about"]/*
        )
    }
    
};

declare function section:filters($tei as element(tei:TEI)) as element() {

    element { QName('http://read.84000.co/ns/1.0', 'filters') } { 
        common:normalize-space(
            $tei/tei:text/tei:body/tei:div[@type eq "filter"]
        )
    }
    
};

declare function section:child-sections($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string) as element(m:section) {
    section:child-sections($tei, $include-text-stats, $include-texts, 1)
};

declare function section:child-sections($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string, $nest as xs:integer) as element(m:section) {
    
    let $id := upper-case(tei-content:id($tei))
    let $section-parent-id := if($id eq 'ALL-TRANSLATED') then 'LOBBY' else $id
    
    let $type := $tei/tei:teiHeader/tei:fileDesc/@type
    
    (: Get child-sections recursively so we end up with whole tree :)
    let $child-sections :=
        for $child-section in $section:sections//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $section-parent-id]]]
            order by xs:integer($child-section/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index) ascending
        return
            section:child-sections($child-section, $include-text-stats, $include-texts, $nest + 1)
    
    (: Child texts for stats :)
    let $child-texts := 
        if($id eq 'ALL-TRANSLATED') then
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $tei-content:published-status-ids]]]
        else
            $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $id]]]
    
    (: Child texts to list :)
    let $child-texts-output := 
        if(($include-texts = ('descendants', 'descendants-published')) or ($include-texts = ('children', 'children-published') and ($nest eq 1 or ($type eq 'grouping' and $nest eq 2)))) then
            (: List child texts :)
            for $tei in 
                (: published only :)
                if($include-texts = ('children-published', 'descendants-published')) then
                    $child-texts[tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $tei-content:published-status-ids]]]
                else
                    $child-texts
            
                (: Get the correct Toh for this parent :)
                for $resource-id in 
                    (: All translated get all the variants :)
                    if($id eq 'ALL-TRANSLATED') then
                        $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                    else
                        $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id = $id]]/@key
                
                let $text-id := tei-content:id($tei)
                let $source := tei-content:source($tei, $resource-id)
                
                (: ~ Apply the filters here?
                let $text-parent-section := ($id, $child-sections/@id)
                let $filters-section-ids := $filters[@section-id]/@section-id
                
                where (
                    (not($filters[@max-pages]) or $filters[@max-pages ! xs:integer(.) ge $source/m:location/@count-pages ! xs:integer(.)])
                    and (not($filters[@section-id]) or $text-parent-section[ancestor-or-self::m:section/@id = $filters-section-ids])
                    and (not($filters[@text-id]) or $filters[@text-id = $text-id])
                ):)
                
                return
                    element { QName('http://read.84000.co/ns/1.0', 'text') }{
                        attribute id { $text-id },
                        attribute resource-id { $resource-id },
                        attribute status { tei-content:translation-status($tei) },
                        attribute status-group { tei-content:translation-status-group($tei) },
                        attribute uri { base-uri($tei) },
                        attribute canonical-html { translation:canonical-html($resource-id) },
                        attribute last-updated { tei-content:last-updated($tei//tei:fileDesc) },
                        $source,
                        translation:toh($tei, $resource-id),
                        translation:titles($tei),
                        translation:title-variants($tei),
                        translation:publication($tei),
                        translation:downloads($tei, $resource-id, 'any-version'),
                        translation:summary($tei)
                    }
        else
            ()
    
    let $child-texts-fileDesc := $child-texts/tei:teiHeader/tei:fileDesc
    let $child-texts-fileDesc-published := $child-texts-fileDesc[tei:publicationStmt[@status = $tei-content:published-status-ids]](:[range:field(("translation-status"), "=", $tei-content:published-status-ids)]:)
    let $child-texts-fileDesc-in-progress := $child-texts-fileDesc[tei:publicationStmt[@status = $tei-content:in-progress-status-ids]](:[range:field(("translation-status"), "=", $tei-content:in-progress-status-ids)]:)
    
    let $child-texts-bibls := $child-texts-fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $id]]
    let $child-texts-bibls-published := $child-texts-fileDesc-published/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $id]](:[range:field(("parent-id"), "eq", $id)]:)
    let $child-texts-bibls-in-progress := $child-texts-fileDesc-in-progress/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $id]](:[range:field(("parent-id"), "eq", $id)]:)
    
    (: Get stats on progress :)
    let $text-stats := 
        if($include-text-stats) then
            
            let $count-text-children :=             count($child-texts-bibls)
            let $count-published-children :=        count($child-texts-bibls-published)
            let $count-in-progress-children :=      count($child-texts-bibls-in-progress)
            
            let $sum-pages-text-children :=         sum($child-texts-bibls/tei:location/@count-pages ! common:integer(.)) 
            let $sum-pages-published-children :=    sum($child-texts-bibls-published/tei:location/@count-pages ! common:integer(.))
            let $sum-pages-in-progress-children :=  sum($child-texts-bibls-in-progress/tei:location/@count-pages ! common:integer(.))
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'text-stats') } { 
                    element stat {
                        attribute type { 'count-text-children' },
                        attribute value { $count-text-children }
                    },
                    element stat {
                        attribute type { 'count-published-children' },
                        attribute value { $count-published-children }
                    },
                    element stat {
                        attribute type { 'count-in-progress-children' },
                        attribute value { $count-in-progress-children }
                    },
                    element stat {
                        attribute type { 'count-text-descendants' },
                        attribute value { $count-text-children + sum($child-sections//m:stat[@type = 'count-text-children']/@value ! xs:integer(.)) }
                    },
                    element stat {
                        attribute type { 'count-published-descendants' },
                        attribute value { $count-published-children + sum($child-sections//m:stat[@type = 'count-published-children']/@value ! xs:integer(.)) }
                    },
                    element stat {
                        attribute type { 'count-in-progress-descendants' },
                        attribute value { $count-in-progress-children + sum($child-sections//m:stat[@type = 'count-in-progress-children']/@value ! xs:integer(.)) }
                    },
                    element stat {
                        attribute type { 'sum-pages-text-children' },
                        attribute value { $sum-pages-text-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-published-children' },
                        attribute value { $sum-pages-published-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-in-progress-children' },
                        attribute value { $sum-pages-in-progress-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-text-descendants' },
                        attribute value { $sum-pages-text-children + sum($child-sections//m:stat[@type = 'sum-pages-text-children']/@value ! xs:integer(.)) }
                    },
                    element stat {
                        attribute type { 'sum-pages-published-descendants' },
                        attribute value { $sum-pages-published-children + sum($child-sections//m:stat[@type = 'sum-pages-published-children']/@value ! xs:integer(.)) }
                    },
                    element stat {
                        attribute type { 'sum-pages-in-progress-descendants' },
                        attribute value { $sum-pages-in-progress-children + sum($child-sections//m:stat[@type = 'sum-pages-in-progress-children']/@value ! xs:integer(.)) }
                    }
                }
            else ()
    
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

declare function section:section-tree($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string, $apply-filters as element(m:filter)*) as element(m:section) {
    
    let $section := section:child-sections($tei, $include-text-stats, $include-texts)

    let $section-filtered := 
        if($apply-filters) then
            section:filter-texts($section, $apply-filters)
        else
            $section
    
    return
        element { node-name($section) }{
            $section/@*,
            $section-filtered/*,
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

declare function section:filter-texts($section as element(m:section), $filters as element(m:filter)*) as element(m:section) {
    element { node-name($section) }{
        $section/@*,
        for $node in $section/*
        return
            if( local-name($node) eq 'texts' ) then
                element { node-name($node) }{
                    $section/@*,
                    $filters,
                    for $text in $node/m:text
                    let $source := $text/m:source
                    let $text-parent-section := $section/descendant-or-self::m:section[@id eq $source/@parent-id]
                    let $filters-section-ids := $filters[@section-id]/@section-id
                    return
                        element { node-name($text) }{
                            $text/@*,
                            attribute filter-match {(
                                (not($filters[@max-pages]) or $source/m:location/@count-pages ! xs:integer(.) le $filters[@max-pages]/@max-pages ! xs:integer(.))
                                and (not($filters[@section-id]) or $text-parent-section[ancestor-or-self::m:section/@id = $filters-section-ids])
                                and (not($filters[@text-id]) or $filters[@text-id = $text/@id])
                            )},
                            $text/*
                        }
                }
            else
                $node
    }
};