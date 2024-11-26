xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare variable $local:tei := collection($common:translations-path);
declare variable $local:exOptions := 
    <option>
        <workingDir>{ $common:environment//eft:backup-conf/@exist-path/string() }/</workingDir>
    </option>;

if($store:conf[@source-url]) then (
    
    let $published-tei := $local:tei//tei:TEI[descendant::tei:publicationStmt/tei:availability[@status = $translation:published-status-ids]]
    
    for $tei at $tei-index in $published-tei
    let $text-id := tei-content:id($tei)
    let $document-url := base-uri($tei)
    let $file-name := util:unescape-uri(replace($document-url, ".+/(.+)$", "$1"), 'UTF-8')
    let $document-path := substring-before($document-url, concat('/', $file-name))
    (:let $single-page := translation:single-page($tei)
    where not($single-page) (\:and $text-id eq 'UT22084-001-001':\):)
    return (
        $tei//tei:sourceDesc/tei:bibl/tei:ref,
        (:$document-path, $file-name,:)
        xmldb:touch($document-path, $file-name),
        store:publication-files($tei, ('translation-html'), ()),
        process:execute(('sleep', '1'), $local:exOptions) ! ()
    )
    
)
else ()