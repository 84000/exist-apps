xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";

declare option exist:serialize "indent=no";

declare variable $local:response := request:get-data()/m:response;
(: For debugging - remove authorisation:)
(:declare variable $local:request := <hc:request href="http://read.84000.local/translation/toh58.xml?view-mode=txt" method="GET"/>;
declare variable $local:send-request := hc:send-request($local:request);
declare variable $local:response := $local:send-request[2]/m:response;:)

declare variable $local:toh-key := $local:response/m:translation/m:source/@key;
declare variable $local:text-id := $local:response/m:translation/@id;
declare variable $local:text-outline := $local:response/m:text-outline[@text-id eq $local:text-id];
declare variable $local:output-style := if($local:response/m:request[@resource-suffix eq 'plain.txt']) then 'plain' else 'annotated';

declare function local:parse-translation() as text()* {

    text { '{{translation:{id:' || $local:text-id || ',key:' || $local:toh-key || ',version:' || tei-content:strip-version-number($local:response/m:translation/m:publication/m:edition/text()[1]) || ',style:' || $local:output-style || '}}}' },
    local:parse-elements($local:response/m:translation/m:part[@type eq 'translation'], 1, '')

};

declare function local:parse-elements($elements as element()*, $element-index as xs:integer, $last-location-id as xs:string) as text()* {
    
    (: 
        These are the content groups.
        Output the contents.
        They will be separated by a return 
    :)
    
    let $element := $elements[$element-index]
    
    let $output-element :=
        $element
            [self::tei:head[not(@type = ('translation', 'colophon'))] | self::tei:p | self::tei:ab | self::tei:l | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label | self::tei:seg]
            [not(@key) or @key eq $local:toh-key]
    
    (: These are the nodes we want to output :)
    (: Union should ensure that node order is retained :)
    let $output-nodes := 
        $output-element/descendant::text()[normalize-space(.)][not(ancestor::tei:note)][not(ancestor::tei:orig)]
        | $output-element/descendant::tei:ref
        | $output-element/descendant::tei:note
    
    let $child-elements := $element/*[not(@content-status eq 'unpublished')][descendant::text()[normalize-space(.)]]
    
    return (
        
        (: Output the content group :)
        if($output-nodes)then 
            (:text { '&#10;' || count($output-nodes) || ' nodes' }:)
            let $chunk-size := 500
            let $chunks-count := (count($output-nodes) div $chunk-size)  ! ceiling(.) ! xs:integer(.)
            for $chunk-index in 1 to $chunks-count
            let $chunk-start := (($chunk-index - 1) * $chunk-size) + 1
            let $chunk-end := $chunk-start + ($chunk-size - 1)
            let $subsequence := subsequence($output-nodes, $chunk-start, $chunk-size)
            return
                (:text { '&#10;' || $chunk-start || '-' || $chunk-end || ' ' || count($subsequence) || ' nodes' }:)
                local:output-nodes($subsequence, 1, $last-location-id)
        
        (: Look for groups down the tree :) 
        else if($child-elements) then
            (:text { '&#10;' || count($child-elements) || ' elements' }:)
            let $chunk-size := 500
            let $chunks-count := (count($child-elements) div $chunk-size)  ! ceiling(.) ! xs:integer(.)
            for $chunk-index in 1 to $chunks-count
            let $chunk-start := (($chunk-index - 1) * $chunk-size) + 1
            let $chunk-end := $chunk-start + ($chunk-size - 1)
            let $subsequence := subsequence($child-elements, $chunk-start, $chunk-size)
            return
                (:text { '&#10;' || $chunk-start || '-' || $chunk-end || ' ' || count($subsequence) || ' nodes' }:)
                local:parse-elements($subsequence, 1, $last-location-id)
        
        else ()
        ,
        
        (: Recurse to next element :)
        if($element-index lt count($elements)) then
            
            let $last-location := $output-nodes[last()] ! local:persistent-location(.)
            
            let $last-location-id := 
                if($last-location[(@xml:id, @id)[. gt '']]) then
                    ($last-location/@xml:id, $last-location/@id)[. gt ''][1]
                else
                    $last-location-id
            
            return
                local:parse-elements($elements, $element-index + 1, $last-location-id)
        
        else ()
        
    )
    
};

declare function local:output-nodes($output-nodes as node()*, $node-index as xs:integer, $last-location-id as xs:string) as text()* {

    let $node := $output-nodes[$node-index]
    let $node-location := local:persistent-location($node)
    let $node-location-id := ($node-location/@xml:id, $node-location/@id)[. gt ''][1]
    (: Output a milestone for a new part if the first element has content :)
    let $node-location-output :=
        if(not($node-location-id eq $last-location-id)) then 
            
            let $node-location-milestone := $local:text-outline/m:pre-processed[@type eq 'milestones']/m:milestone[@id eq $node-location-id]
            
            let $node-location-part := 
                if($node-location-milestone) then
                    $local:text-outline/m:pre-processed[@type eq 'parts']//m:part[@id eq ($node-location-milestone/@label-part-id, $node-location-milestone/@part-id)[1]]
                else 
                    $local:text-outline/m:pre-processed[@type eq 'parts']//m:part[@id eq $node-location-id]
            
            let $milestone-props := (
                $node-location-part/ancestor-or-self::m:part[@prefix][1] ! concat('label:', @prefix, $node-location-milestone ! concat('.', (@label, @index)[1])),
                concat('id:', $node-location-id)
            )
            
            return
                text { '{{milestone:{' ||  string-join($milestone-props, ',')  || '}}}' }
        
        else ()
    
    return (
        if($local:output-style eq 'annotated' or $node instance of text()) then (
            
            (: Add a return character per group or new milestone :)
            if((($local:output-style eq 'annotated' and $node-index eq 1) or ($local:output-style eq 'plain' and count($node | ($output-nodes[. instance of text()])[1]) eq 1)) or $node-location-output) then
                text { '&#10;' }
            else()
            ,
            
            if($local:output-style eq 'annotated' and $node-location-output) then
                $node-location-output
            else ()
            ,
            
            (: Output refs with cRef :)
            if($node[self::tei:ref]) then
            
                let $folio-outline := $local:text-outline/m:pre-processed[@type eq 'folio-refs']/m:folio-ref[@id eq $node/@xml:id][@source-key eq $local:toh-key]
                let $folio-props := (
                    $folio-outline/@index-in-resource[. gt ''] ! concat('number:', .), 
                    $node/@xml:id[. gt ''] ! concat('id:', .), 
                    $node/@cRef[. gt ''] ! concat('folio:', .), 
                    $folio-outline/@cRef-volume[. gt ''] ! concat('volume:', .)
                )
                where $folio-outline
                return 
                    text { '{{page:{' || string-join($folio-props, ',') || '}}}' }
            
            (: Output notes :)
            else if($node[self::tei:note]) then
            
                let $note-outline := $local:text-outline/m:pre-processed[@type eq 'end-notes']/m:end-note[@id eq $node/@xml:id][@source-key eq $local:toh-key]
                let $note-props := (
                    $note-outline/@index[. gt ''] ! concat('index:', .),
                    $node/@xml:id[. gt ''] ! concat('id:', .)
                )
                where $note-outline
                return 
                    text { '{{note:{' || string-join($note-props, ',') || '}}}' }
    
            (: Output text nodes:)
            else if($node instance of text()) then
            
                text {
                    
                    replace(
                        replace(
                            $node 
                        ,'[\r\n\t]', '')   (: Remove returns and tabs :)        
                    ,'\s+', ' ')           (: Condense other whitespace :) 
                    
                }
            
            else ()
            
        )
        
        else ()
        ,
    
        if($node-index lt count($output-nodes)) then
            local:output-nodes($output-nodes, $node-index + 1, ($node-location-id, $last-location-id)[1])
        else ()
    
    )
};

declare function local:persistent-location($node as node()) as element() {

    if($node[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]) then
        $node/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]
    else 
        $node/ancestor-or-self::m:part[@id][1]

};

let $parsed-content := local:parse-translation()
let $string := string-join($parsed-content) ! string-join(tokenize(., '\n') ! replace(., '\s+', ' ') ! replace(., '^\s', ''), '&#10;')
let $binary := util:base64-encode($string)

return
     response:stream-binary($binary, 'text/plain') (:$string:)

