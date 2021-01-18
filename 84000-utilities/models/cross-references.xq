xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

declare function local:ref-context($ref as element(tei:ref)) as element(m:ref-context) {
    let $tei := $ref/ancestor::tei:TEI[1]
    let $text-id := tei-content:id($tei)
    (:let $passage := $ref/ancestor-or-self::*[preceding-sibling::tei:milestone[@xml:id]][1]:)
    return 
        element { QName('http://read.84000.co/ns/1.0', 'ref-context') } {
            attribute resource-id { $text-id },
            translation:titles($tei),
            translation:toh($tei, ''),
            $ref(:,
            $passage/preceding-sibling::tei:milestone[@xml:id][1],
            $passage:)
        }
};

common:response(
    'utilities/cross-references',
    'utilities',
    
    for $ref in $tei-content:translations-collection/descendant::tei:ref[matches(@target, '^(http|https)://read\.84000\.co/translation/')]
    let $page-id := substring-after($ref/@target, 'read.84000.co/translation/')
    let $resource-id := tokenize($page-id, '\.')[1]
    let $tei := tei-content:tei($resource-id, 'translation')
    let $text-id := if($tei) then tei-content:id($tei) else $resource-id
    group by $text-id
    return
        if($tei) then
            element { QName('http://read.84000.co/ns/1.0', 'target-text') } {
            
                attribute id { $text-id },
                attribute resource-id { translation:toh-key($tei[1], '') },
                attribute translation-status-group { tei-content:translation-status-group($tei[1]) },
                
                translation:toh($tei[1], $resource-id[1]),
                translation:titles($tei[1]),
                for $one-ref in $ref
                return 
                    local:ref-context($one-ref)
            }
        
        (: !! Also list refs that point to invalid tohs !! :)
        else
            element { QName('http://read.84000.co/ns/1.0', 'target-text') } {
                
                attribute id { '' },
                attribute resource-id { $resource-id },
                
                for $one-ref in $ref
                return 
                    local:ref-context($one-ref)
                    
            }
)