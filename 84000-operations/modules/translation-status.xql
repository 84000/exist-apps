xquery version "3.1";
(:
    Functions relating to operations/translation-status.xml
    
    This functions as a cache for meta about the translations 
    e.g. the word count and glossary count of a particular version of the translation.
    If a file is queried and the version is out of date or not existing then the 
    cache will be updated for that record and the result served.
    The file also contains notes about the translation project.
    
    operations/translation-status.xml is not deployed between servers. 
    DO NOT use it to store transferrable information, only information specific to this server.
:)

module namespace translation-status="http://read.84000.co/translation-status";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $translation-status:data := doc(concat($common:data-path, '/local/translation-status.xml'));

declare function translation-status:text($text-id as xs:string) as element()? {
    if($text-id gt '') then
        
        $translation-status:data/m:translation-status/m:text[@text-id eq $text-id][1]
        
        (:let $text := $translation-status:data/m:translation-status/m:text[@text-id eq $text-id][1]
        return 
            if(not($text)) then
                translation-status:update($text-id)
            else
                let $tei := tei-content:tei($text-id, 'translation')
                let $tei-version-str := translation:version-str($tei)
                let $translation-status := translation-status:text($text-id)
                let $cached-version-str := if($translation-status) then $translation-status/@version else ''
                let $is-current-version := translation-status:is-current-version($tei-version-str, $cached-version-str)
                return
                    if(not($is-current-version)) then
                        translation-status:update($text-id)
                    else
                        $text:)
    else
        ()
};

declare function translation-status:texts($text-ids as xs:string*) as element()* {

    for $text-id in distinct-values($text-ids)
    return
        $translation-status:data/m:translation-status/m:text[@text-id = $text-id]
        (:translation-status:text($text-id):)
        
};

declare function translation-status:notes($text-id as xs:string) as element()* {
    let $text := translation-status:text($text-id)
    return
        if($text) then
        (
            $text/m:action-note[1],
            $text/m:progress-note[1],
            $text/m:text-note[1]
        )
        else
            ()
};

declare function translation-status:file-name-normalized($string as xs:string) as xs:string {
    (: Normalize the file name for comparison :)
    replace(
        replace(
            translate(
                lower-case(
                    util:unescape-uri($string,"UTF-8")  (: unescape :)
                )                                       (: convert to lower case :)
            , '()', '[]')                               (: convert round brackets to square :)
        ,'[^a-z0-9\.\-_\[\]]', '-')                     (: remove all but alphanumeric .-_[] :)
    ,'\-+', '-')                                        (: replace multiple hyphens with single :)
};

declare function translation-status:file-type($file-name as xs:string) as xs:string {

    let $file-name-normalized := translation-status:file-name-normalized($file-name)
    let $file-name-tokenized := tokenize($file-name-normalized, '\.')
    
    return
        switch($file-name-tokenized[last()])
            case ('xlsx') return 'spreadsheet'
            case ('docx') return 'document'
            default return ''
};

declare function translation-status:tei-file-name($file-name as xs:string) as xs:string {
    replace($file-name,'(\.xlsx|\.docx)$', '$1.tei.xml')
};

declare function translation-status:submissions($text-id as xs:string) as element()* {
    
    let $text := translation-status:text($text-id)
    let $files-collection := concat($common:import-data-path, '/', $text-id)
    let $file-names := 
        if(xmldb:collection-available($files-collection)) then
            xmldb:get-child-resources($files-collection)
        else
            ()
    
    for $file-name at $pos in $file-names
        let $file-name-normalized := translation-status:file-name-normalized($file-name)
        let $file-type := translation-status:file-type($file-name)
        let $tei-file-name := translation-status:tei-file-name($file-name)
        let $submission := $text/m:submission[@id eq $file-name-normalized][1]
        let $date-time := 
            if($submission/@date-time) then 
                xs:dateTime($submission/@date-time) 
            else 
                xs:dateTime('2000-01-01T00:00:00Z')
        where $file-type = ('spreadsheet', 'document')
        order by $date-time descending, xs:string($file-name-normalized) descending
    return
        element { QName('http://read.84000.co/ns/1.0', 'submission') } {
            attribute id { 
                $file-name-normalized
            },
            attribute user { 
                string($submission/@user)
            },
            attribute date-time { 
                $date-time
            },    
            attribute file-name { 
                util:unescape-uri($file-name, "UTF-8")
            },
            attribute original-file-name { 
                util:unescape-uri(string($submission/@original-file-name), "UTF-8")
            },
            attribute file-type { 
                $file-type
            },
            attribute text-id { 
                $text-id
            },
            attribute file-collection { 
                $files-collection
            },
            element tei-file {
                attribute file-name { 
                    util:unescape-uri($tei-file-name, "UTF-8")
                },
                attribute file-exists { 
                    $tei-file-name = $file-names
                }
            },
            $submission/m:item-checked
        }
};

