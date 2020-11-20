xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "indent=no";

declare function local:parse-translation($translation as element(m:translation)) {
    
    text { '{{version:' || $translation/m:publication/m:edition || '}}' },

    for $element in $translation/m:part[@type eq 'translation']/m:part/*
    return
        local:parse-node($translation, $element)
};

declare function local:parse-node($translation as element(m:translation), $element as element()*) {
    
    (: These are the content groups. They will be seperated by a return :)
    if($element[self::m:honoration | self::m:main-title | self::tei:head | self::tei:p | self::tei:ab | self::tei:lg | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label | self::tei:seg | self::tei:milestone])then (
        
        (: Output milestones with id :)
        if($element[self::tei:milestone]) then (
            let $cache-milestone := $translation/m:milestones-cache/m:milestone[@id eq $element/@xml:id]
            let $part := $element/ancestor::m:part[@prefix][1]
            return (
                text { '{{milestone:{label:' || concat($part/@prefix, '.', $cache-milestone/@index) || ',id:' || $element/@xml:id || '}}}' },
                text {'&#32;'}
            )
        )
        
        else (
            (: These are the nodes we want to include :)
            for $node at $position in ($element//text()[not(ancestor::tei:note | ancestor::m:publication[parent::m:translation])][normalize-space(.) gt ''] | $element//tei:milestone | $element//tei:ref | $element//tei:note)
            return (
                (: Add a space before all nodes except the first, unless it's punctuation or followed by punctuation :)
                if($position gt 1 and not(normalize-space($node) = ('.',',','!','?','”',':',';'))) then
                    text {'&#32;'}
                else
                    ()
                ,
                (: Output milestones with id :)
                if($node[self::tei:milestone]) then
                    let $cache-milestone := $translation/m:milestones-cache/m:milestone[@id eq $node/@xml:id]
                    let $part := $node/ancestor::m:part[@prefix][1]
                    where $cache-milestone
                    return
                        text { '{{milestone:{label:' || concat($part/@prefix, '.', $cache-milestone/@index) || ',id:' || $node/@xml:id || '}}}' }
                
                (: Output refs with cRef :)
                else if($node[self::tei:ref]) then
                    let $cache-folio := $translation/m:folios-cache/m:folio-ref[@id eq $node/@xml:id]
                    where $cache-folio
                    return
                        text { '{{page:{number:' || $cache-folio/@index-in-resource || ',id:' || $node/@xml:id || ',folio:' || $node/@cRef || $cache-folio[@cRef-volume gt ''] ! concat(',volume:', ./@cRef-volume) || '}}}' }
                
                (: Output notes :)
                else if($node[self::tei:note]) then
                    let $cache-note := $translation/m:notes-cache/m:end-note[@id eq $node/@xml:id]
                    where $cache-note
                    return
                        text { '{{note:{index:' || $cache-note/@index || ',id:' || $node/@xml:id || '}}}' }

                (: Output text nodes:)
                else
                    (: strip the space of the node :)
                    normalize-space($node)
            ),
            (: Add a return character for the last node :)
            text {'&#10;'}
        )
    )
    (: Look for groups down the tree :)
    else if($element[*]) then
        local:parse-node($translation, $element/*)
    else
        ()
};

let $data := request:get-data()
let $parsed-content := local:parse-translation($data/m:response/m:translation)
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
    response:stream-binary($binary, 'text/plain')(: $string:)



