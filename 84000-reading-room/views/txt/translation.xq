xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "indent=no";

declare function local:parse-translation($response as element(m:response)) {
    
    text { '{{version:' || $response/m:translation/m:publication/m:edition || '}}' },
    text { '&#10;' },

    for $element in $response/m:translation/m:part[@type eq 'translation']/*[not(self::tei:head[@type eq 'translation'])]
    return
        local:parse-node($response, $element)
};

declare function local:parse-node($response as element(m:response), $element as element()) {
    
    (: 
        These are the content groups.
        Output the contents.
        They will be seperated by a return 
    :)
    if($element[self::m:honoration | self::m:main-title | self::tei:head | self::tei:p | self::tei:ab | self::tei:l | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label | self::tei:seg | self::tei:milestone])then (
        
        (: These are the nodes we want to output :)
        let $output-nodes := $element/descendant::text()[not(ancestor::tei:note)][normalize-space(.) gt ''] | $element//tei:milestone | $element//tei:ref | $element//tei:note
        return (
            for $node at $position in ($element[self::tei:milestone] | $output-nodes)
            return
                
                (: Output milestones with id :)
                if($node[self::tei:milestone]) then
                    let $cache-milestone := $response/m:milestones-cache/m:milestone[@id eq $node/@xml:id]
                    let $part := $node/ancestor::m:part[@prefix][1]
                    where $cache-milestone
                    return (
                        text { '{{milestone:{label:' || concat($part/@prefix, '.', $cache-milestone/@index) || ',id:' || $node/@xml:id || '}}}' }
                    )
                
                (: Output refs with cRef :)
                else if($node[self::tei:ref]) then
                    let $cache-folio := $response/m:folios-cache/m:folio-ref[@id eq $node/@xml:id]
                    where $cache-folio
                    return (
                        text { '{{page:{number:' || $cache-folio/@index-in-resource || ',id:' || $node/@xml:id || ',folio:' || $node/@cRef || $cache-folio[@cRef-volume gt ''] ! concat(',volume:', ./@cRef-volume) || '}}}' }
                    )
                (: Output notes :)
                else if($node[self::tei:note]) then
                    let $cache-note := $response/m:notes-cache/m:end-note[@id eq $node/@xml:id]
                    where $cache-note
                    return (
                        text { '{{note:{index:' || $cache-note/@index || ',id:' || $node/@xml:id || '}}}' }
                    )
    
                (: Output text nodes:)
                else 
                   
                    replace(
                        replace(
                            $node
                        , '[\r\n\t]', ' ')    (: remove new line characters :)
                    , '\s+', ' ')            (: condense multiple spaces :)
                    
            ,
            
            (: Add a return character for the last node, if there was some output :)
            if($output-nodes) then
                text { '&#10;' }
            else ()
        )
    )
    (: Look for groups down the tree :) 
    else if($element[*]) then
        for $child-element in $element/*
        return
            local:parse-node($response, $child-element)
    else
        ()
};

let $data := request:get-data()
let $parsed-content := local:parse-translation($data/m:response)
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
    (: response:stream-binary($binary, 'text/plain') :)$string



