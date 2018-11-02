xquery version "3.0";

module namespace trigger="http://exist-db.org/xquery/trigger";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace tei-content="http://read.84000.co/tei-content" at "modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "modules/translation.xql";
import module namespace common="http://read.84000.co/common" at "modules/common.xql";

declare function trigger:after-update-document($uri as xs:anyURI) {
    
    local:log-event("after", "update", "document", $uri),
    local:after-update-document-functions(doc($uri))
    
};

declare function local:after-update-document-functions($doc) {
    
    local:footnote-indexes($doc),
    local:glossary-types($doc),
    local:glossary-bo($doc, false()),
    local:glossary-remove-term-ids($doc),
    local:permanent-ids($doc),
    local:temporary-ids($doc),
    local:last-updated($doc)
    
};

declare function local:footnote-indexes($doc) {

    (: Add indexes to footnotes :)
    (: This supports stable numbering accross all sections :)
    let $count-notes := count($doc/tei:TEI/tei:text//tei:note)
    let $max-note-index := max($doc/tei:TEI/tei:text//tei:note/@index ! xs:integer(concat('0', .)))
    let $count-distinct-note-indexes := count(distinct-values($doc/tei:TEI/tei:text//tei:note/@index))
    let $count-notes-missing-index := count($doc/tei:TEI/tei:text//tei:note[not(@index) or @index eq ''])
    
    return 
        if(
            $count-notes-missing-index > 0
            or $count-notes ne $count-distinct-note-indexes
            or $count-notes ne $max-note-index
        ) then
            for $note at $index in $doc/tei:TEI/tei:text//tei:note
            return
                update insert attribute index {$index} into $note
        else ()
        
};

declare function local:chapter-indexes($doc) {
    (: NOT IN USE :)
    (: Add indexes to chapters :)
    (: This supports internal navigation of chapters :)
    for $chapter at $index in $doc/tei:TEI/tei:text//*[@type='translation']/*[@type='chapter']
    return
        update insert attribute index {$index} into $chapter
        
};

declare function local:permanent-ids($doc) {
    (: Add ids to linkable nodes :)
    (: This enables persistent bookmarks :)
    let $translation-id := tei-content:id($doc)
    let $max-id := max($doc//@xml:id ! substring-after(., $translation-id) ! substring(., 2) ! xs:integer(concat('0', .)))
    for $element at $index in 
        $doc//tei:milestone[(not(@xml:id) or @xml:id='')]
        | $doc//tei:text//tei:note[not(@xml:id) or @xml:id eq '']
        | $doc//*[@type="notes"]//tei:item[not(@xml:id) or @xml:id eq '']
        | $doc//*[@type='listBibl']//tei:bibl[not(@xml:id) or @xml:id eq '']
        | $doc//*[@type='glossary']//tei:gloss[not(@xml:id) or @xml:id eq '']
    let $new-id := concat($translation-id, '-', xs:string(sum(($max-id, $index))))
    return
        update insert attribute xml:id { $new-id } into $element

};

declare function local:temporary-ids($doc) {
    (: Add temporary ids to searchable nodes with no id :)
    (: This allows the search to link through to this block of text :)
    (: These only need to persist for a search/find operation :)
    let $max-id := max($doc//@tid ! xs:integer(concat('0', .)))
    for $element at $index in 
        $doc//tei:text//tei:p[(not(@tid) or @tid='')]
        | $doc//tei:text//tei:head[(not(@tid) or @tid='')]
        | $doc//tei:text//tei:lg[(not(@tid) or @tid='')]
        | $doc//tei:text//tei:ab[(not(@tid) or @tid='')]
        | $doc//tei:text//tei:trailer[(not(@tid) or @tid='')]
        | $doc//tei:front//tei:list/tei:head[(not(@tid) or @tid='')]
        | $doc//tei:body//tei:list/tei:head[(not(@tid) or @tid='')]
    let $new-id := sum(($max-id, $index))
    return
        update insert attribute tid { $new-id } into $element

};

declare function local:remove-temporary-ids($doc) {
    (: Remove ids :)
    for $tid in $doc//tei:text//@tid
    return
        update delete $tid

};

declare function local:glossary-types($doc) {
    (: Add types to glossary items :)
    (: Converts old format to new :)
    let $translation-id := tei-content:id($doc)
    for $glossary in $doc//tei:div[@type='glossary']//tei:gloss[not(@type) or not(@type = ('term', 'person', 'place', 'text'))]
        let $glossary-id := $glossary/tei:term[@xml:id][1]/@xml:id
        let $glossary-id-end := substring-after($glossary-id, $translation-id)
        let $short-type := substring($glossary-id-end, 2, 2)
        let $type := 
            if($short-type eq 'te') then
                'term'
            else if($short-type eq 'pe') then
                'person'
            else if($short-type eq 'pl') then
                'place'
            else if($short-type eq 'tx') then
                'text'
            else
                ''
    return
        if($type) then 
            update insert attribute type { $type } into $glossary
        else
            ()

};

declare function local:glossary-remove-term-ids($doc) {
    (: Remove legacy ids :)
    for $glossary-term-id in $doc//tei:div[@type='glossary']//tei:gloss[@type = ('term', 'person', 'place', 'text')]/tei:term/@xml:id
    return
        update delete $glossary-term-id

};

declare function local:glossary-remove-gloss-ids($doc) {
    (: DO NOT USE ON LIVE TEXTS! :)
    (: Remove ids :)
    for $glossary-id in $doc//tei:div[@type='glossary']//tei:gloss/@xml:id
    return
        update delete $glossary-id

};

declare function local:section-remove-uids($doc) {
    (: Remove legacy ids :)
    for $uid in $doc//tei:text//@uid
    return
        update delete $uid

};

declare function local:last-updated($doc) {
    (: Set last updated note :)
    let $datetime-str := format-dateTime(current-dateTime(), '[D01]/[M01]/[Y0001] at [H01]:[m01]:[s01]')
    let $notesStmt := $doc//tei:teiHeader/tei:fileDesc/tei:notesStmt
    let $note := <note xmlns="http://www.tei-c.org/ns/1.0" type="lastUpdated">{ concat("Last updated at ", $datetime-str, " by ", common:user-name()) }</note>
    return
        if(not($notesStmt)) then 
            update insert <notesStmt xmlns="http://www.tei-c.org/ns/1.0">{ $note }</notesStmt>
            following $doc//tei:teiHeader/tei:fileDesc/tei:sourceDesc
        else if (not($notesStmt/tei:note[@type eq 'lastUpdated'])) then 
            update insert $note into $notesStmt
        else
            update replace $notesStmt/tei:note[@type eq 'lastUpdated'] with $note
                
};

declare function local:glossary-bo($doc, $do-all as xs:boolean) {
    (: Convert bo-ltn to bo term for glossary items :)
    
    let $glosses := 
        if($do-all) then
            $doc//tei:div[@type='glossary']//tei:gloss
        else
            $doc//tei:div[@type='glossary']//tei:gloss[not(count(tei:term[@xml:lang eq 'bo']) eq count(tei:term[@xml:lang eq 'Bo-Ltn']))]
    
    for $gloss in $glosses
    return
    (
        update delete $gloss/tei:term[lower-case(@xml:lang) = 'bo'],
        for $bo-ltn in $gloss/tei:term[lower-case(@xml:lang) = 'bo-ltn'][normalize-space(text())]
        return
            update insert <term xmlns="http://www.tei-c.org/ns/1.0" xml:lang="bo">{ common:bo-term($bo-ltn/text()) }</term> following $bo-ltn
   )
};

declare function local:glossary-prioritise($doc) {
    (: Auto-set priority attribute for glossary items :)
    (: DEPRECATED :)
    for $gloss-missing-priority in $doc//tei:div[@type='glossary']//tei:gloss[not(@priority)]
        let $priority := local:glossary-priority($doc, $gloss-missing-priority)
    return
        update insert attribute priority { $priority } into $gloss-missing-priority

};

declare function local:glossary-remove-prioritise($doc) {

    (: Removes priority attributes :)
    for $priority in $doc//tei:div[@type='glossary']//tei:gloss/@priority
    return
        update delete $priority
    
};

declare function local:glossary-priority($doc, $gloss) as xs:integer {
    (: Take a guess at the priority :)
    let $term := $gloss/tei:term[(lower-case(@xml:lang) = ('eng', 'en') or not(@xml:lang)) and not(@type = 'definition')][1]
    return 
        if(local:glossary-overlaps($doc, $term)) then
            (: If yes then return priority as count of words in english term :)
            common:word-count($term)
        else
            0
};

declare function local:glossary-overlaps($doc, $term) as xs:boolean {
    (: Are there other glossary items containing this string or is this string in other items? :)
    if(
        count(
            $doc//tei:div[@type='glossary']
                //tei:gloss/tei:term[
                    (not(@type) and (not(@xml:lang) or lower-case(@xml:lang) = ('eng', 'en'))) or @type = 'alternative']
                        /text()[.!= $term/text() and (contains(normalize-space(.), $term/text()) or contains($term/text(), normalize-space(.)))]
        )
    ) then
        true()
    else
        false()
};

declare function local:log-event($type as xs:string, $event as xs:string, $object-type as xs:string, $uri as xs:string) {

    let $log-collection := $common:log-path
    let $log := "triggers.xml"
    let $log-uri := concat($log-collection, "/", $log)
    return
    (
        (: create the log file if it does not exist :)
        if (not(doc-available($log-uri))) then
            xmldb:store($log-collection, $log, <log xmlns="http://read.84000.co/ns/1.0"/>)
        else ()
    ,
        (: log the trigger details to the log file :)
        update insert <trigger 
            xmlns="http://read.84000.co/ns/1.0" 
            event="{string-join(($type, $event, $object-type), "-")}" 
            uri="{$uri}" 
            timestamp="{current-dateTime()}" 
            user="{ common:user-name() }"/> 
        into doc($log-uri)/m:log
    )
};


