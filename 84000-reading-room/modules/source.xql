xquery version "3.0";

module namespace source="http://read.84000.co/source";
(: 
    Functions supporting the mapping of the translation to the source.
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace converter="http://tbrc.org/xquery/ewts2unicode" at "java:org.tbrc.xquery.extensions.EwtsToUniModule";
import module namespace functx="http://www.functx.com";

declare variable $source:source-data-path := '/db/apps/tibetan-source/data/';

declare variable $source:ekangyur-work := 'UT4CZ5369';
declare variable $source:ekangyur-path := concat($source:source-data-path, $source:ekangyur-work);
declare variable $source:ekangyur-volume-offset := 126;

declare variable $source:etengyur-work := 'UT23703';
declare variable $source:etengyur-path := concat($source:source-data-path, $source:etengyur-work);
declare variable $source:etengyur-volume-offset := 316;

declare function source:etext-path($work as xs:string) as xs:string {
    if($work eq $source:ekangyur-work) then
        $source:ekangyur-path
    else if($work eq $source:etengyur-work) then
        $source:etengyur-path
    else
        ''
};

(:
    Converts a volume number to a volume number in the ekangyur or etengyur
    e.g. Kangyur Volume 1 = eKangyur volume 127
:)
declare function source:etext-volume-number($work as xs:string, $volume as xs:integer) as xs:integer {
    if($work eq $source:ekangyur-work) then
        $volume + xs:integer($source:ekangyur-volume-offset)
    else if($work eq $source:etengyur-work) then
        $volume + xs:integer($source:etengyur-volume-offset)
    else
        $volume
};

(: 
    Supports a numeric comparison of folio refs
    i.e. translates 1.a -> 1.0 -> 2 -> 1 and 1.b -> 1.5 -> 3 -> 2
:)
declare function source:folio-to-number($folio as xs:string) as xs:integer {
    xs:integer(number(translate($folio, 'ab', '05')) * 2) - 1
};

declare function source:folio-to-page($tei as element(tei:TEI), $resource-id as xs:string, $folio as xs:string) as xs:integer {
    let $folio := 
        if(not(starts-with(lower-case($folio), 'f.'))) then
            concat('f.', $folio)
        else
            $folio
    
    let $folio-refs := translation:folio-refs($tei, $resource-id)
    let $folio-ref := $folio-refs[lower-case(@cRef) eq $folio]
    
    return
        if($folio-ref) then
            functx:index-of-node($folio-refs, $folio-ref)
        else
            1
};

declare function source:page-to-folio($page as xs:integer) as xs:string {
    concat(xs:string(xs:integer(($page + 1) div 2)), '.', if(($page + 1) mod 2 gt 0) then 'b' else 'a')
};

declare function source:etext-id($work as xs:string, $etext-volume-number as xs:string) as xs:string {
    if($work eq $source:ekangyur-work) then
        concat($source:ekangyur-work, '-I1KG9', xs:string($etext-volume-number), '-0000')
    else if($work eq $source:etengyur-work) then
        concat($source:etengyur-work, '-1', xs:string($etext-volume-number), '-0000')
    else
        ''
};

declare function source:etext-volume($etext-id as xs:string) as element()* {
    collection($source:source-data-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'TBRC_TEXT_RID']/text() eq $etext-id]
};

declare function source:etext-page($location as element(m:location), $page-number as xs:integer, $add-context as xs:boolean) as element()? {
    
    let $work := $location/@work
    let $page-volume := 
        for $volume in $location/m:volume
            let $volume-number := xs:integer($volume/@number)
            let $pages-in-preceding-volumes := sum($location/m:volume[xs:integer(@number) lt $volume-number] ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1)))
            let $start-page-in-volume := $pages-in-preceding-volumes + 1
            let $end-page-in-volume := $pages-in-preceding-volumes + (xs:integer($volume/@end-page) - (xs:integer($volume/@start-page) - 1))
            let $page-in-volume := ($page-number - $pages-in-preceding-volumes) + (xs:integer($volume/@start-page) - 1)
            where $page-number ge $start-page-in-volume and $page-number le $end-page-in-volume
        return
            element { QName('http://read.84000.co/ns/1.0','page-volume') } {
                attribute page-number { $page-number },
                attribute volume-number { $volume-number },
                attribute text-start-page { $volume/@start-page },
                attribute text-end-page { $volume/@end-page },
                attribute pages-in-preceding-volumes { $pages-in-preceding-volumes },
                attribute start-page-in-volume { $start-page-in-volume },
                attribute end-page-in-volume  { $end-page-in-volume  },
                attribute page-in-volume { $page-in-volume }
            }
    (: return $page-volume :)
    
    let $page-volume := $page-volume[1]
    where $page-volume
    return
        source:etext-page($work, $page-volume/@volume-number, $page-volume/@page-in-volume, $add-context)
};


