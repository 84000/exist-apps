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

declare variable $update-tm:tm-path := concat($common:data-path, '/translation-memory');

declare function update-tm:update-segment($tmx as element(tmx:tmx), $unit-id as xs:string, $lang as xs:string, $value as xs:string?) as element()? {
    
    let $tm-unit := $tmx/tmx:body/tmx:tu[@id eq $unit-id]
    let $existing-value := $tm-unit/tmx:tuv[@xml:lang eq $lang]
    let $new-value := 
        element { QName('http://www.lisa.org/tmx14', 'tuv') }{
            attribute xml:lang { $lang },
            element seg {
                tokenize($value, '\n')[1]
            }
        }
    
    return
        common:update('update-tm-segment', $existing-value, $new-value, $tm-unit, ())
    
};

declare function update-tm:new-tm($text-id as xs:string, $text-version as xs:string, $first-line-bo as xs:string) as document-node()? {
document {
<tmx xmlns="http://www.lisa.org/tmx14" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.4b">
    <header creationtool="84000-tm-editor" creationtoolversion="{ $common:app-version }" datatype="PlainText" segtype="block" adminlang="en-us" srclang="bo" eft:text-id="{ $text-id }" eft:text-version="{ $text-version }"/>
    <body>
        <tu id="{ $text-id }-TU-1">
            <tuv xml:lang="bo">
                <seg>{ $first-line-bo }</seg>
            </tuv>
            <tuv xml:lang="en">
                <seg/>
            </tuv>
        </tu>
    </body>
</tmx>
}};

declare function update-tm:add-tm($tei as element(tei:TEI)) as xs:string? {
    
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