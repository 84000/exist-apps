xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "indent=no";

declare function local:parse-content($content) {

    for $group in $content/*
    return
        (: These are the content groups. They will be seperated by a return :)
        if($group[self::m:honoration | self::m:main-title | self::tei:head | self::tei:p | self::tei:ab | self::tei:lg | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label | self::tei:seg | self::tei:milestone])then
        (
            (: Output milestones with id :)
            if($group[self::tei:milestone]) then
            (
                text { '{{milestone:{id:' || $group/@xml:id || '}}}' },
                text {'&#32;'}
            )
            else
            (
                (: These are the nodes we want to include :)
                for $node at $position in ($group//text()[not(ancestor::tei:note)][normalize-space(.) gt ''] | $group//tei:milestone | $group//tei:ref[@folio-index] | $group//tei:note[@index])
                return
                (
                    (: Add a space before all nodes except the first, unless it's punctuation or followed by punctuation :)
                    if($position gt 1 and not(normalize-space($node) = ('.',',','!','?','”',':',';'))) then
                        text {'&#32;'}
                    else
                        ()
                    ,
                    (: Output milestones with id :)
                    if($node[self::tei:milestone]) then
                        text { '{{milestone:{id:' || $node/@xml:id || '}}}' }
                    
                    (: Output refs with cRef :)
                    else if($node[self::tei:ref][@folio-index]) then
                        text { '{{page:{number:' || $node/@folio-index || ',folio:' || $node/@cRef || '}}}' }
                    
                    (: Output notes :)
                    else if($node[self::tei:note][@index]) then
                        text { '{{note:{index:' || $node/@index || ',id:' || $node/@xml:id || '}}}' }
                        
                    (: Output text nodes:)
                    else
                        (: strip the space of the node :)
                        normalize-space($node)
                ),
                (: Add a return character for the last node :)
                text {'&#10;'}
            )
        )
        else
            (: Look for groups down the tree :)
            local:parse-content($group)
            
};

let $data := request:get-data()
let $parsed-content := local:parse-content($data/m:response/m:translation/m:prologue | $data/m:response/m:translation/m:body | $data/m:response/m:translation/m:colophon)
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
    response:stream-binary($binary, 'text/plain') (:$string:)

