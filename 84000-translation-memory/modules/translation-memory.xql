xquery version "3.0";

module namespace translation-memory="http://read.84000.co/translation-memory";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace functx="http://www.functx.com";

declare variable $translation-memory:data-path := concat($common:data-path, '/translation-memory-generator/');

declare function translation-memory:translation($translation-id as xs:string) as element(tmx:tmx)? {
    collection($translation-memory:data-path)//tmx:tmx[tmx:header[@eft:text-id eq $translation-id]]
    (:doc(concat($translation-memory:data-path, $translation-id, '.xml'))//tmx:tmx:)
};

declare function translation-memory:folio($translation-id as xs:string, $folio as xs:string) as element() {
    
    <translation-memory 
        xmlns="http://read.84000.co/ns/1.0"
        translation-id="{ $translation-id }"
        folio="{ $folio }">
    {
        for $tu in translation-memory:translation($translation-id)//tmx:tu[tmx:prop[@name = "folio"][lower-case(text()) = lower-case($folio)]]
            order by $tu/tmx:prop[@name = 'position'] ! xs:integer(concat('0', text()))
        return
            $tu
    }
    </translation-memory>
};

declare function translation-memory:remember($translation-id as xs:string, $folio-request as xs:string, $source-str as xs:string, $translation-str as xs:string) as element()? {
    
    let $tmx := translation-memory:translation($translation-id)
    let $tmx := 
        if(not($tmx))then
            let $store := 
                xmldb:store($translation-memory:data-path, concat($translation-id, '.xml'), 
                    <tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0">
                        <header 
                            creationtool="84000-translation-memory" 
                            creationtoolversion="1.0.0.0" 
                            datatype="PlainText"
                            segtype="phrase" 
                            adminlang="en" 
                            srclang="bo" 
                            o-tmf="TEI" 
                            creationdate="{ current-dateTime() }"
                            creationid="{ common:user-name() }"
                            eft:text-id="{ $translation-id }"/>
                        <body/>
                    </tmx>
                )
            let $group := sm:chgrp(xs:anyURI(concat($translation-memory:data-path, concat($translation-id, '.xml'))), 'translation-memory')
            let $user := sm:chmod(xs:anyURI(concat($translation-memory:data-path, concat($translation-id, '.xml'))), 'rw-rw-r--')
            return
                translation-memory:translation($translation-id)
        else
            $tmx
    
    let $source-str := normalize-space($source-str)
    let $translation-str := normalize-space($translation-str)
    
    let $tei := tei-content:tei($translation-id, 'translation')
    (: get the first/default toh-key so that it is consistent :)
    let $toh-key := translation:toh-key($tei, '')
    
    let $folios := translation:folios($tei, $toh-key)
    (: Validate the folio :)
    let $folio := $folios//eft:folio[lower-case(@tei-folio) = lower-case($folio-request)][1]
    
    where $folio
    return
        
        let $current := $tmx//tmx:tu
            [tmx:prop[@name = "folio"]/text()[lower-case(.) = lower-case($folio/@tei-folio)]]
            [tmx:tuv[@xml:lang = "bo"]/tmx:seg[compare(normalize-space(text()), $source-str) eq 0]]
            [1]
        
        let $tuid := 
            if($current) then
                $current/@tuid
            else if($tmx//tmx:tu/@tuid[normalize-space()]) then
                xs:string(max($tmx//tmx:tu/@tuid/string() ! xs:integer(concat('0', .))) + 1)
            else
                '1'
        
        (: Locate the text string in the text so there is some order :)
        let $folio-content := translation:folio-content($tei, $toh-key, $folio/@page-in-text)
        let $translation-str-index := functx:index-of-string-first(normalize-space(data($folio-content)), $translation-str)
        let $translation-str-index := 
            if(not($translation-str-index)) then
                0
            else
                $translation-str-index
        
        let $new := 
            if($source-str gt '' and $translation-str gt '') then
                <tu xmlns="http://www.lisa.org/tmx14" tuid="{ $tuid }">
                    <prop name="folio">{ lower-case($folio/@tei-folio) }</prop>
                    <prop name="position">{ $translation-str-index }</prop>
                    <tuv xml:lang="bo"
                        creationdate="{ current-dateTime() }"
                        creationid="{ common:user-name() }">
                        <seg>{ $source-str }</seg>
                    </tuv>
                    <tuv xml:lang="en"
                        creationdate="{ current-dateTime() }"
                        creationid="{ common:user-name() }">
                        <seg>{ $translation-str }</seg>
                    </tuv>
                </tu>
            else
                ()
        
        return 
            common:update('translation-memory', $current, $new, $tmx/tmx:body, ())
};