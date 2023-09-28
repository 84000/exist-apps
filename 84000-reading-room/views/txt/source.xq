xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";

declare option exist:serialize "indent=no";

declare variable $local:response := request:get-data()/m:response;
declare variable $local:text-id := $local:response/m:translation/@id;
declare variable $local:toh-key := $local:response/m:translation/m:toh[1]/@key;
declare variable $local:toh-number := $local:toh-key ! replace(., '^toh', '');
declare variable $local:text-outline := $local:response/m:text-outline[@text-id eq $local:text-id];
declare variable $local:output-style := if($local:response/m:request[@resource-suffix eq 'plain.txt']) then 'plain' else 'annotated';

declare function local:parse-source() as text()* {

    text { '{{source:{key:' || $local:toh-key || ',style:' || $local:output-style || '}}}' },
    text { '&#10;' },
    local:parse-pages($local:response/m:source/m:page)

};

declare function local:parse-pages($pages as element(m:page)*) as text()* {

    for $page at $position in $pages
    return (
    
        if($local:output-style eq 'annotated') then
            let $page-props := (
                $position ! concat('number:', .), 
                $page/@folio-in-etext[. gt ''] ! concat('folio:', .), 
                $page/@volume[. gt ''] ! concat('volume:', .)
            )
            return
                text { '{{page:{' || string-join($page-props, ',') || '}}}' }
                
        else ()
        ,
        
        for $node at $position in $page/m:language[@xml:lang eq "bo"]/tei:p/node()[. instance of text()]
        where 
            not($local:toh-number)
            or (
               $node[not(following-sibling::tei:milestone[@unit eq 'text'][@toh eq $local:toh-number])]
               and $node[not(preceding-sibling::tei:milestone[@unit eq 'text'][1][not(@toh eq $local:toh-number)])]
            )
        return
            (: Output text :)
            text { translate(normalize-space(concat('', translate(replace($node, '་\s+$', '་'), '&#xA;', ''), '')), '', '') }
            
    )
    
};

(: Actually we want to use the BDRC ids here, but we don't have them for the Tengyur yet :)
(:let $parsed-content := local:parse-content($data/m:response/m:source/m:page, $toh/@key, $toh/m:ref[@type eq 'bdrc-idx']/@value[1]):)
let $parsed-content := local:parse-source()
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
    response:stream-binary($binary, 'text/plain') (:$string:)

