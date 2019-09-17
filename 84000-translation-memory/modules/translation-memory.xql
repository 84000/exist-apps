xquery version "3.0";

module namespace translation-memory="http://read.84000.co/translation-memory";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace functx="http://www.functx.com";

declare function translation-memory:folio($translation-id as xs:string, $folio as xs:string) as node() {
    
    let $doc := doc(concat($common:data-path, '/translation-memory/', $translation-id, '.xml'))
    
    return
        <translation-memory 
            xmlns="http://read.84000.co/ns/1.0"
            translation-id="{ $translation-id }"
            folio="{ $folio }">
        {
            for $tu in $doc//tmx:tu[tmx:prop[@name = "folio"][lower-case(.) = lower-case($folio)]]
                order by $tu/tmx:prop[@name = 'position'] ! xs:integer(concat('0', .))
            return
                $tu
        }
        </translation-memory>
};

declare function translation-memory:remember($translation-id as xs:string, $folio-request as xs:string, $source-str as xs:string, $translation-str as xs:string) as node()? {
    
    let $filepath := concat($common:data-path, '/translation-memory/')
    let $filename := concat($translation-id, '.xml')
    let $doc := doc(concat($filepath, $filename))
    let $source-str := normalize-space($source-str)
    let $translation-str := normalize-space($translation-str)
    let $tei := tei-content:tei($translation-id, 'translation')
    let $toh-key := translation:toh-key($tei, '') (: get the first/default toh-key so that it is consistent :)
    
    let $folios := translation:folios($tei, $toh-key)
    let $folio := $folios/m:folio[lower-case(@tei-folio) = lower-case($folio-request)][1]
    
    where $folio
    return
        let $folio-content := translation:folio-content($tei, $toh-key, $folio/@page-in-text)
        let $translation-memory := translation-memory:folio($translation-id, lower-case($folio/@tei-folio))
        
        let $str-id := $translation-memory/tmx:tu[tmx:tuv[@xml:lang = "bo"][compare(normalize-space(tmx:seg/text()), $source-str) eq 0]][1]/@tuid
        
        let $tuid := 
            if($doc//tmx:tu[@tuid eq $str-id]) then
                $str-id
            else if($doc) then
                xs:string(max($doc//tmx:tu/@tuid ! xs:integer(concat('0', .))) + 1)
            else
                '1'
        
        let $translation-str-index := functx:index-of-string-first(normalize-space(data($folio-content)), $translation-str)
        
        let $tu := 
            <tu xmlns="http://www.lisa.org/tmx14" tuid="{ $tuid }">
                <prop name="folio">{ lower-case($folio/@tei-folio) }</prop>
                <prop name="position">{ $translation-str-index }</prop>
                <tuv 
                    xml:lang="bo"
                    creationdate="{ current-dateTime() }"
                    creationid="{ common:user-name() }">
                    <seg>{ $source-str }</seg>
                </tuv>
                <tuv 
                    xml:lang="en"
                    creationdate="{ current-dateTime() }"
                    creationid="{ common:user-name() }">
                    <seg>{ $translation-str }</seg>
                </tuv>
            </tu>
        
        return
            if($tuid eq $str-id and $source-str ne '' and $translation-str ne '') then
                (: update :)
                <updated xmlns="http://read.84000.co/ns/1.0">
                {
                    update replace $doc//tmx:tu[@tuid eq $tuid] with $tu
                }
                </updated>
            else if($tuid eq $str-id) then
                (: remove :)
                <updated xmlns="http://read.84000.co/ns/1.0">
                {
                    update delete $doc//tmx:tu[@tuid eq $tuid]
                }
                </updated>
            else if($doc) then
                (: Add :)
                <added xmlns="http://read.84000.co/ns/1.0">
                {
                    update insert $tu
                    into $doc//tmx:body
                }
                </added>
            else
                (: Create :)
                <created xmlns="http://read.84000.co/ns/1.0">
                {
                    xmldb:store($filepath, $filename, 
                        <tmx xmlns="http://www.lisa.org/tmx14">
                            <header 
                                creationtool="84000-translation-memory" 
                                creationtoolversion="1.0.0.0" 
                                datatype="PlainText"
                                segtype="phrase" 
                                adminlang="en" 
                                srclang="bo" 
                                o-tmf="TEI" 
                                creationdate="{ current-dateTime() }"
                                creationid="{ common:user-name() }"/>
                            <body>
                            {
                                $tu
                            }
                            </body>
                        </tmx>
                    ),
                    sm:chgrp(xs:anyURI(concat($filepath, $filename)), 'translation-memory'),
                    sm:chmod(xs:anyURI(concat($filepath, $filename)), 'rw-rw-r--')
                }
                </created>
};