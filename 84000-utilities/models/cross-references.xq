xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

declare function local:ref-context($ref as element(tei:ref), $target-tei as element(tei:TEI)?) as element(m:ref-context) {
    let $tei := $ref/ancestor::tei:TEI[1]
    let $text-id := tei-content:id($tei)
    let $toh-key := translation:toh-key($tei, '')
    let $target-toh-key := if($target-tei) then translation:toh-key($target-tei, '') else ()
    let $target := tokenize($ref/@target, '/')[last()]
    let $target-page := tokenize($target, '#')[1]
    let $target-hash := tokenize($target, '#')[2]
    let $target-id-validated := 
        if(not($target-hash) or $target-tei/descendant::*[@xml:id = $target-hash]) then
            true()
        else
            false()
    
    (:let $passage := $ref/ancestor-or-self::*[preceding-sibling::tei:milestone[@xml:id]][1]:)
    return 
        element { QName('http://read.84000.co/ns/1.0', 'ref-context') } {
        
            attribute resource-id { $text-id },
            attribute toh-key { $toh-key },
            attribute target-toh-key { $target-toh-key },
            attribute target-page { $target-page },
            attribute target-hash { $target-hash },
            attribute target-id-validated { $target-id-validated },
            
            translation:titles($tei),
            translation:toh($tei, ''),
            $ref(:,
            $passage/preceding-sibling::tei:milestone[@xml:id][1],
            $passage:)
        }
};

common:response(
    'utilities/cross-references',
    'utilities',(
        utilities:request(),
    
        for $ref in $tei-content:translations-collection/descendant::tei:ref[matches(@target, '^(http|https)://read\.84000\.co/translation/')]
        let $page-id := substring-after($ref/@target, 'read.84000.co/translation/')
        let $resource-id := tokenize($page-id, '\.')[1]
        let $target-tei := tei-content:tei($resource-id, 'translation')
        let $target-text-id := if($target-tei) then tei-content:id($target-tei) else $resource-id
        group by $target-text-id
        return
            if($target-tei) then
                element { QName('http://read.84000.co/ns/1.0', 'target-text') } {
                
                    attribute id { $target-text-id },
                    attribute resource-id { translation:toh-key($target-tei[1], '') },
                    attribute translation-status-group { tei-content:translation-status-group($target-tei[1]) },
                    
                    translation:toh($target-tei[1], $resource-id[1]),
                    translation:titles($target-tei[1]),
                    for $one-ref in $ref
                    return 
                        local:ref-context($one-ref, $target-tei[1])
                }
            
            (: !! Also list refs that point to invalid tohs !! :)
            else
                element { QName('http://read.84000.co/ns/1.0', 'target-text') } {
                    
                    attribute id { '' },
                    attribute resource-id { $resource-id[1] },
                    
                    for $one-ref in $ref
                    return 
                        local:ref-context($one-ref, ())
                        
                }
    )
)