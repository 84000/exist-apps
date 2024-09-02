xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare variable $local:file-type := 'json';
declare variable $local:tei := collection($common:translations-path);
declare variable $local:file-collection := string-join(($common:static-content-path, $local:file-type, 'translation'), '/');
declare variable $local:batch-count := 500;
declare variable $local:exOptions := 
    <option>
        <workingDir>{ $common:environment//eft:backup-conf/@exist-path/string() }/</workingDir>
    </option>;

let $file-maps := 
    for $tei in $local:tei//tei:TEI(:[tei:teiHeader/tei:fileDesc[tei:sourceDesc/tei:bibl[@key = ('toh219')]](\:/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids:\)]:)
    let $text-id := tei-content:id($tei)
    (:let $file-version := store:stored-version-str($text-id, $local:file-type):)
    let $file-version := store:stored-version-str($local:file-collection, concat($text-id, '.', $local:file-type))
    let $file-map := map{}
    let $file-map := map:put($file-map, 'text-id', $text-id)
    let $file-map := map:put($file-map, 'file-version', $file-version)
    where $file-version eq '0'
    return (:$text-id || ' - ' || $file-version:)
        $file-map

let $file-maps-batch := subsequence($file-maps, 1, $local:batch-count)

for $file-map at $file-map-index in $file-maps-batch
let $text-id := $file-map('text-id')
let $file-name := concat($text-id, '.', $local:file-type)
let $file-version := $file-map('file-version')
return (
    
    $file-name || ' - ' || $file-version,
    util:log('info', concat('store:publication-file(', $file-name, ') - ', $file-map-index, ' of ', count($file-maps-batch))),
    (:store:create($file-name),:)
    store:publication-file($tei, $local:file-type, 'translation-files'),
    if($file-map-index lt count($file-maps-batch)) then
        process:execute(('sleep', '2'), $local:exOptions)
    else ()
    
)
