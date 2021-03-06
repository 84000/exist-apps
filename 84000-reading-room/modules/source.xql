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
    
    (: TO DO: Handles legacy links with no 'f.' prefix. This should be deprecated and full folio id required so that f. is not required.  :)
    
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

declare function source:etext-full($location as element(m:location)) as element()? {
    
    let $work := $location/@work
    return
        element { QName('http://read.84000.co/ns/1.0', 'source') } {
            attribute work { $work },
            for $volume in $location/m:volume
                for $page-in-volume at $page-index in xs:integer($volume/@start-page) to xs:integer($volume/@end-page)
                return
                    source:etext-page($work, xs:integer($volume/@number), $page-in-volume, false(), ())
        }
    
};

declare function source:etext-page($location as element(m:location), $page-number as xs:integer, $add-context as xs:boolean, $highlight as xs:string*) as element()? {
    
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
    
    let $page-volume := $page-volume[1]
    where $page-volume
    return
        element { QName('http://read.84000.co/ns/1.0', 'source') } {
            attribute work { $work },
            attribute page-url { concat('https://read.84000.co/source/', $location/@key, '.html?page=', $page-volume/@page-number) },
            source:etext-page($work, $page-volume/@volume-number, $page-volume/@page-in-volume, $add-context, $highlight)
        }
};

declare function source:etext-page($work as xs:string, $volume-number as xs:integer, $page-number as xs:integer, $add-context as xs:boolean, $highlight as xs:string*) as element()? {
    
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
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>10</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    let $query := 
        <query>
            <bool>
            {
                for $phrase in $highlight ! normalize-space(.)
                where not($phrase = ('།'))
                return
                    <phrase>{ $phrase }</phrase>
            }
            </bool>
        </query>
        
    let $page-highlighted := $page[ft:query(., $query, $options)]
    
    let $page-expanded := util:expand($page-highlighted, "expand-xincludes=no")
    
    let $page-expanded :=
        if(not($page-expanded//exist:match)) then
            common:mark-nodes($page, $highlight, 'tibetan')
        else
            $page-expanded
    
    let $paragraph := 
        element { QName('http://www.tei-c.org/ns/1.0', 'p') } { 
            attribute class {'selected'},
            $page-expanded/node()
        }
    
    (: Context around the page, in case page break comes in the middle of a passage :)
    let $preceding-paragraph := 
        if($add-context) then
            element { QName('http://www.tei-c.org/ns/1.0', 'p') } { 
                $preceding-page/tei:milestone[@unit eq 'line'][xs:integer(@n) eq $preceding-milestone-n]
                | $preceding-page/node()[preceding-sibling::tei:milestone[@unit eq 'line'][xs:integer(@n) ge $preceding-milestone-n]] 
            }
        else
            ()
    
    let $trailing-paragraph := 
        if($add-context) then
            element { QName('http://www.tei-c.org/ns/1.0', 'p') } {  
                $trailing-page/tei:milestone[@unit eq 'line'][xs:integer(@n) eq $trailing-milestone-n]
                | $trailing-page/node()[following-sibling::tei:milestone[@unit eq 'line'][xs:integer(@n) le $trailing-milestone-n]] 
            }
        else
            ()
    
    return 
        element { QName('http://read.84000.co/ns/1.0','page') }  {
            attribute volume { $volume-number },
            attribute page-in-volume { $page-number },
            attribute folio-in-volume { source:page-to-folio($page-number) },
            attribute folio-in-etext { $page/@data-orig-n },
            attribute etext-id { $etext-id },
            element language {
                attribute xml:lang {'bo'},
                $preceding-paragraph,
                $paragraph,
                $trailing-paragraph
            }
        }
};

declare function source:etext-volumes($work as xs:string, $pages-for-volume as xs:integer?) as element() {

    element { QName('http://read.84000.co/ns/1.0','volumes') }  {
        let $volumes := collection(source:etext-path($work))
        for $volume at $volume-index in $volumes//tei:TEI
            let $long-id := $volume//tei:idno[@type eq "TBRC_TEXT_RID"]/text()
        return
            element { QName('http://read.84000.co/ns/1.0','volume') } {
                attribute id { $long-id },
                attribute number { $volume-index },
                attribute page-count { count($volume//tei:p) },
                if($pages-for-volume gt 0 and $volume-index eq $pages-for-volume) then
                    for $p at $page-index in $volume//tei:p
                    return
                        element { QName('http://read.84000.co/ns/1.0','page') } {
                            attribute index { $page-index },
                            attribute number { $p/@n },
                            attribute folio { $p/@data-orig-n }
                        }
                else
                    ()
            }
    }
};