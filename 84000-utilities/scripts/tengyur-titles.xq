xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tengyur-tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare function local:data-item($toh as xs:string, $text-id as xs:string, $type as xs:string, $group as xs:string?, $lang as xs:string?, $value as xs:string?) as element(m:item) {
    element { QName('http://read.84000.co/ns/1.0', 'item') } {
        element toh { $toh },
        element text-id { $text-id },
        element type { $type },
        element group { $group },
        element lang { $lang },
        element value { $value }
    }
};

declare function local:data-item-author($author as element(tei:author), $text-id as xs:string, $toh as element(m:toh)) as element(m:item)* {

    let $author-data := $author/data()
    let $type := 
        if(matches($author-data, '^a[\.:]\s*')) then
            'author'
        else if(matches($author-data, '^r[\.:]\s*')) then
            'reviser'
        else 'translator'
    
    let $author-tokenized := tokenize(replace($author-data, '^[atr][\.:]\s*', ''), '[,:]') ! normalize-space(.)
    for $author-string in $author-tokenized
        let $lang := 
            if(count(tokenize($author-string, '\s')) eq 1) then
                'Sa-Ltn'
            else
                'Bo-Ltn'
    
    let $author-id := replace($author-tokenized[1], '\W+', '-')
    
    return
        local:data-item($toh/m:full/text(), $text-id, $type, $author-id, $lang, $author-string)
                    
};

declare function local:title($title as element(tei:title)?) as element(m:title) {
    
    element { QName('http://read.84000.co/ns/1.0', 'title') } {
        $title/@type,
        $title/@xml:lang,
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
                    if(matches($author-tokenized, '^a[\.:]\s*')) then
                        'author'
                    else if(matches($author-tokenized, '^r[\.:]\s*')) then
                        'reviser'
                    else if(matches($author-tokenized, '^t[\.:]\s*')) then
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
    
    let $contributor-ref := replace(($contributor-Bo-Ltn, $contributor-Sa-Ltn)[1]/text(), '\W+', '-')
    
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

element { QName('http://read.84000.co/ns/1.0', 'tengyur-data') } {
    for $tei in $local:tengyur-tei[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq "O1JC76301JC10416"]]]
        let $titles := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
        let $title-Bo-Ltn := $titles[@type eq 'mainTitle'][@xml:lang eq 'Bo-Ltn'][1]
        let $title-Sa-Ltn := $titles[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'][1]
        let $title-en := $titles[@type eq 'mainTitle'][@xml:lang eq 'en'][1]
        let $bibls := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno[@parent-id eq "O1JC76301JC10416"]]
        let $authors := $bibls/tei:author
        let $author-1 := $authors[1]
        let $tohs := 
            for $bibl in $bibls
            return translation:toh($tei, $bibl/@key)
        let $tohs-1 := $tohs[1]
    order by 
        $tohs-1/@number[. gt ''] ! xs:integer(.), 
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
                
                (: 3 main titles required :)
                local:title($title-Bo-Ltn),
                local:title($title-Sa-Ltn),
                local:title($title-en),
                
                (: other titles :)
                for $title in $titles[not(data() = ($title-Bo-Ltn, $title-Sa-Ltn, $title-en))]
                order by $title/@type
                return
                    local:title($title)
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
        (:(
                (\: 3 main titles required :\)
                local:data-item($toh/m:full/text(), $text-id, 'title', 'mainTitle', 'Bo-Ltn', $title-Bo-Ltn),
                local:data-item($toh/m:full/text(), $text-id, 'title', 'mainTitle', 'Sa-Ltn', $title-Sa-Ltn),
                local:data-item($toh/m:full/text(), $text-id, 'title', 'mainTitle', 'en', $title-en),
                (\: other titles :\)
                for $title in $titles[not(data() = ($title-Bo-Ltn, $title-Sa-Ltn, $title-en))]
                return
                    local:data-item($toh/m:full/text(), $text-id, 'title', $title/@type, $title/@xml:lang, $title/data())
                ,
                (\: main author required :\)
                local:data-item-author($author-1, $text-id, $toh),
                (\: other authors :\)
                for $author in $authors[not(data() = $author-1/data())]
                return
                    local:data-item-author($author, $text-id, $toh)
                ,
                (\: blank row between texts :\)
                local:data-item('-', '', '', '', '', '')
            ):)
}
