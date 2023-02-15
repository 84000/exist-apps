xquery version "3.1" encoding "UTF-8";

(: Migrate <tei:q ref="XYZ"/> to <tei:q><ptr type="quote-ref" target="#XYZ"/></tei:q> :)
(: Migrate <tei:q alt="ABC"/> to <tei:q><orig>ABC</orig></tei:q> :)

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare function local:migrate-quote-refs() {

    for $tei at $index in collection($common:tei-path)//tei:TEI[descendant::tei:q[ancestor-or-self::*[@ref]]]
    let $quotes := $tei/descendant::tei:q[ancestor-or-self::*[@ref]]
    let $text-id := tei-content:id($tei)
    where $quotes and $text-id = ((:'UT23703-000-000', :)'UT23703-093-001')
    return (
        
        (: debug :)
        element debug { attribute index { $index }, attribute text-id { $text-id }, attribute count-quotes { count($quotes) } },
        
        (# exist:batch-transaction #) {
        
            for $quote in $quotes[ancestor-or-self::*[@ref]]
            
            (: Convert existing quote attributes into ptr :)
            let $ptr :=
                element { QName('http://www.tei-c.org/ns/1.0', 'ptr') } {
                    attribute type { 'quote-ref' },
                    attribute target { $quote/ancestor-or-self::*[@ref][1]/@ref ! concat('#',.) },
                    if($quote[@type eq 'substring']) then
                        attribute rend { 'substring' }
                    else ()
                    ,
                    attribute xml:id { $quote/@xml:id/string() }
                }
            
            return (
            
                (: debug :)
                $ptr,
                
                (: Migrate @alt to tei:orig :)
                if($quote[@alt][not(tei:orig)]) then 
                    let $orig := 
                        element { QName('http://www.tei-c.org/ns/1.0', 'orig') } {
                            $ptr,
                            text{ $quote/@alt/string() }
                        }
                    return (
                        update insert $orig into $quote,
                        update delete $quote/@alt
                    )
                
                (: Insert ptr in correct node :)
                else if($quote[node()]) then 
                    if($quote[@type eq 'substring'][tei:orig | tei:p]) then 
                        
                        (: Add to orig :)
                        if($quote[tei:orig]) then 
                            update insert $ptr preceding $quote/tei:orig/node()[1]
                        
                        (: Add to p :)
                        else 
                            update insert $ptr preceding $quote/tei:p/node()[1]
                    
                    (: Add to q :)
                    else 
                        update insert $ptr preceding $quote/node()[1]
                
                (: Empty quotes :)
                else
                    update insert $ptr into $quote
                ,
                
                (: Remove legacy attributes :)
                update delete $quote/@*
                
            )
    
        }
    )
};

local:migrate-quote-refs()