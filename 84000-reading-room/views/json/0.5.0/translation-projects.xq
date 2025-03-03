xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace webflow-api = "http://read.84000.co/webflow-api";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
(:import module namespace translation-status = "http://operations.84000.co/translation-status" at "/db/apps/84000-operations/modules/translation-status.xql";:)
import module namespace json-types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT22084-040-002';
declare variable $local:tei := $local:request-text-id[. gt ''] ! tei-content:tei(., 'translation');
declare variable $local:text-id := $local:tei ! tei-content:id(.);
declare variable $local:translation-status := doc(concat($common:data-path, '/local/translation-status.xml'));
declare variable $local:file-versions := doc(concat($common:data-path, '/local/file-versions.xml'));
declare variable $local:webflow-data := doc(concat($common:data-path, '/local/webflow-api.xml'));

element translation-projects {
    
    attribute modelType { 'translation-projects' },
    attribute apiVersion { $json-types:api-version },
    attribute url { concat('/rest/translation-projects.json?', string-join((concat('api-version=', $json-types:api-version), $local:text-id ! concat('text-id=', .)), '&amp;')) },
    attribute timestamp { current-dateTime() },
    
    for $tei in $tei-content:translations-collection//tei:TEI
    let $text-id := tei-content:id($tei)
    let $toh-keys := $tei//tei:sourceDesc/tei:bibl/@key
    where not($local:request-text-id gt '') or $text-id eq $local:text-id 
    
    let $translation-status := $local:translation-status/eft:translation-status/eft:text[@text-id = $text-id]
    let $contract := ($translation-status/eft:contract)[1]
    let $progress-note := $translation-status/eft:progress-note
    let $action-note := $translation-status/eft:action-note
    let $file-versions := (
    
        $local:file-versions//eft:file-version[starts-with(@file-name, $text-id)][not(ends-with(@file-name, '.xml'))],
        
        for $toh-key in $toh-keys
        return 
            $local:file-versions//eft:file-version[starts-with(@file-name, $toh-key)]

    )
    let $webflow-items := $local:webflow-data//webflow-api:item[@id = $toh-keys]
    
    let $project := json-types:project(string-join(($text-id, 'project'), '/'), $text-id, $contract/@number, $contract/@date[. gt ''] ! xs:date(.), $progress-note ! json-types:normalize-text(.), $action-note ! json-types:normalize-text(.))
    
    let $log := (
    
        for $change in $tei//tei:revisionDesc/tei:change
        return
            json-types:log($change/@xml:id, $text-id, $change/@type, $change/@when, $change/@who ! replace(., '^#', ''), $change/@status, $change/tei:desc[not(string-join(text()) eq $change/@status/string())] ! json-types:normalize-text(.))
        ,
        
        json-types:log(string-join(($text-id, 'project', 'project-updated'), '/'), string-join(($text-id, 'project'), '/'), 'project-updated', $translation-status/@updated, (), (), ()),
        
        $progress-note ! json-types:log(string-join(($text-id, 'project', 'progress-note-updated'), '/'), string-join(($text-id, 'project'), '/'), 'progress-note-updated', @last-edited, @last-edited-by, (), ()),
        
        $action-note ! json-types:log(string-join(($text-id, 'project', 'action-note-updated'), '/'), string-join(($text-id, 'project'), '/'), 'action-note-updated', @last-edited, @last-edited-by, (), ()),
    
        for $submission in $translation-status/eft:submission 
        let $submission-id := string-join(($text-id, $submission/@id), '/')
        return (
        
            json-types:submission($submission-id, $text-id, $submission/@id, $submission/@original-file-name),
        
            json-types:log(string-join(($text-id, $submission/@id, 'submission'), '/'), $submission-id, 'draft-submitted', $submission/@date-time, $submission/@user, $submission/@id, ()),
            
            for $item-checked in $submission/eft:item-checked
            return
                json-types:log(string-join(($text-id, $submission/@id, $item-checked/@item-id), '/'), $submission-id, concat('submission-', $item-checked/@item-id), $item-checked/@date-time, $item-checked/@user, '', ())
                
        ),
        
        (: File version updates :)
        for $file-version in $file-versions
        return 
            json-types:log(string-join(($text-id, $file-version/@file-name, 'file-generated'), '/'), $text-id, 'file-generated', $file-version/@timestamp, (), $file-version/@file-name, concat('Status:', $file-version/@status, ', Version:', $file-version/@version))
        ,
        
        (: Webflow api updates :)
        for $webflow-item in $webflow-items
        return 
            json-types:log(string-join(($text-id, $webflow-item/@id, 'webflow-updated'), '/'), $text-id, 'webflow-updated', $webflow-item/@updated, (), $webflow-item/@webflow-id, concat('Status:', $webflow-item/@status, ', Version:', $webflow-item/@version))
        
    )
    
    let $targets := 
        for $target in $translation-status/eft:target-date
        let $log-completed := fn:sort($log[@target_xmlid eq $text-id][@type eq 'translationStatusChange'][@newValue eq $target/@status-id],(), function($log) { $log/@timestamp ! xs:dateTime(.) })[last()]
        return
            json-types:project-target(string-join(($text-id, 'target', $target/@status-id), '/'), $text-id, $target/@status-id, $target/@date-time, $log-completed/@xmlId)
    
    return (
        $project,
        $log,
        $targets
    )
}