declare function translation-status:submission($text-id as xs:string, $submission-id as xs:string) as element()* {
    translation-status:submissions($text-id)[@id eq $submission-id]
};

declare function translation-status:status-updates($tei as element()) as element()* {
    (: Returns notes of status updates :)
    for $status-update in $tei//tei:teiHeader//tei:notesStmt/tei:note[@update = ('text-version', 'translation-status')]
    return
        element { QName('http://read.84000.co/ns/1.0', 'status-update') }{ 
            $status-update/@update,
            $status-update/@value,
            $status-update/@date-time,
            $status-update/@user,
            $status-update/text()
        }
};

declare function translation-status:tasks($text-id as xs:string) as element()* {
    translation-status:text($text-id)/m:task
};

declare function translation-status:next-task-id($text-id as xs:string, $position as xs:integer) as xs:string {
    let $text-tasks := translation-status:tasks($text-id)
    let $next-id := count($text-tasks) + $position
    return
        concat($text-id, '-task-', $next-id)
};

declare function translation-status:is-current-version($tei-version-str as xs:string?, $cached-version-str as xs:string?) as xs:boolean {
    (compare($tei-version-str, $cached-version-str) eq 0)
};

declare function translation-status:word-count($tei as element(tei:TEI)) as xs:integer {
    local:translation-status-value($tei, 'word-count')
};

declare function translation-status:glossary-count($tei as element(tei:TEI)) as xs:integer {
    local:translation-status-value($tei, 'glossary-count')
};

declare function local:translation-status-value($tei as element(tei:TEI), $name as xs:string) {

    let $text-id := tei-content:id($tei)
    let $tei-version-str := translation:version-str($tei)
    let $translation-status := translation-status:text($text-id)
    let $cached-version-str := if($translation-status) then $translation-status/@version else ''
    let $is-current-version := translation-status:is-current-version($tei-version-str, $cached-version-str)
    
    let $cached-count := 
        if($translation-status) then 
            if($name eq 'word-count') then
                $translation-status/@word-count 
            else if($name eq 'glossary-count') then
                $translation-status/@glossary-count 
            else
                0
        else ''
    
    return
        if($is-current-version and functx:is-a-number($cached-count)) then
            xs:integer($cached-count)
        else
            let $create-new-translation-status := translation-status:update($text-id)
            return
                if($name eq 'word-count') then
                    $create-new-translation-status//m:text/@word-count 
                else if($name eq 'glossary-count') then
                    $create-new-translation-status//m:text/@glossary-count 
                else
                    0
};

