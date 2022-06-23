xquery version "3.1" encoding "UTF-8";
import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tmx = "http://www.lisa.org/tmx14";

declare variable $collection-uri := concat($common:data-path, '/translation-memory');

declare function local:add-tu-ids() {
    
    (# exist:batch-transaction #) {
    
        for $tmx in collection($collection-uri)/tmx:tmx
        
        where $tmx/tmx:body/tmx:tu[not(@id) or not(tmx:prop[@name eq 'location-id'])] and $tmx/tmx:header[@eft:text-id = ('UT22084-040-005')]
        
        let $tei := tei-content:tei($tmx/tmx:header/@eft:text-id, 'translation')
        let $text-id := tei-content:id($tei)
        let $toh-key := translation:toh($tei, '')/@key
        let $folio-refs-sorted := translation:folio-refs-sorted($tei, $toh-key)
        
        where $tei and $tmx/tmx:body/tmx:tu[not(@id) or not(tmx:prop[@name eq 'location-id'])]
        return (
        
            $text-id,
            
            for $tu at $tu-index in $tmx/tmx:body/tmx:tu
            
            let $id-attribute := attribute id { string-join(($text-id, 'TU', $tu-index),'-') }
            
            let $location-prop := $tu/tmx:prop[@name eq "location-id"][1]
            let $folio-prop := $tu/tmx:prop[@name eq "folio"][1]
            
            (:where $tu-index eq 1:)
            return (
               (: Set the id :)
                if($tu[@id]) then
                    update replace $tu/@id with $id-attribute
                else
                    update insert $id-attribute into $tu
                ,
                (: Add the location :)
                if(not($location-prop) and $folio-prop) then
                
                    (: Get the nearest location to the folio :)
                    let $folio := 
                        if($folio-prop[@m:cRef-volume]) then
                            $folio-refs-sorted[lower-case(@cRef) eq lower-case($folio-prop/text())][lower-case(@cRef-volume) eq lower-case($folio-prop/@m:cRef-volume)][1]
                        else
                            $folio-refs-sorted[lower-case(@cRef) eq lower-case($folio-prop/text())][1]
                     
                     where $folio
                     let $location-prop :=
                        element { QName('http://www.lisa.org/tmx14', 'prop') } {
                            attribute name { 'location-id' },
                            text { $folio/@xml:id }
                        }
                        
                     return
                        update insert $location-prop following $folio-prop
                        
                else ()
            )
                    
        )
    }

};

local:add-tu-ids()