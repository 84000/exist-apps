xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace webflow-api = "http://read.84000.co/webflow-api";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT22084-040-002';
declare variable $local:request-tei := $local:request-text-id[. gt ''] ! tei-content:tei(., 'translation');
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:translation-status := doc(concat($common:data-path, '/local/translation-status.xml'));
declare variable $local:file-versions := doc(concat($common:data-path, '/local/file-versions.xml'));
declare variable $local:webflow-data := doc(concat($common:data-path, '/local/webflow-api.xml'));
declare variable $local:teis := $tei-content:translations-collection//tei:TEI;
declare variable $local:count-teis := count($local:teis);

declare function local:translation-project($tei as element(tei:TEI)) {

    let $text-id := tei-content:id($tei)
    let $toh-keys := $tei//tei:sourceDesc/tei:bibl/@key
    where not($local:request-text-id gt '') or count($tei | $local:request-tei) eq 1 
    
    (:let $log := util:log('INFO', 'store-translation-project:'|| $text-id || '('|| functx:index-of-node($local:teis, $tei) ||'/'|| $local:count-teis ||')'):)
    let $translation-status := ($local:translation-status/eft:translation-status/eft:text[@text-id = $text-id])[1]
    let $contract := ($translation-status/eft:contract)[1]
    let $progress-note := $translation-status/eft:progress-note
    let $action-note := $translation-status/eft:action-note
    let $submissions := $translation-status/eft:submission
    let $target-dates := $translation-status/eft:target-date
    let $file-versions := (
    
        $local:file-versions//eft:file-version[starts-with(@file-name, $text-id)][not(ends-with(@file-name, '.xml'))],
        
        for $toh-key in $toh-keys
        return 
            $local:file-versions//eft:file-version[starts-with(@file-name, $toh-key)]

    )
    let $webflow-items := $local:webflow-data//webflow-api:item[@id = $toh-keys]
    
    let $project := 
        if($contract or $progress-note or $action-note or $submissions or $target-dates) then
            types:project(string-join(($text-id, 'project'), '/'), $text-id, $contract/@number, $contract/@date[. gt ''] ! xs:date(.), $progress-note ! helpers:normalize-text(.), $action-note ! helpers:normalize-text(.))
        else ()
    
    let $log := (
    
        for $change in $tei//tei:revisionDesc/tei:change
        return
            types:log($change/@xml:id, $text-id, $change/@type, $change/@when, $change/@who ! replace(., '^#', ''), ($change/@status, $change/@source)[1], $change/tei:desc[not(string-join(text()) eq $change/@status/string())] ! helpers:normalize-text(.))
        ,
        
        if($project) then (
            
            types:log(string-join(($text-id, 'project', 'project-updated'), '/'), $project/@xmlId, 'project-updated', $translation-status/@updated, (), (), ()),
            
            $progress-note ! types:log(string-join(($text-id, 'project', 'progress-note-updated'), '/'), $project/@xmlId, 'progress-note-updated', @last-edited, @last-edited-by, (), ()),
            
            $action-note ! types:log(string-join(($text-id, 'project', 'action-note-updated'), '/'), $project/@xmlId, 'action-note-updated', @last-edited, @last-edited-by, (), ()),
            
            for $submission in $submissions
            let $submission-id := string-join(($text-id, $submission/@id), '/')
            return (
                
                types:submission($submission-id, $project/@xmlId, $text-id, $submission/@id, $submission/@original-file-name),
                
                types:log(string-join(($text-id, $submission/@id, 'submission'), '/'), $submission-id, 'draft-submitted', $submission/@date-time, $submission/@user, $submission/@id, ()),
                
                for $item-checked in $submission/eft:item-checked
                return
                    types:log(string-join(($text-id, $submission/@id, $item-checked/@item-id), '/'), $submission-id, concat('submission-', $item-checked/@item-id), $item-checked/@date-time, $item-checked/@user, '', ())
                
            )
        )
        else ()
        ,
        
        (: File version updates :)
        for $file-version in $file-versions
        return 
            types:log(string-join(($text-id, $file-version/@file-name, 'file-generated'), '/'), $text-id, 'file-generated', $file-version/@timestamp, (), $file-version/@file-name, string-join(($file-version/@status ! concat('Status:', .), $file-version/@version ! concat('Version:', .)), ', '))
        ,
        
        (: Webflow api updates :)
        for $webflow-item in $webflow-items
        return 
            types:log(string-join(($text-id, $webflow-item/@id, 'webflow-updated'), '/'), $text-id, 'webflow-updated', $webflow-item/@updated, (), $webflow-item/@webflow-id, string-join(($webflow-item/@status ! concat('Status:', .), $webflow-item/@version ! concat('Version:', .)), ', '))
        
    )
    
    let $targets := 
        if($project) then
            for $target in $target-dates
            let $log-completed := fn:sort($log[@target_xmlid eq $text-id][@type eq 'translationStatusChange'][@newValue eq $target/@status-id],(), function($log) { $log/@timestamp ! xs:dateTime(.) })[last()]
            return
                types:project-target(string-join(($text-id, 'target', $target/@status-id), '/'), $project/@xmlId, $target/@status-id, $target/@date-time, $log-completed/@xmlId)

        else ()
    
    return (
        $project,
        $log,
        $targets
    )
    
};

let $response := 
    element translation-projects {
        
        attribute modelType { 'translation-projects' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/translation-projects.json?', string-join((concat('api-version=', $types:api-version), $local:request-tei ! concat('text-id=', $local:request-text-id)), '&amp;')) },
        attribute timestamp { current-dateTime() },
    
        for $tei in $local:teis
        return
            local:translation-project($tei)
        
    }

return
    helpers:store($local:request-store, $response, concat($response/@modelType, '.json'), ())


        