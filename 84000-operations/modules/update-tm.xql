xquery version "3.1";

module namespace update-tm="http://operations.84000.co/update-tm";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace functx="http://www.functx.com";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";
declare namespace bcrdb="http://www.bcrdb.org/ns/1.0";

declare variable $update-tm:tm-path := concat($common:data-path, '/translation-memory');

declare function update-tm:update-segment($tmx as element(tmx:tmx), $unit-id as xs:string, $lang as xs:string, $value as xs:string?) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    let $new-segment := tokenize($value, '\n')[1]
    
    where $tm-unit
    return
        if($new-segment gt '') then
            
            let $existing-tuv := $tm-unit/tmx:tuv[@xml:lang eq $lang]
            let $new-tuv := 
                element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                    attribute xml:lang { $lang },
                    element seg { $new-segment }
                }
            
            let $padding-before := text {$tm-unit/tmx:tuv[last()]/preceding-sibling::text()[1] }

            return
                if($existing-tuv) then 
                    update replace $existing-tuv with $new-tuv
                else
                    update insert ($padding-before, $new-tuv) into $tm-unit
                    
        else (
            update delete $tm-unit,
            update-tm:set-tu-ids($tmx)
        )
};

declare function update-tm:update-unit($tmx as element(tmx:tmx), $unit-id as xs:string, $value-bo as xs:string?, $value-en as xs:string?) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    let $value-bo-tokenized := tokenize($value-bo, '\n')
    let $value-en-tokenized := tokenize($value-en, '\n')
    
    let $new-unit := 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{
            attribute id { $unit-id },
            element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                attribute xml:lang { 'bo' },
                element seg { $value-bo-tokenized[1] }
            },
            element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                attribute xml:lang { 'en' },
                element seg { $value-en-tokenized[1] }
            }
        }
    
    return (
    
        update replace $tm-unit with $new-unit,
        
        if(count($value-bo-tokenized) gt 1) then (
            update-tm:add-unit($tmx, string-join(subsequence($value-bo-tokenized, 2), ''), (), $tmx/tmx:body/tmx:tu[@id eq $unit-id])
        )
        else ()
        
    )
    
};

declare function update-tm:add-unit($tmx as element(tmx:tmx), $value-bo as xs:string?, $value-en as xs:string?, $add-following as element(tmx:tu)?) as element()? {
    
    let $new-unit := 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{
            element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                attribute xml:lang { 'bo' },
                element seg { tokenize($value-bo, '\n')[1] }
            },
            if($value-en) then
                element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                    attribute xml:lang { 'en' },
                    element seg { tokenize($value-en, '\n')[1] }
                }
            else ()
        }
    
    (: Add whitespace for readability :)
    let $padding-after := text { $tmx/tmx:body/tmx:tu[last()]/preceding-sibling::text()[1] }
    
    return (
        if($add-following) then
            update insert ($new-unit, $padding-after) following $add-following
        else
            update insert ($new-unit, $padding-after) into $tmx/tmx:body
        ,
        update-tm:set-tu-ids($tmx)
    )
    
};

declare function update-tm:remove-unit($tmx as element(tmx:tmx), $unit-id as xs:string) as element()? {
    
    update-tm:update-segment($tmx, $unit-id, 'bo', '')
    
};

declare function update-tm:new-tm($text-id as xs:string, $text-version as xs:string, $segments-bo as xs:string*) as document-node()? {
document {
<tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.4b">
    <header creationtool="84000-tm-editor" creationtoolversion="{ $common:app-version }" datatype="PlainText" segtype="block" adminlang="en-us" srclang="bo" eft:text-id="{ $text-id }" eft:text-version="{ $text-version }"/>
    <body>
    {
        for $segment-bo at $index in $segments-bo
        return
            <tu id="{ $text-id }-TU-{ $index }">
                <tuv xml:lang="bo">
                    <seg>{ $segment-bo }</seg>
                </tuv>
                <tuv xml:lang="en">
                    <seg/>
                </tuv>
            </tu>
    }
    </body>
</tmx>
}};

declare function update-tm:new-tmx-from-bcrdCorpus($tei as element(tei:TEI), $bcrd-resource as element(bcrdb:bcrdCorpus)) as xs:string? {
    
    let $text-id := tei-content:id($tei)
    let $text-version := tei-content:version-str($tei)
    let $location := translation:location($tei, '')
    
    let $filename := concat(translation:filename($tei, ''), '.tmx')
    
    let $segments-bo := 
        for $sentence in $bcrd-resource//bcrdb:sentence
        return
            string-join($sentence//bcrdb:phrase/text(), '/ ') ! concat(., '/ ') ! common:bo-from-wylie(.)
            
    let $new-tm := update-tm:new-tm($text-id, $text-version, $segments-bo)
    let $existing-tm := collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]
    
    where $text-id and $text-version and $filename and $new-tm and not($existing-tm)
    let $log := util:log('info', concat('update-tm-add-tm:', $filename))
    return (
        (: Create the file :)
        xmldb:store($update-tm:tm-path, $filename, $new-tm, 'application/xml'),
        sm:chgrp(xs:anyURI(concat($update-tm:tm-path, '/', $filename)), 'translation-memory'),
        sm:chmod(xs:anyURI(concat($update-tm:tm-path, '/', $filename)), 'rw-rw-r--')
    )
    
};

declare function update-tm:new-tmx($tei as element(tei:TEI)) as xs:string? {
    
    let $text-id := tei-content:id($tei)
    let $text-version := tei-content:version-str($tei)
    let $location := translation:location($tei, '')
    let $source-page := source:etext-page($location, 1, false(), ())
    let $source-page-text := string-join($source-page//eft:language[@xml:lang eq 'bo']/tei:p//text(), ' ')
    let $first-line-bo := (tokenize($source-page-text, '།།\s+།།')[2], $source-page-text)[1]
    let $first-line-bo := (tokenize($first-line-bo, '།\s+')[1] ! concat(., '།'), $first-line-bo)[1]
    
    let $filename := concat(translation:filename($tei, ''), '.tmx')
    let $new-tm := update-tm:new-tm($text-id, $text-version, $first-line-bo)
    let $existing-tm := collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]
    
    where $text-id and $text-version and $filename and $new-tm and not($existing-tm)
    let $log := util:log('info', concat('update-tm-add-tm:', $filename))
    return (
        (: Create the file :)
        xmldb:store($update-tm:tm-path, $filename, $new-tm, 'application/xml'),
        sm:chgrp(xs:anyURI(concat($update-tm:tm-path, '/', $filename)), 'translation-memory'),
        sm:chmod(xs:anyURI(concat($update-tm:tm-path, '/', $filename)), 'rw-rw-r--')
    )
    
};

declare function update-tm:set-tu-ids($tmx) {
    
    (# exist:batch-transaction #) {
    
        let $text-id:= $tmx/tmx:header/@eft:text-id/string()
        where $text-id gt '' and $tmx/tmx:body/tmx:tu[not(@id)]
        
        for $tu at $tu-index in $tmx/tmx:body/tmx:tu
        let $id-attribute := attribute id { string-join(($text-id, 'TU', $tu-index),'-') }
        return 
            if($tu[@id]) then
                update replace $tu/@id with $id-attribute
            else
                update insert $id-attribute into $tu
                
    }

};