xquery version "3.0";

module namespace trigger="http://exist-db.org/xquery/trigger";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "modules/translation.xql";
import module namespace glossary="http://read.84000.co/glossary" at "modules/glossary.xql";
import module namespace functx = "http://www.functx.com";

declare function trigger:after-update-document($uri as xs:anyURI) {
    
    (:local:log-event("after", "update", "document", $uri),:)
    local:after-update-document-functions(doc($uri))
    
};

declare function trigger:after-create-document($uri as xs:anyURI) {
    
    (:local:log-event("after", "create", "document", $uri),:)
    local:after-update-document-functions(doc($uri))
    
};

declare function local:after-update-document-functions($doc) {

    if($doc[tei:TEI/tei:teiHeader/tei:fileDesc[@type = "section"]/tei:publicationStmt/tei:idno[@xml:id]]) then (
    
        local:permanent-ids($doc),
        local:temporary-ids($doc),
        local:last-updated($doc)
        
    )
    else if($doc[tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id]]) then (
        
        local:permanent-ids($doc),
        (:local:remove-temporary-ids($doc),:)
        local:temporary-ids($doc),
        local:glossary-bo($doc, false()),
        local:last-updated($doc)
        
    )
    else ()
    
};

declare function local:permanent-ids($doc) {

    (: Add xml:ids to linkable nodes :)
    (: This enables persistent bookmarks :)
    
    let $translation-id := tei-content:id($doc/tei:TEI)
    where $translation-id
    return (
    
        util:log('info', concat('trigger-permanent-ids:', $translation-id)),
    
        let $elements := (
            $doc//tei:text//tei:milestone
            | $doc//tei:text//tei:note
            | $doc//tei:text//tei:ref[@type = ('folio', 'volume')]
            | $doc//tei:text//tei:q[ancestor-or-self::*/@ref]
            | $doc//tei:div[@type="notes"]//tei:item
            | $doc//tei:div[@type='listBibl']//tei:bibl
            | $doc//tei:div[@type='glossary']//tei:gloss
        )
        
        (: Add any missing @xml:ids :)
        let $elements-missing-id := $elements[not(@xml:id) or @xml:id eq '']
        
        where $elements-missing-id
            let $max-id := max($elements/@xml:id ! substring-after(., $translation-id) ! substring(., 2) ! common:integer(.))
            for $element at $index in $elements-missing-id
                let $new-id := concat($translation-id, '-', xs:string(sum(($max-id, $index))))
            return
                update insert attribute xml:id { $new-id } into $element
        ,
        
        (: If any parts are missing a @xml:id then re-calculate all :)
        let $part-missing-id := $doc//tei:text//tei:div[@type = ('section', 'chapter', 'prologue', 'homage', 'colophon')][not(@xml:id) or @xml:id eq '']
        where $part-missing-id
            for $part in $doc//tei:text//tei:div[@type][@type = ('section', 'chapter', 'prologue', 'homage', 'colophon')]
            
            (: Get the base type - except for translation :)
            let $base-type := $part/ancestor::tei:div[not(@type eq 'translation')][last()]/@type
            
            (: Get the index of this part in each ancestor part :)
            let $part-indexes := 
                for $ancestor-or-self in $part/ancestor-or-self::tei:div[@type = ('section', 'chapter', 'prologue', 'homage', 'colophon')]
                return (
                    if($ancestor-or-self[@prefix]) then $ancestor-or-self/@prefix ! replace(., '\W', '-')
                    else if($ancestor-or-self/@type eq 'prologue') then if ($base-type) then 'p' else ()
                    else if($ancestor-or-self/@type eq 'homage') then if ($base-type) then 'h' else ()
                    else if($ancestor-or-self/@type eq 'colophon') then if ($base-type) then 'c' else ()
                    else count($ancestor-or-self/preceding-sibling::tei:div[@type = ('section', 'chapter')]) + 1
                )
            
            (: Join the elements into an id :)
            let $part-id := string-join(($translation-id, ($base-type, $part/@type)[1], $part/@xml:lang, $part-indexes), '-')
            return
                update insert attribute xml:id { $part-id } into $part
        
    )
};

