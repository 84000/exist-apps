module namespace update-translation = "http://operations.84000.co/update-translation";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace sponsors = "http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors = "http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace sponsorship = "http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace translation-status = "http://read.84000.co/translation-status" at "translation-status.xql";
import module namespace store = "http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

import module namespace functx = "http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

declare function update-translation:minor-version-increment($tei as element(tei:TEI), $form-action as xs:string) as element()* {
    
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
    
    return
        common:update('add-note', (), $note, $tei//tei:fileDesc/tei:notesStmt, ())

};

declare function update-translation:publication-status($tei as element(tei:TEI)) as element()* {
    
    let $request-parameter-names := request:get-parameter-names()
    
    (: exist:batch-transaction should defer triggers until all updates are made :)
    return
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
                    attribute {'status'} {$request-status},
                    
                    (: Copy any other attributes :)
                    $existing-value/@*[not(name(.) eq 'status')],
                    
                    (: Copy any other nodes :)
                    $existing-value/*[not(self::tei:date)],
                    
                    (: Set the date :)
                    element {QName("http://www.tei-c.org/ns/1.0", "date")} {
                        text {$request-publication-date}
                    }
                    
                }
                
                let $existing-status := $existing-value/@status/string()
                let $existing-publication-date := $existing-value/tei:date/string()
                    
                    where $parent and ($request-status ne $existing-status or $request-publication-date ne $existing-publication-date)
                return
                    
                    let $do-update := common:update('publication-statement', $existing-value, $new-value, $parent, $insert-following)
                    
                    return
                        (
                        
                        $do-update,
                        
                        (: Add the note - if it's a status update :)
                        if ($do-update[self::m:updated] and $request-status ne $existing-status) then
                            local:add-note($tei, 'translation-status', $request-status, $request-status)
                        else
                            ()
                        )
            else
                ()
                
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
                
                return
                    (
                    
                    $do-publication-statement-update,
                    $do-update,
                    
                    (: Add the note :)
                    if ($do-update[self::m:updated]) then
                        local:add-note($tei, 'text-version', $version-number-str, $update-notes)
                    else
                        ()
                    )
        
        
        } (: close exist:batch-transaction :)
};

declare function update-translation:title-statement($tei as element(tei:TEI)) as element()* {
    
    let $parent := $tei/tei:teiHeader/tei:fileDesc
    let $existing-value := $parent/tei:titleStmt
    
    let $container-ws := $existing-value/preceding-sibling::text()[1]
    let $node-ws := $existing-value/tei:*[1]/preceding-sibling::text()
    
    let $form-action := request:get-parameter('form-action', '')
    
    let $new-value :=
    (: titleStmt :)
    element {node-name($existing-value)} {
        
        (: titleStmt attributes :)
        $existing-value/@*,
        
        if ($form-action eq 'update-titles') then
            
            (: Add all the titles from the request :)
            for $title-text-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'title-text-')], '-')
            let $title-index := substring-after($title-text-param, 'title-text-')
            let $title-text := request:get-parameter($title-text-param, '')
            let $title-type := request:get-parameter(concat('title-type-', $title-index), '')
            let $title-lang := request:get-parameter(concat('title-lang-', $title-index), '')
                where $title-text gt ''
            return
                (
                (: Add whitespace before node :)
                $node-ws,
                (: Add title node :)
                element {QName("http://www.tei-c.org/ns/1.0", "title")} {
                    attribute type {$title-type},
                    attribute xml:lang {$title-lang},
                    text {
                        if ($title-lang eq 'Sa-Ltn') then
                            replace($title-text, '\-', '­')
                        else
                            $title-text
                    }
                }
                )
        
        else
            
            (: Just copy them :)
            for $existing-node in $existing-value/*[self::tei:title]
            return
                (
                $node-ws,
                $existing-node
                )
        ,
        
        if ($form-action eq 'update-contributors') then
            (
            
            (: Add all the contributors from the request :)
            
            (: Translator main :)
            let $translator-team-id := request:get-parameter('translator-team-id', '')
                
                where $translator-team-id gt ''
            return
                (
                $node-ws,
                element {QName("http://www.tei-c.org/ns/1.0", "author")} {
                    
                    attribute role {'translatorMain'},
                    attribute ref {$translator-team-id},
                    
                    (: Carry over the text :)
                    if ($existing-value/tei:author[@role eq 'translatorMain'][@ref eq $translator-team-id]) then
                        $existing-value/tei:author[@role eq 'translatorMain']/node()
                    else
                        ()
                }
                )
            ,
            
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
                $contributors:contributors//m:person[@xml:id eq substring-after($contributor-id, 'contributors.xml#')]/m:label/text()
                
                where $contributor-id gt '' and $contributor-node-name and $contributor-role
            return
                (
                $node-ws,
                element {QName("http://www.tei-c.org/ns/1.0", $contributor-node-name)} {
                    attribute role {$contributor-role},
                    attribute ref {$contributor-id},
                    text {$contributor-expression}
                }
                )
            )
        else
            (: Just copy them :)
            for $existing-node in $existing-value/*[self::tei:author | self::tei:editor | self::tei:consultant]
            return
                (
                $node-ws,
                $existing-node
                )
        ,
        if ($form-action eq 'update-sponsorship') then
            (
            
            (: Add all the sponsors from the request :)
            for $sponsor-id-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'sponsor-id-')], '-')
            
            let $sponsor-index := substring-after($sponsor-id-param, 'sponsor-id-')
            let $sponsor-id := request:get-parameter($sponsor-id-param, '')
            let $sponsor-expression := request:get-parameter(concat('sponsor-expression-', $sponsor-index), '')
            let $sponsor-expression :=
            if ($sponsor-expression gt '') then
                $sponsor-expression
            else
                $sponsors:sponsors//m:sponsor[@xml:id eq substring-after($sponsor-id, 'sponsors.xml#')]/m:label/text()
                
                where $sponsor-id gt ''
            return
                (
                $node-ws,
                element {QName("http://www.tei-c.org/ns/1.0", "sponsor")} {
                    attribute ref {$sponsor-id},
                    text {$sponsor-expression}
                }
                )
            )
        else
            (: Just copy them :)
            for $existing-node in $existing-value/*[self::tei:sponsor]
            return
                (
                $node-ws,
                $existing-node
                )
        ,
        (: Copy anything else in case there are comments or something :)
        for $existing-node in $existing-value/*[not(. instance of text())][not(self::tei:title | self::tei:author | self::tei:editor | self::tei:consultant | self::tei:sponsor)]
        return
            (
            $node-ws,
            $existing-node
            )
        ,
        $container-ws
    }
        
        where $parent and ($existing-value or $new-value)
    return
        (# exist:batch-transaction #) {
            
            (: Increment the version number - do first so it can evaluate the change :)
            if (not(deep-equal($existing-value, $new-value))) then
                update-translation:minor-version-increment($tei, $form-action)
            else
                ()
            ,
            
            (: Do the update :)
            common:update($form-action, $existing-value, $new-value, $parent, ())
            
            (:(
                element update-debug {
                    element existing-value { $existing-value }, 
                    element new-value { $new-value }, 
                    element parent { $parent }
                }
            ):)
            
        }
};

declare function update-translation:project($text-id as xs:string) as element()* {
    
    let $parent := $sponsorship:data/m:sponsorship
    
    let $existing-value := $parent/m:project[@id eq request:get-parameter('sponsorship-project-id', '')]
    
    let $new-value := sponsorship:project-posted($text-id)
        
        where $parent and ($existing-value or $new-value)
    return
        (: Do the update :)
        common:update('update-translation-project', $existing-value, $new-value, $parent, ())
        (:(
            element update-debug {
                element existing-value { $existing-value }, 
                element new-value { $new-value }, 
                element parent { $parent }
            }
        ):)

};

declare function update-translation:locations($tei as element(tei:TEI)) as element()* {
    
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
        
        return
            (
            
            (: add bibl whitespace :)
            if ($bibl-index gt 1) then
                $bibl-ws
            else
                (),
            
            (: bibl :)
            element {node-name($bibl)} {
                $bibl/@*,
                
                (: These nodes precede :)
                $bibl/tei:location[1]/preceding-sibling::node(),
                
                (: location :)
                element {QName("http://www.tei-c.org/ns/1.0", "location")} {
                    attribute work {request:get-parameter(concat('work-', $toh-key), '0')},
                    attribute count-pages {request:get-parameter(concat('count-pages-', $toh-key), '0')},
                    
                    for $volume-key at $volume-index in $volume-keys
                    let $volume-number := request:get-parameter(concat('volume-', $toh-key, '-', $volume-key), '0')
                        where $volume-number gt '0'
                    return
                        (
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
                
                (: In case we add other nodes or comments :)
                $bibl/tei:location[last()]/following-sibling::node()
            }
            ),
        (: In case we add other nodes or comments :)
        $existing-value/tei:bibl[last()]/following-sibling::node()
    }
        
        where $parent and ($existing-value or $new-value)
    return
        (# exist:batch-transaction #) {
            
            (: Increment the version number - do first so it can evaluate the change :)
            if (not(deep-equal($existing-value, $new-value))) then
                update-translation:minor-version-increment($tei, 'update-locations')
            else
                ()
            ,
            
            (: Do the update :)
            common:update('update-translation-locations', $existing-value, $new-value, $parent, $insert-following)
            
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

declare function update-translation:update-glossary($tei as element(tei:TEI), $glossary-id as xs:string) as element()* {
    
    (: To create a new item pass a $glossary-id that is unused :)
    
    let $parent := $tei//tei:back//tei:list[@type eq 'glossary']
    
    (: Look for an existing item :)
    let $existing-item := $parent/tei:item[tei:gloss/@xml:id eq $glossary-id]
    
    (: If it's an update and the main term is '' then don't construct the new value e.g. remove existing :)
    let $remove := (request:get-parameter('form-action', '') eq 'update-glossary' and request:get-parameter('term-main-text-1', '') eq '')
    
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
                        attribute type {request:get-parameter('glossary-type', '')}
                    else
                        $existing-item/tei:gloss/@type
                    ,
                    
                    (: @mode :)
                    if (request:get-parameter('glossary-mode', 'match') = $glossary:modes) then
                        attribute mode {request:get-parameter('glossary-mode', 'match')}
                    else
                        $existing-item/tei:gloss/@mode
                    ,
                        
                    (: Get the terms from the request :)
                    for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-main-text-')], '-')
                    let $term-index := substring-after($term-param, 'term-main-text-')
                    let $term-text := request:get-parameter($term-param, '')
                    let $term-lang := common:valid-lang(request:get-parameter(concat('term-main-lang-', $term-index), ''))
                        where $term-text gt ''
                    return(
                        common:ws(7),
                        element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                            if ($term-lang gt '' and not($term-lang eq 'en')) then
                                attribute xml:lang {$term-lang}
                            else
                                ()
                            ,
                            text {$term-text}
                        }
                    ),
                        
                    (: Get the alternatives from the request :)
                    for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-alternative-text-')], '-')
                    let $term-index := substring-after($term-param, 'term-alternative-text-')
                    let $term-text := request:get-parameter($term-param, '')
                    let $term-lang := common:valid-lang(request:get-parameter(concat('term-alternative-lang-', $term-index), ''))
                        where $term-text gt ''
                    return (
                        common:ws(7),
                        element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                            attribute type {'alternative'},
                            if ($term-lang gt '' and not($term-lang eq 'en')) then
                                attribute xml:lang {$term-lang}
                            else()
                            ,
                            text {$term-text}
                        }
                    ),
                        
                    (: Get the definitions from the request :)
                    for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-definition-text-')], '-')
                    let $term-text := request:get-parameter($term-param, '')
                    let $term-text-markup := common:markup($term-text, 'http://www.tei-c.org/ns/1.0')
                        where $term-text gt '' and $term-text-markup
                    return (
                        common:ws(7),
                        element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                            attribute type {'definition'},
                            $term-text-markup
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
                    
                    (: end of gloss :)
                    common:ws(6)
                
                },
                
                (: end of item :)
                common:ws(5)
            }
        else
            ()
    
    let $insert-following := $existing-item/preceding-sibling::tei:item[1]
        
    where $parent and ($existing-item or $new-value)
    return (
        (: Do the update :)
        common:update('glossary-item', $existing-item, $new-value, $parent, $insert-following),
        
        (: If we are removing then also remove the entity instance and refresh the cache :)
        if ($remove) then (
            update-translation:cache-glossary($tei, 'none'),
            entities:remove-instance($glossary-id)
        )
        else
            ()
            
            (:element debug {
                attribute form-action { request:get-parameter('form-action', '') },
                attribute term-main-text-1 { request:get-parameter('term-main-text-1', '') },
                attribute glossary-id { $glossary-id },
                element existing-value { $existing-item }, 
                element new-value { $new-value }(\:, 
                element parent { $parent }, 
                element insert-following { $insert-following }:\)
            }:)
    )
};

declare function update-translation:cache-glossary($tei as element(tei:TEI), $glossary-id as xs:string*) as element()* {
    
    (: 
        Pass $glossary-ids to refresh cache for particular items
        - or 'uncached' to select those with no cache
        - or () to select all
        - or 'none' will select none just re-index
    :)
    
    (: Existing cache :)
    let $cache := translation:cache($tei, true())
    let $glossary-cache := $cache/m:glossary-cache
    
    (: TEI glossary items :)
    let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]
    
    let $refresh-ids :=
        if ($glossary-id eq 'uncached') then
            $tei-glossary[not(@xml:id = $glossary-cache/m:gloss[m:location]/@id)]/@xml:id
        else if (count($glossary-id) gt 0) then
            $tei-glossary[@xml:id = $glossary-id]/@xml:id
        else
            'all'
    
    let $glossary-cache-new := translation:glossary-cache($tei, $refresh-ids, true())
    
    let $do-caching := common:update('cache-glossary', $glossary-cache, $glossary-cache-new, $cache, $glossary-cache/preceding-sibling::*[1])
    
    let $set-cache-version := store:store-version-str(concat($common:data-path, '/cache'), concat(tei-content:id($tei), '.cache'), tei-content:version-str($tei))
    
    return
        (:element debug { $glossary-cache-new }:)
        $do-caching
        


};
