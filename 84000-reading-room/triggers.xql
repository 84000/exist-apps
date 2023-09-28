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

(: Process document after update or create :)
declare function trigger:after-update-document($uri as xs:anyURI) {

    local:log-event("after", "update", "document", $uri),
    local:after-update-document-functions(doc($uri))
    
};

declare function trigger:after-create-document($uri as xs:anyURI) {
    
    local:log-event("after", "create", "document", $uri),
    local:after-update-document-functions(doc($uri))
    
};

declare function local:after-update-document-functions($doc) {
    
     util:log('info', 'after-update-document-functions'),
        
    (# exist:batch-transaction #) {
        
        if($doc[tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id]]) then (
            
            local:permanent-ids($doc),
            (:local:remove-temporary-ids($doc),:)
            local:temporary-ids($doc),
            local:glossary-bo($doc, false()),
            util:log('info', 'trigger-completed')
            
        )
        else ()
        
    }
};

declare function local:permanent-ids($doc) {

    (: Add xml:ids to linkable nodes :)
    (: This enables persistent bookmarks :)
    
    let $tei := $doc/tei:TEI
    let $text-id := tei-content:id($tei)
    where $text-id
    return (
    
        util:log('info', concat('trigger-permanent-ids:', $text-id)),
    
        let $elements := (
            $tei//tei:text//tei:milestone
            | $tei//tei:text//tei:note[@place eq 'end']
            | $tei//tei:text//tei:ref[@type = ('folio', 'volume')]
            | $tei//tei:text//tei:ptr[@type eq 'quote-ref'][@target][ancestor::tei:q]
            | $tei//tei:div[@type eq 'notes']//tei:item
            | $tei//tei:div[@type eq 'listBibl']//tei:bibl
            | $tei//tei:div[@type eq 'glossary']//tei:gloss
            | $tei//tei:titleStmt/tei:author
            | $tei//tei:titleStmt/tei:editor
            | $tei//tei:titleStmt/tei:consultant
            | $tei//tei:titleStmt/tei:sponsor
            | $tei//tei:sourceDesc/tei:bibl/tei:author
            | $tei//tei:sourceDesc/tei:bibl/tei:editor
            | $tei//tei:revisionDesc/tei:change
            (:| $tei//tei:sourceDesc/tei:bibl/tei:citedRange - add these manually:)
        )
        
        (: Add any missing, empty or duplicate @xml:ids (duplicate tests too slow for production) :)
        let $elements-missing-id := $elements[not(@xml:id) or @xml:id eq '' (:or not(position() eq min(index-of($elements/@xml:id/string(), @xml:id/string()))):)]
        
        where $elements-missing-id
            let $max-id := tei-content:max-xml-id-int($tei)
            for $element at $index in $elements-missing-id
                let $new-id := tei-content:next-xml-id($text-id, sum(($max-id, $index)))
            return
                update insert attribute xml:id { $new-id } into $element
        ,
        
        (: If any parts are missing a @xml:id then re-calculate all :)
        let $part-missing-id := $tei//tei:text//tei:div[@type = ('section', 'chapter', 'prologue', 'homage', 'colophon')][not(@xml:id) or @xml:id eq '']
        where $part-missing-id
            for $part in $tei//tei:text//tei:div[@type][@type = ('section', 'chapter', 'prologue', 'homage', 'colophon')]
            
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
            let $part-id := string-join(($text-id, ($base-type, $part/@type)[1], $part/@xml:lang, $part-indexes), '-')
            return
                update insert attribute xml:id { $part-id } into $part
        
    )
};

declare function local:temporary-ids($doc) {

    (: Add temporary ids to content nodes :)
    (: This allows enables the TEI editor functionality :)
    (: These only need to persist for a request/response cycle:)
    (: Copy/pasting elements can introduce duplicates and redundancy so this should resolve those :)
    
    let $text-id := tei-content:id($doc/tei:TEI)
    where $text-id

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
        $doc//tei:text//tei:p[not(parent::tei:gloss)]
        | $doc//tei:text//tei:label[not(parent::tei:p)]
        | $doc//tei:text//tei:table
        | $doc//tei:text//tei:head[not(parent::tei:table)][not(@type eq 'translation')]
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
    
        util:log('info', concat('trigger-temporary-ids:', $text-id)),
        
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
    
    let $text-id := tei-content:id($doc/tei:TEI)
    where $text-id
    return (
    
        util:log('info', concat('trigger-remove-temporary-ids:', $text-id)),
    
        for $tid in $doc//tei:text//@tid
        return
            update delete $tid
    )
        
};

declare function local:glossary-bo($doc, $do-all as xs:boolean) {

    (: Convert bo-ltn to bo term for glossary items :)
    let $text-id := tei-content:id($doc/tei:TEI)
    let $glosses := 
        if($do-all) then
            $doc//tei:div[@type eq 'glossary']//tei:gloss
        else 
            $doc//tei:div[@type eq 'glossary']//tei:gloss[tei:term[@xml:lang eq 'Bo-Ltn'][not(@n eq (following-sibling::tei:term[1][@xml:lang eq 'bo']/@n, '0')[1])]]
    
    where $text-id
    return (
    
        util:log('info', concat('trigger-glossary-bo: ', $text-id, ' (', count($glosses), ' updates)')),
        
        (: Check for glosses with a Bo-Ltn term that doesn't have a bo equivalent :)
        for $gloss in $glosses
        return (
        
            (: Remove existing Tibetan :)
            update delete $gloss/tei:term[@xml:lang eq 'bo']/preceding-sibling::node()[1][. instance of text()],
            update delete $gloss/tei:term[@xml:lang eq 'bo'],
            
            (: Loop through all Wylie terms to get an index :)
            for $term-bo-ltn at $index in $gloss/tei:term[@xml:lang = 'Bo-Ltn'][normalize-space(text())]
            
            let $term-bo := 
                element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                    attribute xml:lang { 'bo' },
                    $term-bo-ltn/@type,
                    attribute n { $index },
                    $term-bo-ltn/@status,
                    text { $term-bo-ltn/text() ! normalize-unicode(.) ! normalize-space(.) ! common:bo-term(.) } 
                }
            
            return (
                
                (: Update @n in Wylie :)
                if($term-bo-ltn[not(@n ! xs:integer(.) eq $index)]) then
                    update insert attribute n { $index } into $term-bo-ltn
                else (),
                
                (: Insert correct Tibetan :)
                update insert (text{ common:ws(7) }, $term-bo) following $term-bo-ltn
                
            )
            
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
            text { common:ws(1) },
            <trigger xmlns="http://read.84000.co/ns/1.0" 
                event="{ string-join(($type, $event, $object-type), "-") }" 
                uri="{ $uri }" 
                timestamp="{ current-dateTime() }" 
                user="{ common:user-name() }"/>
        )
        into $log
};


(: Log other events too :)
(:declare function trigger:before-create-collection($uri as xs:anyURI) {
    local:log-event("before", "create", "collection", $uri)
};:)

declare function trigger:after-create-collection($uri as xs:anyURI) {
    local:log-event("after", "create", "collection", $uri)
};

(:declare function trigger:before-copy-collection($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "copy", "collection", concat("from: ", $uri, " to: ", $new-uri))
};:)

declare function trigger:after-copy-collection($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "copy", "collection", concat("from: ", $uri, " to: ", $new-uri))
};

