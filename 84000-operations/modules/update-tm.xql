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
declare namespace fn="http://www.w3.org/2005/xpath-functions";

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
    return 
        update-tm:store-tmx($new-tm, $filename)
    
};

declare function update-tm:new-tmx-from-linguae-dharmae($tei as element(tei:TEI)) as element(tmx:tmx)? {
    
    let $toh-key := tei-content:source($tei,'')/@key
    let $text-id := tei-content:id($tei)
    let $text-version := tei-content:version-str($tei)
    
    where $toh-key
    
    let $ld-path := concat($common:data-path, '/uploads/linguae-dharmae/aligned/31-10-2022/complete/', $toh-key, '-bo_aligned.txt')
    let $ld-doc := util:binary-to-string(util:binary-doc($ld-path))
    let $ld-lines := tokenize($ld-doc, '\n')
    
    where count($ld-lines) gt 0
    return
        <tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.4b">
            { common:ws(1) }
            <header creationtool="linguae-dharmae/84000" creationtoolversion="{ $common:app-version }" datatype="PlainText" segtype="block" adminlang="en-us" srclang="bo" eft:text-id="{ $text-id }" eft:text-version="{ $text-version }" eft:source-ref="{ $ld-path }"/>
            { common:ws(1) }
            <body>
            {   
                for $line at $index in $ld-lines
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

declare function update-tm:store-tmx($tmx as element(tmx:tmx), $filename as xs:string) as xs:string? {
    (
        (: Create the file :)
        util:log('info', concat('update-tm-add-tmx:', $filename)),
        xmldb:store($update-tm:tm-path, $filename, $tmx, 'application/xml'),
        sm:chgrp(xs:anyURI(concat($update-tm:tm-path, '/', $filename)), 'translation-memory'),
        sm:chmod(xs:anyURI(concat($update-tm:tm-path, '/', $filename)), 'rw-rw-r--')
    )
};

declare function update-tm:tm-units-aligned($tei as element(tei:TEI), $tmx as element(tmx:tmx)?) as element(eft:tm-unit-aligned)* {

    let $text-id := tei-content:id($tei)
    let $text-version := tei-content:version-str($tei)
    
    (: Convert TEI to text :)
    let $tei-text-nodes := local:tei-text-nodes($tei//tei:div[@type eq 'translation'])
    let $tei-text-string := string-join($tei-text-nodes, ' ')
    
    (: Match the translation :)
    return 
        local:tm-unit-aligned($tmx/tmx:body/tmx:tu, 1, $tei-text-string)

};

declare function local:tei-text-nodes($elements as element()*) as xs:string* {
    
    for $element in $elements
    return (
        (: Recurse through divs divs :)
        if($element[self::tei:div][@xml:id | @type]) then (
            concat('{{milestone:', ($element/@xml:id, $element/@type)[1], '}} '),
            local:tei-text-nodes($element/*)
        )
        
        (: Ignore some head tags :)
        else if($element[self::tei:head][@type = ('translation', 'titleHon', 'colophon')]) then
            ()
        
        (: Add milestone markers :)
        else if($element[self::tei:milestone][@xml:id]) then
            concat('{{milestone:', $element/@xml:id, '}} ')
        
        (: Otherwise include all descendant text :)
        else 
            string-join($element/descendant::text()[normalize-space(.)][not(ancestor::tei:note | ancestor::tei:orig)], '') ! normalize-space(.) ! normalize-unicode(.)
            
    )
};

declare function local:tm-unit-aligned($tm-units as element(tmx:tu)*, $tm-unit-index as xs:integer, $tei-text-substr as xs:string?) as element()* {
    
    let $tm-unit := $tm-units[$tm-unit-index] 
    let $tm-bo := ($tm-unit/tmx:tuv[@xml:lang eq 'bo']/tmx:seg ! normalize-space(.), '')[1]
    let $tm-en := ($tm-unit/tmx:tuv[@xml:lang eq 'en']/tmx:seg ! normalize-space(.), '')[1]
    
    (: Remove content in double square brackets :)
    let $tm-en-notes-removed := replace($tm-en, '\[{2}.*\]{2}\s*', '')
    
    (: Build a regex :)
    let $tm-en-regex := if($tm-en-notes-removed gt '') then concat('(?:^|\s|\}{2})([^\p{L}\p{N}\s]*)(', string-join(tokenize($tm-en-notes-removed, '[^\p{L}\p{N}]+', 'i')[normalize-space(.)] ! lower-case(.) ! functx:escape-for-regex(.), '[^\p{L}\p{N}]+'), ')([^\p{L}\p{N}\s]*)(?:\s|\{{2}|$)') else '--force-no-match--'
    
    (: Find the next occurrence of this string :)
    let $tei-text-substr-analyzed := analyze-string($tei-text-substr, $tm-en-regex, 'i')
    let $tei-text-substr-match := $tei-text-substr-analyzed//fn:match[fn:group][1]
    let $tei-text-substr-group := $tei-text-substr-match/fn:group[@nr]
    let $tei-text-substr-preceding := string-join(($tei-text-substr-match/preceding-sibling::node()/descendant-or-self::text(), $tei-text-substr-group[1]/preceding-sibling::node()/descendant-or-self::text()))
    let $tei-text-substr-trailing := 
        if($tei-text-substr-match) then
            string-join(($tei-text-substr-group[last()]/following-sibling::node()/descendant-or-self::text(), $tei-text-substr-match/following-sibling::node()/descendant-or-self::text()))
        else
            $tei-text-substr-analyzed/fn:non-match/text()
    
    (: Pass on the string with the chunk extracted :)
    let $tei-text-substr-remainder := string-join(($tei-text-substr-preceding, $tei-text-substr-trailing))
    
    (: Find the id in the preceding chunk :)
    let $tei-text-preceding-analyzed := if($tei-text-substr-match) then analyze-string($tei-text-substr-preceding, '\{{2}milestone:([^\{\}]+)\}{2}') else ()
    let $tei-text-preceding-location-match := $tei-text-preceding-analyzed//fn:match[last()]
    let $tei-location-id := 
        if($tei-text-preceding-location-match) then 
            $tei-text-preceding-location-match/fn:group[@nr eq '1']
        else ()
    
    let $revision := 
        if($tei-text-substr-match and not(normalize-space($tm-en) eq normalize-space(string-join($tei-text-substr-group)))) then
            normalize-space(string-join($tei-text-substr-group))
        else ()
    
    let $new-location := 
        if($tei-location-id gt '' and not($tei-location-id eq $tm-unit/tmx:prop[@name eq 'location-id']/string())) then
            $tei-location-id
        else ()
    
    return (
        
        element { QName('http://read.84000.co/ns/1.0','tm-unit-aligned') } {
            
            (:attribute debug { $tm-en-regex },:)
            attribute id { $tm-unit/@id },
            attribute index { $tm-unit-index },
            
            if(not($tm-bo gt '')) then
                attribute issue { 'bo-missing' }
            else if(not($tm-en gt '')) then
                attribute issue { 'en-missing' }
            else if(not($tei-text-substr-match)) then
                attribute issue { 'en-unmatched' }
            else if($revision) then
                attribute issue { 'en-revised' }
            else if($new-location) then
                attribute issue { 'new-location' }
            else ()
            ,
            
            if($new-location) then
                attribute new-location { $new-location }
            else ()
            ,
            
            if($revision) then (
                element revision { normalize-space(string-join($tei-text-substr-group)) }
            )
            else ()
            
            (:,$tm-en-regex:)
            (:,if(not($tei-text-substr-match)) then $tei-text-substr-analyzed else ():)
            (:,$tei-text-substr-remainder:)
            
        },
        
        (: Recurse with the remainder :)
        if($tm-unit-index lt count($tm-units)) then
            local:tm-unit-aligned($tm-units, $tm-unit-index + 1, normalize-space($tei-text-substr-remainder))
        
        (: Or return the remainder for use in the UI :)
        else 
            let $remainder-str := replace($tei-text-substr-remainder, '\{{2}milestone:([^\{\}]+)\}{2}', '') ! replace(., '\s+[^\p{L}\p{N}]+\s+', ' ') ! normalize-space(.)
            where $remainder-str
            return
                element { QName('http://read.84000.co/ns/1.0','remainder') } {
                    $remainder-str
                }
    )
    
};

declare function update-tm:apply-revisions($tm-units-aligned as element(eft:tm-unit-aligned)*, $tmx as element(tmx:tmx)) as xs:string* {
    
    (# exist:batch-transaction #) {
    
    for $tm-unit-aligned in $tm-units-aligned[@new-location or eft:revision]
    let $tu := $tmx/tmx:body/tmx:tu[@id eq $tm-unit-aligned/@id]
    let $tu-location-id := $tu/tmx:prop[@name eq 'location-id']
    
    return (
    
        (: Apply the revision :)
        if($tm-unit-aligned[eft:revision]) then (
            concat('Update tu[id=', $tu/@id,']/tuv[@xml:lang=en]/seg/text() to ', $tm-unit-aligned[eft:revision]/text()),
            update replace $tu/tmx:tuv[@xml:lang eq 'en']/tmx:seg/text() with $tm-unit-aligned/eft:revision/text()
        )
        else ()
        ,
        
        (: Update the location :)
        if($tm-unit-aligned[@new-location]) then 
        
            let $tu-location-id-new :=
                element { QName('http://www.lisa.org/tmx14','prop') } { 
                    attribute name { 'location-id' },
                    text { $tm-unit-aligned/@new-location }
                }
                
            return (
                    concat('Update tu[id=', $tu/@id,']/prop/@location-id to ', $tm-unit-aligned/@new-location),
                    if($tu-location-id) then
                        update replace $tu-location-id with $tu-location-id-new
                    else
                        update insert ($tu-location-id-new, text { common:ws(3) } ) preceding $tu/tmx:tuv[1]
                )
                
        else ()
        
    )
        
    }(: close exist:batch-transaction  :)
};
