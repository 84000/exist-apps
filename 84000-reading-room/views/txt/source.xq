xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "indent=no";

declare function local:parse-content($pages as element(m:page)*, $resource-id as xs:string, $toh-key-source as xs:string?) as xs:string* {

    for $page at $position in $pages
    return (
    
        text { '{{page:{resource-id:'  || $resource-id || ',number:' || $position || ',folio:' || $page/@folio-in-etext || ',volume:' || $page/@volume || '}}}' },
        
        for $node at $position in $page/m:language[@xml:lang eq "bo"]/tei:p/node()[. instance of text()]
        where 
            not($toh-key-source)
            or (
               $node[not(following-sibling::tei:milestone[@unit eq 'text'][@toh eq $toh-key-source])]
               and $node[not(preceding-sibling::tei:milestone[@unit eq 'text'][1][@toh ne $toh-key-source])]
            )
        return
            (: Output text :)
            translate(normalize-space(concat('', translate(replace($node, '་\s+$', '་'), '&#xA;', ''), '')), '', '')
    )
    
};

let $data := request:get-data()
let $toh := $data/m:response/m:translation/m:toh[1]
(: TO DO: Using the $toh/@number is a temporary solution until new markers are added to the source :)
let $parsed-content := local:parse-content($data/m:response/m:source/m:page, $toh/@key, $toh/@number)
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
    response:stream-binary($binary, 'text/plain') (:$string:)

