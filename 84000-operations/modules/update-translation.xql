module namespace update-translation = "http://operations.84000.co/update-translation";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace sponsors = "http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors = "http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace sponsorship = "http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace functx = "http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function update-translation:publication-status($tei as element(tei:TEI)) as element()* {
    
    (: exist:batch-transaction should defer triggers until all updates are made :)
    (# exist:batch-transaction #) {
        
        let $text-id := tei-content:id($tei)
        
        return
            (: The updates have to follow in the correct order e.g. input-1, input-2... :)
            for $request-parameter in request:get-parameter-names()[. = ('text-version', 'publication-date', 'translation-status')]
            
                (: Get the new value :)
                let $new-value :=
                
                    (: Version :)
                    if ($request-parameter eq 'text-version') then
                            
                        let $set-default := request:set-attribute('text-version', 'v 0.1.0')
                        let $set-default := request:set-attribute('text-version-date', format-dateTime(current-dateTime(), '[Y]'))
                        let $set-default := request:set-attribute('update-notes', common:get-parameter('text-version'))
                        
                        return
                            element {QName("http://www.tei-c.org/ns/1.0", "editionStmt")} {
                                element edition {
                                    text { common:get-parameter('text-version') || ' '},
                                    element date {
                                        text { common:get-parameter('text-version-date') }
                                    }
                                }
                            }
                
                    (: Publication date :)
                    else if ($request-parameter eq 'publication-date') then
                        
                        let $publication-date := request:get-parameter('publication-date', '')
                        let $set-default := request:set-attribute('update-notes', $publication-date)
                        
                        return
                            element { QName("http://www.tei-c.org/ns/1.0", "date") } {
                                text { $publication-date }
                            }
                    
                    (: Attributes: translation status :)
                    else if ($request-parameter = ('translation-status')) then
                        let $request-status := request:get-parameter($request-parameter, '')
                        (: force zero to '' :)
                        let $request-status := 
                            if ($request-status eq '0') then
                                ''
                            else
                                $request-status
                        (: set attribute for later :)
                        let $set-default := request:set-attribute('update-notes', $request-status)
                        return
                            attribute {'status'} { $request-status }
                                     
                    (: Default to a string value :)
                    else
                        ()
                                    
                (: Get the context so we can add :)
                let $parent :=
                    if ($request-parameter eq 'text-version') then
                        $tei//tei:fileDesc
                    else if ($request-parameter eq 'publication-date') then
                        $tei//tei:fileDesc/tei:publicationStmt
                    else if ($request-parameter eq 'translation-status') then
                        $tei//tei:fileDesc/tei:publicationStmt
                    else
                        ()
                                
                (: Get the existing value so we can compare / replace :)
                let $existing-value :=
                    if ($request-parameter eq 'text-version') then
                        $parent/tei:editionStmt
                    else if ($request-parameter eq 'publication-date') then
                        $parent/tei:date
                    else if ($request-parameter eq 'translation-status') then
                        $parent/@status
                    else
                        ()
                                
                 (: Specify a location to add it to if necessary :)
                 let $insert-following :=
                    if ($request-parameter eq 'text-version') then
                        $parent/tei:titleStmt
                    else if ($request-parameter eq 'publication-date') then
                        $parent/tei:idno[last()]
                    else
                        ()
                
                (: Define a note to add to notesStmt :)
                let $add-note :=
                    element {QName("http://www.tei-c.org/ns/1.0", "note")} {
                        attribute type {'updated'},
                        attribute update {$request-parameter},
                        attribute value {common:get-parameter($request-parameter)},
                        attribute date-time {current-dateTime()},
                        attribute user {common:user-name()},
                        text {common:get-parameter('update-notes')}
                    }
                
                where $existing-value or $new-value
            return
                (: Do the update :)
                let $do-update := common:update($request-parameter, $existing-value, $new-value, $parent, $insert-following)
                return (
                    $do-update,
                
                    (: Add the note :)
                    if ($do-update[self::m:updated]) then
                        common:update('add-note', (), $add-note, $tei//tei:fileDesc/tei:notesStmt, ())
                    else
                        ()
                 )
            (:element update-debug {
                element request-parameter { $request-parameter }, 
                element existing-value { $existing-value }, 
                element new-value { $new-value }, 
                element parent { $parent }, 
                element insert-following { $insert-following }
            }:)
    
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
        element { node-name($existing-value) } {
            
            (: titleStmt attributes :)
            $existing-value/@*,
            
            if($form-action eq 'update-titles') then
            
                (: Add all the titles from the request :)
                for $title-text-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'title-text-')], '-')
                    let $title-index := substring-after($title-text-param, 'title-text-')
                    let $title-text := request:get-parameter($title-text-param, '')
                    let $title-type := request:get-parameter(concat('title-type-', $title-index), '')
                    let $title-lang := request:get-parameter(concat('title-lang-', $title-index), '')
                where $title-text gt ''
                return (
                    (: Add whitespace before node :)
                    $node-ws,
                    (: Add title node :)
                    element {QName("http://www.tei-c.org/ns/1.0", "title")} {
                        attribute type {$title-type},
                        attribute xml:lang {$title-lang},
                        text {$title-text}
                    }
                )
                
            else
                
                (: Just copy them :)
                for $existing-node in $existing-value/*[self::tei:title]
                return (
                    $node-ws,
                    $existing-node
                )
            ,
            
            if($form-action eq 'update-contributors') then (
            
                (: Add all the contributors from the request :)
                
                (: Translator main :)
                let $translator-team-id := request:get-parameter('translator-team-id', '')
                
                where $translator-team-id gt ''
                return (
                    $node-ws,
                    element {QName("http://www.tei-c.org/ns/1.0", "author")} {
                    
                        attribute role { 'translatorMain' },
                        attribute ref { $translator-team-id },
                        
                        (: Carry over the text :)
                        if($existing-value/tei:author[@role eq 'translatorMain'][@ref eq $translator-team-id]) then
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
                return (
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
                return (
                    $node-ws,
                    $existing-node
                )
            ,
            if($form-action eq 'update-sponsorship') then (
                
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
                return (
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
        
    where $existing-value or $new-value
    return
        (: Do the update :)
        common:update($form-action, $existing-value, $new-value, $parent, ())
        (:(
            element update-debug {
                element existing-value { $existing-value }, 
                element new-value { $new-value }, 
                element parent { $parent }
            }
        ):)
};

declare function update-translation:project($text-id as xs:string) as element()* {
    
    let $parent := $sponsorship:data/m:sponsorship
    
    let $existing-value := $parent/m:project[@id eq request:get-parameter('sponsorship-project-id', '')]
    
    let $new-value := sponsorship:project-posted($text-id)
        
        where $existing-value or $new-value
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
        
        return (
            
            (: add bibl whitespace :)
            if($bibl-index gt 1) then 
                $bibl-ws
            else
                (),
            
            (: bibl :)
            element {node-name($bibl)} {
                $bibl/@*,
                
                (: These nodes precede :)
                $bibl/tei:location[1]/preceding-sibling::node(),
                
                (: location :)
                element { QName("http://www.tei-c.org/ns/1.0", "location") } {
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
                            element { QName("http://www.tei-c.org/ns/1.0", "volume") } {
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
        
        where $existing-value or $new-value
    return
        (: Do the update :)
        common:update('update-translation-locations', $existing-value, $new-value, $parent, $insert-following)
        (:(
            element update-debug {
                element existing-value { $existing-value }, 
                element new-value { $new-value }, 
                element parent { $parent }
            }
        ):)

};


declare function update-translation:update-glossary($tei as element(tei:TEI), $glossary-id as xs:string) as element()* {
    
    (: To create a new item pass a $glossary-id that is unused :)
    
    let $parent := $tei//tei:back//tei:list[@type eq 'glossary']
    
    (: Look for an existing item :)
    let $existing-value := $parent/tei:item[tei:gloss/@xml:id eq $glossary-id]
    
    (: Only construct the new value if there's an id :)
    let $new-value := 
        if(
            (: Only construct the new value if it's existing or it's a valid id :)
            $existing-value or tei-content:valid-xml-id($tei, $glossary-id)
            
            (: If it's an update and the main term is '' then don't construct the new value e.g. delete existing :)
            and not(request:get-parameter('form-action', '') eq 'update-glossary' and request:get-parameter('term-main-text-1', '') eq '')
        ) then
            element { QName('http://www.tei-c.org/ns/1.0', 'item') } {
                $existing-value/@*,
                common:ws(6),
                element { QName('http://www.tei-c.org/ns/1.0', 'gloss') } {
                    
                    (: Update glossary item :)
                    if (request:get-parameter('form-action', '') eq 'update-glossary') then (
                        
                        (: @xml:id :)
                        attribute xml:id { $glossary-id },
                        
                        (: @type :)
                        if(request:get-parameter('glossary-type', '') = $glossary:types) then 
                            attribute type { request:get-parameter('glossary-type', '') }
                        else
                            $existing-value/tei:gloss/@type
                        ,
                        
                        (: @mode :)
                        if(request:get-parameter('glossary-mode', '') = $glossary:modes) then 
                            attribute mode { request:get-parameter('glossary-mode', '') }
                        else
                            $existing-value/tei:gloss/@mode
                        ,
                        
                        (: Get the terms from the request :)
                        for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-main-text-')], '-')
                        let $term-index := substring-after($term-param, 'term-main-text-')
                        let $term-text := request:get-parameter($term-param, '')
                        let $term-lang := common:valid-lang(request:get-parameter(concat('term-main-lang-', $term-index), ''))
                        where $term-text gt ''
                        return (
                            common:ws(7),
                            element { QName('http://www.tei-c.org/ns/1.0', 'term') } {(
                                if($term-lang gt '' and not($term-lang eq 'en')) then
                                    attribute xml:lang { $term-lang }
                                else ()
                                ,
                                text{ $term-text }
                            )}
                        ),
                        
                        (: Get the alternatives from the request :)
                        for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-alternative-text-')], '-')
                        let $term-index := substring-after($term-param, 'term-alternative-text-')
                        let $term-text := request:get-parameter($term-param, '')
                        let $term-lang := common:valid-lang(request:get-parameter(concat('term-alternative-lang-', $term-index), ''))
                        where $term-text gt ''
                        return (
                            common:ws(7),
                            element { QName('http://www.tei-c.org/ns/1.0', 'term') } {(
                                attribute type { 'alternative' },
                                if($term-lang gt '' and not($term-lang eq 'en')) then
                                    attribute xml:lang { $term-lang }
                                else ()
                                ,
                                text{ $term-text }
                            )}
                        ),
                        
                        (: Get the definitions from the request :)
                        for $term-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-definition-text-')], '-')
                        let $term-text := request:get-parameter($term-param, '')
                        let $term-text-markup := common:markup($term-text, 'http://www.tei-c.org/ns/1.0')
                        where $term-text gt '' and $term-text-markup
                        return (
                            common:ws(7),
                            element { QName('http://www.tei-c.org/ns/1.0', 'term') } {(
                                attribute type { 'definition' },
                                $term-text-markup
                            )}
                        ),
                        
                        (: Copy other nodes :)
                        for $node in $existing-value/tei:gloss/*[not(self::tei:term)]
                        return (
                            common:ws(7),
                            $node
                        ),
                        
                        (: end of gloss :)
                        common:ws(6)
                    )
                    
                    (: Update cache (expression locations) :)
                    else if (request:get-parameter('form-action', '') eq 'cache-expressions') then (
                        
                        (: Copy other nodes :)
                        $existing-value/tei:gloss/@*,
                        for $node in $existing-value/tei:gloss/*[not(self::m:cache)]
                        return (
                            common:ws(7),
                            $node
                        ),
                        
                        (: Add an eft:cache node :)
                        (
                            common:ws(7),
                            element { QName('http://read.84000.co/ns/1.0', 'cache') } {(
                            
                                (: Add each expression-location from the request :)
                                for $expression-location in request:get-parameter('expression-location[]', '')
                                return (
                                    common:ws(8),
                                    element expression {
                                        attribute location {$expression-location}
                                    }
                                ),
                                
                                (: end of cache :)
                                common:ws(7)
                                
                            )}
                        ),
                        
                        (: end of gloss :)
                        common:ws(6)
                    )
                    
                    (: Default: copy :)
                    else (
                        $existing-value/tei:gloss/@*,
                        $existing-value/tei:gloss/node()
                    )
                        
                },
                
                (: end of item :)
                common:ws(5)
            }
        else ()
    
    let $insert-following := $existing-value/preceding-sibling::tei:item[1]
    
    where $existing-value or $new-value
    return
        (: Do the update :)
        common:update('glossary-item', $existing-value, $new-value, $parent, $insert-following)
        
        (:element update-debug {
            attribute glossary-id { $glossary-id },
            element existing-value { $existing-value }, 
            element new-value { $new-value }, 
            element parent { $parent }, 
            element insert-following { $insert-following }
        }:)

};
