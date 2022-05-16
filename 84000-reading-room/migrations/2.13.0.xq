xquery version "3.1" encoding "UTF-8";
import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

declare variable $collection-uri := concat($common:data-path, '/translation-memory');

declare function local:add-tu-ids() {
    
    (# exist:batch-transaction #) {
    
        for $tmx in collection($collection-uri)/tmx:tmx
        let $text-id:= $tmx/tmx:header/@eft:text-id/string()
        where $text-id = ('UT22084-059-006')
        for $tu at $tu-index in $tmx/tmx:body/tmx:tu
        let $index-attribute := attribute id { string-join(($text-id, 'TU', $tu-index),'-') }
        (:where $tu-index eq 1:)
        return 
            if($tu[@id]) then
                update replace $tu/@id with $index-attribute
            else
                update insert $index-attribute into $tu 
    
    }

};

local:add-tu-ids()