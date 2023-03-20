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
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        
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
                        attribute status { tei-content:translation-status($target-tei) },
                        attribute status-group { tei-content:translation-status-group($target-tei) },
                        
                        translation:titles($target-tei, $link/@target),
                        translation:toh($target-tei, $link/@target)
                        
                    }
                else ()
            }
            
    }
};

common:response(
    'utilities/linked-texts',
    'utilities',(
        utilities:request(),
        for $tei in $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:link[@type][@target]]
        return
            local:linked-text($tei)
    )
)