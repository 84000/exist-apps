xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare variable $local:file-type := 'json';
declare variable $local:tei := collection($common:translations-path);
declare variable $local:file-collection := collection(string-join(($common:data-path, $local:file-type), '/'));
declare variable $local:file-versions := doc(string-join(($common:data-path, 'local', 'file-versions.xml'), '/'));

(: Generate and store files :)
for $tei in $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids]
let $text-id := tei-content:id($tei)
let $tei-version-str := tei-content:version-str($tei)
(:where $text-id eq 'UT23703-113-010':)
return
    for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
    let $file-name := concat($toh-key, '.', $local:file-type)
    let $file-version := $local:file-versions//eft:file-version[@file-name eq $file-name]
    let $file-path := string-join(($common:data-path, $local:file-type, $file-name), '/')
    (: Check if there's an existing file-version :)
    where not($file-version)
    return (
    
        $file-name,
        
        if($local:file-type eq 'json') then
            store:store-new-json($file-path, $tei-version-str)
        else ()
        
    )
,

(: Push to github:)
if($local:file-type eq 'json') then
    deploy:push('data-json', (), 'Generate missing json', ())
else ()