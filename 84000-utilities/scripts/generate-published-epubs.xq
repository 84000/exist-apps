xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store = "http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy = "http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare variable $local:file-type := 'epub';
declare variable $local:tei := collection($common:translations-path);
declare variable $local:file-collection := string-join(($common:static-content-path, $local:file-type, 'translation'), '/');

(: Select missing files :)
let $missing-file-maps :=
    for $tei in $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation:published-status-ids]
    let $text-id := tei-content:id($tei)
    let $tei-version-str := tei-content:version-str($tei)
    order by $text-id
    return
        for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        let $file-name := concat($toh-key, '.', $local:file-type)
        (:let $file-version := store:stored-version-str($toh-key, $local:file-type):)
        let $file-version := store:stored-version-str($local:file-collection, concat($toh-key, '.', $local:file-type))
        let $file-path := string-join(($common:data-path, $local:file-type, $file-name), '/')
        let $file-map := map{}
        let $file-map := map:put($file-map, 'file-path', $file-path)
        let $file-map := map:put($file-map, 'file-version', $file-version)
        let $file-map := map:put($file-map, 'tei-version', $tei-version-str)
        (: Check if there's an existing file-version :)
        where not($file-version gt '0')
        return 
            $file-map

(: Generate and store files :)
for $file-map at $index in $missing-file-maps
where $index le 10
return (
    (:$file-map('file-path') || ' - ' || $file-map('file-version') || ' - ' || $file-map('tei-version'),:)
    store:store-new-epub($file-map('file-path'), $file-map('tei-version'))
)
