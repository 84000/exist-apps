module namespace update-tei = "http://operations.84000.co/update-tei";

import module namespace update-entity = "http://operations.84000.co/update-entity" at "update-entity.xql";
import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace sponsors = "http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors = "http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace knowledgebase = "http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

import module namespace translation-status = "http://read.84000.co/translation-status" at "translation-status.xql";
import module namespace store = "http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

import module namespace functx = "http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $update-tei:blocking-jobs := scheduler:get-scheduled-jobs()//scheduler:job[@name = ('cache-glossary-locations', 'auto-assign-entities')][not(scheduler:trigger/state/text() eq 'COMPLETE')];

declare function update-tei:minor-version-increment($tei as element(tei:TEI), $form-action as xs:string) as element()* {
    
    (: Force a minor version increment:)
    
    let $version-number-str-increment := tei-content:version-number-str-increment($tei, 'revision')
    let $version-date := tei-content:version-date($tei)
    
    let $new-editionStmt :=
        element {QName("http://www.tei-c.org/ns/1.0", "editionStmt")} {
            element edition {
                text {'v ' || $version-number-str-increment || ' '},
                element date {
                    text {$version-date}
                }
            }
        }
    
    let $fileDesc := $tei//tei:fileDesc
    
    let $existing-editionStmt := $fileDesc/tei:editionStmt
    
    where not(tei-content:locked-by-user($tei) gt '')
    return (
    
        (: Do the update :)
        common:update('text-version', $existing-editionStmt, $new-editionStmt, $fileDesc, $fileDesc/tei:titleStmt),
        
        (: Add a note :)
        local:add-note($tei, 'text-version', $version-number-str-increment, concat('Auto (', $form-action, ')'))
        
    )

};

