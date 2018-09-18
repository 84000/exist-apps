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

declare function section:titles($tei) as node() {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'mainTitle')
    }
    </titles>
};

declare function section:abstract($tei as node()) as node() {

    <abstract xmlns="http://read.84000.co/ns/1.0">
    { 
        $tei/tei:text/tei:front/tei:div[@type eq "abstract"]/*
    }
    </abstract>
    
};

declare function section:warning($tei as node()) as node() {

    <warning xmlns="http://read.84000.co/ns/1.0">
    { 
        $tei/tei:text/tei:front/tei:div[@type eq "warning"]/*
    }
    </warning>
    
};

declare function section:about($tei as node()) as node() {

    <about xmlns="http://read.84000.co/ns/1.0">
    { 
        $tei/tei:text/tei:body/tei:div[@type eq "about"]/*
    }
    </about>
    
};

declare function section:descendants($tei as node(), $nest as xs:integer, $include-text-stats as xs:boolean) as node() {
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

declare function section:text-stats($tei as node()) as node() {
    
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

declare function section:texts($section-id as xs:string, $published-only as xs:boolean, $include-descendants as xs:boolean) as node() {
    
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
                    { translation:downloads($tei, $resource-id) }
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

declare function section:all-translated-texts() as node() {
    
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
                { translation:downloads($tei, $resource-id) }
                { translation:summary($tei) }
            </text>
        
    }
    </texts>
        
};

declare function section:sections($id as xs:string, $published-only as xs:boolean) as node() {
    
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

declare function section:section($tei as node(), $published-only as xs:boolean) as node(){

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

(:
declare function section:parent($section) {
    $section/..
};

declare function section:count-child-texts($section) as xs:int {
    count($section/o:node[@type = "text"])
};

declare function section:count-descendant-texts($section) as xs:int {
    count($section//o:node[@type = "text"][not(o:node[@type = "chapter"])]) + count($section//o:node[@type = "chapter"])
};

declare function section:count-descendant-translated($section) as xs:int {
    count($section//o:node[@type="translation"][o:description[@type="status"][text() = "completed"]])
};

declare function section:count-descendant-inprogress($section) as xs:int {
    count($section//o:node[@type="translation"][o:description[@type="status"][text() = "inProcess"]])
};

declare function section:count-translations($section) as xs:int {
    count(contains(collection($common:translations-path)//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id, $section//o:node/@RID))
};

declare function section:title($section, $lang as xs:string) as xs:string
{
    let $title :=
    (
        if($lang eq "en") then
            $section/o:title[@xml:lang = "en"] 
            | $section/o:title[@lang = "english"]
            | $section/o:name[@xml:lang = "en"]
            | $section/o:name[@lang = "english"]
        else if($lang eq "bo-ltn") then
            $section/o:title[not(@xml:lang)][@type = "bibliographicalTitle"]
            | $section/o:title[@lang = "tibetan"]
            | $section/o:name[not(@xml:lang)][not(@lang)]
            | $section/o:name[@xml:lang = "bo-ltn"]
            | $section/o:name[@lang = "tibetan"]
        else if($lang eq "sa-ltn") then
            $section/o:title[@xml:lang = "sa-ltn"] 
            | $section/o:title[@lang = "sanskrit"]
            | $section/o:name[@xml:lang = "sa-ltn"]
            | $section/o:name[@lang = "sanskrit"]
        else if($lang eq "bo") then
            $section/o:title[@xml:lang = "bo"]
        else
            ""
    )[1]
    return 
        if($title) then
            $title/text()
        else
            ""
};

declare function section:titles($section) as node() {
    
    let $bo := section:title($section, "bo") 
    let $bo-ltn := section:title($section, "bo-ltn")
    return 
        <titles xmlns="http://read.84000.co/ns/1.0">
            <title xml:lang="en">{ section:title($section, "en") }</title>
            <title xml:lang="bo">
            {
                if(not($bo) and $bo-ltn) then
                    common:bo-title($bo-ltn)
                else
                    $bo
            }
            </title>
            <title xml:lang="bo-ltn">{ $bo-ltn }</title>
            <title xml:lang="sa-ltn">{ section:title($section, "sa-ltn") }</title>
        </titles>
    
};

declare function section:ancestors($section as node()*,  $nest as xs:integer) as node()* {

    let $parent := section:parent($section)
    return
        if($parent/@RID) then
            <parent xmlns="http://read.84000.co/ns/1.0" id="{ $parent/@RID }" nesting="{ $nest }">
                <title xml:lang="en">{ section:title($parent, "en") }</title>
                { 
                    section:ancestors($parent, $nest + 1) 
                }
            </parent>
        else
            ()
    
};

declare function section:contents($section as node()*) as node() {

    <contents xmlns="http://read.84000.co/ns/1.0">
    { 
        common:unescape($section/o:description[@type = "contents"]/text()) 
    }
    </contents>
    
};

declare function section:summary($section as node()*) as node() {

    <summary xmlns="http://read.84000.co/ns/1.0">
    { 
        common:unescape($section/o:description[@type = "summary"]/text()) 
    }
    </summary>
    
};

declare function section:sections($section as node()*) as node() {

    let $outlines := collection($common:outlines-path)
    return
        <sections xmlns="http://read.84000.co/ns/1.0">
        {
            (: This looks a bit odd but child sections might not be children, so we need to get the ids and then query the whole outline :)
            for $child-section-id in $section/o:node[@type = ("section", "pseudo-section", "link")]/@RID
                let $child-section := $outlines//*[@RID eq $child-section-id][not(@type = "link")]
            return
                <section id="{ $child-section/@RID }" warning="{ $child-section/@warning }" type="{ $child-section/@type }">
                    { 
                        section:titles($child-section) 
                    }
                    <contents>
                    { 
                        common:unescape($child-section/o:description[@type = "contents"]/text()) 
                    }
                    </contents>
                    <texts 
                        count-child-texts="{ section:count-child-texts($section) }" 
                        count-descendant-texts="{ section:count-descendant-texts($child-section) }" 
                        count-descendant-translated="{ section:count-descendant-translated($child-section) }"
                        count-descendant-inprogress="{ section:count-descendant-inprogress($child-section) }">
                    </texts>
                </section>
        }
        </sections>
    
};

declare function section:texts($section as node()*, $section-id as xs:string, $translated-only as xs:string) as node() {
    
    let $outlines := collection($common:outlines-path)
    return
        <texts xmlns="http://read.84000.co/ns/1.0"
            count-child-texts="{ section:count-child-texts($section) }" 
            count-descendant-texts="{ section:count-descendant-texts($section) }" 
            count-descendant-translated="{ section:count-descendant-translated($section) }"
            count-descendant-inprogress="{ section:count-descendant-inprogress($section) }"
            translated-only="{ $translated-only }">
        {
            
            let $texts := 
                if($section-id eq 'all-translated') then
                    $outlines//o:node[@type = "text"][.//o:node[@type = 'translation']/o:description[@type = 'status']/text() eq 'completed']
                else
                    if($translated-only eq '1') then
                        $section/o:node[@type = "text"][.//o:node[@type = 'translation']/o:description[@type = 'status']/text() eq 'completed']
                    else
                        $section/o:node[@type = "text"]
            
            let $translated := ($section-id eq 'all-translated' or $translated-only eq '1')
            let $ancestors := $section-id eq 'all-translated'
            
            for $text in $texts
            return
                outline-text:text($text, $translated, $ancestors)
        }
        </texts>
    
};
:)
