xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:teis := $tei-content:translations-collection//tei:TEI;
declare variable $local:text-refs := doc(concat($common:data-path, '/config/linked-data/text-refs.xml'));

(:declare function local:linked-data($text as element(eft:text), $source-key as xs:string) as element(eft:linkedData)* {

    for $text-ref in $text/eft:ref[@type = ('bdrc-work-id','bdrc-tibetan-id','bdrc-derge-id')]
    return
        types:linked-data($source-key, 'sameAs', $text-ref/@value)
    ,
    for $text-ref in $text/eft:ref[@type = ('rkts-work-id')]
    return
        types:linked-data($source-key, 'sameAs', 'RefrKTsK:' || $text-ref/@value)

};:)

let $response := 
    element works-relations {
        
        attribute modelType { 'works-relations' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/works-relations.json?', string-join((concat('api-version=', $types:api-version)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        for $source-tei in $local:teis
        return
            for $source-bibl in $source-tei//tei:sourceDesc/tei:bibl[@key]
            let $source-text-ref := $local:text-refs//eft:text[@key eq $source-bibl/@key]
            return (
                for $link in $source-tei//tei:sourceDesc/tei:link[@type]
                let $target-tei := tei-content:tei($link/@target, 'translation')
                let $target-text-ref := $local:text-refs//eft:text[@key eq $link/@target]
                return
                    types:object-relation($source-bibl/@key, $link/@type, ($target-tei ! $link/@target, $target-text-ref/eft:ref[@type eq 'eft-section-id']/@value, concat('unknown:', $link/@target))[1])
                
                (:,
                $source-text-ref ! local:linked-data(., $source-bibl/@key):)
                
            )
        (:,
        
        let $source-keys := $local:teis//tei:sourceDesc/tei:bibl/@key
        let $tei-refs := $local:text-refs//eft:text[@key = $source-keys]
        for $source-text-ref in $local:text-refs//eft:text except $tei-refs
        return
            $source-text-ref ! local:linked-data(., $source-text-ref/@key)
        :)
    }



return
    if($local:request-store eq 'store') then
        helpers:store($response, concat($response/@modelType, '.json'), ())
    else
        $response
        