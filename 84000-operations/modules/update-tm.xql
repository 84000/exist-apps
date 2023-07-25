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
declare variable $update-tm:units-aligned-per-page := 100;
declare variable $update-tm:blocking-jobs := scheduler:get-scheduled-jobs()//scheduler:job[@name = ('tm-maintenance')][not(scheduler:trigger/state/text() eq 'COMPLETE')];
declare variable $update-tm:flags := ('requires-attention','alternative-source');

declare function update-tm:update-unit($tmx as element(tmx:tmx), $unit-id as xs:string, $value-bo as xs:string?, $value-en as xs:string?, $location-id as xs:string, $flags as xs:string*) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    let $value-bo-tokenized := tokenize($value-bo, '\n')
    let $value-en-tokenized := tokenize($value-en, '\n')
    
    let $new-unit := 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{
        
            attribute id { $unit-id },
            
            (: Preserve eft elements :)
            for $other in $tm-unit/eft:*
            return (
                common:ws(3),
                $other
            ),
            
            (: Preserve additional tmx:props :)
            for $prop in $tm-unit/tmx:prop[not(@name = ('location-id','revision','unmatched', $update-tm:flags ))]
            return (
                common:ws(3),
                $prop
            ),
            
            (: location-id :)
            if($location-id gt '') then (
               common:ws(3),
               element { QName('http://www.lisa.org/tmx14', 'prop') }{
                   attribute name { 'location-id' },
                   text { $location-id }
               }
            )
            else()
            ,
            
            (: revision :)
            common:ws(3),
            element { QName('http://www.lisa.org/tmx14', 'prop') }{
                attribute name { 'revision' },
                text { $tmx/tmx:header/@eft:text-version/string() }
            },
            
            (: flags :)
            for $flag in $update-tm:flags
            where $flag[. = $flags]
            return (
               common:ws(3),
               element { QName('http://www.lisa.org/tmx14', 'prop') }{
                   attribute name { $flag },
                   attribute user { common:user-name() },
                   attribute timestamp { current-dateTime() }
               }
            ),
            
            if($value-bo-tokenized[1]) then (
                common:ws(3),
                element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                    attribute xml:lang { 'bo' },
                    element seg { $value-bo-tokenized[1] }
                }
            )
            else()
            ,
            
            if($value-en-tokenized[1]) then (
                common:ws(3),
                element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                    attribute xml:lang { 'en' },
                    element seg { $value-en-tokenized[1] }
                }
            )
            else(),
            
            common:ws(2)
        }
    
    where not($update-tm:blocking-jobs)
    return (
        
        update replace $tm-unit with $new-unit
        ,
        
        if(count($value-bo-tokenized) gt 1 or count($value-en-tokenized) gt 1) then (
            update-tm:add-unit($tmx, string-join(subsequence($value-bo-tokenized, 2), ''), string-join(subsequence($value-en-tokenized, 2), ''), $location-id, $tmx/tmx:body/tmx:tu[@id eq $unit-id], true())
        )
        else ()
        
    )
    
};

declare function update-tm:add-unit($tmx as element(tmx:tmx), $value-bo as xs:string?, $value-en as xs:string?, $location-id as xs:string, $add-following as element(tmx:tu)?, $set-tu-ids as xs:boolean?) as element()? {
    
    let $new-unit := 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{
        
            common:ws(3),
            element { QName('http://www.lisa.org/tmx14', 'prop') }{
                attribute name { 'revision' },
                text { $tmx/tmx:header/@eft:text-version/string() }
            },
            
            if($location-id gt '') then (
                common:ws(3),
                element { QName('http://www.lisa.org/tmx14', 'prop') }{
                    attribute name { 'location-id' },
                    text { $location-id }
                }
            )
            else ()
            ,
            
            if($value-bo) then (
                common:ws(3),
                element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                    attribute xml:lang { 'bo' },
                    element seg { normalize-space($value-bo) }
                }
            )
            else ()
            ,
            
            if($value-en) then (
                common:ws(3),
                element { QName('http://www.lisa.org/tmx14', 'tuv') }{
                    attribute xml:lang { 'en' },
                    element seg { normalize-space($value-en) }
                }
            )
            else ()
            ,
            
            common:ws(2)
        }
    
    (: Add whitespace for readability :)
    let $padding := common:ws(2)
    
    return (
    
        if($add-following) then
            update insert ($padding, $new-unit) following $add-following
        else
            update insert ($new-unit, $padding) into $tmx/tmx:body
        ,
        
        (: If added then re-set ids :)
        if($set-tu-ids) then
            update-tm:set-tu-ids($tmx)
        else ()
    )
    
};

