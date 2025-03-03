xquery version "3.1" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace store="http://read.84000.co/store" at "../modules/store.xql";
import module namespace webflow="http://read.84000.co/webflow-api" at "/db/apps/84000-operations/modules/webflow-api.xql";
import module namespace functx="http://www.functx.com";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $local:exec-options := 
    <option>
        <workingDir>/{ $common:environment//eft:env-vars/eft:var[@id eq 'home']/text() }/</workingDir>
    </option>;

declare function local:extend-file-versions() {

    let $file-versions := doc('/db/apps/84000-data/local/file-versions.xml')
    let $webflow-conf := doc('/db/apps/84000-data/local/webflow-api.xml')
    let $teis := $tei-content:translations-collection//tei:TEI
    
    for $tei in $teis
    let $text-id := tei-content:id($tei)
    let $publication-status := ($tei//tei:publicationStmt/tei:availability/@status[. gt '']/string(), '')[1]
    let $publication-version := tei-content:version-str($tei)
    
    let $update-file-versions := (
    
        $file-versions//eft:file-version[starts-with(@file-name, $text-id)][not(@status)],
        
        for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
        let $source-key := $bibl/@key/string()
        return 
            $file-versions//eft:file-version[starts-with(@file-name, $source-key)][not(@status)]

    )
    
    let $update-webflow-items := 
        for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
        let $source-key := $bibl/@key/string()
        return 
            $webflow-conf//webflow:item[@id eq $source-key][not(@status) or not(@version)]
    
    return (
    
        for $file-version in $update-file-versions
        return
            update insert attribute status { $publication-status } into $file-version
        ,
        
        for $webflow-item in $update-webflow-items
        return (
            if($webflow-item[not(@status)]) then
                update insert attribute status { $publication-status } into $webflow-item
            else (),
            if($webflow-item[not(@version)]) then
                update insert attribute version { $publication-version } into $webflow-item
            else ()
        )
        
    )
    
};

declare function local:patch-texts() {
    
    let $translations-tei := $tei-content:translations-collection//tei:TEI
    
    for $bibl in $translations-tei//tei:sourceDesc/tei:bibl[@key]
    return (
    
        $bibl/tei:ref,
        
        util:log('INFO', concat('webflow-patch-text: ', $bibl/@key)),
        webflow:patch-text($bibl/@key),
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
        
    )
    
};

declare function local:fix-import-notes() {
    
    (:$tei-content:translations-collection//tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt[tei:note[@type = 'title'][@update]]:)
    
    for $tei in subsequence($tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:revisionDesc/tei:change[@source][not(@type eq 'import')][tei:desc//text()]], 1, 50)
    let $text-id := tei-content:id($tei)
    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    let $revisionDesc :=  $fileDesc/tei:revisionDesc
    let $notesStmt :=  $fileDesc/tei:notesStmt
    let $existing-notes-count := count($notesStmt/tei:note)
    let $changes-move := $revisionDesc/tei:change[@source][not(@type eq 'import')][tei:desc//text()]
    
    where $changes-move
    
    let $notesStmt-new := 
        element { QName('http://www.tei-c.org/ns/1.0', 'notesStmt') } { 
            $notesStmt/@*,
            for $note in $notesStmt/*
            return (
                common:ws(4),
                $note
            ),
            for $change in $changes-move
            let $change-text := string-join($change/tei:desc/text()) ! normalize-space(.)
            where $change-text
            return (
                common:ws(4),
                element { QName('http://www.tei-c.org/ns/1.0', 'note') }{
                    attribute type { $change/@type/string() },
                    attribute date-time { $change/@when/string() },
                    attribute user { $change/@who/string() ! replace(., '^#', '') },
                    attribute import { $change/@source/string() },
                    text { $change-text }
                }
            ),
            common:ws(3)
        }
    
    let $revisionDesc-new := 
        element { QName('http://www.tei-c.org/ns/1.0', 'revisionDesc') } { 
            $revisionDesc/@*,
            for $change in $revisionDesc/* except $changes-move
            return (
                common:ws(4),
                $change
            ),
            common:ws(3)
        }
    
    return (
        (# exist:batch-transaction #) {
            $text-id,
            (:$notesStmt,
            $revisionDesc,
            $notesStmt-new,
            $revisionDesc-new:)
            update replace $notesStmt with $notesStmt-new,
            update replace $revisionDesc with $revisionDesc-new,
            process:execute(('sleep', '0.5'), $local:exec-options) ! ()
        }
    )
    
};

(:local:extend-file-versions():)
(:local:patch-texts():)
local:fix-import-notes()


