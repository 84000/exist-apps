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

declare variable $entities:entities := doc(concat($common:data-path, '/operations/entities.xml'));

declare function entities:entities($ids as xs:string*) as element() {
    
    element { QName('http://read.84000.co/ns/1.0', 'entities') }{
        if(count($ids) gt 0) then
            $entities:entities/m:entities/m:entity[m:definition[@id = $ids]]
        else
            ()
    }
    
};