declare function update-tm:remove-unit($tmx as element(tmx:tmx), $unit-id as xs:string) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    
    where $tm-unit and not($update-tm:blocking-jobs)
    return (
    
        update delete $tm-unit,
        
        (: If removed then re-set ids :)
        update-tm:set-tu-ids($tmx)
        
    )
    
};

declare function update-tm:set-tu-ids($tmx) {
    
    (# exist:batch-transaction #) {
    
        let $text-id:= $tmx/tmx:header/@eft:text-id/string()
        where $text-id gt '' and $tmx/tmx:body/tmx:tu[not(@id)]
        
        let $log := util:log('info', concat('update-tm-set-tu-ids: ', $text-id))
        
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
    
    let $text-outline := translation:parts($tei, (), $translation:view-modes/eft:view-mode[@id eq 'outline'], ())
    let $translation-outline := $text-outline[@id eq 'translation']
    
    let $ld-path := concat($common:data-path, '/uploads/linguae-dharmae/aligned/31-10-2022/complete/', $toh-key, '-bo_aligned.txt')
    let $ld-doc := util:binary-to-string(util:binary-doc($ld-path))
    let $ld-lines := tokenize($ld-doc, '\n')
    
    where count($ld-lines) gt 0
    
    let $tus :=
        for $line at $index in $ld-lines
        let $segments := tokenize($line, '\t')
        let $bo := $segments[1] ! replace(., '\{.+\}', '')
        let $en := $segments[2]
        where $bo
        return 
            element { QName('http://www.lisa.org/tmx14','tu') } {
                attribute id { concat($text-id, '-TU-', $index)},
                common:ws(3),
                element tuv {
                    attribute xml:lang { 'bo' },
                    element seg { $bo }
                },
                common:ws(3),
                element tuv {
                    attribute xml:lang { 'en' },
                    element seg { $en }
                },
                common:ws(2)
            }
    
    return
        <tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.4b">
            { common:ws(1) }
            <header creationtool="linguae-dharmae/84000" creationtoolversion="{ $common:app-version }" datatype="PlainText" segtype="block" adminlang="en-us" srclang="bo" eft:text-id="{ $text-id }" eft:text-version="{ $text-version }" eft:source-ref="{ $ld-path }"/>
            { common:ws(1) }
            <body>
            {
                for $tu in $tus
                return (
                    common:ws(2), 
                    $tu
                )
            }
            { common:ws(1) }
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

declare function update-tm:apply-revisions($tei as element(tei:TEI), $tmx as element(tmx:tmx)) {
    
    let $start-time := util:system-dateTime()
    
    let $text-id := tei-content:id($tei)
    let $tei-version := tei-content:version-str($tei)
    
    let $tm-units := $tmx/tmx:body/tmx:tu
    let $tmx-version := $tmx/tmx:header/@eft:text-version
    let $tmx-duration := $tmx/tmx:header/@eft:seconds-to-revise
    
    let $log := util:log('info', concat('update-tm-apply-revisions:', $text-id, ', ', format-number(count($tm-units), '#,###'), ' units...'))
    
    (: Clear existing remainders :)
    let $clear-remainders := 
        for $remainder-unit in $tm-units[not(tmx:tuv[@xml:lang eq 'bo'])]
        return
            update delete $remainder-unit
    
    let $tm-units := $tmx/tmx:body/tmx:tu
    let $apply-revisions := local:apply-revisions($tm-units, 1, $tei, ())
    
    (: Save new remainders :)
    let $add-remainders :=
        for $tm-unit-remainder in $apply-revisions[@remainder]
        for $remainder-match in analyze-string($tm-unit-remainder, '(\{{2}[a-zA-Z0-9:-]+\}{2})?([^\{{2}]+)', 'i')/fn:match
        let $remainder-en := normalize-space($remainder-match/fn:group[@nr eq '2']/text())
        let $remainder-location := $remainder-match/fn:group[@nr eq '1']/text() ! replace(., '\{{2}([a-zA-Z]+):([a-zA-Z0-9\-]+)\}{2}', '$2', 'i')
        where matches($remainder-en, '\p{L}+', 'i')
        return 
            update-tm:add-unit($tmx, (), $remainder-en, $remainder-location, (), false())
    
    let $end-time := util:system-dateTime()
    let $duration-seconds := functx:total-seconds-from-duration($end-time - $start-time)
    
    (: Recurse through chunks of units applying revisions :)
    return (
        
        (: Return the updates so we can log a count :)
        $apply-revisions,
        
        (: Reset the ids :)
        update-tm:set-tu-ids($tmx),
        
        (: Update TM version number :)
        if($tmx-version) then
            update replace $tmx-version with attribute eft:text-version { $tei-version } 
        else
            update insert attribute eft:text-version { $tei-version } into $tmx/tmx:header
        ,
        
        (: Update TM duration :)
        if($tmx-duration) then
            update replace $tmx-duration with attribute eft:seconds-to-revise { $duration-seconds } 
        else
            update insert attribute eft:seconds-to-revise { $duration-seconds } into $tmx/tmx:header
        ,
        
        util:log('info', concat('update-tm-apply-revisions: ', count($apply-revisions), ' units revised.'))
        
    )
    
};

declare function local:apply-revisions($tm-units as element(tmx:tu)*, $start-unit as xs:integer, $tei as element(tei:TEI), $tei-text as xs:string?) as element(eft:tm-unit-aligned)* {
    
    (: Recurse through chunks of TM units applying revisions :)
    
    (# exist:batch-transaction #) {
    
    let $tm-units-chunk := subsequence($tm-units, $start-unit, $update-tm:units-aligned-per-page)
    let $tm-units-aligned := local:tm-unit-aligned($tm-units-chunk, 1, $start-unit, $tei, $tei-text)
    let $tm-units-revised := $tm-units-aligned[@new-location or @unmatched or eft:revision]
    let $tm-units-remainder := $tm-units-aligned[@remainder]
    
    let $log := util:log('info', concat('update-tm-apply-revisions: ', count($tm-units-revised), ' revisions in units ', $start-unit, ' to ', ($start-unit - 1) + count($tm-units-chunk)))
    
    let $tei-version:= tei-content:version-str($tei)
    let $next-start-unit := $start-unit + $update-tm:units-aligned-per-page

    return (
        
        (: Apply the revisions :)
        
        let $tu-revision-prop-new :=
            element { QName('http://www.lisa.org/tmx14','prop') } { 
                attribute name { 'revision' },
                text { $tei-version }
            }
        
        for $tm-unit-aligned in $tm-units-revised
        let $tu := $tm-units[@id eq $tm-unit-aligned/@id]
        let $tu-location-id := $tu/tmx:prop[@name eq 'location-id']
        let $tu-revision-prop := $tu/tmx:prop[@name eq 'revision']
        let $tu-unmatched-prop := $tu/tmx:prop[@name eq 'unmatched']
        
        let $tu-location-id-new :=
            element { QName('http://www.lisa.org/tmx14','prop') } {
                attribute name { 'location-id' },
                text { $tm-unit-aligned/@new-location }
            }
        
        where $tu
        return (
            
            $tm-unit-aligned,
            
            (: Apply the revision :)
            if($tm-unit-aligned[eft:revision]) then (
                update replace $tu/tmx:tuv[@xml:lang eq 'en']/tmx:seg/text() with $tm-unit-aligned/eft:revision/text(),
                update delete $tu-unmatched-prop
            )
            else (
                
                (: Remove empty values :)
                if(string-join($tu/tmx:tuv[@xml:lang eq 'en']/tmx:seg/text()) ! not(normalize-space(.))) then
                    update delete $tu/tmx:tuv[@xml:lang eq 'en']
                    
                else if(string-join($tu/tmx:tuv[@xml:lang eq 'bo']/tmx:seg/text()) ! not(normalize-space(.))) then
                    update delete $tu/tmx:tuv[@xml:lang eq 'bo']
                    
                else ()
                ,
                
                (: Flag unmatched :)
                if($tm-unit-aligned[@unmatched]) then 
                    
                    let $tu-unmatched-prop-new :=
                        element { QName('http://www.lisa.org/tmx14','prop') } { 
                            attribute name { 'unmatched' },
                            text { $tei-version }
                        }
                    
                    return
                        if ($tu-unmatched-prop) then
                            update replace $tu-unmatched-prop with $tu-unmatched-prop-new
                        
                        else
                            update insert ($tu-unmatched-prop-new, common:ws(3) ) preceding $tu/tmx:tuv[1]
            
                else if($tu-unmatched-prop) then
                    update delete $tu-unmatched-prop
                
                else ()
                
            )
            ,
            
            (: Update the location :)
            if($tm-unit-aligned[@new-location] and $tu-location-id) then 
                update replace $tu-location-id with $tu-location-id-new
            
            else if($tm-unit-aligned[@new-location]) then
                update insert ($tu-location-id-new, common:ws(3) ) preceding $tu/tmx:tuv[1]
            
            else ()
            ,
            
            (: Audit the revision :)
            if($tm-unit-aligned[@new-location or eft:revision]) then
                if($tu-revision-prop) then
                    update replace $tu-revision-prop with $tu-revision-prop-new
                else
                    update insert ($tu-revision-prop-new, common:ws(3) ) preceding $tu/tmx:tuv[1]
            else ()
            
        )
        ,
        
        (: Return content-break remainders :)
        $tm-units-remainder[@remainder eq 'content-break-remainder'],
        
        (: Recurse try the next chunk :)
        if($next-start-unit le count($tm-units)) then
            let $tei-text-remainder := $tm-units-aligned[@remainder eq 'tei-text-remainder'][normalize-space(text())]
            where $tei-text-remainder
            return
                local:apply-revisions($tm-units, $next-start-unit, $tei, $tei-text-remainder/text())
        
        (: Return final remainder :)
        else 
            $tm-units-aligned[@remainder eq 'tei-text-remainder']
        
    )
    }(: close exist:batch-transaction  :)
};

declare function local:tm-unit-aligned($tm-units as element(tmx:tu)*, $tm-unit-pos as xs:integer, $tm-unit-index as xs:integer, $tei as element(tei:TEI), $tei-text as xs:string?) as element(eft:tm-unit-aligned)* {
    
    (: Try to align an English segment with the TEI to find revisions :)
    
    let $tm-unit := $tm-units[$tm-unit-pos] 
    let $tm-bo := string-join($tm-unit/tmx:tuv[@xml:lang eq 'bo']/tmx:seg/text())
    let $tm-en := string-join($tm-unit/tmx:tuv[@xml:lang eq 'en']/tmx:seg/text())
    
    (: Remove content in double square brackets :)
    let $tm-en-notes-removed := replace($tm-en, '\[{2}.*\]{2}\s*', '')
    
    (: Build a regex :)
    let $tm-en-regex := 
        if($tm-en-notes-removed gt '') then 
            concat(
                (: Non-capture word start :)
                '(?:^|\s|—|\}{2})',
                (: Capture leading punctuation :)
                '([^\p{L}\s]*)',
                (: Iterate through words :)
                '(', string-join(
                    tokenize($tm-en-notes-removed, '[^\p{L}]+', 'i')[normalize-space(.)] ! lower-case(.) ! functx:escape-for-regex(.), 
                    (: separated by non-word, (and optional {{tag}}) :)
                    '[^\p{L}]+(?:\{{2}[^\{\}]+\}{2}[^\p{L}]+)?'
                ), ')',
                (: Capture trailing punctuation :)
                '([^\p{L}\s]*)',
                (: Non-capture word end :)
                '(?:\s|—|\{{2}|$)'
            )
            (:let $tm-en-tokenized := tokenize($tm-en-notes-removed, '[^\p{L}]+', 'i')
            let $tm-en-tokenized-first := $tm-en-tokenized[1]
            let $tm-en-tokenized-last := $tm-en-tokenized[last()]
            return
                concat(
                
                    (\: prologue :\)
                    '(?:^|\s|\}{2})([^\p{L}\s]*)(', 
                    
                    (\: start word :\)
                    $tm-en-tokenized-first,
                    
                    (\: negative look-behind of start word :\)
                    '(?!.*\b', $tm-en-tokenized-first, '\b)',
                    
                    (\: number of instances of end word :\)
                    string-join($tm-en-tokenized[. eq $tm-en-tokenized-last] ! concat('[^\p{L}]+.*?[^\p{L}]+', .)),
                    
                    (\: epilogue :\)
                    ')([^\p{L}\s]*)(?:\s|\{{2}|$)'
                    
                ):)
        else '--force-no-match--'
    
    (: A content-break property resets the $tei-text :)
    let $tm-content-break := $tm-unit/tmx:prop[@name eq 'content-break']/text() ! string()
    let $tei-content-break-section := $tei//tei:div[@type eq 'translation']/tei:div[@xml:id eq $tm-content-break]
    
    (: Store any remainder text :)
    let $tm-content-break-remainder := 
        if($tei-content-break-section  and $tei-text ! normalize-space(.)) then
            $tei-text ! normalize-space(.)
        else ()
    
    (: Load new text :)
    let $tei-text := 
        (: A content-break property resets the $tei-text :)
        if($tei-content-break-section) then
            local:tei-text-string($tei-content-break-section)
        
        (: Otherwise, start at the beginning, but exclude content-break sections to come :)
        else if($tm-unit-index eq 1) then
            
            let $tmx-content-breaks := $tm-unit/ancestor::tmx:body//tmx:prop[@name eq 'content-break']/text() ! string()
            return
                local:tei-text-string($tei//tei:div[@type eq 'translation']/tei:*[not(@xml:id = $tmx-content-breaks)])
        
        (: Use the string passed :)
        else 
            $tei-text
    
    let $log-content-break :=
        if($tei-content-break-section) then 
            util:log('info', concat('update-tm-tm-unit-aligned: ', 'content-break:', $tm-content-break, ' content-length:', format-number(string-length($tei-text), '#,###')))
        else ()
    
    (: Find the next occurrence of this string :)
    let $tei-text-analyzed := analyze-string($tei-text, $tm-en-regex, 'i')
    
    let $tei-text-match := $tei-text-analyzed//fn:match[fn:group][1]
    let $tei-text-group := $tei-text-match/fn:group[@nr]
    let $tei-text-group-analyzed := if($tei-text-match) then analyze-string(string-join($tei-text-group), '(\{{2}[^\{\}]+\}{2})', 'i') else ()
    
    (: Extract any milestones from the string :)
    let $tei-text-match-string := string-join($tei-text-group-analyzed/fn:non-match/text()) ! normalize-space(.)
    let $tei-text-group-milestone := $tei-text-group-analyzed/fn:group[@nr eq '1']/text()
    
    (: Get preceding and following text to pass on :)
    let $tei-text-preceding := string-join(($tei-text-match/preceding-sibling::node()/descendant-or-self::text(), $tei-text-group[1]/preceding-sibling::node()/descendant-or-self::text()))
    let $tei-text-trailing := 
        if($tei-text-match) then
            string-join(($tei-text-group-milestone, $tei-text-group[last()]/following-sibling::node()/descendant-or-self::text(), $tei-text-match/following-sibling::node()/descendant-or-self::text()))
        else
            $tei-text-analyzed/fn:non-match/text()
    
    (: Pass on the string with the chunk extracted :)
    let $tei-text-remainder := string-join(($tei-text-preceding, $tei-text-trailing)) ! normalize-space(.)
    
    (: Find the id in the preceding chunk :)
    let $tei-text-preceding-analyzed := if($tei-text-match) then analyze-string($tei-text-preceding, '\{{2}milestone:([^\{\}]+)\}{2}', 'i') else ()
    let $tei-text-preceding-location-match := $tei-text-preceding-analyzed//fn:match[last()]
    let $tei-location-id := 
        if($tei-text-preceding-location-match) then 
            $tei-text-preceding-location-match/fn:group[@nr eq '1']
        else ()
    
    (: Test for a revision :)
    let $revision := 
        if($tei-text-match and not(normalize-space($tm-en) eq $tei-text-match-string)) then
            $tei-text-match-string
        else ()
    
    (: Test for a new location :)
    let $new-location := 
        if($tei-location-id gt '' and not($tei-location-id eq $tm-unit/tmx:prop[@name eq 'location-id']/string())) then
            $tei-location-id
        else ()
    
    return (
        
        if($tm-unit) then
            element { QName('http://read.84000.co/ns/1.0','tm-unit-aligned') } {
                
                (:attribute debug { $tm-en-regex },:)
                attribute id { $tm-unit/@id },
                attribute index { $tm-unit-index },
                
                if(not($tm-bo gt '')) then
                    attribute issue { 'bo-missing' }
                else if(not($tm-en gt '')) then
                    attribute issue { 'en-missing' }
                else if(not($tei-text-match)) then
                    attribute issue { 'en-unmatched' }
                else if($revision) then
                    attribute issue { 'en-revised' }
                else if($new-location) then
                    attribute issue { 'new-location' }
                else ()
                ,
                
                if(not($tei-text-match)) then
                    attribute unmatched { 1 }
                else ()
                ,
                
                if($new-location) then
                    attribute new-location { $new-location }
                else ()
                ,
                
                if($revision) then
                    element revision { 
                        attribute xml:lang { 'en' },
                        $revision 
                    }
                else ()
                
                
            }
        else ()
        ,
        
        (: Content break, return remainder :)
        if($tm-content-break-remainder) then
            element { QName('http://read.84000.co/ns/1.0','tm-unit-aligned') } {
                attribute remainder { 'content-break-remainder' },
                text {  local:tei-text-remainder($tm-content-break-remainder) }
            }
        else (),
        
        (: Recurse with the remainder :)
        if($tm-unit-pos lt count($tm-units)) then
            local:tm-unit-aligned($tm-units, $tm-unit-pos + 1, $tm-unit-index + 1, $tei, $tei-text-remainder)
        
        (: The last of this batch, return the remainder :)
        else
            element { QName('http://read.84000.co/ns/1.0','tm-unit-aligned') } {
                attribute remainder { 'tei-text-remainder' },
                text { local:tei-text-remainder($tei-text-remainder) }
            }
        
    )
    
};

declare function local:tei-text-string($nodes as node()*) as xs:string? {

    let $tei-text-nodes := local:tei-text-strings($nodes)
    
    return 
        string-join($tei-text-nodes, ' ')
        
};

declare function local:tei-text-strings($nodes as node()*) as xs:string* {
    
    for $node in $nodes
    return (
        
        (: Ignore some head tags :)
        if($node[self::tei:head][@type = ('translation', 'colophon')]) then
            ()
        
        (: Don't recurse into some tags :)
        else if($node[self::tei:note | self::tei:orig]) then
            ()
        
        (: Add milestone markers :)
        else if($node[self::tei:milestone][@xml:id]) then
            concat('{{milestone:', $node/@xml:id, '}} ')
        
        (: Add a milestone and recurse down the tree :)
        else if($node[self::tei:div][@xml:id | @type]) then (
            concat('{{milestone:', ($node/@xml:id, $node/@type)[1], '}} '),
            local:tei-text-strings($node/node())
        )
        
        (: Return the text :)
        else if($node instance of text()) then
            $node ! normalize-space(.) ! normalize-unicode(.)
        
        (: Recurse down the tree :)
        else if($node[node()]) then
            local:tei-text-strings($node/node())
        
        else ()
            
    )
};

declare function local:tei-text-remainder($remainder as xs:string?) as xs:string* {
    
    (: Filter out milestones that are not followed by content :)
    let $remainder-analyzed := analyze-string($remainder, '(\{{2}[a-zA-Z0-9:-]+\}{2})?([^\{{2}]+)', 'i')
    for $match in $remainder-analyzed/fn:match
    where matches($match/fn:group[@nr eq '2']/text(), '\p{L}+', 'i')
    return 
        string-join($match/fn:group)
        
};
