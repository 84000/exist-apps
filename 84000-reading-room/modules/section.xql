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

declare function section:text($tei as element(tei:TEI), $resource-id as xs:string, $include-ancestors as xs:boolean){
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute id { tei-content:id($tei) },
        attribute resource-id { $resource-id },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        attribute document-url { tei-content:document-url($tei) },
        attribute canonical-html { translation:canonical-html($resource-id, '') },
        attribute last-updated { tei-content:last-updated($tei//tei:fileDesc) },
        tei-content:source($tei, $resource-id),
        translation:toh($tei, $resource-id),
        tei-content:ancestors($tei, $resource-id, 0),
        translation:titles($tei),
        translation:title-variants($tei),
        translation:publication($tei),
        translation:downloads($tei, $resource-id, 'any-version'),
        translation:summary($tei)
    }
};

declare function section:child-sections($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string) as element(m:section) {
    section:child-sections($tei, $include-text-stats, $include-texts, 1)
};

declare function section:child-sections($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string, $nest as xs:integer) as element(m:section) {
    
    let $id := tei-content:id($tei) ! upper-case(.)
    
    let $type := $tei/tei:teiHeader/tei:fileDesc/@type
    
    (: Get child-sections recursively so we end up with whole tree :)
    let $child-sections :=
        for $child-section in $section:sections//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
            order by $child-section/tei:teiHeader//tei:sourceDesc/@sort-index ! xs:integer(.) ascending
        return
            section:child-sections($child-section, $include-text-stats, $include-texts, $nest + 1)
    
    (: Child texts for stats :)
    let $child-texts := $section:texts//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
    let $child-texts-fileDesc-published := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translation:published-status-ids]]
    let $child-texts-fileDesc-translated := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translation:translated-status-ids]]
    let $child-texts-fileDesc-in-translation := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translation:in-translation-status-ids]]
    let $child-texts-fileDesc-in-progress := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translation:in-progress-status-ids]]
    
    let $child-texts-bibls := $child-texts/tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]
    let $child-texts-bibls-published := $child-texts-fileDesc-published/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]
    let $child-texts-bibls-translated := $child-texts-fileDesc-translated/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]
    let $child-texts-bibls-in-translation := $child-texts-fileDesc-in-translation/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]
    let $child-texts-bibls-in-progress := $child-texts-fileDesc-in-progress/tei:sourceDesc/tei:bibl[tei:idno/@parent-id eq $id]
    
    (: Child texts to list :)
    let $child-texts-output := 
        if(($include-texts = ('descendants', 'descendants-published')) or ($include-texts = ('children', 'children-published') and ($nest eq 1 or ($type eq 'grouping' and $nest eq 2)))) then
            (: List child texts :)
            for $text-tei in 
                (: published only :)
                if($include-texts = ('children-published', 'descendants-published')) then
                    $child-texts[tei:teiHeader//tei:publicationStmt[@status = $translation:published-status-ids]]
                else
                    $child-texts
            
                (: Get the correct Toh for this parent :)
                for $resource-id in $text-tei//tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno[@parent-id = $id]]/@key
                return
                    section:text($text-tei, $resource-id, false())
        else ()
    
    (: Get stats on progress :)
    let $text-stats := 
        if($include-text-stats) then
            
            let $count-text-children :=             count($child-texts-bibls)
            let $count-published-children :=        count($child-texts-bibls-published)
            let $count-translated-children :=       count($child-texts-bibls-translated)
            let $count-in-translation-children :=   count($child-texts-bibls-in-translation)
            let $count-in-progress-children :=      count($child-texts-bibls-in-progress)
            
            let $sum-pages-text-children :=            sum($child-texts-bibls/tei:location/@count-pages ! common:integer(.)) 
            let $sum-pages-published-children :=       sum($child-texts-bibls-published/tei:location/@count-pages ! common:integer(.))
            let $sum-pages-translated-children :=      sum($child-texts-bibls-translated/tei:location/@count-pages ! common:integer(.))
            let $sum-pages-in-translation-children :=  sum($child-texts-bibls-in-translation/tei:location/@count-pages ! common:integer(.))
            let $sum-pages-in-progress-children :=     sum($child-texts-bibls-in-progress/tei:location/@count-pages ! common:integer(.))
            
            let $sum-child-sections-count-text-children :=               sum($child-sections//m:stat[@type = 'count-text-children']/@value ! xs:integer(.))
            let $sum-child-sections-count-published-children :=          sum($child-sections//m:stat[@type = 'count-published-children']/@value ! xs:integer(.))
            let $sum-child-sections-count-translated-children :=         sum($child-sections//m:stat[@type = 'count-translated-children']/@value ! xs:integer(.))
            let $sum-child-sections-count-in-translation-children :=     sum($child-sections//m:stat[@type = 'count-in-translation-children']/@value ! xs:integer(.))
            let $sum-child-sections-count-in-progress-children :=        sum($child-sections//m:stat[@type = 'count-in-progress-children']/@value ! xs:integer(.))
            
            let $sum-child-sections-sum-pages-text-children :=           sum($child-sections//m:stat[@type = 'sum-pages-text-children']/@value ! xs:integer(.))
            let $sum-child-sections-sum-pages-published-children :=      sum($child-sections//m:stat[@type = 'sum-pages-published-children']/@value ! xs:integer(.))
            let $sum-child-sections-sum-pages-translated-children :=     sum($child-sections//m:stat[@type = 'sum-pages-translated-children']/@value ! xs:integer(.))
            let $sum-child-sections-sum-pages-in-translation-children := sum($child-sections//m:stat[@type = 'sum-pages-in-translation-children']/@value ! xs:integer(.))
            let $sum-child-sections-sum-pages-in-progress-children :=    sum($child-sections//m:stat[@type = 'sum-pages-in-progress-children']/@value ! xs:integer(.))
            
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
                        attribute type { 'count-translated-children' },
                        attribute value { $count-translated-children }
                    },
                    element stat {
                        attribute type { 'count-in-translation-children' },
                        attribute value { $count-in-translation-children }
                    },
                    element stat {
                        attribute type { 'count-in-progress-children' },
                        attribute value { $count-in-progress-children }
                    },
                    element stat {
                        attribute type { 'count-text-descendants' },
                        attribute value { $count-text-children + $sum-child-sections-count-text-children }
                    },
                    element stat {
                        attribute type { 'count-published-descendants' },
                        attribute value { $count-published-children + $sum-child-sections-count-published-children }
                    },
                    element stat {
                        attribute type { 'count-translated-descendants' },
                        attribute value { $count-translated-children + $sum-child-sections-count-translated-children }
                    },
                    element stat {
                        attribute type { 'count-in-translation-descendants' },
                        attribute value { $count-in-translation-children + $sum-child-sections-count-in-translation-children }
                    },
                    element stat {
                        attribute type { 'count-in-progress-descendants' },
                        attribute value { $count-in-progress-children + $sum-child-sections-count-in-progress-children }
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
                        attribute type { 'sum-pages-translated-children' },
                        attribute value { $sum-pages-translated-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-in-translation-children' },
                        attribute value { $sum-pages-in-translation-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-in-progress-children' },
                        attribute value { $sum-pages-in-progress-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-text-descendants' },
                        attribute value { $sum-pages-text-children + $sum-child-sections-sum-pages-text-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-published-descendants' },
                        attribute value { $sum-pages-published-children + $sum-child-sections-sum-pages-published-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-translated-descendants' },
                        attribute value { $sum-pages-translated-children + $sum-child-sections-sum-pages-translated-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-in-translation-descendants' },
                        attribute value { $sum-pages-in-translation-children + $sum-child-sections-sum-pages-in-translation-children }
                    },
                    element stat {
                        attribute type { 'sum-pages-in-progress-descendants' },
                        attribute value { $sum-pages-in-progress-children + $sum-child-sections-sum-pages-in-progress-children }
                    }
                }
            else ()
    
    (: Derive last updated from tree :)
    (: child texts :)
    let $child-texts-last-updated := $child-texts/tei:teiHeader/tei:fileDesc  ! tei-content:last-updated(.)
    (: sub sections :)
    let $child-sections-last-updated := $child-sections/@last-updated ! xs:dateTime(.)
    let $last-updated := 
        max((
            $child-texts-last-updated, 
            $child-sections-last-updated,
            (: default date :)
            tei-content:last-updated(<empty/>)
        ))
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            attribute id { $id },
            attribute type { $type },
            attribute nesting { $nest },
            attribute document-url { tei-content:document-url($tei) },
            attribute sort-index { $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            attribute last-updated { $last-updated },
            attribute include-texts { $include-texts },
            attribute toh-number-first { min($child-texts-output/m:toh/@number ! number(.)) },
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

declare function section:section-tree($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string) as element(m:section) {
    
    (: Includes ancestors and descendant sections, and about content :)
    
    let $section := section:child-sections($tei, $include-text-stats, $include-texts)
    
    return
        element { node-name($section) }{
            $section/@*,
            $section/*,
            section:about($tei),
            tei-content:ancestors($tei, '', 1),
            section:filters($tei)
        }
        
};

declare function section:all-translated($apply-filters as element(m:filter)*) as element(m:section) {
    
    let $section-tei := tei-content:tei('ALL-TRANSLATED', 'section')
    (:let $sections := section:section-tree(tei-content:tei('lobby', 'section'), true(), 'descendants-published'):)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            attribute id { 'ALL-TRANSLATED' },
            attribute type { $section-tei/tei:teiHeader/tei:fileDesc/@type },
            attribute document-url { tei-content:document-url($section-tei) },
            attribute sort-index { $section-tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            attribute last-updated { tei-content:last-updated($section-tei/tei:teiHeader/tei:fileDesc) },
            section:titles($section-tei),
            section:abstract($section-tei),
            section:warning($section-tei),
            section:about($section-tei),
            section:filters($section-tei),
            (:$sections,:)
            element { QName('http://read.84000.co/ns/1.0', 'texts') }{
                
                (: Include filters :)
                $apply-filters,
                
                (: Output the texts found in the sections tree - applying the filters :)
                let $texts := 
                    for $tei in $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc[tei:publicationStmt[@status = $translation:published-status-ids]]]
                        for $resource-id in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                        return 
                            section:text($tei, $resource-id, true())
                            
                for $text in $texts
                where (
                    (not($apply-filters[@text-id]) or $apply-filters[@text-id][@text-id = $text/@id])
                    and (not($apply-filters[@max-pages]) or $apply-filters[@max-pages][@max-pages ! xs:integer(.) ge $text/m:source/m:location/@count-pages ! xs:integer(.)])
                    and (not($apply-filters[@section-id]) or $text[descendant::m:parent[@id = $apply-filters[@section-id]/@section-id]])
                )
                return (
                    (:<debug text-id="{ $text/@id }" parent-id="{ $text/m:source/@parent-id }" count-pages="{ $text/m:source/m:location/@count-pages }"/>,:)
                    $text
                )
                
            }
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
