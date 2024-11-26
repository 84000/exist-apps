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

(:local:extend-file-versions():)
local:patch-texts()



