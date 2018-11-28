xquery version "3.1";

module namespace translation-status="http://read.84000.co/translation-status";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $translation-status:data := doc(concat($common:data-path, '/operations/translation-status.xml'));

declare function translation-status:text($text-id as xs:string) as item()?{
    $translation-status:data/m:translation-status/m:text[@text-id eq $text-id]
};

declare function translation-status:texts($text-id as xs:string*) as item()*{
    $translation-status:data/m:translation-status/m:text[@text-id = $text-id]
};

declare function translation-status:notes($text-id as xs:string) as element()?{
    let $text := translation-status:text($text-id)
    return
        $text/m:notes[1]
};

declare function translation-status:tasks($text-id as xs:string) as element()*{
    let $text := translation-status:text($text-id)
    return
        $text/m:task
};

declare function translation-status:next-task-id($text-id as xs:string) as xs:string {
    let $text-tasks := translation-status:tasks($text-id)
    let $next-id := count($text-tasks) + 1
    return
        concat($text-id, '-task-', $next-id)
};

declare function translation-status:is-current-version($tei-version-str as xs:string?, $cached-version-str as xs:string?) as xs:boolean {
    ($cached-version-str and compare($tei-version-str, $cached-version-str) eq 0)
};

declare function translation-status:word-count($tei as element()) as xs:integer {
    
    let $text-id := tei-content:id($tei)
    let $tei-version-str := translation:version-str($tei)
    let $translation-status := translation-status:text($text-id)
    
    let $cached-version-str := $translation-status/@version
    let $cached-count := $translation-status/@word-count
    
    return
        if(translation-status:is-current-version($tei-version-str, $cached-version-str) and functx:is-a-number($cached-count)) then
            xs:integer($cached-count)
        else
            let $create-new-translation-status := translation-status:update($text-id)
            let $translation-status := translation-status:text($text-id)
            return
                $translation-status/@word-count
            
        
};

declare function translation-status:glossary-count($tei as element()) as xs:integer {
    
    let $text-id := tei-content:id($tei)
    let $tei-version-str := translation:version-str($tei)
    let $translation-status := translation-status:text($text-id)
    
    let $cached-version-str := $translation-status/@version
    let $cached-count := $translation-status/@glossary-count
    
    return
        if(translation-status:is-current-version($tei-version-str, $cached-version-str) and functx:is-a-number($cached-count)) then
            xs:integer($cached-count)
        else
            let $create-new-translation-status := translation-status:update($text-id)
            let $translation-status := translation-status:text($text-id)
            return
                $translation-status/@glossary-count
    
};

declare function translation-status:update($text-id as xs:string) as element()? {
    
    let $existing-value := translation-status:text($text-id)
    
    let $existing-notes := $existing-value/m:notes
    let $new-notes-text := request:get-parameter('status-notes', '')
    
    let $tei := tei-content:tei($text-id, 'translation')
    let $tei-version-str := translation:version-str($tei)
    
    let $cached-version-str := $existing-value/@version
    let $cached-word-count := $existing-value/@word-count
    let $cached-glossary-count := $existing-value/@glossary-count
    
    let $word-count := 
        if(translation-status:is-current-version($tei-version-str, $cached-version-str) and functx:is-a-number($cached-word-count)) then
            xs:integer($cached-word-count)
        else
            translation:word-count($tei)
    
    let $glossary-count := 
        if(translation-status:is-current-version($tei-version-str, $cached-version-str) and functx:is-a-number($cached-glossary-count)) then
            xs:integer($cached-glossary-count)
        else
            translation:glossary-count($tei)
    
    let $new-value := 
        element { QName('http://read.84000.co/ns/1.0', 'text') }{
            attribute text-id { $text-id },
            attribute version { $tei-version-str },
            attribute word-count { $word-count },
            attribute glossary-count { $glossary-count },
            if($new-notes-text and not(compare($existing-notes/text(), $new-notes-text) eq 0)) then
                element notes {
                    attribute last-edited { current-dateTime() },
                    attribute last-edited-by { common:user-name() },
                    text { $new-notes-text }
                }
            else
                $existing-notes
            ,
            for $task in $existing-value/m:task
            return
                if($task/@xml:id = request:get-parameter('task-check-off[]', '')) then
                    functx:add-or-update-attributes(
                        $task, 
                        (xs:QName('checked-off'), xs:QName('checked-off-by')), 
                        (current-dateTime(), common:user-name())
                    )
                else if($task/@xml:id = request:get-parameter('task-hide[]', '')) then
                    functx:add-or-update-attributes(
                        $task, 
                        (xs:QName('hidden'), xs:QName('hidden-by')), 
                        (current-dateTime(), common:user-name())
                    )
                else
                    $task
            ,
            if(request:get-parameter('new-task', '')) then
                element task {
                    attribute xml:id { translation-status:next-task-id($text-id) },
                    attribute added { current-dateTime() },
                    attribute added-by { common:user-name() },
                    text { request:get-parameter('new-task', '') }
                }
            else
                ()
        }
    
    let $parent := $translation-status:data/m:translation-status
    
    let $insert-following := $translation-status:data/m:translation-status/m:text[last()]
    
return
    if($existing-value or $new-value) then
        common:update('translation-status', $existing-value, $new-value, $parent, $insert-following)
        (:element update-debug {
            element request-parameter { 'translation-status' }, 
            element existing-value { $existing-value }, 
            element new-value { $new-value }, 
            element parent { $parent }, 
            element insert-following { $insert-following }
        }:)
    else
        ()
    
};

