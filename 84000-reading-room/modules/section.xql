xquery version "3.1";

module namespace section="http://read.84000.co/section";

(:declare namespace o="http://www.tbrc.org/models/outline";:)
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "knowledgebase.xql";

declare variable $section:sections := collection($common:sections-path);
declare variable $section:texts := collection($common:translations-path);

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
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        attribute document-url { base-uri($tei) },
        attribute canonical-html { translation:canonical-html($resource-id, '') },
        attribute last-updated { tei-content:last-modified($tei) },
        tei-content:source($tei, $resource-id),
        translation:toh($tei, $resource-id),
        tei-content:ancestors($tei, $resource-id, 0),
        translation:titles($tei, $resource-id),
        translation:title-variants($tei, $resource-id),
        translation:publication($tei),
        translation:publication-status($tei//tei:sourceDesc/tei:bibl[@key eq $resource-id], ()),
        translation:downloads($tei, $resource-id, 'any-version'),
        translation:summary($tei)
    }
};


declare function section:publication-status($section-id as xs:string, $sponsorship-text-ids as xs:string*) as element(m:translation-summary) {
    
    let $section-tei := tei-content:tei($section-id, 'section')
    
    where $section-tei
    return
        element { QName('http://read.84000.co/ns/1.0','translation-summary') } {
        
            attribute section-id { $section-id },
            attribute document-url { base-uri($section-tei) },
            element title { tei-content:title-any($section-tei) },
            
            (: Get publication status of texts in child sections :)
            let $subsection-statuses :=
                for $sub-section-fileDesc in $tei-content:sections-collection//tei:fileDesc[tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $section-id]]
                order by $sub-section-fileDesc/tei:sourceDesc/@sort-index ! xs:integer(.) ascending
                return 
                    section:publication-status($sub-section-fileDesc/tei:publicationStmt/tei:idno/@xml:id, $sponsorship-text-ids)
            
            (: Get publication status of texts in this section :)
            let $section-statuses := 
                for $bibl in $tei-content:translations-collection//tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq $section-id]]
                return
                    translation:publication-status($bibl, $sponsorship-text-ids)
            
            let $combined-statuses := $subsection-statuses/descendant-or-self::m:publication-status | $section-statuses/self::m:publication-status
            
            return (
                $subsection-statuses,
                $section-statuses,
                local:publication-summary($section-statuses, 'toh', 'children'),
                local:publication-summary($section-statuses[@bibl-first], 'text', 'children'),
                local:publication-summary($combined-statuses, 'toh', 'descendant'),
                local:publication-summary($combined-statuses[@bibl-first], 'text', 'descendant')
            )
        
        }
};

declare function local:publication-summary($publication-statuses as element(m:publication-status)*, $grouping as xs:string, $scope as xs:string) as element(m:publications-summary) {
    
    let $publication-statuses-first-block := $publication-statuses[@block-index ! xs:integer(.) eq 1]
    return
        element { QName('http://read.84000.co/ns/1.0', 'publications-summary') } {
            
            attribute grouping { $grouping },
            attribute scope { $scope },
            
            element { QName('http://read.84000.co/ns/1.0', 'texts') } {
                attribute total { count($publication-statuses-first-block) },
                attribute published { count($publication-statuses-first-block[@status = $translation:published-status-ids]) },
                attribute translated { count($publication-statuses-first-block[@status = $translation:translated-status-ids]) },
                attribute in-translation { count($publication-statuses-first-block[@status = $translation:in-translation-status-ids]) },
                attribute not-started { count($publication-statuses-first-block[not(@status = ($translation:published-status-ids | $translation:translated-status-ids | $translation:in-translation-status-ids))]) },
                attribute sponsored { count($publication-statuses-first-block[@sponsored]) }
            },
            
            element { QName('http://read.84000.co/ns/1.0', 'pages') } {
                attribute total { sum($publication-statuses/@count-pages) },
                attribute published { sum($publication-statuses[@status = $translation:published-status-ids]/@count-pages) },
                attribute translated { sum($publication-statuses[@status = $translation:translated-status-ids]/@count-pages) },
                attribute in-translation { sum($publication-statuses[@status = $translation:in-translation-status-ids]/@count-pages) },
                attribute not-started { sum($publication-statuses[not(@status = ($translation:published-status-ids | $translation:translated-status-ids | $translation:in-translation-status-ids))]/@count-pages) },
                attribute sponsored { sum($publication-statuses[@sponsored]/@count-pages) }
            }
            
        }
    
};

declare function section:child-sections($tei as element(tei:TEI), $include-texts as xs:string) as element(m:section) {
    section:child-sections($tei, $include-texts, 1)
};

