xquery version "3.1" encoding "UTF-8";
(:
    Returns the cumulative glossary xml
    -------------------------------------------------------------
:)
module namespace entities="http://read.84000.co/entities";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

declare variable $entities:entities := doc(concat($common:data-path, '/operations/entities.xml'))/m:entities;
declare variable $entities:types := (
    'eft-glossary-term', 
    'eft-glossary-person', 
    'eft-glossary-place', 
    'eft-glossary-text', 
    'eft-attribution-person'
);
declare variable $entities:instance-types := ('glossary-item');

declare function entities:entities($instance-ids as xs:string*) as element() {
    
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        if(count($instance-ids) gt 0) then
            $entities:entities/m:entity[m:instance[@id = $instance-ids]]
        else ()
    }
    
};

declare function entities:next-id() as xs:string {
    
    let $max-id := max($entities:entities//@xml:id ! substring-after(., 'entity-') ! common:integer(.))
    return
        string-join(('entity', xs:string(sum(($max-id, 1)))), '-')
    
};
