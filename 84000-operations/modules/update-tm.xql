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
            
            (: If removed then re-set ids :)
            update-tm:set-tu-ids($tmx)
        )
};

declare function update-tm:update-unit($tmx as element(tmx:tmx), $unit-id as xs:string, $value-bo as xs:string?, $value-en as xs:string?, $location-id as xs:string) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    let $value-bo-tokenized := tokenize($value-bo, '\n')
    let $value-en-tokenized := tokenize($value-en, '\n')
    
    let $new-unit := 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{
        
            attribute id { $unit-id },
            
            $tm-unit/tmx:prop[not(@name = ('location-id'))],
            
            element { QName('http://www.lisa.org/tmx14', 'prop') }{
                attribute name { 'location-id' },
                text { $location-id }
            },
            
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
        
        if(normalize-space($value-bo-tokenized[1]) gt '') then 
            update replace $tm-unit with $new-unit
        else (),
        
        if(count($value-bo-tokenized) gt 1) then (
            update-tm:add-unit($tmx, string-join(subsequence($value-bo-tokenized, 2), ''), string-join(subsequence($value-en-tokenized, 2), ''), $location-id, $tmx/tmx:body/tmx:tu[@id eq $unit-id])
        )
        else ()
        
    )
    
};

declare function update-tm:add-unit($tmx as element(tmx:tmx), $value-bo as xs:string?, $value-en as xs:string?, $location-id as xs:string, $add-following as element(tmx:tu)?) as element()? {
    
    let $new-unit := 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{
            
            if($location-id gt '') then
                element { QName('http://www.lisa.org/tmx14', 'prop') }{
                    attribute name { 'location-id' },
                    text { $location-id }
                }
            else ()
            ,
            
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
        
        (: If added then re-set ids :)
        update-tm:set-tu-ids($tmx)
    )
    
};

declare function update-tm:remove-unit($tmx as element(tmx:tmx), $unit-id as xs:string) as element()? {
    
    update-tm:update-segment($tmx, $unit-id, 'bo', '')
    
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

declare function update-tm:new-tm($text-id as xs:string, $text-version as xs:string, $source-ref as xs:string, $segments-bo as xs:string*) as document-node()? {
document {
<tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.4b">
    <header creationtool="84000-tm-editor" creationtoolversion="{ $common:app-version }" datatype="PlainText" segtype="block" adminlang="en-us" srclang="bo" eft:text-id="{ $text-id }" eft:text-version="{ $text-version }" eft:source-ref="{ $source-ref }"/>
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
    
    let $filename := concat(translation:filename($tei, ''), '.tmx')
    
    let $segments-bo := 
        for $sentence in $bcrd-resource//bcrdb:sentence
        return
            string-join($sentence//bcrdb:phrase/text(), '/ ') ! concat(., '/ ') ! common:bo-from-wylie(.)
    
    let $new-tm := update-tm:new-tm($text-id, $text-version, util:document-name($bcrd-resource), $segments-bo)
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

declare function update-tm:new-tmx-from-linguae-dharmae($toh-key as xs:string) as element(tmx:tmx)? {
    
    let $ld-path := concat($common:data-path, '/uploads/linguae-dharmae/aligned/31-10-2022/cleaned/', $toh-key, '-bo_aligned_cleaned.txt')
    let $ld-doc := util:binary-to-string(util:binary-doc($ld-path))
    
    let $tei := tei-content:tei($toh-key, 'translation')
    let $text-id := tei-content:id($tei)
    let $text-version := tei-content:version-str($tei)
    
    return
    <tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.4b">
        { common:ws(1) }
        <header creationtool="linguae-dharmae/84000" creationtoolversion="{ $common:app-version }" datatype="PlainText" segtype="block" adminlang="en-us" srclang="bo" eft:text-id="{ $text-id }" eft:text-version="{ $text-version }" eft:source-ref="{ $ld-path }"/>
        { common:ws(1) }
        <body>
        {   
            for $line at $index in tokenize($ld-doc, '\n')
            let $segments := tokenize($line, '\t')
            let $bo := $segments[1] ! replace(., '\{.+\}', '')
            let $en := $segments[2]
            where $bo
            return (
                common:ws(2),
                <tu id="{ $text-id }-TU-{ $index }">
                    { common:ws(3) }
                    <tuv xml:lang="bo">
                        <seg>{ $bo }</seg>
                    </tuv>
                    { common:ws(3) }
                    <tuv xml:lang="en">
                        <seg>{ $en }</seg>
                    </tuv>
                    { common:ws(2) }
                </tu>
            ),
            common:ws(1) 
        }
        </body>
        { common:ws(0) }
    </tmx>

};

declare function update-tm:maintain-tmx($tei as element(tei:TEI)){
    
    (: Get the TM file :)
    
    (: Convert TEI to text :)
    
    (: Loop through TM segments :)
        (: Match the translation :)
        (: Update changes to translation :)
        (: Add milestone ids :)
    
};