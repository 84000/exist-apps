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
declare variable $local:target-collection := string-join(($common:static-content-path, $local:file-type, 'translation'), '/');
declare variable $local:start-index := 2001;
declare variable $local:batch-count := 2000;
declare variable $local:exOptions := 
    <option>
        <workingDir>{ $common:environment//eft:backup-conf/@exist-path/string() }/</workingDir>
    </option>;
declare variable $local:sync-path := $common:environment//eft:git-config/eft:push/eft:repo[@id eq 'data-json']/@path/string();

if($store:conf[@source-url] and $local:sync-path) then (
    
    let $teis := $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[not(@status = $translation:published-status-ids)]]
    let $teis-subsequence := subsequence($teis, $local:start-index, $local:batch-count)
    
    for $tei at $tei-index in $teis-subsequence
    let $text-id := tei-content:id($tei)
    let $target-file-name := concat($text-id, '.', $local:file-type)
    let $tei-version := tei-content:version-str($tei)
    let $publication-status := ($tei//tei:publicationStmt/tei:availability/@status[. gt '']/string(), '')[1]
    let $source-url := concat($store:conf/@source-url, '/translation/', $text-id, '.json?api-version=0.4.0&amp;annotate=false')
    let $target-file-name := concat($text-id, '.', $local:file-type)
    return (
        
        $source-url || ' / ' || $tei-version,
        util:log('info', concat('generate-published-json(', $source-url, ', ', ($local:start-index + $tei-index - 1), '/', count($teis) , ')')),
        store:http-download($source-url, $local:target-collection, $target-file-name, $store:permissions-group),
        (:store:store-version-str($target-file-name, $tei-version, $publication-status),:)
        store:store-version-str($target-file-name, $tei-version),
        process:execute(('sleep', '1'), $local:exOptions) ! ()
        
    ),
    
    file:sync($local:target-collection, $local:sync-path, ())
    
)
else ()