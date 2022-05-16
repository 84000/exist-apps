xquery version "3.1";

module namespace update-tm="http://operations.84000.co/update-tm";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

declare function update-tm:update-segment($tmx as element(tmx:tmx), $unit-id as xs:string, $lang as xs:string, $value as xs:string?) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    let $existing-value := $tm-unit/tmx:tuv[@xml:lang eq $lang]
    let $new-value := 
        element { QName('http://www.lisa.org/tmx14', 'tuv') }{
            attribute xml:lang { $lang },
            element seg {
                tokenize($value, '\n')[1]
            }
        }
    
    return
        common:update('update-tm-segment', $existing-value, $new-value, $tm-unit, ())
    
};
