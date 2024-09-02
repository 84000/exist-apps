xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

common:response(
    'utilities/cross-references',
    'utilities',(
        utilities:request(),
        
        let $source-teis := ($tei-content:translations-collection//tei:TEI, $tei-content:knowledgebase-collection//tei:TEI)
        let $source-texts :=
            for $source-tei in $source-teis
            let $source-resource-id := tei-content:id($source-tei)
            let $source-resource-type := tei-content:type($source-tei)
            let $source-status-group := tei-content:publication-status-group($source-tei)
            let $source-refs := $source-tei/descendant::tei:ref[matches(@target, '^https?://read\.84000[^/]*/translation/([^\.#]+)')]
            where $source-refs (:and $source-resource-id eq 'UT22084-093-018':)
            return
                element { QName('http://read.84000.co/ns/1.0', 'source-text') } {
                    
                    attribute id { $source-resource-id },
                    attribute type { $source-resource-type },
                    attribute status-group { tei-content:publication-status-group($source-tei) },
                    
                    tei-content:titles-all($source-tei),
                    $source-resource-type[. eq 'translation'] ! translation:toh($source-tei, ''),
                    
                    for $ref in $source-refs
                    let $target-path := replace($ref/@target, '^https?://read\.84000[^/]+/translation/(.+)', '$1', 'i')
                    let $target-page := tokenize($target-path, '#')[1]
                    let $target-hash := tokenize($target-path, '#')[2]
                    let $target-resource-id := replace($target-path, '^([^\.#]+)(.*)', '$1', 'i')
                    return
                        element ref {
                            $ref/@*,
                            attribute target-path { $target-path },
                            attribute target-page { $target-page },
                            attribute target-hash { $target-hash },
                            attribute target-resource-id { $target-resource-id },
                            if(not(matches($ref/@target, '^https?://read\.84000\.co/translation/'))) then 
                                element issue { attribute type { 'invalid-domain' } }
                            else ()
                            ,
                            if(not(matches($target-page, '(^[a-zA-Z0-9\-]*\.html$|^[a-zA-Z0-9\-]*$)', 'i'))) then 
                                element issue { attribute type { 'invalid-url' } }
                            else ()
                            ,
                            if(not($target-hash)) then ()
                            else if($tei-content:translations-collection/id($target-hash)) then ()
                            else if($tei-content:translations-collection/id(substring-after($target-hash, 'end-note-'))[self::tei:note][@place eq 'end']) then ()
                            else
                                element issue { attribute type { 'invalid-id' } }
                        }
                    
                }
            
            let $target-texts :=
                for $text-ref in $source-texts/m:ref
                let $target-resource-id := $text-ref/@target-resource-id
                group by $target-resource-id
                let $target-tei := tei-content:tei($target-resource-id, 'translation')
                where $target-tei
                return
                    element { QName('http://read.84000.co/ns/1.0', 'target-text') } {
                        
                        attribute id { tei-content:id($target-tei) },
                        attribute type { tei-content:type($target-tei) },
                        attribute status-group { tei-content:publication-status-group($target-tei) },
                        attribute ref-target-resource-id { $target-resource-id },
                        
                        tei-content:titles-all($target-tei),
                        translation:toh($target-tei, $target-resource-id)
                        
                    }
            
            return 
                for $source-text in $source-texts
                return
                    element { node-name($source-text) } {
                        $source-text/@*,
                        $source-text/*[not(local-name() eq 'ref')],
                        for $ref in $source-text/m:ref
                        let $target-text := ($target-texts[@id eq $ref/@target-resource-id], $target-texts[m:toh[@key eq $ref/@target-resource-id]])[1]
                        return
                            element { node-name($ref) } {
                                $ref/@*,
                                $ref/*,
                                if (not($target-text)) then
                                    element issue { attribute type { 'invalid-text' } }
                                else ()
                                ,
                                if ($ref[@rend eq 'pending'] and $target-text[@status-group eq 'published']) then
                                    element issue { attribute type { 'pending-link-published-text' } }
                                else ()
                                ,
                                if ($ref[not(@rend eq 'pending')] and $target-text[not(@status-group eq 'published')]) then
                                    element issue { attribute type { 'active-link-unpublished-text' } }
                                else ()
                                ,
                                $target-text
                            }
                    }
    )
)