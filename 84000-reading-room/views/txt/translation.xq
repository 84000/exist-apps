xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "indent=no";

declare function local:parse-translation($response as element(m:response)) as text()* {

    
    text { '{{version:' || $response/m:translation/m:publication/m:edition || '}}' },
    text { '&#10;' },
    
    let $toh-key := $response/m:translation//m:source/@key
    for $element in $response/m:translation/m:part[@type eq 'translation']
    return
        local:parse-node($response, $element, $toh-key)
        
};

declare function local:parse-node($response as element(m:response), $element as element(), $toh-key as xs:string?) as text()* {
    
    (: 
        These are the content groups.
        Output the contents.
        They will be separated by a return 
    :)
    if(
        $element[
            self::tei:head[not(@type = ('translation', 'colophon'))]
            | self::tei:p | self::tei:ab | self::tei:l | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label | self::tei:seg | self::tei:milestone
        ][not(@key) or @key eq $toh-key]
    ) then (
        
        let $text-id := $response/m:translation/@id
        
        (: These are the nodes we want to output :)
        let $output-nodes := $element/descendant::text()[not(ancestor::tei:note)][not(ancestor::tei:orig)][normalize-space(.) gt ''] | $element//tei:milestone | $element//tei:ref | $element//tei:note
        
        return (
            for $node at $position in ($element[self::tei:milestone] | $output-nodes)
            return
                
                (: Output milestones with id :)
                if($node[self::tei:milestone]) then
                    let $cache-milestone := $response/m:text-outline[@text-id eq $text-id]/m:pre-processed[@type eq 'milestones']/m:milestone[@id eq $node/@xml:id]
                    let $part := $node/ancestor::m:part[@prefix][1]
                    where $cache-milestone
                    return (
                        text { '{{milestone:{label:' || concat($part/@prefix, '.', ($cache-milestone/@label, $cache-milestone/@index)[1]) || ',id:' || $node/@xml:id || '}}}' }
                    )
                
                (: Output refs with cRef :)
                else if($node[self::tei:ref]) then
                    let $cache-folio := $response/m:text-outline[@text-id eq $text-id]/m:pre-processed[@type eq 'folio-refs']/m:folio-ref[@id eq $node/@xml:id][@resource-id eq $toh-key]
                    where $cache-folio
                    return (
                        text { '{{page:{number:' || $cache-folio/@index-in-resource || ',id:' || $node/@xml:id || ',folio:' || $node/@cRef || $cache-folio[@cRef-volume gt ''] ! concat(',volume:', ./@cRef-volume) || '}}}' }
                    )
                
                (: Output notes :)
                else if($node[self::tei:note]) then
                    let $cache-note := $response/m:text-outline[@text-id eq $text-id]/m:pre-processed[@type eq 'end-notes']/m:end-note[@id eq $node/@xml:id]
                    where $cache-note
                    return (
                        text { '{{note:{index:' || $cache-note/@index || ',id:' || $node/@xml:id || '}}}' }
                    )
    
                (: Output text nodes:)
                else 
                   
                    text {
                        replace(
                            replace(
                                $node
                            , '[\r\n\t]', ' ')    (: remove new line characters :)
                        , '\s+', ' ')             (: condense multiple spaces :)
                    }
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
            local:parse-node($response, $child-element, $toh-key)
    
    else ()
};

let $data := request:get-data()
let $parsed-content := local:parse-translation($data/m:response)
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
     response:stream-binary($binary, 'text/plain') (:$string:)