declare function translation-status:update($text-id as xs:string) as element()? {

    let $existing-value := translation-status:text($text-id)
    let $request-parameters := request:get-parameter-names()
    
    let $tei := tei-content:tei($text-id, 'translation')
    let $tei-version-str := translation:version-str($tei)
    
    let $cached-version-str := if($existing-value) then $existing-value/@version else ''
    let $cached-word-count := if($existing-value) then $existing-value/@word-count else ''
    let $cached-glossary-count := if($existing-value) then $existing-value/@glossary-count else ''
    
    let $word-count := 
        if(translation-status:is-current-version($tei-version-str, $cached-version-str) and functx:is-a-number($cached-word-count)) then
           xs:integer($cached-word-count)
        else if(tei-content:translation-status-group($tei) eq 'published') then
            translation:word-count($tei)
        else
           0
   
    let $glossary-count := 
        if(translation-status:is-current-version($tei-version-str, $cached-version-str) and functx:is-a-number($cached-glossary-count)) then
           xs:integer($cached-glossary-count)
        else if(tei-content:translation-status-group($tei) eq 'published') then
            translation:glossary-count($tei)
        else
           0
   
   let $new-value := 
       element { QName('http://read.84000.co/ns/1.0', 'text') }{
           attribute text-id { $text-id },
           attribute updated { current-dateTime() },
           attribute version { $tei-version-str },
           attribute word-count { $word-count },
           attribute glossary-count { $glossary-count },
           if('action-note' = $request-parameters and not(compare(string($existing-value/m:action-note), request:get-parameter('action-note', '')) eq 0))then
               element action-note {
                   attribute last-edited { current-dateTime() },
                   attribute last-edited-by { common:user-name() },
                   text { request:get-parameter('action-note', '') }
               }
           else
               $existing-value/m:action-note
           ,
           if('progress-note' = $request-parameters and not(compare(string($existing-value/m:progress-note), request:get-parameter('progress-note', '')) eq 0))then
               element progress-note {
                   attribute last-edited { current-dateTime() },
                   attribute last-edited-by { common:user-name() },
                   text { request:get-parameter('progress-note', '') }
               }
           else
               $existing-value/m:progress-note
           ,
           if('text-note' = $request-parameters and not(compare(string($existing-value/m:text-note), request:get-parameter('text-note', '')) eq 0))then
               element text-note {
                   attribute last-edited { current-dateTime() },
                   attribute last-edited-by { common:user-name() },
                   text { request:get-parameter('text-note', '') }
               }
           else
               $existing-value/m:text-note
           ,
           for $task in $existing-value/m:task
           return
               if($task/@xml:id = request:get-parameter('task-check-off[]', '')) then
                   functx:add-or-update-attributes(
                       $task, 
                       (xs:QName('checked-off'), xs:QName('checked-off-by')), 
                       (current-dateTime(), common:user-name())
                   )
               else
                   $task
           ,
           for $task-id at $pos in request:get-parameter('task-add[]', '')
               let $task-text := request:get-parameter(concat('task-add-', $task-id), '')
               where $task-text
           return
               element task {
                   attribute xml:id { translation-status:next-task-id($text-id, $pos) },
                   attribute added { current-dateTime() },
                   attribute added-by { common:user-name() },
                   if(not($task-id eq 'custom')) then
                       attribute task-id { $task-id }
                   else
                       (),
                   text { $task-text }
               }
           ,
           (: Include existing sbmissions, unless it's removal is in request :)
           $existing-value/m:submission[not(@id eq request:get-parameter('delete-submission-id', ''))],
           (: Add additional submissions :)
           if(request:get-attribute('submission-id') gt '' and not($existing-value/m:submission[@id eq request:get-attribute('submission-id')])) then
               element submission {
                   attribute id { request:get-attribute('submission-id') },
                   attribute original-file-name { request:get-uploaded-file-name('submit-translation-file') },
                   attribute date-time { current-dateTime() },
                   attribute user { common:user-name() }
               }
           else
               ()
           
       }
   
    let $parent := $translation-status:data/m:translation-status
    
    let $insert-following := $translation-status:data/m:translation-status/m:text[last()]
   
    let $do-update := 
        if(($existing-value or $new-value) and common:user-in-group(('operations', 'utilities'))) then
            common:update('translation-status', $existing-value, $new-value, $parent, $insert-following)
        else
            ()
            
    return
        element { QName('http://read.84000.co/ns/1.0', 'updated') }
        {
            $do-update/@*,
            $new-value
        }
};

declare function translation-status:update-submission($text-id as xs:string, $submission-id as xs:string) as element()* {
    
    let $text-status := translation-status:text($text-id)
    let $parent := $text-status/m:submission[@id eq $submission-id]
    let $existing-values :=  $parent/m:item-checked
    let $new-values := 
        for $checked-item-id in request:get-parameter('checklist[]', '')
            where $checked-item-id gt '' and not($existing-values[@item-id eq $checked-item-id])
        return
            element { QName('http://read.84000.co/ns/1.0', 'item-checked') } {
                attribute item-id { $checked-item-id },
                attribute date-time { current-dateTime() },
                attribute user { common:user-name() }
            }
    
    let $do-update := 
        for $new-value in $new-values
        return
            common:update('update-submission', (), $new-value, $parent, ())
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'updated') }
        {
            attribute update { 'replace' },
            $new-values
        }
};

