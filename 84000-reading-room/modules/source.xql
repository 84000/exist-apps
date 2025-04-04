xquery version "3.0";

module namespace source="http://read.84000.co/source";
(: 
    Functions supporting the mapping of the translation to the source.
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bdo="http://purl.bdrc.io/ontology/core/";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace glossary="http://read.84000.co/glossary" at "glossary.xql";
import module namespace search="http://read.84000.co/search" at "search.xql";
import module namespace machine-translation="http://read.84000.co/machine-translation" at "machine-translation.xql";
import module namespace functx="http://www.functx.com";

declare variable $source:source-data-path := '/db/apps/tibetan-source/data';

declare variable $source:kangyur-work := 'UT4CZ5369';
declare variable $source:ekangyur-path := string-join(($source:source-data-path, $source:kangyur-work), '/');
declare variable $source:ekangyur-volume-offset := 126;

declare variable $source:tengyur-work := 'UT23703';
declare variable $source:etengyur-path := string-join(($source:source-data-path, $source:tengyur-work), '/');
declare variable $source:etengyur-volume-offset := 316;

declare function source:work-name($work as xs:string) as xs:string {
    if($work eq $source:kangyur-work) then 'kangyur' 
    else if($work eq $source:tengyur-work) then 'tengyur'
    else 'unknown'
};

declare function source:etext-path($work as xs:string) as xs:string {
    if($work eq $source:kangyur-work) then
        $source:ekangyur-path
    else if($work eq $source:tengyur-work) then
        $source:etengyur-path
    else
        ''
};

(: Converts a volume number to a volume number in the ekangyur or etengyur
    e.g. Kangyur Volume 1 = eKangyur volume 127
:)
declare function source:etext-volume-number($work as xs:string, $volume as xs:integer) as xs:integer {
    if($work eq $source:kangyur-work) then
        $volume + xs:integer($source:ekangyur-volume-offset)
    else if($work eq $source:tengyur-work) then
        $volume + xs:integer($source:etengyur-volume-offset)
    else
        $volume
};

(: Supports a numeric comparison of folio refs
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

declare function source:ref-id-to-page($tei as element(tei:TEI), $resource-id as xs:string, $ref-id as xs:string) as xs:integer {
    
    let $ref-id := upper-case($ref-id)
    let $folio-refs := translation:folio-refs($tei, $resource-id)
    let $folio-ref := $folio-refs[@xml:id eq $ref-id]
    
    return
        if($folio-ref) then
            functx:index-of-node($folio-refs, $folio-ref)
        else
            1
    
};

declare function source:etext-id($work as xs:string, $etext-volume-number as xs:string) as xs:string {
    if($work eq $source:kangyur-work) then
        concat($source:kangyur-work, '-I1KG9', xs:string($etext-volume-number), '-0000')
    else if($work eq $source:tengyur-work) then
        concat($source:tengyur-work, '-1', xs:string($etext-volume-number), '-0000')
    else
        ''
};

declare function source:etext-volume($etext-id as xs:string) as element()* {
    collection($source:source-data-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'TBRC_TEXT_RID']/text() eq $etext-id]
};

declare function source:etext-full($location as element(m:location)) as element(m:source) {
    
    element { QName('http://read.84000.co/ns/1.0', 'source') } {
        $location/@work,
        for $volume in $location/m:volume
        let $text-count-pages := xs:integer($volume/@end-page) - xs:integer($volume/@start-page)
        let $offset-in-work-volume := if($location/@work eq $source:tengyur-work) then 2 else 0
        let $volume-start-page := (xs:integer($volume/@start-page) + $offset-in-work-volume)
        let $volume-end-page := $volume-start-page + $text-count-pages
        return
            for $page-in-volume at $page-index in $volume-start-page to $volume-end-page
            return 
                local:etext-page($location/@work, xs:integer($volume/@number), $page-in-volume, $page-index, false())
    }
    
};

declare function source:etext-page($location as element(m:location), $page-number as xs:integer, $add-context as xs:boolean) as element(m:source)? {
    
    let $work := $location/@work
    
    let $offset-in-work-volume := 
        if($work eq $source:tengyur-work) then 2
        else 0
    
    (: Loop through $location/m:volume in the TEI and establish the volume and page in volume for this $page-number (page index) :)
    let $page-volume := 
        for $volume in $location/m:volume
        let $volume-number := xs:integer($volume/@number)
        let $pages-in-preceding-volumes := sum($location/m:volume[xs:integer(@number) lt $volume-number] ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1)))
        let $start-page-in-volume := $pages-in-preceding-volumes + 1
        let $end-page-in-volume := $pages-in-preceding-volumes + (xs:integer($volume/@end-page) - (xs:integer($volume/@start-page) - 1))
        where $page-number ge $start-page-in-volume and $page-number le $end-page-in-volume
        return
            element { QName('http://read.84000.co/ns/1.0','page-volume') } {
                attribute page-number { $page-number },
                attribute volume-number { $volume-number },
                (:attribute text-start-page { $volume/@start-page },
                attribute text-end-page { $volume/@end-page },
                attribute pages-in-preceding-volumes { $pages-in-preceding-volumes },
                attribute start-page-in-volume { $start-page-in-volume },
                attribute end-page-in-volume  { $end-page-in-volume  },:)
                attribute page-in-volume { ($page-number - $pages-in-preceding-volumes) + ((xs:integer($volume/@start-page) + $offset-in-work-volume) - 1) }
            }
    
    let $page-volume := $page-volume[1]
    where $page-volume
    return
        local:etext-page($work, $page-volume/@volume-number, $page-volume/@page-in-volume, $page-number, $add-context)
        
};

