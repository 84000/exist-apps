xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tengyur-tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare function local:data-item($text-id as xs:string, $toh as xs:string, $type as xs:string, $group as xs:string?, $lang as xs:string?, $value as xs:string?) as element(m:item) {
    element { QName('http://read.84000.co/ns/1.0', 'item') } {
        element toh { $toh },
        element text-id { $text-id },
        element type { $type },
        element group { $group },
        element lang { $lang },
        element value { $value }
    }
};

declare function local:title($title as element(tei:title)?, $type as xs:string, $lang as xs:string) as element(m:title) {
    
    element { QName('http://read.84000.co/ns/1.0', 'title') } {
        attribute type { $type },
        attribute xml:lang { $lang },
        $title/text()
    }
    
};

declare function local:contributor($author as element(tei:author)) as element()* {

    let $author-data := $author/data()
    
    let $type := 
        if(matches($author-data, '^a[\.:]\s*')) then
            'author'
        else if(matches($author-data, '^r[\.:]\s*')) then
            'reviser'
        else 
            'translator'
    
    let $author-tokenized := tokenize(replace($author-data, '^[atr][\.:]\s*', ''), '[,:]') ! normalize-space(.)
    
    let $contributors := 
        for $author-string in $author-tokenized
        return 
            element { QName('http://read.84000.co/ns/1.0', 'contributor') } {
                attribute type { 
                    if(matches($author-string, '^a[\.:]\s*')) then
                        'author'
                    else if(matches($author-string, '^r[\.:]\s*')) then
                        'reviser'
                    else if(matches($author-string, '^t[\.:]\s*')) then
                        'translator'
                    else $type
                },
                attribute xml:lang { 
                    if(count(tokenize($author-string, '\s')) eq 1) then
                        'Sa-Ltn'
                    else
                        'Bo-Ltn'
                },
                replace($author-string, '^[atr][\.:]\s*', '')
            }
    
    
    
    let $contributor-Bo-Ltn := $contributors[@xml:lang eq 'Bo-Ltn'][1]
    let $contributor-Sa-Ltn := $contributors[@xml:lang eq 'Sa-Ltn'][1]
    
    let $contributor-ref := replace(($contributor-Bo-Ltn, $contributor-Sa-Ltn)[1]/text() ! lower-case(.), "[^a-zA-Z0-9']+", "-")
    
    return (
            element { QName('http://read.84000.co/ns/1.0', if($contributor-Bo-Ltn[@type]) then $contributor-Bo-Ltn/@type else $type) } {
                attribute xml:lang { 'Bo-Ltn' },
                attribute ref { $contributor-ref },
                $contributor-Bo-Ltn/text()
            },
            element { QName('http://read.84000.co/ns/1.0', if($contributor-Sa-Ltn[@type]) then $contributor-Sa-Ltn/@type else $type) } {
                attribute xml:lang { 'Sa-Ltn' },
                attribute ref { $contributor-ref },
                $contributor-Sa-Ltn/text()
            },
            for $contributor in $contributors[not(text() = ($contributor-Sa-Ltn/text(), $contributor-Bo-Ltn/text()))]
            return
                element { QName('http://read.84000.co/ns/1.0', $contributor/@type) } {
                    $contributor/@xml:lang,
                    attribute ref { $contributor-ref },
                    $contributor/text()
                }
    )
    
};

declare function local:spreadsheet-data( $tengyur-data as element(m:tengyur-data) ) as element(m:tengyur-data) {
    element { QName('http://read.84000.co/ns/1.0', 'tengyur-data') } {
        for $text in $tengyur-data/m:text
        return (
            for $element in $text/*
            return
                if(local-name($element) eq 'title') then
                    local:data-item($text/@text-id, $text/m:toh/@label, 'title', $element/@type, $element/@xml:lang, $element/text())
                else if(local-name($element) = ('author','translator','reviser')) then
                    local:data-item($text/@text-id, $text/m:toh/@label, local-name($element), $element/@ref, $element/@xml:lang, $element/text())
                else 
                    ()
            ,
            element { QName('http://read.84000.co/ns/1.0', 'item') } {
                element toh { '-' }
            }
        )
    }
};

let $tengyur-data :=
element { QName('http://read.84000.co/ns/1.0', 'tengyur-data') } {

    element export {
        attribute timestamp { current-dateTime() },
        attribute user { common:user-name() }
    },
    
    (:let $current-block := ("O1JC76301JC21614"):)
    let $lowest-toh := 1401
    let $highest-toh := 1606
    
    return
    for $tei in $local:tengyur-tei(:[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id = $current-block]]]:)
            
        let $titles := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title

        let $local-titles := 
            for $type in ('mainTitle'(:, 'longTitle', 'otherTitle':))
            for $lang in ('Bo-Ltn', 'Sa-Ltn', 'en')
            return
                local:title($titles[@type eq $type][@xml:lang eq $lang][1], $type, $lang)
                
        let $bibls := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location[@work = 'UT23703']]
        let $authors := $bibls/tei:author
        let $author-1 := $authors[1]
        let $tohs := 
            for $bibl in $bibls
            return translation:toh($tei, $bibl/@key)
        let $tohs-1 := $tohs[1]
        let $toh-number := $tohs-1/@number[. gt ''] ! xs:integer(.)
    
    where 
        $toh-number ge $lowest-toh
        and $toh-number le $highest-toh
        (:and count($bibls) gt 1:)
    
    order by 
        $toh-number, 
        $tohs-1/@letter, 
        $tohs-1/@chapter-number[. gt ''] ! xs:integer(.),
        $tohs-1/@chapter-letter
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'text') } {
            
            attribute text-id { tei-content:id($tei) },
            
            for $toh in $tohs
            return
            element { QName('http://read.84000.co/ns/1.0', 'toh') } {
                attribute key { $toh/@key },
                attribute label { $toh/m:full/text() }
            },
            
            $local-titles,
            
            (: other titles :)
            for $title in $titles[not(data() = $local-titles/data())]
            order by $title/@type
            return
                local:title($title, $title/@type, $title/@xml:lang)
            ,
            (: main author required :)
            if($author-1) then
                local:contributor($author-1)
            else (),
            
            (: other authors :)
            for $author in $authors[not(data() = $author-1/data())]
            return
                local:contributor($author)
        }
}

return (:local:spreadsheet-data($tengyur-data):)$tengyur-data