declare function local:add-note($tei as element(tei:TEI), $update as xs:string, $value as xs:string, $note as xs:string?) as element()* {
    
    let $note :=
        element {QName("http://www.tei-c.org/ns/1.0", "note")} {
            attribute type {'updated'},
            attribute update {$update},
            attribute value {$value},
            attribute date-time {current-dateTime()},
            attribute user {common:user-name()},
            text {
                if ($note) then
                    $note
                else
                    $value
            }
        }
        
    where not(tei-content:locked-by-user($tei) gt '')
    return
        common:update('add-note', (), $note, $tei//tei:fileDesc/tei:notesStmt, ())

};

declare function update-tei:publication-status($tei as element(tei:TEI)) as element()* {
    
    let $request-parameter-names := request:get-parameter-names()
    
    where not(tei-content:locked-by-user($tei) gt '')
    return
        (: exist:batch-transaction should defer triggers until all updates are made :)
        (# exist:batch-transaction #) {
            
            let $parent := $tei//tei:fileDesc
            
            (: publicationStmt :)
            (: Do this first to establish if there were updates, then we can force a version increment if there were :)
            let $do-publication-statement-update :=
            
            if ($request-parameter-names = 'publication-date' and $request-parameter-names = 'translation-status') then
                
                let $existing-value := $parent/tei:publicationStmt
                let $insert-following := $parent/tei:editionStmt
                
                (: Publication date :)
                let $request-publication-date := request:get-parameter('publication-date', '')
                
                (: Translation status :)
                let $request-status := request:get-parameter('translation-status', '')
                (: Force zero to '' :)
                let $request-status :=
                if ($request-status eq '0') then
                    ''
                else
                    $request-status
                
                let $new-value :=
                element {QName("http://www.tei-c.org/ns/1.0", "publicationStmt")} {
                    
                    (: Set the status :)
                    attribute {'status'} { $request-status },
                    
                    (: Copy any other attributes :)
                    $existing-value/@*[not(name(.) eq 'status')],
                    
                    (: Copy any other nodes :)
                    $existing-value/*[not(self::tei:date)],
                    
                    (: Set the date :)
                    element {QName("http://www.tei-c.org/ns/1.0", "date")} {
                        text { $request-publication-date }
                    }
                    
                }
                
                let $existing-status := $existing-value/@status/string()
                let $existing-publication-date := $existing-value/tei:date/string()
                    
                where $parent and ($request-status ne $existing-status or $request-publication-date ne $existing-publication-date)
                return
                    
                    let $do-update := common:update('publication-statement', $existing-value, $new-value, $parent, $insert-following)
                    
                    return (
                        
                        $do-update,
                        
                        (: Add the note - if it's a status update :)
                        if ($do-update[self::m:updated] and $request-status ne $existing-status) then
                            local:add-note($tei, 'translation-status', $request-status, $request-status)
                        else ()
                        
                    )
            else ()
            
            (: editionStmt :)
            (: Do this second and force a version update if there was a change to the publicationStmt :)
            let $existing-value := $parent/tei:editionStmt
            let $insert-following := $parent/tei:titleStmt
            
            (: Get the version from the request :)
            let $request-version := request:get-parameter('text-version', '')
            (: Make a comparable string from the request :)
            let $request-version-number-str := tei-content:strip-version-number($request-version)
            (: Get the current version number from the TEI :)
            let $existing-version-number-str := tei-content:version-number-str($tei)
            (: Test if it's a new version :)
            let $request-is-current-version := tei-content:is-current-version($existing-version-number-str, $request-version-number-str)
            
            (: If the request is the current version number (not incremented) but there was an update - then force an increment :)
            let $version-number-str :=
                if ($request-is-current-version and $do-publication-statement-update[self::m:updated]) then
                    tei-content:version-number-str-increment($tei, 'revision')
                else
                    $request-version-number-str
                
            (: Get the date from the request :)
            let $request-version-date := request:get-parameter('text-version-date', format-dateTime(current-dateTime(), '[Y]'))
            
            let $new-value :=
                element {QName("http://www.tei-c.org/ns/1.0", "editionStmt")} {
                    element edition {
                        text {'v ' || $version-number-str || ' '},
                        element date {
                            text {$request-version-date}
                        }
                    }
                }
            
            (: Test if it's a new version :)
            let $new-is-current-version := tei-content:is-current-version($existing-version-number-str, $version-number-str)
            
            let $existing-version-date := $existing-value/tei:date/string()
                
            where $parent and (not($new-is-current-version) or $request-version-date ne $existing-version-date)
            return
                
                let $do-update := common:update('text-version', $existing-value, $new-value, $parent, $insert-following)
                
                let $update-notes := request:get-parameter('update-notes', '')
                let $update-notes :=
                if ($update-notes eq '') then
                    if (not($version-number-str eq $request-version-number-str)) then
                        (: It's a forced update :)
                        'Auto (update-publication-status)'
                    else
                        (: It's a requested update :)
                        $request-version-number-str
                else
                    (: The user defined a note :)
                    $update-notes
                
                return (
                    
                    $do-publication-statement-update,
                    $do-update,
                    
                    (: Add the note :)
                    if ($do-update[self::m:updated]) then
                        local:add-note($tei, 'text-version', $version-number-str, $update-notes)
                    else ()
                    
                )
        
        } (: close exist:batch-transaction :)
};

declare function local:titles-from-request() as element(tei:title)* {
    
    (: Add all the titles from the request :)
    for $title-text-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'title-text-')], '-')

    let $title-index := substring-after($title-text-param, 'title-text-')
    let $title-text := request:get-parameter($title-text-param, '')
    let $title-type := request:get-parameter(concat('title-type-', $title-index), '')
    let $title-lang := request:get-parameter(concat('title-lang-', $title-index), '')
    let $valid-lang := common:valid-lang(replace($title-lang, '\-rc$', ''))
    
    where $title-text gt ''
    return
        element { QName("http://www.tei-c.org/ns/1.0", "title") } {
            attribute type {$title-type},
            if(lower-case($title-lang) eq 'sa-ltn-rc') then (
                attribute xml:lang {'Sa-Ltn'},
                attribute rend {'reconstruction'}
            )
            else 
                attribute xml:lang { $valid-lang }
            ,
            text {
                if ($valid-lang eq 'Sa-Ltn') then
                    replace($title-text, '\-', '­')
                else
                    $title-text
            }
        }

};

declare function update-tei:title-statement($tei as element(tei:TEI)) as element()* {
    let $titles :=
        if (request:get-parameter('form-action', '') eq 'update-titles') then
            local:titles-from-request()
        else
            $tei//tei:fileDesc/tei:titleStmt/tei:title
    return 
        update-tei:title-statement($tei, $titles)
};

declare function update-tei:title-statement($tei as element(tei:TEI), $titles as element(tei:title)*) as element()* {
    
    let $parent := $tei/tei:teiHeader/tei:fileDesc
    let $existing-value := $parent/tei:titleStmt
    
    let $container-ws := $existing-value/preceding-sibling::text()[1]
    let $node-ws := $existing-value/tei:*[1]/preceding-sibling::text()
    
    let $form-action := request:get-parameter('form-action', 'update-titles', false())
    
    let $new-value :=
        (: titleStmt :)
        element { node-name($existing-value) } {
            
            (: titleStmt attributes :)
            $existing-value/@*,
            
            (: Add titles - don't allow duplicates :)
            for $title in $titles
            let $title-text := $title/text()
            group by $title-text
            order by 
                if($title[1]/@type eq 'mainTitle') then 1 else if($title[1]/@type eq 'longTitle') then 2 else 3 ascending,
                if($title[1]/@xml:lang eq 'en') then 1 else if($title[1]/@xml:lang eq 'Sa-Ltn') then 2 else 3 ascending
            where $title-text[not(. eq '')]
            return (
                $node-ws,
                $title[1]
            ),
            
            if ($form-action eq 'update-contributors') then (
                
                (: Add all the contributors from the request :)
                
                (: Translator main :)
                let $translator-team-id := request:get-parameter('translator-team-id', '') ! lower-case(.)
                let $existing-translator-team := $existing-value/tei:author[@role eq 'translatorMain']
                    
                where $translator-team-id gt ''
                return (
                    $node-ws,
                    element {QName("http://www.tei-c.org/ns/1.0", "author")} {
                        
                        attribute role {'translatorMain'},
                        attribute ref { contributors:contributor-uri($translator-team-id)[1] },
                        
                        (: Carry over the text :)
                        if ($existing-translator-team[@ref] and contributors:contributor-id($existing-translator-team/@ref) eq $translator-team-id) then
                            $existing-translator-team/node()
                        else ()
                        
                    }
                    
                ),
                
                (: Add other contributors from the request :)
                for $contributor-id-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'contributor-id-')], '-')
                
                    let $contributor-id := request:get-parameter($contributor-id-param, '')
                    let $contributor-index := substring-after($contributor-id-param, 'contributor-id-')
                    let $contributor-type := request:get-parameter(concat('contributor-type-', $contributor-index), '')
                    let $contributor-type-tokenized := tokenize($contributor-type, '-')
                    let $contributor-node-name := $contributor-type-tokenized[1]
                    let $contributor-role :=
                        if (count($contributor-type-tokenized) eq 2) then
                            $contributor-type-tokenized[2]
                        else
                            ''
                    let $contributor-expression := request:get-parameter(concat('contributor-expression-', $contributor-index), '')
                    let $contributor-expression :=
                        if ($contributor-expression gt '') then
                            $contributor-expression
                        else
                            $contributors:contributors//m:person[@xml:id eq $contributor-id]/m:label/text()
                        
                where $contributor-id gt '' and $contributor-node-name and $contributor-role
                return (
                    $node-ws,
                    element {QName("http://www.tei-c.org/ns/1.0", $contributor-node-name)} {
                        attribute role {$contributor-role},
                        attribute ref { contributors:contributor-uri($contributor-id)[1] },
                        text {$contributor-expression}
                    }
                )
            )
            
        else
            (: Just copy them :)
            for $existing-node in $existing-value/*[self::tei:author | self::tei:editor | self::tei:consultant]
            return (
                $node-ws,
                $existing-node
            )
        ,
        
        if ($form-action eq 'update-sponsorship') then (
            
            (: Add all the sponsors from the request :)
            for $sponsor-id-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'sponsor-id-')], '-')
            
            let $sponsor-index := substring-after($sponsor-id-param, 'sponsor-id-')
            let $sponsor-id := request:get-parameter($sponsor-id-param, '')
            let $sponsor-expression := request:get-parameter(concat('sponsor-expression-', $sponsor-index), '')
            let $sponsor-expression :=
            if ($sponsor-expression gt '') then
                $sponsor-expression
            else
                $sponsors:sponsors//m:sponsor[@xml:id eq $sponsor-id]/m:label/text()
                
                where $sponsor-id gt ''
            return (
                $node-ws,
                element {QName("http://www.tei-c.org/ns/1.0", "sponsor")} {
                    attribute ref { sponsors:sponsor-uri($sponsor-id)[1] },
                    text {$sponsor-expression}
                }
            )
        )
        else
            (: Just copy them :)
            for $existing-node in $existing-value/*[self::tei:sponsor]
            return (
                $node-ws,
                $existing-node
             )
        ,
        
        
        (: Copy anything else in case there are comments or something :)
        for $existing-node in $existing-value/*[not(. instance of text())][not(self::tei:title | self::tei:author | self::tei:editor | self::tei:consultant | self::tei:sponsor)]
        return (
            $node-ws,
            $existing-node
        )
        ,
        $container-ws
    }
    
    let $notes-statement := 
        element { QName("http://www.tei-c.org/ns/1.0", "notesStmt") } {
            $parent/tei:notesStmt/@*,
            
            for $note in $parent/tei:notesStmt/*[not(local-name(.) eq 'note' and @type = ('title', 'title-internal'))]
            return (
                $node-ws,
                $note
            ),
            
            for $titles-note-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'titles-note-text-')], '-')
            let $titles-note := request:get-parameter($titles-note-param, '')
            let $titles-note-index := substring-after($titles-note-param, 'titles-note-text-')
            let $titles-note-type := request:get-parameter(concat('titles-note-type-', $titles-note-index), '')
            where normalize-space($titles-note) gt ''
            return (
                $node-ws,
                element {QName("http://www.tei-c.org/ns/1.0", "note")} {
                    attribute type { if($titles-note-type eq 'internal') then 'title-internal' else 'title' },
                    attribute date-time {current-dateTime()},
                    attribute user {common:user-name()},
                    text {$titles-note}
                }
            ),
            $container-ws
        }
    
    where 
        not(tei-content:locked-by-user($tei) gt '')
        and $parent and ($existing-value or $new-value)
    return 
        (# exist:batch-transaction #) {
            
            (: Increment the version number - do first so it can evaluate the change :)
            if (not(deep-equal($existing-value, $new-value))) then
                update-tei:minor-version-increment($tei, $form-action)
            else ()
            ,
            
            (: Update titles :)
            common:update($form-action, $existing-value, $new-value, $parent, ()),
            
            (: Update notes :)
            if (request:get-parameter('form-action', '') eq 'update-titles') then
                common:update('titles-notes', $parent/tei:notesStmt, $notes-statement, $parent, ())
            else ()
            
            (:(
                element update-debug {
                    element existing-value { $existing-value }, 
                    element new-value { $new-value }, 
                    element parent { $parent }
                }
            ):)
            
        }
};

declare function update-tei:source($tei as element(tei:TEI)) as element()* {
    
    let $parent := $tei/tei:teiHeader/tei:fileDesc
    let $existing-value := $parent/tei:sourceDesc
    let $insert-following := $parent/tei:publicationStmt
    
    let $bibl-ws := $existing-value/tei:bibl[1]/preceding-sibling::text()[1]
    let $location-ws := $existing-value/tei:bibl[1]/tei:location[1]/preceding-sibling::text()[1]
    let $volume-ws := $existing-value/tei:bibl[1]/tei:location[1]/tei:volume[1]/preceding-sibling::text()[1]
    
    let $new-value :=
    (: sourceDesc :)
    element {node-name($existing-value)} {
        
        $existing-value/@*,
        $existing-value/tei:bibl[1]/preceding-sibling::node(),
        
        for $bibl at $bibl-index in $existing-value/tei:bibl
        
        let $toh-key := $bibl/@key
        let $volume-keys :=
            for $parameter in request:get-parameter-names()
            let $paramater-base := concat('volume-', $toh-key, '-')
            where starts-with($parameter, $paramater-base)
            return
                substring-after($parameter, $paramater-base)
        
        return (
            
            (: add bibl whitespace :)
            if ($bibl-index gt 1) then
                $bibl-ws
            else (),
            
            (: bibl :)
            element {node-name($bibl)} {
                $bibl/@*,
                
                (: <ref/> :)
                for $element in $bibl/tei:ref
                return (
                    $location-ws,
                    $element
                ),
                
                (: <biblScope/> :)
                for $element in $bibl/tei:biblScope
                return (
                    $location-ws,
                    $element
                ),
                
                (: <author/> <editor/> :)
                let $attribution-parameter-type := concat('attribution-role-',$toh-key,'-')
                for $attribution-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., $attribution-parameter-type)], '-')
                let $attribution-index := substring-after($attribution-param, $attribution-parameter-type)
                let $attribution-role := request:get-parameter(concat('attribution-role-',$toh-key,'-', $attribution-index), '')
                let $attribution-entity := request:get-parameter(concat('attribution-entity-',$toh-key,'-', $attribution-index), '')
                let $attribution-expression := request:get-parameter(concat('attribution-expression-',$toh-key,'-', $attribution-index), '')
                let $attribution-lang := request:get-parameter(concat('attribution-lang-',$toh-key,'-', $attribution-index), '') ! common:valid-lang(.)
                let $attribution-revision := request:get-parameter(concat('attribution-revision-',$toh-key,'-', $attribution-index), '')
                let $attribution-key := request:get-parameter(concat('attribution-key-',$toh-key,'-', $attribution-index), '')
                
                let $attribution-entity :=
                    if($attribution-entity eq 'create-entity-for-expression') then
                        let $new-entity := update-entity:new-entity($attribution-lang, $attribution-expression, 'eft-person', '', '', '')
                        let $save-entity := common:update('entity', (), $new-entity, $entities:entities, ())
                        where $save-entity
                        return
                            $new-entity/@xml:id/string()
                    else
                        $attribution-entity
                
                where $attribution-role gt ''
                return (
                    $location-ws,
                    element {QName("http://www.tei-c.org/ns/1.0", if($attribution-role eq 'reviser') then 'editor' else 'author')} {
                        if($attribution-role = ('translator')) then
                            attribute role {'translatorTib'}
                        else if($attribution-role = ('reviser')) then
                            attribute role {'reviser'}
                        else ()
                        ,
                        if(not($attribution-entity eq '')) then
                            attribute ref {concat('eft:', $attribution-entity)}
                        else ()
                        ,
                        if(not($attribution-lang eq '')) then
                            attribute xml:lang {$attribution-lang}
                        else ()
                        ,
                        if(not($attribution-revision eq '')) then
                            attribute revision {$attribution-revision}
                        else ()
                        ,if(not($attribution-key eq '')) then
                            attribute key {$attribution-key}
                        else ()
                        ,
                        text { $attribution-expression }
                    }
                ),
                
                (: <location/> :)
                $location-ws,
                element {QName("http://www.tei-c.org/ns/1.0", "location")} {
                    attribute work {request:get-parameter(concat('work-', $toh-key), '0')},
                    attribute count-pages {request:get-parameter(concat('count-pages-', $toh-key), '0')},
                    
                    for $volume-key at $volume-index in $volume-keys
                    let $volume-number := request:get-parameter(concat('volume-', $toh-key, '-', $volume-key), '0')
                        where $volume-number gt '0'
                    return (
                        (: add volume whitespace :)
                        $volume-ws,
                        
                        (: volume :)
                        element {QName("http://www.tei-c.org/ns/1.0", "volume")} {
                            attribute number {$volume-number},
                            attribute start-page {request:get-parameter(concat('start-page-', $toh-key, '-', $volume-key), '0')},
                            attribute end-page {request:get-parameter(concat('end-page-', $toh-key, '-', $volume-key), '0')}
                        }
                    )
                    ,
                    $location-ws
                },
                
                (: <idno/> :)
                for $element in $bibl/tei:idno
                return (
                    $location-ws,
                    $element
                ),
                
                (: Anything else :)
                for $element in $bibl/*[not(local-name(.) = ('ref','biblScope','author','editor','location','idno'))]
                return (
                    $location-ws,
                    $element
                ),
                
                $bibl-ws
            }
        ),
        
        (: In case we add other nodes or comments :)
        $existing-value/tei:bibl[last()]/following-sibling::node()
        
    }
        
    where 
        not(tei-content:locked-by-user($tei) gt '')
        and $parent and ($existing-value or $new-value)
    return
        (# exist:batch-transaction #) {
            
            (: Increment the version number - do first so it can evaluate the change :)
            if (not(deep-equal($existing-value, $new-value))) then
                update-tei:minor-version-increment($tei, 'update-locations')
            else()
            ,
            
            (: Do the update :)
            common:update('update-tei-locations', $existing-value, $new-value, $parent, $insert-following)
            
            (:,
            (
                element update-debug {
                    element existing-value { $existing-value }, 
                    element new-value { $new-value }, 
                    element parent { $parent }
                }
            )
            :)
            
        }

};

declare function update-tei:update-glossary($tei as element(tei:TEI), $glossary-id as xs:string) as element()* {

    (: To create a new item pass a $glossary-id that is unused :)
    let $parent := $tei//tei:back//tei:list[@type eq 'glossary']
    
    (: Look for an existing item :)
    let $existing-item := $parent/tei:item[tei:gloss[@xml:id eq $glossary-id]]
    
    (: If it's an update and the main term is '' then don't construct the new value e.g. remove existing :)
    let $remove := (request:get-parameter('form-action', '') eq 'update-glossary' and request:get-parameter('main-term', '') eq '')
    
    let $tei-version := tei-content:version-str($tei)
    
    (: Only construct the new value if it's existing or it's a valid id :)
    let $new-value :=
        if (($existing-item or tei-content:valid-xml-id($tei, $glossary-id)) and not($remove)) then
            element {QName('http://www.tei-c.org/ns/1.0', 'item')} {
                $existing-item/@*,
                common:ws(6),
                
                element {QName('http://www.tei-c.org/ns/1.0', 'gloss')} {
                    
                    (: @xml:id :)
                    attribute xml:id { $glossary-id },
                    
                    (: @type :)
                    if (request:get-parameter('glossary-type', '') = $glossary:types) then
                        attribute type { request:get-parameter('glossary-type', 'term') }
                    else if($existing-item/tei:gloss[@type]) then
                        $existing-item/tei:gloss/@type
                    else
                        attribute type { 'term' }
                    ,
                    
                    (: @mode :)
                    if (request:get-parameter('glossary-mode', 'match') = $glossary:modes) then
                        attribute mode { request:get-parameter('glossary-mode', 'match') }
                    else if($existing-item/tei:gloss[@mode]) then
                        $existing-item/tei:gloss/@mode
                    else 
                        attribute mode { 'match' }
                    ,
                    
                    (: Main term :)
                    common:ws(7),
                    element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                        text {
                            request:get-parameter('main-term', $glossary-id)
                        }
                    },
                    
                    (: Source terms and alternatives :)
                    for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-text-')], '-')
                    let $term-index := substring-after($term-param, 'term-text-')
                    let $term-text := request:get-parameter($term-param, '')
                    let $term-lang-type := request:get-parameter(concat('term-lang-', $term-index), '')
                    let $term-type := 
                        if(matches($term-lang-type, '\-sr$')) then 
                            'semanticReconstruction' 
                        else if(matches($term-lang-type, '\-tr$')) then 
                            'transliterationReconstruction' 
                        else if(matches($term-lang-type, '\-sa$')) then 
                            'sourceAttested' 
                        else ()
                    let $term-status := request:get-parameter(concat('term-status-', $term-index), '')
                    let $term-lang := common:valid-lang(replace($term-lang-type, '\-(sr|tr|sa)$', ''))
                    where $term-text gt ''
                    return (
                        common:ws(7),
                        element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                        
                            (: Lang - if more than one en term is passed then make it an alternative :)
                            if($term-lang eq 'en') then
                                attribute type {'alternative'}
                            else ( 
                                attribute xml:lang { $term-lang },
                                if($term-type gt '') then attribute type { $term-type } else (),
                                if($term-status gt '') then attribute status  { $term-status } else ()
                            )
                            ,
                            
                            (: Text - skip if text matches placeholder - if Sanskrit parse hyphens :)
                            if ($term-lang eq 'Sa-Ltn') then
                                if(not($term-text eq common:local-text('glossary.term-empty-sa-ltn', 'en'))) then
                                    text { replace($term-text, '\-', '­'(: This is a soft-hyphen :)) }
                                else ()
                                
                            else if ($term-lang eq 'Bo-Ltn') then
                                if(not($term-text eq common:local-text('glossary.term-empty-bo-ltn', 'en'))) then
                                    text { $term-text }
                                else ()
                                
                            else 
                                text { $term-text }
                            
                        }
                    ),
                    
                    (: Get the definitions from the request :)
                    for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-definition-text-')], '-')
                    let $term-text := request:get-parameter($term-param, '')
                    let $term-text-markup := common:markup($term-text, 'http://www.tei-c.org/ns/1.0')
                    where $term-text gt ''
                    return (
                        common:ws(7),
                        element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                            attribute type {'definition'},
                            if($term-text-markup) then
                                $term-text-markup
                            else
                                $term-text
                        }
                    ),
                    
                    (: Copy other nodes :)
                    if ($existing-item) then
                        for $node in $existing-item/tei:gloss/*[not(self::tei:term)]
                        return (
                            common:ws(7),
                            $node
                        )
                    else ()
                    ,
                    
                    $existing-item/tei:gloss/comment(),
                    
                    (: end of gloss :)
                    common:ws(6)
                
                },
                
                $existing-item/comment(),
                
                (: end of item :)
                common:ws(5)
            }
        else ()
    
    
    where 
        not(tei-content:locked-by-user($tei) gt '')
        and $parent and ($existing-item or $new-value)
    return (
    
        (: Update the glossary entry :)
        common:update('glossary-item', $existing-item, $new-value, $parent, ()),
        
        (: If we are removing the instance then also remove the entity instance and refresh the cache :)
        if ($remove) then (
            (: Does the cache refresh get triggered anyway? :)
            (:update-tei:cache-glossary($tei, 'none'),:)
            update-entity:remove-instance($glossary-id)
        )
        (: Update the entity instance :)
        else 
            update-entity:update-instance($glossary-id)
        
        (:element debug {
            attribute form-action { request:get-parameter('form-action', '') },
            attribute term-main-text-1 { request:get-parameter('main-term', '') },
            attribute glossary-id { $glossary-id },
            element existing-value { $existing-item }, 
            element new-value { $new-value }, 
            element parent { $parent }, 
            element insert-following { $insert-following }(\::\)
        }:)
    )
};

declare function update-tei:cache-glossary($tei as element(tei:TEI), $glossary-id as xs:string*) as element()* {
    
    (: 
        Pass $glossary-id to refresh cache for particular items
        - or 'uncached' to process those with no cache
        - or 'version'  to process those from an old version
        - or 'all'      to process all
        - or 'none'     will select none just re-index
    :)
    
    (: Start the clock :)
    let $start-time := util:system-dateTime()
    let $text-id := tei-content:id($tei)
    let $log := util:log('info', concat('update-tei-cache-glossary:', $text-id))
    
    (: Get data :)
    let $cache := tei-content:cache($tei, true())
    let $glossary-cache := $cache/m:glossary-cache
    let $tei-version := tei-content:version-str($tei)
    
    (: Don't allow if it's processing :)
    where not($update-tei:blocking-jobs)
    return
    
    (: TEI glossary items :)
    let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]
    
    (: Which glossary entries to refresh :)
    let $refresh-locations :=
        if ($glossary-id eq 'uncached') then
            $tei-glossary[not(@xml:id = $glossary-cache/m:gloss[m:location]/@id)]/@xml:id
        else if ($glossary-id eq 'version') then
            $tei-glossary[not(@xml:id = $glossary-cache/m:gloss[@tei-version eq $tei-version]/@id)]/@xml:id
        else if ($glossary-id eq 'all') then
            $tei-glossary/@xml:id
        else
            $tei-glossary[@xml:id = $glossary-id]/@xml:id
    
    let $log := util:log('info', concat('update-tei-cache-glossary-count:', count($refresh-locations)))
    
    (: Process in chunks :)
    let $cache-glossary-chunks := local:cache-glossary-chunk($tei, $cache, $refresh-locations, 1)
    
    (: Set version - only if all are done :)
    (:let $set-cache-version := 
        if(count($glossary-cache/m:gloss[@tei-version eq $tei-version]) eq count($tei-glossary)) then
            store:store-version-str(concat($common:data-path, '/cache'), concat(tei-content:id($tei), '.cache'), $tei-version)
        else ():)
    
    (: Record build time - only if it's the whole set :)
    let $end-time := util:system-dateTime()
    let $set-duration := 
        if(count($refresh-locations) eq count($tei-glossary/@xml:id)) then
            common:update('glossary-cache-duration', $glossary-cache/@seconds-to-build, attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) }, $glossary-cache, ())
        else ()
    
    return
        (:element debug { $glossary-cache-new }:)
        $cache-glossary-chunks

};

declare function local:cache-glossary-chunk($tei as element(tei:TEI), $cache as element(m:cache), $refresh-locations as xs:string*, $chunk as xs:integer) as element()* {
    
    let $count := count($refresh-locations)
    let $chunk-size := xs:integer(500)
    let $chunks-count := xs:integer(ceiling($count div $chunk-size))
    let $chunk-start := ($chunk-size * ($chunk - 1)) + 1
    let $chunk-end := ($chunk-start + $chunk-size) - 1
    
    let $text-id := tei-content:id($tei)
    
    return (
        if($chunk-start le $count) then (
        
            (: Get subsequence :)
            let $refresh-locations-chunk := subsequence($refresh-locations, $chunk-start, $chunk-size)
            
            (: Get new cache :)
            let $glossary-cache-new := glossary:cache($tei, $refresh-locations-chunk, true())
            
            (: Save new cache :)
            return (
                common:update('cache-glossary', $cache/m:glossary-cache, $glossary-cache-new, $cache, ()),
                util:log('info', concat('update-tei-cache-glossary-chunk:', $text-id, ' ', $chunk, '/', $chunks-count))
            )
            
        )
        else ()
        ,
        (: Recurse to next chunk :)
        if($chunk-end lt $count) then
            local:cache-glossary-chunk($tei, $cache, $refresh-locations, $chunk + 1)
        else ()
    )
    
};

declare function update-tei:add-knowledgebase($title as xs:string) {

    let $id := knowledgebase:id($title)
    let $titles := <title xmlns="http://www.tei-c.org/ns/1.0" type="mainTitle" xml:lang="en">{ $title }</title>
    return
        update-tei:add-knowledgebase($id, $titles)
};

declare function update-tei:add-knowledgebase($id as xs:string, $titles as element(tei:title)*) {

    let $filename := concat(replace($id, '\-', '_'), '.xml')
    let $new-tei := knowledgebase:new-tei($id, $titles)
    let $existing-tei := tei-content:tei($id, 'knowledgebase')
    
    where $id and $filename and $new-tei and not($existing-tei)
    return (
        (: Create the file :)
        xmldb:store($common:knowledgebase-path, $filename, $new-tei, 'application/xml'),
        sm:chgrp(xs:anyURI(concat($common:knowledgebase-path, '/', $filename)), 'tei'),
        sm:chmod(xs:anyURI(concat($common:knowledgebase-path, '/', $filename)), 'rw-rw-r--')
    )
};

declare function update-tei:knowledgebase-header($tei as element(tei:TEI)) as element()* {
    
    (# exist:batch-transaction #) {
        
        let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
        
        let $request-parameter-names := request:get-parameter-names()
        
        (: Get the titles from the request :)
        let $request-titles := local:titles-from-request()
        let $request-publication-date := request:get-parameter('publication-date', '')
        let $request-status := request:get-parameter('publication-status', '')
        (: Force zero to '' :)
        let $request-status := if ($request-status eq '0') then '' else $request-status
        let $existing-status := $fileDesc/tei:publicationStmt/@status/string()
        
        (: Get the version from the request :)
        let $request-version := request:get-parameter('text-version', '')
        (: Make a comparable string from the request :)
        let $request-version-number-str := tei-content:strip-version-number($request-version)
        (: Get the current version number from the TEI :)
        let $existing-version-number-str := tei-content:version-number-str($tei)
        (: Test if it's a new version :)
        let $request-is-current-version := tei-content:is-current-version($existing-version-number-str, $request-version-number-str)
        (: Get the date from the request :)
        let $request-version-date := request:get-parameter('text-version-date', format-dateTime(current-dateTime(), '[Y]'))
        
        let $new-fileDesc :=
            element { node-name($fileDesc) } {
                
                $fileDesc/@*,
                
                for $node in $fileDesc/node()
                
                (: Copy the whitespace of the first child node :)
                let $node-ws := $node/tei:*[1]/preceding-sibling::text()
                
                return
                    
                    (: Add titles from request :)
                    if(local-name($node) eq 'titleStmt' and $request-titles) then (
                        
                        element { node-name($node) } {
                            
                            $node/@*,
                            
                            for $title in $request-titles
                            return (
                                (: Add whitespace before node :)
                                $node-ws,
                                $title
                            )
                        }
                        
                    )
                    
                    (: Update edition statement :)
                    else if(local-name($node) eq 'editionStmt' and $request-parameter-names = 'text-version') then (
                    
                        element { node-name($node) } {
                            
                            $node/@*,
                            
                            element edition {
                                text {'v ' || $request-version-number-str || ' '},
                                element date {
                                    text { $request-version-date }
                                }
                            }
                            
                        }
                    )
                    
                    (: Update publication status :)
                    else if(local-name($node) eq 'publicationStmt' and $request-parameter-names = 'publication-status') then (
                        
                        element { node-name($node) } {
                        
                            (: Set the status :)
                            attribute {'status'} { $request-status },
                            
                            (: Copy any other attributes :)
                            $node/@*[not(name(.) eq 'status')],
                            
                            (: Copy any other nodes :)
                            
                            for $element in $node/*[not(self::tei:date)]
                            return (
                                $node-ws,
                                $element
                            ),
                            
                            (: Set the date :)
                            $node-ws,
                            element {QName("http://www.tei-c.org/ns/1.0", "date")} {
                                text { $request-publication-date }
                            }
                            
                        }
                    )
                    
                    (: Copy all other nodes :)
                    else $node   
                }
        
        
        where not(tei-content:locked-by-user($tei) gt '')
        return
        
            (: Do update :)
            let $update-header := common:update('knowledgebase-header', $fileDesc, $new-fileDesc, (), ())
                
            return (
                
                (: Return update :)
                $update-header,
                
                if ($update-header[self::m:updated]) then (
                    (: Note the status update :)
                    if ($request-status ne $existing-status) then
                        local:add-note($tei, 'publication-status', $request-status, $request-status)
                    else ()
                    ,
                    (: Increment the version number if not already done :)
                    if($request-is-current-version) then
                        update-tei:minor-version-increment($tei, 'knowledgebase-header')
                    else ()
                )
                else ()
                    
            )
        
    } (: close exist:batch-transaction :)
};

declare function update-tei:markup($tei as element(tei:TEI), $markdown as xs:string*, $passage-id as xs:string, $newline-element as xs:string) as element()? {
    
    let $passage-id-parsed := replace($passage-id, '^node\-', '')
    let $current-tei := $tei//*[(@xml:id, @tid) = $passage-id-parsed]
    
    let $markdown-element := 
        element { QName('http://read.84000.co/ns/1.0', 'markdown') } {
            attribute newline-element { if($newline-element gt '') then $newline-element else 'div' },
            attribute target-namespace { 'http://www.tei-c.org/ns/1.0' },
            $markdown
        }
    
    let $serialization-options := 
        <output:serialization-parameters>
            <output:method value="xml"/>
            <output:version value="1.1"/>
            <output:indent value="no"/>
            <output:omit-xml-declaration value="yes"/>
        </output:serialization-parameters>
    
    let $markup := transform:transform($markdown-element, doc('/db/apps/84000-operations/views/common.xsl'), (), (), $serialization-options)
    
    let $new-tei := 
        (: Update with new content :)
        if($markdown gt '') then
            element { node-name($current-tei) } {
            
                (: Copy attributes :)
                $current-tei/@*[not(local-name(.) eq 'rend' and string() eq 'default-text')],
                
                (: Copy elements derived from new lines :)
                if($newline-element gt '' and $markup[node()]) then
                    $markup/node()
                
                (: No new lines so merge divs :)
                else if($markup[tei:div/node()]) then
                    $markup/tei:div/node()
                
                (: Nothing derived from markdown so copy to be safe :)
                else
                    $markdown
                ,
                
                (: Copy comments :)
                $current-tei/comment()
                
            }
        (: Remove the element :)
        else ()
    
    (: If it's a delete, in some cases we want to remove more than the node itself :)
    let $current-tei :=
    
        (: There is no content and it has no siblings :)
        if(not($new-tei) and not($current-tei/following-sibling::* | $current-tei/preceding-sibling::*)) then
        
            (: It's in a list :)
            if($current-tei[parent::tei:item[parent::tei:list]])then
            
                (: remove the whole list if this is the only item :)
                if(count($current-tei/parent::tei:item/parent::tei:list/tei:item) eq 1) then
                    $current-tei/parent::tei:item/parent::tei:list
                (: remove the whole item :)
                else
                    $current-tei/parent::tei:item
            
            (: It's the last element in a div, remove the div :)
            else if($current-tei[parent::tei:div]) then
                $current-tei/parent::tei:div
            
            else $current-tei
            
        else
            $current-tei
    
    where not(tei-content:locked-by-user($tei) gt '') and $current-tei
    return 
        common:update('tei-markup', $current-tei, $new-tei, (), ())

};

declare function update-tei:add-element($tei as element(tei:TEI), $passage-id as xs:string, $new-element-name as xs:string) as element()? {
    
    let $passage-id-parsed := replace($passage-id, '^node\-', '')
    let $passage := $tei//tei:*[(@xml:id, @tid) = $passage-id-parsed]
    let $new-element-tokenized := tokenize($new-element-name, '-')
    let $new-element-source := $new-element-tokenized[1]
    let $new-element-type := $new-element-tokenized[2]
    let $new-element-relation := $new-element-tokenized[3]
    
    (: Validate the request :)
    where 
        not(tei-content:locked-by-user($tei) gt '')
        and count($new-element-tokenized) eq 3
        and (
            ($new-element-source eq 'itemPara' and $passage[self::tei:p[parent::tei:item[parent::tei:list]]])
            or ($new-element-source eq 'head' and $passage[self::tei:head])
            or ($new-element-source eq 'para' and $passage[self::tei:p])
            or ($new-element-source eq 'bibl' and $passage[self::tei:bibl])
            or ($new-element-source = ('section', 'part') and $passage[self::tei:div])
        )
        and $new-element-type[. = ('item', 'para', 'listLabel', 'listDots', 'listNumbers', 'listLetters', 'bibl', 'section', 'itemPara', 'itemListDots', 'itemListNumbers', 'itemListLetters')]
        and $new-element-relation[. = ('before', 'after')]
    return
    
    (: The element to add :)
    let $new-element :=
        if($new-element-type eq 'item') then
            element { QName('http://www.tei-c.org/ns/1.0', 'item') } {
                attribute rend { 'default-text' },
                element p {
                    text { 'New list item...' }
                }
             }
        
        else if($new-element-type eq 'listLabel') then
            element { QName('http://www.tei-c.org/ns/1.0', 'label') } {
                attribute rend { 'default-text' },
                text { 'New label...' }
             }
             
        else if($new-element-type = ('listDots', 'listNumbers', 'listLetters', 'itemListDots', 'itemListNumbers', 'itemListLetters')) then (
            (: Add milestone if it's a root list :)
            if($new-element-type = ('listDots', 'listNumbers', 'listLetters') and count($passage/ancestor::tei:list) le 1) then
                element { QName('http://www.tei-c.org/ns/1.0', 'milestone') } {
                    attribute unit { 'chunk' }
                }
            else ()
            ,
            element { QName('http://www.tei-c.org/ns/1.0', 'label') } {
                attribute rend { 'default-text' },
                text { 'New list...' }
            },
            element { QName('http://www.tei-c.org/ns/1.0', 'list') } {
                attribute type { 'bullet' },
                if($new-element-type = ('listDots', 'itemListDots')) then
                    attribute rend { 'dots' }
                else if($new-element-type = ('listNumbers', 'itemListNumbers')) then
                    attribute rend { 'numbers' }
                else if($new-element-type = ('listLetters', 'itemListLetters')) then
                    attribute rend { 'letters' }
                else ()
                ,
                element item {
                    element p {
                        attribute rend { 'default-text' },
                        text { 'New list item 1...' }
                    }
                },
                element item {
                    element p {
                        attribute rend { 'default-text' },
                        text { 'New list item 2...' }
                    }
                }
            }
        )
        
        else if($new-element-type = ('para', 'itemPara')) then
            element { QName('http://www.tei-c.org/ns/1.0', 'p') } {
                attribute rend { 'default-text' },
                text { 'New paragraph...' }
            }
        
        else if($new-element-type = ('bibl')) then
            element { QName('http://www.tei-c.org/ns/1.0', 'bibl') } {
                attribute rend { 'default-text' },
                text { 'New biblographic reference...' }
            }
        
        else if($new-element-type = ('section')) then
            tei-content:new-section($passage/ancestor::tei:div[last()]/@type)
        else ()
    
    (: What level in the tree to add it? :)
    let $sibling :=
        (: It's in a list :)
        if($passage[self::tei:p[parent::tei:item[parent::tei:list]]]) then
            
            (: Add a sibling of the passage in the item :)
            if($new-element-type = ('itemPara', 'itemListDots', 'itemListNumbers', 'itemListLetters')) then
                $passage
                
            (: Add sibling of the item :)
            else if($new-element-type eq 'item') then
                $passage/parent::tei:item
                
            (: Default: Add sibling of the list :)
            else 
                $passage/parent::tei:item/parent::tei:list
        
        (: Default: Add sibling :)
        else 
            $passage
    
    where 
        $new-element[node()]
        and $sibling
    return
        element { QName('http://read.84000.co/ns/1.0', 'updated') } {
        
            attribute node { 'add-tei-element' },   
            
            (: Add before or after :)
            if($new-element-relation eq 'before') then
                update insert $new-element preceding $sibling
            else 
                update insert $new-element following $sibling
                
        }
        
};

declare function update-tei:comment($tei as element(tei:TEI), $passage-id as xs:string, $comment as xs:string) as element()? {

    let $passage-id-parsed := replace($passage-id, '^node\-', '')
    let $current-tei := $tei//*[(@xml:id, @tid) = $passage-id-parsed]
    let $comment-sanitised := replace(normalize-space($comment), '\-+', '-')
    let $new-tei := 
        element { node-name($current-tei) } {
            $current-tei/@*,
            $current-tei/text() | $current-tei/*,
            if($comment-sanitised gt '') then
                comment {
                    concat(' ', $comment-sanitised, ' ')
                }
            else ()
        }
    
    where 
        not(tei-content:locked-by-user($tei) gt '')
        and $current-tei
    return
        element { QName('http://read.84000.co/ns/1.0', 'updated') } {
        
            attribute node { 'tei-comment' },
            
            (: Update directly to ensure change is detected :)
            update replace $current-tei with $new-tei
            
        }
};

declare function update-tei:archive-latest($tei as element(tei:TEI)) as element()? {
    
    (: Archive path is tei/toh-key/current-date-time :)
    let $toh-key := translation:toh-key($tei, '')
    let $document-url := tei-content:document-url($tei)
    let $file-name := util:unescape-uri(replace($document-url, ".+/(.+)$", "$1"), 'UTF-8')

    where $toh-key and $file-name
    
        let $archive-path := concat($common:archive-path, '/', 'tei')
        let $store-folder := concat($toh-key, '/', format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]_[H01]-[m01]-[s01]'))
        let $store-path := concat($archive-path, '/', $store-folder)
        let $store-file-uri := xs:anyURI(concat($store-path, '/', $file-name))
        
        let $document :=
            document {
                <?xml-model href="../../../../tei/schema/current/translation.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>,
                $tei
            }
        
        let $create-collection := xmldb:create-collection($archive-path, $store-folder)
        let $store-file := xmldb:store($store-path, $file-name, $document, 'application/xml')
        let $set-file-group:= sm:chgrp($store-file-uri, 'dba')
        let $set-file-permissions:= sm:chmod($store-file-uri, 'rw-rw-r--')
        
        return
            <stored xmlns="http://read.84000.co/ns/1.0">{ $store-file }</stored>
};