declare function section:child-sections($tei as element(tei:TEI), $include-texts as xs:string, $nest as xs:integer) as element(m:section) {
    
    let $id := tei-content:id($tei) ! upper-case(.)
    
    let $type := $tei/tei:teiHeader/tei:fileDesc/@type
    
    (: Get child-sections recursively so we end up with whole tree :)
    let $child-sections :=
        for $child-section in $section:sections//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
            order by $child-section/tei:teiHeader//tei:sourceDesc/@sort-index ! xs:integer(.) ascending
        return
            section:child-sections($child-section, $include-texts, $nest + 1)
    
    (: Child texts for stats :)
    let $child-texts := $section:texts//tei:TEI[tei:teiHeader//tei:sourceDesc/tei:bibl/tei:idno[@parent-id eq $id]]
    let $child-texts-fileDesc-published := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:availability[@status = $translation:published-status-ids]]
    let $child-texts-fileDesc-translated := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:availability[@status = $translation:translated-status-ids]]
    let $child-texts-fileDesc-in-translation := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:availability[@status = $translation:in-translation-status-ids]]
    let $child-texts-fileDesc-in-progress := $child-texts/tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:availability[@status = $translation:in-progress-status-ids]]
    
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
                    $child-texts[tei:teiHeader//tei:publicationStmt/tei:availability[@status = $translation:published-status-ids]]
                else
                    $child-texts
            
                (: Get the correct Toh for this parent :)
                for $resource-id in $text-tei//tei:teiHeader//tei:sourceDesc/tei:bibl[tei:idno[@parent-id = $id]]/@key
                return
                    section:text($text-tei, $resource-id, false())
                    
        else ()
    
    (: Derive last updated from tree :)
    (: child texts :)
    let $child-texts-last-updated := $child-texts ! tei-content:last-modified(.)
    (: sub sections :)
    let $child-sections-last-updated := $child-sections/@last-updated ! xs:dateTime(.)
    let $last-updated := 
        max((
            $child-texts-last-updated, 
            $child-sections-last-updated,
            (: default date :)
            xs:dateTime('2010-01-01T00:00:00')
        ))
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            attribute id { $id },
            attribute type { $type },
            attribute nesting { $nest },
            attribute document-url { base-uri($tei) },
            attribute sort-index { $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            attribute last-updated { $last-updated },
            attribute include-texts { $include-texts },
            attribute toh-number-first { min($child-texts-output/m:toh/@number ! number(.)) },
            
            tei-content:title-set($tei, 'mainTitle'),
            
            (: avoid duplicate ids :)
            if($nest gt 1) then
                common:strip-ids(section:abstract($tei))
            else
                section:abstract($tei),
            
            common:strip-ids(section:warning($tei)),
            
            $child-sections,
            
            element { QName('http://read.84000.co/ns/1.0', 'texts') }{
                attribute published-only { if($include-texts = ('children-published', 'descendants-published')) then '1' else '0' },
                $child-texts-output
            },
            
            knowledgebase:page($tei)
            
        }
        
};

declare function section:section-tree($tei as element(tei:TEI), $include-text-stats as xs:boolean, $include-texts as xs:string) as element(m:section) {
    
    (: Includes ancestors and descendant sections, and about content :)
    
    let $section := $tei[tei:teiHeader/tei:fileDesc[@type eq 'section']] ! section:child-sections(., $include-texts)
    
    return
        element { node-name($section) }{
            $section/@*,
            $section/*,
            tei-content:ancestors($tei, '', 1),
            section:filters($tei),
            if($include-text-stats) then
                section:publication-status(tei-content:id($tei), ())
            else ()
        }
        
};

declare function section:all-translated($apply-filters as element(m:filter)*) as element(m:section) {
    
    let $section-tei := tei-content:tei('ALL-TRANSLATED', 'section')
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'section') }{
            attribute id { 'ALL-TRANSLATED' },
            attribute type { $section-tei/tei:teiHeader/tei:fileDesc/@type },
            attribute document-url { base-uri($section-tei) },
            attribute sort-index { $section-tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@sort-index },
            attribute last-updated { tei-content:last-modified($section-tei) },
            
            tei-content:title-set($section-tei, 'mainTitle'),
            section:abstract($section-tei),
            section:warning($section-tei),
            (:section:about($section-tei),:)
            section:filters($section-tei),
            
            element { QName('http://read.84000.co/ns/1.0', 'texts') }{
                
                (: Include filters :)
                $apply-filters,
                
                (: Output the texts found in the sections tree - applying the filters :)
                let $texts := 
                    for $tei in $section:texts//tei:TEI[tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:availability[@status = $translation:published-status-ids]]]
                    return
                        for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                        return 
                            section:text($tei, $toh-key, true())
                            
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
                section:child-sections($tei, 'descendants-published')
            else
                section:child-sections($tei, 'descendants')
        else
            if($include-descendants)then
                section:child-sections($tei, 'children-published')
            else
                section:child-sections($tei, 'children')
};
