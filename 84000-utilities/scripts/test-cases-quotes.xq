xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare option exist:serialize "method=xml indent=no";

declare function local:source-content($elements as node()*) {
    for $element in $elements
    return 
        element { node-name($element) } {
            $element/@*,
            if(not($element[self::tei:note])) then 
                for $node in $element/node()
                return
                    if($node instance of text()) then
                        $node
                    else if($node instance of element()) then
                        local:source-content($node)
                    else ()
            else ()
        }
};

let $resource-id := 'UT23703-093-001'
let $part-id := 'UT23703-093-001-section-1'

let $tei := tei-content:tei($resource-id, 'translation')
let $source := tei-content:source($tei, $resource-id)
let $tei-part := $tei//tei:div[@type eq 'translation']/tei:div(:[@xml:id eq $part-id]:)

let $texts := collection($common:tei-path)//tei:TEI

return
    element { QName('http://read.84000.co/ns/1.0', 'test-cases') } {
    
        attribute type { 'quotes' },
        
        for $quote-ref in $tei-part//tei:ptr[@type eq 'quote-ref'][@target][@rend eq 'substring']
        let $source-location-id := $quote-ref/@target ! replace(., '^#', '')
        let $source-milestone := $texts/id($source-location-id)[self::tei:milestone]
        let $quote-orig := $quote-ref/parent::tei:orig
        where $quote-orig[not(contains(., '…'))]
        return
            element quote {
                attribute id { $quote-ref/@xml:id },
                element quote-text {
                    $quote-ref/ancestor::tei:q ! string-join(descendant::text()[not(ancestor::tei:note | ancestor::tei:orig)]) ! normalize-space(.)
                },
                element source-xml {
                    local:source-content($source-milestone/following-sibling::tei:*[count(preceding-sibling::tei:milestone[1] | $source-milestone) eq 1][not(self::tei:milestone)])
                },
                element matched-xml {
                   $quote-orig/node()[count(. | $quote-ref) gt 1]
                }
            }
            
    }