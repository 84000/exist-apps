xquery version "3.0";

module namespace source="http://read.84000.co/source";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace converter="http://tbrc.org/xquery/ewts2unicode" at "java:org.tbrc.xquery.extensions.EwtsToUniModule";
import module namespace functx="http://www.functx.com";

declare function source:folio-to-number($folio as xs:string) as numeric {
    number(translate($folio, 'ab', '05'))
};

declare function source:ekangyur-mappings($volume as xs:integer, $page as xs:string) as element() {

    let $mapping := collection(concat($common:data-path, '/config'))//m:folio-mappings/m:mapping[@source eq "ekangyur"]
    
    let $range := $mapping/m:range[xs:integer(@volume) eq $volume][source:folio-to-number(@start) le source:folio-to-number($page)][source:folio-to-number(@end) ge source:folio-to-number($page)]
    
    let $page-offset := 
        if ($range) then 
            $range/@page-offset
        else
            $mapping/@page-offset
    
    return
        <mapping 
            xmlns="http://read.84000.co/ns/1.0" 
            volume-add="{ $mapping/@volume-add }"
            page-multiplier="{ $mapping/@page-multiplier }" 
            page-offset="{ $page-offset }">
            {
                $range 
            }
        </mapping>
};

declare function source:ekangyur-volume-number($volume as xs:integer) as xs:integer {
    let $ekangyur-mappings := source:ekangyur-mappings($volume, '')
    return
        $volume + xs:integer($ekangyur-mappings/@volume-add)
};

declare function source:translation-volume-number($ekangyur-volume-number as xs:integer) as xs:integer {
    let $ekangyur-mappings := source:ekangyur-mappings(0, '')
    return
        $ekangyur-volume-number - xs:integer($ekangyur-mappings/@volume-add)
};

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

declare function source:ekangyur-id($volume-number as xs:string) as xs:string {
    concat('UT4CZ5369-I1KG9', xs:string($volume-number), '-0000')
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

declare function source:ekangyur-volumes() as element() {
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
            <volume id="{ $long-id }" number="{ $number }" page-count="{ $page-count }" />
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

