xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

declare function local:linked-text($tei as element(tei:TEI)) as element(m:text) {
    element { QName('http://read.84000.co/ns/1.0', 'text') } {
    
        attribute id { tei-content:id($tei) },
        attribute document-url { base-uri($tei) },
        attribute file-name { util:unescape-uri(replace(base-uri($tei), ".+/(.+)$", "$1"), 'UTF-8') },
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        
        translation:titles($tei, ()),
        translation:toh($tei, ''),
        
        for $link in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:link[@type][@target]
        let $target-tei := tei-content:tei($link/@target, 'translation')
        return
            element link {
                $link/@*,
                if($target-tei) then
                    element { QName('http://read.84000.co/ns/1.0', 'text') } {
                    
                        attribute id { tei-content:id($target-tei) },
                        attribute document-url { base-uri($target-tei) },
                        attribute file-name { util:unescape-uri(replace(base-uri($target-tei), ".+/(.+)$", "$1"), 'UTF-8') },
                        attribute status { tei-content:publication-status($target-tei) },
                        attribute status-group { tei-content:publication-status-group($target-tei) },
                        
                        translation:titles($target-tei, $link/@target),
                        translation:toh($target-tei, $link/@target)
                        
                    }
                else ()
            }
            
    }
};

declare function local:spreadsheet-data($linked-texts as element(m:text)*){
    element { QName('http://read.84000.co/ns/1.0', 'spreadsheet-data') } {
    
        attribute key { '84000-linked-texts' },
        
        for $text in $linked-texts
        order by 
            $text/m:toh[1]/@number[. gt ''] ! xs:integer(.),
            $text/m:toh[1]/@chapter-number[. gt ''] ! xs:integer(.)
        return
            element row {
                element ID { $text/@id/string() },
                element Toh { 
                    attribute width { '10' },
                    string-join($text/m:toh/m:base, ' ') 
                },
                for $type in ('isCommentaryOf','hasCommonSourceText')
                return
                element { $type } {
                    attribute width { '50' }, 
                    if($text/m:link[@type eq $type]/m:text[m:toh]) then
                        string-join($text/m:link[@type eq $type]/m:text/m:toh/m:base ! string-join(text()) ! normalize-space(), ', ')
                    else if($text/m:link[@type eq $type][@target gt '']) then
                        string-join($text/m:link[@type eq $type]/@target ! normalize-space(), ', ') ! concat('Not found: ', .)
                    else ()
                }
            }
        
    }
};

let $linked-texts := 
    for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:link[@type][@target]]
    return
        local:linked-text($tei)

return
    common:response(
        'utilities/linked-texts',
        'utilities',(
            utilities:request(),
            if(request:get-parameter('resource-suffix', '') eq 'xlsx') then
                local:spreadsheet-data($linked-texts)
            else
                $linked-texts
        )
    )

