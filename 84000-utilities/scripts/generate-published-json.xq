xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare variable $local:file-type := 'json';
declare variable $local:tei := collection($common:translations-path);
declare variable $local:file-collection := collection(string-join(($common:data-path, $local:file-type), '/'));
declare variable $local:file-versions := doc(string-join(($common:data-path, $local:file-type, 'file-versions.xml'), '/'));
declare variable $local:batch-count := 5;
declare variable $local:exOptions := 
    <option>
        <workingDir>{ $common:environment//eft:backup-conf/@exist-path/string() }/</workingDir>
    </option>;
    
let $file-maps := 
    for $tei in $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids]
    let $text-id := tei-content:id($tei)
    let $file-version := store:stored-version-str($text-id, $local:file-type)
    let $file-map := map{}
    let $file-map := map:put($file-map, 'text-id', $text-id)
    let $file-map := map:put($file-map, 'file-version', $file-version)
    where $file-version eq '0' 
    return 
        $file-map

for $file-map at $tei-index in subsequence($file-maps, 1, $local:batch-count)
let $text-id := $file-map('text-id')
let $file-name := concat($text-id, '.', $local:file-type)
let $file-version := $file-map('file-version')
return (
    
    $file-name || ' - ' || $file-version,
    util:log('info', concat('store:create(', $file-name, ') - ', $tei-index, ' of ', $local:batch-count)),
    store:create($file-name),
    process:execute(('sleep', '10'), $local:exOptions)
    
)