declare function source:etext-page($work as xs:string, $volume-number as xs:integer, $page-number as xs:integer, $add-context as xs:boolean) as element()? {
    
    let $etext-volume-number := source:etext-volume-number($work, $volume-number)
    let $etext-id := source:etext-id($work, $etext-volume-number)
    let $etext-volume := source:etext-volume($etext-id)
    let $page := $etext-volume//tei:p[xs:integer(@n) eq $page-number]
    let $preceding-page := $etext-volume//tei:p[xs:integer(@n) eq $page-number - 1]
    let $trailing-page := $etext-volume//tei:p[xs:integer(@n) eq $page-number + 1]
    let $preceding-lines := 1
    let $preceding-milestone-n := count($preceding-page/tei:milestone[@unit eq 'line']) - ($preceding-lines - 1)
    let $trailing-lines := 3
    let $trailing-milestone-n := ($trailing-lines + 1)
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'source') } {
            attribute work { $work },
            attribute volume { $volume-number },
            attribute page-in-volume { $page-number },
            attribute folio-in-volume { source:page-to-folio($page-number) },
            attribute folio-in-etext { $page/@data-orig-n },
            attribute etext-id { $etext-id },
            element language {
                attribute xml:lang {'bo'},
                
                if($add-context) then (
                    element { QName('http://www.tei-c.org/ns/1.0', 'p') } { 
                        $preceding-page/tei:milestone[@unit eq 'line'][xs:integer(@n) eq $preceding-milestone-n]
                        | $preceding-page/child::node()[preceding-sibling::tei:milestone[@unit eq 'line'][xs:integer(@n) ge $preceding-milestone-n]] 
                    },
                    element { QName('http://www.tei-c.org/ns/1.0', 'p') } { 
                        attribute class {'selected'},
                        $page/child::node() 
                    },
                    element { QName('http://www.tei-c.org/ns/1.0', 'p') } {  
                        $trailing-page/tei:milestone[@unit eq 'line'][xs:integer(@n) eq $trailing-milestone-n]
                        | $trailing-page/child::node()[following-sibling::tei:milestone[@unit eq 'line'][xs:integer(@n) le $trailing-milestone-n]] 
                    }
                )
                else
                    $page
                
            }
        }
};

declare function source:etext-volumes($work as xs:string, $pages-for-volume as xs:integer?) as element() {
    <volumes xmlns="http://read.84000.co/ns/1.0">
    { 
        let $volumes := collection(source:etext-path($work))
        for $volume at $volume-index in $volumes//tei:TEI
            let $long-id := $volume//tei:idno[@type eq "TBRC_TEXT_RID"]/text()
        return
            <volume id="{ $long-id }" number="{ $volume-index }" page-count="{ count($volume//tei:p) }" >
            {
                if($pages-for-volume gt 0 and $volume-index eq $pages-for-volume) then
                    for $p at $page-index in $volume//tei:p
                    return
                        <page index="{ $page-index }" number="{ $p/@n }" folio="{ $p/@data-orig-n }"/>
                else
                    ()
            }
            </volume>
    }
    </volumes>
};