declare function local:etext-page($work as xs:string, $volume-number as xs:integer, $page-number as xs:integer, $page-index as xs:integer, $add-context as xs:boolean) as element(m:page) {
    
    let $etext-volume-number := source:etext-volume-number($work, $volume-number)
    let $etext-id := source:etext-id($work, $etext-volume-number)
    let $etext-volume := source:etext-volume($etext-id)
    let $page := $etext-volume//tei:p[range:eq(@n, $page-number)]
    let $preceding-page := $etext-volume//tei:p[range:eq(@n, $page-number - 1)]
    let $trailing-page := $etext-volume//tei:p[range:eq(@n, $page-number + 1)]
    let $preceding-lines := 1
    let $preceding-milestone-n := count($preceding-page/tei:milestone[@unit eq 'line']) - ($preceding-lines - 1)
    let $trailing-lines := 3
    let $trailing-milestone-n := ($trailing-lines + 1)
    
    (: Context around the page, in case page break comes in the middle of a passage :)
    let $preceding-paragraph := 
        if($add-context) then
            $preceding-page/tei:milestone[@unit eq 'line'][range:eq(@n, $preceding-milestone-n)]
            | $preceding-page/node()[preceding-sibling::tei:milestone[@unit eq 'line'][range:ge(@n, $preceding-milestone-n)]] 
        else ()
    
    let $trailing-paragraph := 
        if($add-context) then
            $trailing-page/tei:milestone[@unit eq 'line'][range:eq(@n, $trailing-milestone-n)]
            | $trailing-page/node()[following-sibling::tei:milestone[@unit eq 'line'][range:le(@n, $trailing-milestone-n)]] 
        else ()
    
    return 
        element { QName('http://read.84000.co/ns/1.0','page') }  {
            attribute volume { $volume-number },
            attribute page-in-volume { $page-number },
            attribute folio-in-volume { source:page-to-folio($page-number) },
            attribute folio-in-etext { $page/@data-orig-n },
            attribute page-in-text { $page-index },
            attribute etext-id { $etext-id },
            element language {
                attribute xml:lang {'bo'},
                if($preceding-paragraph) then element { QName('http://www.tei-c.org/ns/1.0', 'p') } { $preceding-paragraph } else (),
                element { QName('http://www.tei-c.org/ns/1.0', 'p') } { attribute class {'selected'}, $page/node() },
                if($trailing-paragraph) then element { QName('http://www.tei-c.org/ns/1.0', 'p') } { $trailing-paragraph } else ()
            }
        }
        
};

declare function source:etext-volumes($work as xs:string, $pages-for-volume as xs:integer?) as element(m:volumes) {

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
                else ()
            }
    }
};

declare function source:bdrc-rdf($toh as element(m:toh)) as element(rdf:RDF)* {
    
    if($toh/m:ref[@type eq 'bdrc-tibetan-id'][@value]) then
        
        try {
        
            let $send-request-work := hc:send-request(<hc:request href="{ concat($toh/m:ref[@type eq 'bdrc-work-id']/@value/string(),'.rdf') }" method="GET"/>)
            let $work-rdf := $send-request-work[2]/rdf:RDF
            
            let $send-request-bo := hc:send-request(<hc:request href="{ concat($toh/m:ref[@type eq 'bdrc-tibetan-id']/@value/string(),'.rdf') }" method="GET"/>)
            let $bo-rdf := $send-request-bo[2]/rdf:RDF
            
            return (
                
                $work-rdf,
                
                (:for $resource-id in $work-rdf/bdo:Work/bdo:workHasInstance/@rdf:resource
                let $send-request := hc:send-request(<hc:request href="{ concat($resource-id,'.rdf') }" method="GET"/>)
                return
                    $send-request[2]/rdf:RDF:)
                    
                $bo-rdf
                
                (:for $resource-id in $bdrc-rdf/bdo:Work/bdo:workHasParallelsIn/@rdf:resource
                let $send-request := hc:send-request(<hc:request href="{ concat($resource-id,'.rdf') }" method="GET"/>)
                return
                    $send-request[2]/rdf:RDF:)
                
            )
            
        }
        catch * {
            element rdf:RDF  { element debug { 'Error (' || $err:code || '): ' || $err:description } }
        }
        
    else ()
    
};

declare function source:href($source-key as xs:string, $ref-index as xs:string?, $url-parameters as xs:string*, $fragment as xs:string?) as xs:string {
    concat('/', string-join(('source', $source-key, $ref-index ! ('folio', $ref-index)), '/'), string-join($url-parameters[. gt ''], '&amp;')[. gt ''] ! concat('?', .), $fragment ! concat('#', .))
};
