xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "indent=no";

declare function local:parse-content($content) {

    for $page at $position in $content//m:page
    return (
    
        text { '{{page:{number:' || $position || ',folio:' || $page/@folio-in-etext || ',volume:' || $page/@volume || '}}}' },
        
        for $node at $position in $page//node()[self::text() | self::tei:milestone[@unit eq "text"]]
        return
            if($node[self::tei:milestone]) then (
            
                (: Output milestones with id :)
                if($position gt 1) then
                    text {'&#10;'}
                else
                    (),
                text { '{{toh:' || $node/@toh || '}}' }
            
            )
            else
                (: Output text :)
                translate(normalize-space(concat('', translate(replace($node, '་\s+$', '་'), '&#xA;', ''), '')), '', '')
    )
};

let $data := request:get-data()
let $parsed-content := local:parse-content($data/m:response/m:source)
let $string := string-join($parsed-content, '')
let $binary := util:base64-encode($string)

return
    response:stream-binary($binary, 'text/plain') (:$string:)