(:declare function trigger:before-move-collection($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "move", "collection", concat("from: ", $uri, " to: ", $new-uri))
};:)

declare function trigger:after-move-collection($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "move", "collection", concat("from: ", $uri, " to: ", $new-uri))
};

(:declare function trigger:before-delete-collection($uri as xs:anyURI) {
    local:log-event("before", "delete", "collection", $uri)
};:)

declare function trigger:after-delete-collection($uri as xs:anyURI) {
    local:log-event("after", "delete", "collection", $uri)
};

(:declare function trigger:before-create-document($uri as xs:anyURI) {
    local:log-event("before", "create", "document", $uri)
};:)

(:declare function trigger:before-update-document($uri as xs:anyURI) {
    local:log-event("before", "update", "document", $uri)
};:)

(:declare function trigger:before-copy-document($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "copy", "document", concat("from: ", $uri, " to: ", $new-uri))
};:)

declare function trigger:after-copy-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "copy", "document", concat("from: ", $uri, " to: ", $new-uri))
};

(:declare function trigger:before-move-document($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "move", "document", concat("from: ", $uri, " to: ", $new-uri))
};:)

declare function trigger:after-move-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "move", "document", concat("from: ", $uri, " to: ", $new-uri))
};

(:declare function trigger:before-delete-document($uri as xs:anyURI) {
    local:log-event("before", "delete", "document", $uri)
};:)

declare function trigger:after-delete-document($uri as xs:anyURI) {
    local:log-event("after", "delete", "document", $uri)
};