declare function local:temporary-ids($doc) {

    (: Add temporary ids to searchable nodes with no id :)
    (: This allows the search to link through to this block of text :)
    (: These only need to persist for a request/response cycle:)
    (: Copy/pasting elements can introduce duplicates and redundancy so this sorts those out too :)
    
    let $translation-id := tei-content:id($doc/tei:TEI)
    where $translation-id

    (: 
        TO DO: replace this with logic
        The logic here is actually to add a @tid to any
        node that has content, but not an @xml:id.
        But not where the parent has content too 
        e.g. 
        <p tid="1">Text <span>sub-node</span> more text.</p>
        NOT
        <p tid="1">Text <span tid="1">sub-node</span> more text.</p>
    :)
    let $tid-elements := (
        $doc//tei:text//tei:p
        | $doc//tei:text//tei:label[not(parent::tei:p)]
        | $doc//tei:text//tei:table
        | $doc//tei:text//tei:head[not(parent::tei:table)]
        | $doc//tei:text//tei:lg
        | $doc//tei:text//tei:item[parent::tei:list[not(@type = ('abbreviations','glossary'))]][matches(text(), '[\p{L}\p{N}]+', 'i')]
        | $doc//tei:text//tei:ab
        | $doc//tei:text//tei:trailer
    )[not(@xml:id)][not(ancestor::tei:note | ancestor::tei:orig)]
    
    (: Find duplicates and empty nodes :)
    let $tid-elements-to-update := (
        for $element in $tid-elements[@tid]
        let $element-id := $element/@tid
        group by $element-id
        where count($element) gt 1
        return $element
        ,
        $tid-elements[not(@tid) or @tid eq '']
    )
    
    (: Find redundant attributes :)
    let $tids-to-remove := $doc//@tid except $tid-elements/@tid
    
    let $max-tid := max($doc//@tid ! common:integer(.))
    
    return (
    
        util:log('info', concat('trigger-temporary-ids:', $translation-id)),
        
        (: Elements to update :)
        for $element at $index in $tid-elements-to-update[not(ancestor::tei:note)][not(ancestor::tei:orig)]
        return
            update insert attribute tid { sum(($max-tid, $index)) } into $element
        ,
        
        (: Attributes to remove :)
        for $attribute in $tids-to-remove
        return
            update delete $attribute
        
    )
};

declare function local:remove-temporary-ids($doc) {

    (: Remove ids :)
    
    let $translation-id := tei-content:id($doc/tei:TEI)
    where $translation-id
    return (
    
        util:log('info', concat('trigger-remove-temporary-ids:', $translation-id)),
    
        for $tid in $doc//tei:text//@tid
        return
            update delete $tid
    )
        
};

declare function local:last-updated($doc) {

    (: Set last updated note :)
    
    let $translation-id := tei-content:id($doc/tei:TEI)
    where $translation-id
    return (
    
        util:log('info', concat('trigger-last-updated:', $translation-id)),
    
        let $notesStmt := $doc//tei:teiHeader/tei:fileDesc/tei:notesStmt
        let $note := 
            element { QName('http://www.tei-c.org/ns/1.0', 'note') }{
                attribute type {'lastUpdated'},
                attribute date-time { current-dateTime() },
                attribute user { common:user-name() },
                text { format-dateTime(current-dateTime(), '[D01]/[M01]/[Y0001] [H01]:[m01]:[s01]') }
            }
        
        return
            if(not($notesStmt)) then 
                update insert 
                    element { QName('http://www.tei-c.org/ns/1.0', 'notesStmt') }{
                        $note
                    }
                following $doc//tei:teiHeader/tei:fileDesc/tei:sourceDesc
            else if (not($notesStmt/tei:note[@type eq 'lastUpdated'])) then 
                update insert $note into $notesStmt
            else
                update replace $notesStmt/tei:note[@type eq 'lastUpdated'] with $note
                
    )
};

declare function local:glossary-bo($doc, $do-all as xs:boolean) {

    (: Convert bo-ltn to bo term for glossary items :)
    
    let $translation-id := tei-content:id($doc/tei:TEI)
    where $translation-id
    return (
    
        util:log('info', concat('trigger-glossary-bo:', $translation-id)),
    
        let $glosses := 
            if($do-all) then
                $doc//tei:div[@type='glossary']//tei:gloss
            else
                $doc//tei:div[@type='glossary']//tei:gloss[not(count(tei:term[@xml:lang eq 'bo']) eq count(tei:term[@xml:lang eq 'Bo-Ltn']))]
        
        for $gloss in $glosses
        return (
            (: Delete existing :)
            update delete $gloss/tei:term[@xml:lang = 'bo'],
            
            (: Insert new :)
            for $bo-ltn-term in $gloss/tei:term[@xml:lang = 'Bo-Ltn'][normalize-space(text())]
            
                let $bo-term := 
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        attribute xml:lang { 'bo' },
                        text { common:bo-term($bo-ltn-term/text()) } 
                    }
                
            return
                update insert (text{ common:ws(7) }, $bo-term) following $bo-ltn-term
        )
   )
};

declare function local:log-event($type as xs:string, $event as xs:string, $object-type as xs:string, $uri as xs:string) {
    
    (: 
        Note: this only logs if the log file is present (available)
        To inhibit logging remove the log file.    
    :)
    
    let $log-file := "triggers.xml"
    let $log-uri := concat($common:log-path, "/", $log-file)
    let $log := doc($log-uri)/m:log
    
    where doc-available($log-uri)
    return
        (: Insert log :)
        update insert (
            common:ws(1),
            <trigger xmlns="http://read.84000.co/ns/1.0" 
                event="{string-join(($type, $event, $object-type), "-")}" 
                uri="{$uri}" 
                timestamp="{current-dateTime()}" 
                user="{ common:user-name() }"/>
        )
        into $log
};