(:
declare function source:ekangyur-page-number($volume as xs:integer, $folio-page as xs:integer, $folio-side as xs:string) as xs:integer {
    let $ekangyur-mappings := source:ekangyur-mappings($volume, concat($folio-page, '.', $folio-side))
    let $ekangyur-page := (xs:integer($folio-page) * xs:integer($ekangyur-mappings/@page-multiplier)) + xs:integer($ekangyur-mappings/@page-offset)
    return
        if($folio-side eq 'b') then
            $ekangyur-page + 1
        else 
            (: presume it's side a :)
            $ekangyur-page
};

declare function source:translation-folio($ekangyur-volume-number as xs:integer, $ekangyur-page-number as xs:integer) as xs:string {
    (:  
        This is tricky!!!!!!!
        Loop through the mappings and calculate the page numbers for a range 
            is this page number in that range? 
    :)
    (: PROVISIONAL calculation without offsets :)
    let $volume := source:translation-volume-number($ekangyur-volume-number)
    let $page-number := ceiling($ekangyur-page-number div 2)
    let $side := 
        if($page-number mod 2 eq 0)then
            'b'
        else
            'a'
    return
        concat('F', '.', $page-number, '.', $side)
};

declare function source:ekangyur-id($ekangyur-volume-number as xs:string) as xs:string {
    concat($source:ekangyur-work-str, xs:string($ekangyur-volume-number), '-0000')
};

declare function source:ekangyur-volume($ekangyur-id as xs:string) as element()* {
    collection($common:ekangyur-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'TBRC_TEXT_RID']/text() eq $ekangyur-id]
};

declare function source:ekangyur-page($ekangyur-volume-number as xs:integer, $ekangyur-page-number as xs:integer, $add-context as xs:boolean) as element() {
    
    let $ekangyur-id := source:ekangyur-id($ekangyur-volume-number)
    let $ekangyur-volume := source:ekangyur-volume($ekangyur-id)
    let $ekangyur-volume-page-count := count($ekangyur-volume//tei:p)
    
    return
        if($ekangyur-volume-page-count and ($ekangyur-page-number gt $ekangyur-volume-page-count))then
            
            (: Recurse to find it in the next volume :)
            source:ekangyur-page(($ekangyur-volume-number + 1), ($ekangyur-page-number - $ekangyur-volume-page-count), $add-context)
        
        else
            
            let $page := $ekangyur-volume//tei:p[xs:integer(@n) eq $ekangyur-page-number]
            let $preceding-page := $ekangyur-volume//tei:p[xs:integer(@n) eq $ekangyur-page-number - 1]
            let $trailing-page := $ekangyur-volume//tei:p[xs:integer(@n) eq $ekangyur-page-number + 1]
            let $preceding-lines := 1
            let $preceding-milestone-n := count($preceding-page/tei:milestone[@unit eq 'line']) - ($preceding-lines - 1)
            let $trailing-lines := 3
            let $trailing-milestone-n := ($trailing-lines + 1)
            
            let $bo := 
                if($add-context) then (
                    <tei:p>
                    { 
                        $preceding-page/tei:milestone[@unit eq 'line'][xs:integer(@n) eq $preceding-milestone-n]
                        | $preceding-page/child::node()[preceding-sibling::tei:milestone[@unit eq 'line'][xs:integer(@n) ge $preceding-milestone-n]] 
                    }
                    </tei:p>,
                    <tei:p class="selected">
                    { 
                        $page/child::node() 
                    }
                    </tei:p>,
                    <tei:p>
                    { 
                        $trailing-page/tei:milestone[@unit eq 'line'][xs:integer(@n) eq $trailing-milestone-n]
                        | $trailing-page/child::node()[following-sibling::tei:milestone[@unit eq 'line'][xs:integer(@n) le $trailing-milestone-n]] 
                    }
                    </tei:p>
                )
                else
                    $page
            
            return 
                <source
                    xmlns="http://read.84000.co/ns/1.0" 
                    name="ekangyur"
                    volume="{ $ekangyur-volume-number }" 
                    ekangyur-id="{ $ekangyur-id }"
                    page="{ $ekangyur-page-number }" 
                    volume-page-count="{ $ekangyur-volume-page-count }" >
                    <language xml:lang="bo">{ $bo }</language>
                </source>
        
};

declare function source:bo-ltn($bo as xs:string) as xs:string {
    <p xmlns="http://www.tei-c.org/ns/1.0">
    { 
        for $line at $pos in $bo/text()[normalize-space(.)]
        return
        (
            element tei:milestone {
                attribute unit {'line'},
                attribute n { $pos }
            },
            text {
                converter:toWylie($line)
            }
        )
    }
    </p>
};

declare function source:ekangyur-volumes($pages-for-volume as xs:integer?) as element() {
    <volumes xmlns="http://read.84000.co/ns/1.0">
    { 
        let $volumes := collection($common:ekangyur-path)
        for $volume in $volumes//tei:TEI
            let $long-id := $volume//tei:idno[@type eq "TBRC_TEXT_RID"]/text()
            let $short-id := substring-before(substring-after($long-id, 'UT4CZ5369-'), '-0000')
            let $number-id := substring-after($short-id, 'I1KG9')
            let $number := source:translation-volume-number(xs:integer($number-id))
            let $page-count := count($volume//tei:p)
        return
            <volume id="{ $long-id }" number="{ $number }" page-count="{ $page-count }" >
            {
                if($pages-for-volume gt 0 and $number eq $pages-for-volume) then
                    for $p at $index in $volume//tei:p
                    return
                        <page index="{ $index }" number="{ $p/@n }" folio="{ $p/@data-orig-n }"/>
                else
                    ()
            }
            </volume>
    }
    </volumes>
};

declare function source:translated-pages($ignore-ekangur-pages) as element() {
    (: 
        Look up folio <refs> in translations
        Map them to eKangyur pages
        Exclude some
    :)
    <translated-pages xmlns="http://read.84000.co/ns/1.0">
    { 
        let $translations := collection($common:translations-path)
        
        for $ref in $translations//tei:body//*[@type eq 'translation']//tei:ref[not(@type)][upper-case(substring-before(@cRef, '.')) eq 'F']

        return
            <page id="{ $ref/@cRef }" doc="{ base-uri($ref) }" />
    }
    </translated-pages>
};
:)
