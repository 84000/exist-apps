xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

(:declare option exist:serialize "method=xml indent=no";:)
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

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

let $commentary-id := 'UT23703-093-001'
let $root-id := 'UT22084-026-001'

let $commentary-tei := tei-content:tei($commentary-id, 'translation')
let $commentary-part := $commentary-tei//tei:div[@type eq 'translation'](:/tei:div[@xml:id eq 'UT23703-093-001-section-1']:)

let $root-tei := tei-content:tei($root-id, 'translation')

return
    element { QName('http://read.84000.co/ns/1.0', 'test-cases') } {
    
        attribute type { 'quotes' },
        
        for $quote-ref in $commentary-part//tei:ptr[@type eq 'quote-ref'][@target][@rend eq 'substring'][parent::tei:orig]
        let $source-location-id := $quote-ref/@target ! replace(., '^#', '')
        let $source-milestone := $root-tei/id($source-location-id)[self::tei:milestone]
        let $quote-orig := $quote-ref/parent::tei:orig
        where $source-milestone (:$quote-orig[not(contains(., '…'))]:)
        return
            element quote {
                attribute id { $quote-ref/@xml:id },
                element quote-text {
                    $quote-ref/ancestor::tei:q ! string-join(descendant::text()[not(ancestor::tei:note | ancestor::tei:orig)]) ! normalize-space(.)
                }(:,
                element source-xml {
                    local:source-content($source-milestone/following-sibling::tei:*[count(preceding-sibling::tei:milestone[1] | $source-milestone) eq 1][not(self::tei:milestone)])
                }:),
                element manual-match-in-root {
                    attribute milestone-id { $source-milestone/@xml:id },
                    $quote-orig ! string-join(descendant::text()) ! normalize-space(.)
                }
            }
            
    }