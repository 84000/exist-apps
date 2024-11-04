xquery version "3.1" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace webflow="http://read.84000.co/webflow-api";

declare function local:extend-file-versions() {

    let $file-versions := doc('/db/apps/84000-data/local/file-versions.xml')
    let $webflow-conf := doc('/db/apps/84000-data/local/webflow-api.xml')
    let $teis := $tei-content:translations-collection//tei:TEI
    
    for $tei in $teis
    let $text-id := tei-content:id($tei)
    let $publication-status := ($tei//tei:publicationStmt/tei:availability/@status[. gt '']/string(), '')[1]
    let $publication-version := tei-content:version-str($tei)
    
    let $update-file-versions := (
    
        $file-versions//eft:file-version[starts-with(@file-name, $text-id)][not(@status eq $publication-status) or not(@version eq $publication-version)],
        
        for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
        let $source-key := $bibl/@key/string()
        return 
            $file-versions//eft:file-version[starts-with(@file-name, $source-key)][not(@status eq $publication-status) or not(@version eq $publication-version)]

    )
    
    let $update-webflow-items := 
        for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
        let $source-key := $bibl/@key/string()
        return 
            $webflow-conf//webflow:item[@id eq $source-key][not(@status eq $publication-status) or not(@version eq $publication-version)]
    
    return (
    
        for $file-version in $update-file-versions
        return
            update insert attribute status { $publication-status } into $file-version
        ,
        
        for $webflow-item in $update-webflow-items
        return (
            update insert attribute status { $publication-status } into $webflow-item,
            update insert attribute version { $publication-version } into $webflow-item
        )
        
    )
    
};

local:extend-file-versions()