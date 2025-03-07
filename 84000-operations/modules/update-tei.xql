module namespace update-tei = "http://operations.84000.co/update-tei";

import module namespace update-entity = "http://operations.84000.co/update-entity" at "update-entity.xql";
import module namespace translation-status = "http://operations.84000.co/translation-status" at "translation-status.xql";
import module namespace helper="http://operations.84000.co/helper" at "helper.xql";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace sponsors = "http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors = "http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace knowledgebase = "http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace store = "http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

import module namespace functx = "http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $update-tei:blocking-jobs := scheduler:get-scheduled-jobs()//scheduler:job[@name = ('cache-glossary-locations', 'auto-assign-entities')][not(scheduler:trigger/state/text() eq 'COMPLETE')];

declare function update-tei:minor-version-increment($tei as element(tei:TEI), $note as xs:string) {
    update-tei:minor-version-increment($tei, $note, ())
};

declare function update-tei:minor-version-increment($tei as element(tei:TEI), $note as xs:string, $version-number-str as xs:string?) as node()* {
    
    (: Force a minor version increment:)
    let $version-number-str-increment := 
        if(not($version-number-str gt '')) then
            tei-content:version-number-str-increment($tei, 'revision')
        else
            $version-number-str
            
    let $text-id := tei-content:id($tei)
    
    let $editionStmt-new :=
        element {QName("http://www.tei-c.org/ns/1.0", "editionStmt")} {
            common:ws(4) ,
            element edition {
                text {'v ' || $version-number-str-increment || ' '},
                element date {
                    text { format-date(current-date(), '[Y]') }
                }
            },
            common:ws(3)
        }
    
    where not(tei-content:locked-by-user($tei) gt '')
    return (
    
        (: Do the update :)
        common:update('text-version', $tei//tei:fileDesc/tei:editionStmt, $editionStmt-new, (), $tei//tei:fileDesc/tei:titleStmt),
        
        (: Add a change :)
        update-tei:add-change($tei, 'text-version', $version-number-str-increment, $note),
        
        util:log('info', concat('update-tei-minor-version-increment:', $text-id))
        
    )

};

declare function local:add-note($tei as element(tei:TEI), $update as xs:string, $value as xs:string, $note as xs:string?) as element()* {
    
    let $note :=
        element {QName("http://www.tei-c.org/ns/1.0", "note")} {
            attribute type {'updated'},
            attribute update {$update},
            attribute value {$value},
            attribute date-time { current-dateTime() },
            attribute user { common:user-name() },
            text {
                if ($note) then
                    $note
                else
                    $value
            }
        }
        
    where not(tei-content:locked-by-user($tei) gt '')
    return 
        if($tei//tei:fileDesc/tei:notesStmt[tei:note]) then
            update insert ( common:ws(4), $note) following $tei//tei:fileDesc/tei:notesStmt/tei:note[last()]
        else
            update insert ( common:ws(4), $note, common:ws(3) ) into $tei//tei:fileDesc/tei:notesStmt

};

declare function update-tei:add-change($tei as element(tei:TEI), $type as xs:string, $status as xs:string?, $note as xs:string?) as element()* {
    
    let $change :=
        element {QName("http://www.tei-c.org/ns/1.0", "change")} {
            attribute who { '#' || common:user-name() },
            attribute when { current-dateTime() },
            attribute type { $type },
            attribute status { $status },
            attribute xml:id { tei-content:next-xml-id($tei) },
            common:ws(5),
            element desc { ($note, $status)[1] },
            common:ws(4)
        }
    
    where not(tei-content:locked-by-user($tei) gt '')
    return 
        (: Add a change :)
        if($tei//tei:fileDesc/tei:revisionDesc[tei:change]) then
            update insert ( common:ws(4), $change ) following $tei//tei:fileDesc/tei:revisionDesc/tei:change[last()]
        
        else (
            
            (: Add a revisionDesc :)
            if($tei//tei:fileDesc[not(tei:revisionDesc)]) then
                update insert ( common:ws(3), element { QName('http://www.tei-c.org/ns/1.0', 'revisionDesc') } {}, common:ws(2) ) into $tei//tei:fileDesc
            else (),
            
            (: Add a change :)
            update insert ( common:ws(4), $change, common:ws(3) ) into $tei//tei:fileDesc/tei:revisionDesc
            
        )
        
};

declare function update-tei:publication-status($tei as element(tei:TEI)) as element()* {
    
    let $request-parameter-names := request:get-parameter-names()
    
    let $text-id := tei-content:id($tei)
    let $document-url := base-uri($tei)
    
    where not(tei-content:locked-by-user($tei) gt '')
    return
        (: exist:batch-transaction should defer triggers until all updates are made :)
        (# exist:batch-transaction #) {
            
            let $fileDesc := $tei//tei:fileDesc
            
            (: tei:publicationStmt/tei:availability/@status :)
            let $availability := $fileDesc/tei:publicationStmt/tei:availability
            let $do-publication-status-update :=
                if($availability and $request-parameter-names = 'translation-status') then
                    
                    let $existing-status := $availability/@status
                    (: Translation status :)
                    let $request-status := request:get-parameter('translation-status', '')
                    (: Force zero to '' :)
                    let $request-status := if ($request-status eq '0') then '' else $request-status
                    let $new-status := attribute status { $request-status }
                    
                    where $availability and not($request-status eq $existing-status/string())
                    return (
                        common:update('publication-status', $existing-status, $new-status, $availability, ()),
                        update-tei:add-change($tei, 'translation-status', $request-status, $request-status)
                    )
                else ()
             
             (: tei:publicationStmt/tei:date :)
             let $publicationStmt := $fileDesc/tei:publicationStmt
             let $do-publication-date-update :=
                if($publicationStmt and $request-parameter-names = 'publication-date') then
                    
                    let $existing-publication-date := $publicationStmt/tei:date
                    
                    (: Publication date :)
                    let $request-publication-date := request:get-parameter('publication-date', '')
                    
                    let $new-publication-date :=
                        element {QName("http://www.tei-c.org/ns/1.0", "date")} {
                            text { $request-publication-date }
                        }
                    
                    where $publicationStmt and ($request-publication-date ne $existing-publication-date/string())
                    return
                        common:update('publication-date', $existing-publication-date, $new-publication-date, $publicationStmt, $publicationStmt/tei:idno[last()])
                        
                else ()
            
            (: Get the current version number from the TEI :)
            let $existing-version-number-str := tei-content:version-number-str($tei)
            (: Make a comparable string from the request :)
            let $request-version-number-str := tei-content:strip-version-number(request:get-parameter('text-version', ''))
            (: Test if it's a new version :)
            let $request-is-current-version := tei-content:is-current-version($existing-version-number-str, $request-version-number-str)
            
            (: Force a version update if there was a change to the publicationStmt :)
            where $do-publication-status-update[self::m:updated] or $do-publication-date-update[self::m:updated] or not($request-is-current-version)
            return
            
                let $update-notes := request:get-parameter('update-notes', '') ! normalize-space()
                let $update-notes :=
                    (: It's a forced update :)
                    if (not($update-notes gt '') and $request-is-current-version) then
                        'Auto (update-publication-status)'
                        
                    (: It's a requested update :)
                    else if(not($update-notes gt '')) then
                        concat('User set version to ', $request-version-number-str)
                        
                    (: The user defined a note :)
                    else
                        $update-notes
                
                let $do-version-increment := 
                    (: No increment was requested, but doing one anyway :)
                    if($request-is-current-version) then
                        update-tei:minor-version-increment($tei, $update-notes, ())
                    
                    (: Increment was requested :)
                    else
                        update-tei:minor-version-increment($tei, $update-notes, $request-version-number-str)
                
                return (
                    
                    $do-publication-status-update,
                    $do-publication-date-update,
                    $do-version-increment,
                    
                    (: Push to Github & push to static site :)
                    if($store:conf) then (
                        
                        deploy:push('data-tei', (), concat($text-id, ' / ',  $request-version-number-str), $document-url)(:,
                        
                        (\: store-publication-files for unpublished texts :\)
                        if($availability[not(@status = $translation:published-status-ids)]) then
                            
                            let $schedule-publication := 
                                helper:async-script(
                                    'store-publication-files',
                                    string-join(('store-publication-files', $text-id), '-'),
                                    <parameters xmlns="">
                                        <param name="resource-id" value="{ $text-id }"/>
                                        <param name="publish-file-group" value="{ string-join(('translation-html','translation-files', 'publications-list'), ',') }"/>
                                    </parameters>
                                )
                                
                            return ()
                            
                        else ():)
                        
                    )
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
    let $title-key := request:get-parameter(concat('title-key-', $title-index), '')
    let $title-lang := request:get-parameter(concat('title-lang-', $title-index), '')
    let $valid-lang := common:valid-lang(replace($title-lang, '\-r[ps]$', ''))
    
    where $title-text gt ''
    return
        element { QName("http://www.tei-c.org/ns/1.0", "title") } {
            attribute type { $title-type },
            attribute xml:lang { $valid-lang },
            if(lower-case($title-lang) eq 'sa-ltn-rp') then (
                attribute rend { 'reconstructedPhonetic' }
            )
            else if(lower-case($title-lang) eq 'sa-ltn-rs') then (
                attribute rend { 'reconstructedSemantic' }
            )
            else ()
            ,
            if($title-key gt '') then
                attribute key { $title-key }
            else ()
            ,
            text {
                (: Replace hyphens with soft-hypens :)
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
    let $title-statement-existing := $parent/tei:titleStmt
    
    let $text-id := tei-content:id($tei)
    let $max-xml-id-int := tei-content:max-xml-id-int($tei)
    
    let $container-ws := common:ws(3)
    let $node-ws := common:ws(4)
    
    let $form-action := request:get-parameter('form-action', 'update-titles', false())
    
    let $title-statement-new :=
    
        (: titleStmt :)
        element { node-name($title-statement-existing) } {
            
            (: titleStmt attributes :)
            $title-statement-existing/@*,
            
            (: Add titles - don't allow duplicates :)
            for $title in $titles
            let $title-text := $title/text()
            group by $title-text
            order by 
                if($title[1]/@type eq 'mainTitle') then 1 else if($title[1]/@type eq 'longTitle') then 2 else if($title[1]/@type eq 'otherTitle') then 3 else 4 ascending,
                if($title[1]/@xml:lang eq 'en') then 1 else if($title[1]/@xml:lang eq 'Sa-Ltn') then 2 else if($title[1]/@xml:lang eq 'bo') then 3 else 4 ascending,
                $title[1]/@xml:lang/string(),
                $title[1]/@key/string()
                
            where $title-text[not(. eq '')]
            return (
                $node-ws,
                $title[1]
            ),
            
            (: Add contributors :)
            if ($form-action eq 'update-contributors') then (
                
                for $contributor-id-param at $param-index in ('contributor-id-team', common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'contributor-id-')], '-')[not(. eq 'contributor-id-team')])
                    
                    let $contributor-index := substring-after($contributor-id-param, 'contributor-id-')
                    
                    let $contributor-id := request:get-parameter(concat('contributor-id-', $contributor-index), '')
                    let $contributor-target := $contributors:contributors/id($contributor-id)[self::m:person | self::m:team]
                    
                    let $contribution-id := request:get-parameter(concat('contribution-id-', $contributor-index), '')
                    let $contribution-existing := $title-statement-existing/id($contribution-id)[self::tei:author | self::tei:editor | self::tei:consultant]
                    let $contribution-instance-existing := $contributors:contributors//m:instance[@id eq $contribution-id]
                    let $contribution-id :=
                        if(not($contribution-existing)) then
                            tei-content:next-xml-id($text-id, sum(($max-xml-id-int, $param-index)))
                        else 
                            $contribution-id
                    
                    (: Derive element name and role from type :)
                    let $contribution-type := request:get-parameter(concat('contributor-type-', $contributor-index), '')
                    let $contribution-type-tokenized := tokenize($contribution-type, '-')
                    let $contribution-node-name := 
                        if($contributor-id-param eq 'contributor-id-team') then
                            'author'
                        else 
                            $contribution-type-tokenized[1]
                    
                    let $contribution-role :=
                        if($contributor-id-param eq 'contributor-id-team') then
                            'translatorMain'
                        else if (count($contribution-type-tokenized) eq 2) then
                            $contribution-type-tokenized[2]
                        else
                            ''
                    
                    let $contribution-expression := request:get-parameter(concat('contributor-expression-', $contributor-index), '')
                    
                    let $is-contribution := if($contribution-node-name gt '' and $contribution-role gt '' and $contributor-target) then true() else false()
                    
                    (: Move the instance record from existing entity to, or create one in, the target :)
                    (: This can happen independent of the update to the tei and doesn't require a new version of the text :)
                    let $update-instance :=
                        (: update-entity:move-instance performs move, or add :)
                        if($is-contribution) then
                            update-entity:move-instance($contribution-id, 'translation-contribution', $contribution-instance-existing, $contributor-target)
                        (: update-entity:move-instance removes instance if no target :)
                        else
                            update-entity:move-instance($contribution-id, 'translation-contribution', $contribution-instance-existing, ())
                    
                    return 
                        (: Record the contribution :)
                        if($is-contribution) then (
                            $node-ws,
                            element { QName("http://www.tei-c.org/ns/1.0", $contribution-node-name) } {
                                attribute role {$contribution-role},
                                attribute xml:id { $contribution-id },
                                
                                if ($contribution-expression gt '') then
                                    $contribution-expression
                                else if($contribution-existing[node()] and $contributor-target) then
                                    $contribution-existing/node()
                                else
                                    $contributor-target/m:label/text()
                                }
                        )
                        else ()
                
            )
            (: or just copy them :)
            else
                
                for $existing-node in $title-statement-existing/*[self::tei:author | self::tei:editor | self::tei:consultant]
                return (
                    $node-ws,
                    $existing-node
                )
            ,
        
            (: Add sponsors :)
            if ($form-action eq 'update-sponsorship') then (
                
                (: Add all the sponsors from the request :)
                for $sponsor-id-param at $param-index in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'sponsor-id-')], '-')
                
                let $sponsor-index := substring-after($sponsor-id-param, 'sponsor-id-')
                let $sponsor-id := request:get-parameter($sponsor-id-param, '')
                let $sponsorship-id := request:get-parameter(concat('sponsorship-id-', $sponsor-index), '')
                (: New xml:id for additions :)
                let $sponsorship-id :=
                    if(not($sponsorship-id gt '')) then
                        tei-content:next-xml-id($text-id, sum(($max-xml-id-int, $param-index)))
                    else 
                        $sponsorship-id
                
                let $sponsorship-instance-existing := $sponsors:sponsors//m:instance[@id eq $sponsorship-id]
                let $sponsor-target := $sponsors:sponsors/id($sponsor-id)[self::m:sponsor]
                
                let $sponsor-expression := request:get-parameter(concat('sponsor-expression-', $sponsor-index), '')
                let $sponsor-expression :=
                    if ($sponsor-expression gt '') then
                        $sponsor-expression
                    else
                        $sponsor-target/m:label/text()
                
                return (
                    
                    (: Move or assign the instance :)
                    update-entity:move-instance($sponsorship-id, 'translation-sponsor', $sponsorship-instance-existing, $sponsor-target),
                    
                    (: Add node to TEI :)
                    if($sponsor-id gt '') then (
                        $node-ws,
                        element {QName("http://www.tei-c.org/ns/1.0", "sponsor")} {
                            attribute xml:id { $sponsorship-id },
                            text { $sponsor-expression }
                        }
                    )
                    else ()
                    
                )
                
            )
            (: or just copy them :)
            else
                for $existing-node in $title-statement-existing/*[self::tei:sponsor]
                return (
                    $node-ws,
                    $existing-node
                 )
        ,
        
            (: Copy anything else in case there are comments or something :)
            for $existing-node in $title-statement-existing/*[not(. instance of text())][not(self::tei:title | self::tei:author | self::tei:editor | self::tei:consultant | self::tei:sponsor)]
            return (
                $node-ws,
                $existing-node
            ),
            
            $container-ws
        }
    
    let $title-statement-change := not(deep-equal($title-statement-existing, $title-statement-new))
    
    let $notes-statement-existing := $parent/tei:notesStmt
    
    let $notes-from-request :=
        for $titles-note-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'titles-note-text-')], '-')
        let $titles-note := request:get-parameter($titles-note-param, '') ! normalize-space(.)
        let $titles-note-index := substring-after($titles-note-param, 'titles-note-text-')
        let $titles-note-existing := $notes-statement-existing/tei:note[string-join(text()) ! normalize-space(.) eq $titles-note]
        let $titles-note-type := request:get-parameter(concat('titles-note-type-', $titles-note-index), '')
        where $titles-note gt ''
        return 
            element { QName("http://www.tei-c.org/ns/1.0", "note") } {
                attribute type { if($titles-note-type eq 'internal') then 'title-internal' else 'title' },
                attribute date-time { ($titles-note-existing/@date-time, current-dateTime())[1] },
                attribute user { ($titles-note-existing/@user, common:user-name())[1] },
                $titles-note-existing/@update ! attribute update { string() },
                $titles-note-existing/@import ! attribute import { string() },
                text { $titles-note }
            }
    
    let $notes-remainder := $notes-statement-existing/*[not(local-name(.) eq 'note' and @type = ('title', 'title-internal'))]
    
    let $notes-statement-new := 
        element { QName("http://www.tei-c.org/ns/1.0", "notesStmt") } {
        
            $notes-statement-existing/@*,
            
            $notes-from-request ! ($node-ws, .),
            $notes-remainder ! ($node-ws, .),
            if($notes-from-request or $notes-remainder) then $container-ws else ()
            
        }
    
    let $notes-statement-change := not(deep-equal($notes-statement-existing, $notes-statement-new))
    
    where not(tei-content:locked-by-user($tei) gt '')
    return 
        (# exist:batch-transaction #) {
            
            (: Update titles :)
            if($title-statement-change) then
                update replace $title-statement-existing with $title-statement-new
            else (),
            
            (: Update notes :)
            if ($notes-statement-change) then
                update replace $notes-statement-existing with $notes-statement-new
            else ()
            ,
            
            (: Increment the version number - do first so it can evaluate the change :)
            (: Don't increment if this request included a change to the version!! :)
            if ($title-statement-change or $notes-statement-change) then
                update-tei:minor-version-increment($tei, concat('Auto (', $form-action, ')'))
            else ()
            
        }
        (:element update-debug {
            element title-statement {
               element existing-value { $title-statement-existing }, 
               element new-value { $title-statement-new }
            },
            element notes-statement {
               element existing-value { $notes-statement-existing }, 
               element new-value { $notes-statement-new }
            }
        }:)
};

declare function update-tei:source($tei as element(tei:TEI)) as element()* {
    
    let $parent := $tei/tei:teiHeader/tei:fileDesc
    let $existing-value := $parent/tei:sourceDesc
    let $insert-following := $parent/tei:publicationStmt
    
    let $bibl-ws := common:ws(4)
    let $location-ws := common:ws(5)
    let $volume-ws := common:ws(6)
    
    let $new-value :=
        (: sourceDesc :)
        element { node-name($existing-value) } {
            
            $existing-value/@*,
            $existing-value/tei:bibl[1]/preceding-sibling::node(),
            
            for $bibl at $bibl-index in $existing-value/tei:bibl[@key]
            
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
                    let $attribution-parameter-role := concat('attribution-role-',$toh-key,'-')
                    let $text-id := tei-content:id($tei)
                    let $max-xml-id-int := tei-content:max-xml-id-int($tei)
                    
                    for $attribution-param at $param-index in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., $attribution-parameter-role)], '-')
                    
                    let $attribution-index := substring-after($attribution-param, $attribution-parameter-role)
                    let $attribution-id := request:get-parameter(concat('attribution-id-',$toh-key,'-', $attribution-index), '')
                    let $attribution-role := request:get-parameter(concat('attribution-role-',$toh-key,'-', $attribution-index), '')
                    let $attribution-entity-id := request:get-parameter(concat('attribution-entity-',$toh-key,'-', $attribution-index), '')
                    let $attribution-expression := request:get-parameter(concat('attribution-expression-',$toh-key,'-', $attribution-index), '')
                    let $attribution-lang := request:get-parameter(concat('attribution-lang-',$toh-key,'-', $attribution-index), '') ! common:valid-lang(.)
                    let $attribution-revision := request:get-parameter(concat('attribution-revision-',$toh-key,'-', $attribution-index), '')
                    let $attribution-key := request:get-parameter(concat('attribution-key-',$toh-key,'-', $attribution-index), '')
                    
                    let $attribution-entity := $entities:entities/id($attribution-entity-id)[self::m:entity]
                    
                    (: New xml:id for additions :)
                    let $attribution-id :=
                        if(not($attribution-id gt '')) then
                            tei-content:next-xml-id($text-id, sum(($max-xml-id-int, $param-index)))
                        else
                            $attribution-id
                    
                    return (
                        
                        (: Create a new entity :)
                        if($attribution-entity-id eq 'create-entity-for-expression') then
                            let $new-entity := update-entity:new-entity($attribution-lang, $attribution-expression, 'eft-person', 'source-attribution', $attribution-id, '')
                            return
                                update insert $new-entity into $entities:entities
                        
                        (: Move attribution to an existing entity :)
                        else
                            let $attribution-instance-existing := $entities:entities//m:instance[@id eq $attribution-id]
                            let $entity-target := $entities:entities/id($attribution-entity-id)[self::m:entity]
                            
                            return 
                                update-entity:move-instance($attribution-id, 'source-attribution', $attribution-instance-existing, $entity-target)
                        ,
                        
                        if($attribution-role gt '') then (
                            $location-ws,
                            element { QName("http://www.tei-c.org/ns/1.0", if($attribution-role eq 'reviser') then 'editor' else 'author') } {
                                
                                if($attribution-role = ('translator')) then
                                    attribute role {'translatorTib'}
                                else if($attribution-role = ('reviser')) then
                                    attribute role {'reviser'}
                                else if($attribution-role = ('author-contested')) then
                                    attribute role {'authorContested'}
                                else (),
                                
                                attribute xml:id { $attribution-id },
                                
                                if(not($attribution-lang eq '')) then
                                    attribute xml:lang {$attribution-lang}
                                else (),
                                
                                if(not($attribution-revision eq '')) then
                                    attribute revision {$attribution-revision}
                                else (),
                                
                                if(not($attribution-key eq '')) then
                                    attribute key {$attribution-key}
                                else (),
                                
                                text { $attribution-expression }
                                
                            }
                        )
                        else ()
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
            
            (: Copy translation blocks bibl :)
            $bibl-ws, 
            $existing-value/tei:bibl[not(@key)],
            
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
                update-tei:minor-version-increment($tei, concat('Auto (', 'update-locations', ')'))
            else()
            ,
            
            (: Do the update :)
            common:update('update-tei-locations', $existing-value, $new-value, $parent, $insert-following)
            
        }
        (:(
            element update-debug {
                element existing-value { $existing-value }, 
                element new-value { $new-value }, 
                element parent { $parent }
            }
        ):)
};

(: Stub function for adding multiple glossary items from post
declare function update-tei:glossary-add-items($tei as element(tei:TEI)) as element()* {
    
    for $entity-id in request:get-parameter('entity-add[]', '')
    let $glossary-id := tei-content:next-xml-id($tei)
    return
        update-tei:update-glossary($tei, $glossary-id)
    
};:)

declare function update-tei:update-glossary($tei as element(tei:TEI), $glossary-id as xs:string) as element()* {

    (: To create a new item pass a $glossary-id that is unused :)
    let $parent := $tei/tei:text/tei:back/tei:div[@type eq 'glossary']/tei:list[@type eq 'glossary']
    
    (: If there's no parent list create one :)
    let $parent :=
        if(not($parent)) then
            
            let $check-back :=
                if(not($tei/tei:text/tei:back)) then
                    update insert ( common:ws(2), element { QName('http://www.tei-c.org/ns/1.0', 'back') } {} ) into $tei/tei:text
                else ()
            
            let $check-div :=
                if(not($tei/tei:text/tei:back/tei:div[@type eq 'glossary'])) then
                    update insert ( common:ws(3), element { QName('http://www.tei-c.org/ns/1.0', 'div') } { attribute type { 'glossary' } } ) into $tei/tei:text/tei:back
                else ()
            
            let $check-list :=
                if(not($tei/tei:text/tei:back/tei:div[@type eq 'glossary']/tei:list[@type eq 'glossary'])) then
                    update insert ( common:ws(4), element { QName('http://www.tei-c.org/ns/1.0', 'list') } { attribute type { 'glossary' } } ) into $tei/tei:text/tei:back/tei:div[@type eq 'glossary']
                else ()
            
            return
                $tei/tei:text/tei:back/tei:div[@type eq 'glossary']/tei:list[@type eq 'glossary']
        
        else
            $parent
    
    (: Look for an existing item :)
    let $existing-item := $parent/tei:item[tei:gloss[@xml:id eq $glossary-id]]
    
    (: Look up entity :)
    let $entity := $entities:entities//m:entity[m:instance/@id = $glossary-id]
    let $entity :=
        if(not($entity) and request:get-parameter('entity-id', '') gt '') then
            $entities:entities/id(request:get-parameter('entity-id', ''))[self::m:entity]
        else
            $entity
    
    (: If it's an update and the main term is '' then don't construct the new value e.g. remove existing :)
    let $remove-entry := (request:get-parameter('form-action', '') eq 'update-glossary' and request:get-parameter('main-term', '') eq '')
    
    let $tei-version := tei-content:version-str($tei)
    
    let $main-term := request:get-parameter('main-term', $glossary-id)
    
    let $glossary-type :=
        if (request:get-parameter('glossary-type', '') = $glossary:types) then
            request:get-parameter('glossary-type', 'term')
        else if($existing-item/tei:gloss[@type = $glossary:types]) then
            $existing-item/tei:gloss/@type/string()
        else
            'term'
    
    let $glossary-mode :=
        if (request:get-parameter('glossary-mode', 'match') = $glossary:modes) then
            request:get-parameter('glossary-mode', 'match')
        else if($existing-item/tei:gloss[@mode = $glossary:modes]) then
            $existing-item/tei:gloss/@mode/string()
        else 
            'match'
    
    (: Only construct the new value if it's existing or it's a valid id :)
    let $new-value :=
        if (($existing-item or tei-content:valid-xml-id($tei, $glossary-id)) and not($remove-entry)) then
            element {QName('http://www.tei-c.org/ns/1.0', 'item')} {
                $existing-item/@*,
                common:ws(6),
                
                element {QName('http://www.tei-c.org/ns/1.0', 'gloss')} {
                    
                    (: @xml:id :)
                    attribute xml:id { $glossary-id },
                    
                    (: @type :)
                    attribute type { $glossary-type },
                    
                    (: @mode :)
                    attribute mode { $glossary-mode },
                    
                    (: Main term :)
                    common:ws(7),
                    element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                        attribute type {'translationMain'},
                        text { $main-term }
                    },
                    
                    (: Get all the term-lang-n input :)
                    let $lang-params := common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-lang-')], '-')
                    (: Loop per lang :)
                    for $lang in ('en','Sa-Ltn','Bo-Ltn','zh','Pi-Ltn')
                    return
                        (: Get the input for this lang :)
                        for $lang-param at $index in $lang-params[request:get-parameter(., '') ! common:valid-lang(.) eq $lang]
                        (: Derive the row / input set :)
                        let $term-index := substring-after($lang-param, 'term-lang-')
                        (: Get the associated text / type / status :)
                        let $term-text := request:get-parameter(concat('term-text-', $term-index), '')
                        let $term-type := request:get-parameter(concat('term-type-', $term-index), '')
                        let $term-status := request:get-parameter(concat('term-status-', $term-index), '')
                        (: Validate / get default of the type :)
                        let $attestation-type := ($glossary:attestation-types//m:attestation-type[@id eq $term-type] | $glossary:attestation-types//m:attestation-type[m:migrate/@id = $term-type] | $glossary:attestation-types//m:attestation-type[m:appliesToLang[@xml:lang eq $lang][@default]][1] | $glossary:attestation-types//m:attestation-type[@id eq 'sourceUnspecified'] )[1]
                        
                        (: Filter out empty content :)
                        where 
                            $term-text gt ''
                            and not($lang eq 'Sa-Ltn' and $term-text eq common:local-text('glossary.term-empty-sa-ltn', 'en'))
                            and not($lang eq 'Bo-Ltn' and $term-text eq common:local-text('glossary.term-empty-bo-ltn', 'en'))
                        
                        return (
                            common:ws(7),
                            element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                            
                                if($lang eq 'en') then (
                                    attribute type {'translationAlternative'},
                                    text { $term-text ! normalize-space(.) }
                                )
                                
                                else if($lang eq 'Sa-Ltn') then (
                                    attribute xml:lang { 'Sa-Ltn' },
                                    if($attestation-type) then
                                        attribute type { $attestation-type/@id }
                                    else(),
                                    if($term-status gt '') then 
                                        attribute status  { $term-status } 
                                    else (),
                                    text { $term-text ! replace(., '\-', '­') ! lower-case(.) ! normalize-unicode(.) ! normalize-space(.) }
                                )
                                
                                else if($lang eq 'Bo-Ltn') then (
                                    attribute xml:lang { 'Bo-Ltn' },
                                    if($attestation-type) then
                                        attribute type { $attestation-type/@id }
                                    else(),
                                    attribute n { $index },
                                    if($term-status gt '') then 
                                        attribute status  { $term-status } 
                                    else (),
                                    text { $term-text ! normalize-unicode(.) ! normalize-space(.) }
                                )
                                
                                else ( 
                                    attribute xml:lang { $lang },
                                    if($attestation-type) then
                                        attribute type { $attestation-type/@id }
                                    else(),
                                    if($term-status gt '') then 
                                        attribute status  { $term-status } 
                                    else (),
                                    text { $term-text ! normalize-unicode(.) ! normalize-space(.) }
                                )
                                
                            },
                            
                            (: If it's Bo-Ltn also add bo :)
                            if($lang eq 'Bo-Ltn') then (
                                common:ws(7),
                                element {QName('http://www.tei-c.org/ns/1.0', 'term')} {
                                    attribute xml:lang { 'bo' },
                                    if($attestation-type) then
                                        attribute type { $attestation-type/@id }
                                    else(),
                                    attribute n { $index },
                                    if($term-status gt '') then 
                                        attribute status  { $term-status } 
                                    else (),
                                    text { $term-text ! normalize-unicode(.) ! normalize-space(.) ! common:bo-term(.)}
                                }
                            )
                            else ()
                        )
                    ,
                    
                    (: Convert the definitions from the request into TEI :)
                    let $definitions-markup := 
                        for $definition-param in common:sort-trailing-number-in-string(request:get-parameter-names()[starts-with(., 'term-definition-text-')], '-')
                        let $definition-text := request:get-parameter($definition-param, '')
                        let $definition-markup := common:markup($definition-text, 'http://www.tei-c.org/ns/1.0')
                        where $definition-text gt ''
                        return
                            element {QName('http://www.tei-c.org/ns/1.0', 'p')} {
                                (: If the xml conversion fails, nevertheless add the escaped text :)
                                if($definition-markup) then
                                    $definition-markup
                                else
                                    $definition-text
                            }
                    
                    let $use-definition := 
                        if($definitions-markup and $entity/m:content[@type eq 'glossary-definition'][node()]) then
                            request:get-parameter('use-definition', '')[. = ('both', 'append', 'prepend', 'override', 'incompatible')]
                        else ()
                    
                    where $definitions-markup
                    return (
                        common:ws(7),
                        element {QName('http://www.tei-c.org/ns/1.0', 'note')} {
                            attribute type { 'definition' },
                            if($use-definition gt '') then
                                attribute rend { $use-definition }
                            else ()
                            ,
                            for $definition-markup in $definitions-markup
                            return (
                                common:ws(8),
                                $definition-markup
                            ),
                            common:ws(7)
                        }
                    ),
                    
                    (: Copy other nodes :)
                    if ($existing-item) then
                        for $node in $existing-item/tei:gloss/*[not(self::tei:term)][not(@type eq 'definition')]
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
        if($remove-entry and $entity) then (
            (: Does the cache refresh get triggered anyway? :)
            (:update-tei:cache-glossary-locations($tei, 'none'),:)
            update-entity:remove-instance($glossary-id)
        )
        
        (: If we are creating a new entry and an entity is defined then make the association :)
        else if(not($existing-item) and $entity) then
            update-entity:match-instance($entity/@xml:id, $glossary-id, 'glossary-item', ())
            
        else ()
        
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

declare function update-tei:glossary-definition-use($tei as element(tei:TEI), $glossary-id as xs:string){
    
    let $entry := $tei/id($glossary-id)[self::tei:gloss]
    let $definition := $entry/tei:note[@type eq 'definition']
    let $request-value := request:get-parameter('use-definition', '')[. = ('', 'both', 'append', 'prepend', 'override', 'incompatible')]
    
    where $entry
    return
        (: No value submitted :)
        if($definition[@rend] and $request-value eq '') then
            update delete $definition/@rend
        
        (: Update @rend :)
        else if($definition[@rend]) then
            update replace $definition/@rend with attribute rend { $request-value }
        
        (: Add @rend :)
        else if($definition) then
            update insert attribute rend { $request-value } into $definition
        
        else ()
        
};

declare function update-tei:cache-glossary-locations($tei as element(tei:TEI), $glossary-id as xs:string*) as element()* {
    
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
    let $glossary-cached-locations := glossary:cached-locations($tei, (), true())
    let $tei-version := tei-content:version-str($tei)
    let $publication-status := ($tei//tei:publicationStmt/tei:availability/@status[. gt '']/string(), '')[1]

    (: TEI glossary items :)
    let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']//tei:gloss[@xml:id][not(@mode eq 'surfeit')]
    
    (: Which glossary entries to refresh :)
    let $refresh-locations-for :=
        if ($glossary-id eq 'uncached') then
            $tei-glossary[not(@xml:id = $glossary-cached-locations/m:gloss[m:location]/@id)]/@xml:id
        else if ($glossary-id eq 'version') then
            $tei-glossary[not(@xml:id = $glossary-cached-locations/m:gloss[@tei-version eq $tei-version]/@id)]/@xml:id
        else if ($glossary-id eq 'all') then
            $tei-glossary/@xml:id
        else
            $tei-glossary[@xml:id = $glossary-id]/@xml:id
    
    let $log := util:log('info', concat('update-tei-cache-glossary: ', format-number(count($refresh-locations-for), '#,###'), ' entries'))
    
    (: Process in chunks :)
    let $cache-glossary-chunks := local:cache-glossary-chunk($tei, $refresh-locations-for, 1)
    
    (: Record build time - only if it's the whole set :)
    let $end-time := util:system-dateTime()
    
    (: Get the file again :)
    let $glossary-cached-locations := glossary:cached-locations($tei, false())
    let $duration-attribute := $glossary-cached-locations/@seconds-to-build
    let $duration-attribute-new := attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) }
    let $set-duration := 
        if(count($refresh-locations-for) eq count($tei-glossary/@xml:id)) then
            if($duration-attribute) then
                update replace $duration-attribute with $duration-attribute-new
            else
                update insert $duration-attribute-new into $glossary-cached-locations
        else ()
    
    (: Store file version :)
    let $store-file-version := store:store-version-str(concat($text-id, '.xml'), $tei-version, $publication-status)
    
    return 
        $cache-glossary-chunks
};

declare function local:cache-glossary-chunk($tei as element(tei:TEI), $glossary-ids as xs:string*, $chunk as xs:integer) as element()* {
    
    let $count := count($glossary-ids)
    let $chunk-size := xs:integer(500)
    let $chunks-count := xs:integer(ceiling($count div $chunk-size))
    let $chunk-start := ($chunk-size * ($chunk - 1)) + 1
    let $chunk-end := ($chunk-start + $chunk-size) - 1
    
    let $text-id := tei-content:id($tei)
    
    return (
        if($chunk-start le $count) then (
        
            (: Get subsequence :)
            let $glossary-ids-chunk := subsequence($glossary-ids, $chunk-start, $chunk-size)
            
            (: Get new cache :)
            let $glossary-cached-locations-refreshed := glossary:cached-locations($tei, $glossary-ids-chunk, true())
            
            (: Save new cache :)
            return (
                (:common:update('cache-glossary', $glossary-cached-locations, $glossary-cached-locations-new, $glossary-cached-locations/parent::m:cache, ()),:)
                (:update replace $glossary-cached-locations with $glossary-cached-locations-refreshed,:)
                element stored { xmldb:store($glossary:cached-locations-path, concat($text-id, '.xml'), $glossary-cached-locations-refreshed) },
                util:log('info', concat('update-tei-cache-glossary-chunk: ', $text-id, ' ', $chunk, '/', $chunks-count))
            )
            
        )
        else ()
        ,
        (: Recurse to next chunk :)
        if($chunk-end lt $count) then
            local:cache-glossary-chunk($tei, $glossary-ids, $chunk + 1)
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
        
        (: Evaluate if this is a new version :)
        let $request-version := request:get-parameter('text-version', '')
        (: Make a comparable string from the request :)
        let $request-version-number-str := tei-content:strip-version-number($request-version)
        (: Get the current version number from the TEI :)
        let $existing-version-number-str := tei-content:version-number-str($tei)
        (: Test if it's a new version :)
        let $request-is-current-version := tei-content:is-current-version($existing-version-number-str, $request-version-number-str)
        
        where not(tei-content:locked-by-user($tei) gt '')
        return (
            
            (: Add titles from request :)
            if($fileDesc/tei:titleStmt and $request-titles) then 
               
               let $titleStmt-new :=
                    element { QName("http://www.tei-c.org/ns/1.0", "titleStmt") } {
                        $fileDesc/tei:titleStmt/@*,
                        for $title in $request-titles
                        return (
                            (: Add whitespace before node :)
                            common:ws(4),
                            $title
                        ),
                        common:ws(3)
                    }
                    
                where not(deep-equal($fileDesc/tei:titleStmt/tei:title, $titleStmt-new/tei:title))
                return (
                
                    common:update('knowledgebase-header', $fileDesc/tei:titleStmt, $titleStmt-new, (), ()),
                    
                    (: If not requested then increment version :)
                    if($request-is-current-version) then
                        update-tei:minor-version-increment($tei, 'Titles updated')
                    else ()
                    
                )
                
            else ()
            ,
            
            (: Update edition statement :)
            if($request-parameter-names = 'text-version' and not($request-is-current-version)) then 
                
                (: Get the version from the request :)
                let $version-note := request:get-parameter('version-note', '')
                
                let $editionStmt-new :=
                    element { QName("http://www.tei-c.org/ns/1.0", "editionStmt") } {
                        $fileDesc/tei:editionStmt/@*,
                        common:ws(4),
                        element edition {
                            text {'v ' || $request-version-number-str || ' '},
                            element date {
                                text { format-dateTime(current-dateTime(), '[Y]') }
                            }
                        },
                        common:ws(3)
                    }
                
                where not(deep-equal($fileDesc/tei:editionStmt/*, $editionStmt-new/*))
                return (
                
                    common:update('knowledgebase-header', $fileDesc/tei:editionStmt, $editionStmt-new, $fileDesc, $fileDesc/tei:titleStmt),
                    
                    (: Log the version update :)
                    update-tei:add-change($tei, 'text-version', $request-version-number-str, ($version-note, $request-version-number-str)[. gt ''][1])
                    
                )
                
            else ()
            ,
            
            (: Update publication status :)
            if($fileDesc/tei:publicationStmt and $request-parameter-names = 'publication-status') then 
                
                let $request-status := request:get-parameter('publication-status', '')
                (: Force zero to '' :)
                let $request-status := if ($request-status eq '0') then '' else $request-status
                let $existing-status := $fileDesc/tei:publicationStmt/tei:availability/@status/string()
                
                let $request-publication-date := request:get-parameter('publication-date', '')
        
                let $publicationStmt-new :=
                    element { QName("http://www.tei-c.org/ns/1.0", "publicationStmt") } {
                    
                        (: Copy any attributes :)
                        $fileDesc/tei:publicationStmt/@*,
                        
                        common:ws(4),
                        $fileDesc/tei:publicationStmt/tei:publisher,
                        
                        (: Set the status, create if missing :)
                        common:ws(4),
                        element { QName("http://www.tei-c.org/ns/1.0", "availability") } {
                            attribute status { $request-status },
                            $fileDesc/tei:publicationStmt/tei:availability/@*[not(local-name() = ('status'))],
                            $fileDesc/tei:publicationStmt/tei:availability/node()
                        },
                        
                        for $idno in $fileDesc/tei:publicationStmt/tei:idno
                        return (
                            common:ws(4),
                            $idno
                        ),
                        
                        (: Set the date :)
                        common:ws(4),
                        element { node-name($fileDesc/tei:publicationStmt/tei:date) } {
                            text { $request-publication-date }
                        },
                        
                        (: Copy any other nodes :)
                        for $element in $fileDesc/tei:publicationStmt/*[not(local-name() = ('publisher','availability','idno','date'))]
                        return (
                            common:ws(4),
                            $element
                        ),
                        
                        common:ws(3)
                        
                    }
                
                where not(deep-equal($fileDesc/tei:publicationStmt/*, $publicationStmt-new/*))
                return (
                
                    common:update('knowledgebase-header', $fileDesc/tei:publicationStmt, $publicationStmt-new, (), ()),
                    
                    (: Log the status update :)
                    if ($request-status ne $existing-status) then
                        update-tei:add-change($tei, 'publication-status', $request-status, $request-status)
                    else ()
                    
                )
            
            else ()
            
        )
        
    } (: close exist:batch-transaction :)
};

declare function update-tei:update-content($tei as element(tei:TEI), $content-escaped as xs:string*, $passage-id as xs:string, $content-hidden as xs:boolean, $add-milestone as xs:boolean) as element()? {
    
    let $passage-id-parsed := replace($passage-id, '^node\-', '')
    let $current-tei := $tei//*[@xml:id eq $passage-id-parsed] | $tei//*[@tid eq $passage-id-parsed]
    let $content-unescaped := common:markup($content-escaped, 'http://www.tei-c.org/ns/1.0')
    
    let $milestone :=
        if(not($current-tei/preceding-sibling::*[1][self::tei:milestone]) and $add-milestone) then 
            element { QName('http://www.tei-c.org/ns/1.0','milestone') } {
                attribute unit { 'chunk' }
            }
        else ()
    
    (: Update with new content :)
    let $new-tei := 
        if($content-escaped gt '') then 
            element { node-name($current-tei) } {
            
                (: Copy attributes :)
                $current-tei/@*[not(name(.) eq 'rend' and string() eq 'default-text')],
                
                if($content-hidden) then
                    attribute rend { 'default-text' }
                else (),
                
                (: Check there's a result :)
                if($content-unescaped[node()]) then
                    $content-unescaped
                
                (: Nothing derived from markdown so copy to be safe :)
                else
                    $content-escaped
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
    
    where $current-tei and not(tei-content:locked-by-user($tei) gt '')
    return 
        if($new-tei) then (
            if($milestone) then
                update insert ($milestone, common:ws(5)) preceding $current-tei 
            else (),
            update replace $current-tei with $new-tei
        )
        else
            update delete $current-tei

};

(: Unreliable
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
    
    let $markup := transform:transform($markdown-element, doc('/db/apps/84000-operations/views/functions.xsl'), (), (), $serialization-options)
    
    let $new-tei := 
        (\: Update with new content :\)
        if($markdown gt '') then
            element { node-name($current-tei) } {
            
                (\: Copy attributes :\)
                $current-tei/@*[not(name(.) eq 'rend' and string() eq 'default-text')],
                
                (\: Copy elements derived from new lines :\)
                if($newline-element gt '' and $markup[node()]) then
                    $markup/node()
                
                (\: No new lines so merge divs :\)
                else if($markup[tei:div/node()]) then
                    $markup/tei:div/node()
                
                (\: Nothing derived from markdown so copy to be safe :\)
                else
                    $markdown
                ,
                
                (\: Copy comments :\)
                $current-tei/comment()
                
            }
        (\: Remove the element :\)
        else ()
    
    (\: If it's a delete, in some cases we want to remove more than the node itself :\)
    let $current-tei :=
    
        (\: There is no content and it has no siblings :\)
        if(not($new-tei) and not($current-tei/following-sibling::* | $current-tei/preceding-sibling::*)) then
        
            (\: It's in a list :\)
            if($current-tei[parent::tei:item[parent::tei:list]])then
            
                (\: remove the whole list if this is the only item :\)
                if(count($current-tei/parent::tei:item/parent::tei:list/tei:item) eq 1) then
                    $current-tei/parent::tei:item/parent::tei:list
                (\: remove the whole item :\)
                else
                    $current-tei/parent::tei:item
            
            (\: It's the last element in a div, remove the div :\)
            else if($current-tei[parent::tei:div]) then
                $current-tei/parent::tei:div
            
            else $current-tei
            
        else
            $current-tei
    
    where not(tei-content:locked-by-user($tei) gt '') and $current-tei
    return 
        common:update('tei-markup', $current-tei, $new-tei, (), ())

};:)

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
            or ($new-element-relation eq 'create' and $new-element-type eq 'part' and not($tei//tei:div[@type eq $new-element-source]))
        )
        and $new-element-type[. = ('item', 'para', 'listLabel', 'listDots', 'listNumbers', 'listLetters', 'bibl', 'section', 'itemPara', 'itemListDots', 'itemListNumbers', 'itemListLetters', 'part')]
        and $new-element-relation[. = ('before', 'after', 'create')]
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
        
        else if($new-element-type eq 'part') then
            element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
                attribute type { $new-element-source },
                element p {
                    attribute rend { 'default-text' },
                    text { 'A summary of the article...' }
                }
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
        and (
            $new-element-relation eq 'create'
            or ($new-element-relation[. = ('before', 'after')] and $sibling)
        )
    return
        element { QName('http://read.84000.co/ns/1.0', 'updated') } {
        
            attribute node { 'add-tei-element' },   
            
            (: Create a new section :)
            if($new-element-relation eq 'create') then
                if($new-element-source eq 'abstract') then
                    update insert $new-element into $tei//tei:text/tei:front
                else ()
            
            (: Add before or after :)
            else if($new-element-relation eq 'before') then
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
    let $toh-key := translation:source-key($tei, '')
    let $document-url := base-uri($tei)
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
