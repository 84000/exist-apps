xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:tengyur-tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare variable $local:import-texts := collection('/db/apps/84000-data/uploads/tengyur-import');

(: ~ Standalone xpath to check what's been done

declare namespace tei="http://www.tei-c.org/ns/1.0";

for $note in collection('/db/apps/84000-data/tei/translations/tengyur/placeholders')//tei:notesStmt/tei:note[@import]
let $import-id := $note/@import/string()
group by $import-id
return $import-id

:)

declare function local:merge-element ($element as element(), $import-text as element(m:text)) {
    
    let $import-file-name := $import-text/parent::m:tengyur-data/m:head[1]/m:doc[1]/@doc_id/string()
    where $import-file-name
    return
    
    (: Titles :)
    if(local-name($element) eq 'titleStmt') then
        element { node-name($element) } {
        
            (: Copy attributes :)
            $element/@*,
            
            (: Import titles :)
            for $title in $import-text/m:title
            order by if($title[@type eq 'mainTitle']) then 1 else if($title[@type eq 'longTitle']) then 2 else 3
            where $title[not(@xml:lang/string() eq 'Bo-Ltn')]
            for $lang in (common:valid-lang($title/@xml:lang), if($title[@xml:lang = ('Bo', 'bo')]) then 'Bo-Ltn' else ())
            for $title-tokenized at $token-index in tokenize($title/data(), '/')
            return
                element title {
                    $title/@*[not(local-name(.) = ('lang', 'type'))],
                    attribute xml:lang { $lang },
                    if ($title[@type = ('mainTitle', 'longTitle', 'otherTitle')] and $token-index eq 1) then 
                        $title/@type
                    else (
                        attribute type { 'otherTitle' },
                        attribute group { $title/@type/string() }
                    ),
                    if($title[not(@rend)] and matches($title-tokenized, '^\*.*')) then
                        attribute rend { 'reconstruction' }
                    else ()
                    ,
                    if($lang eq 'Bo-Ltn') then
                        common:wylie-from-bo($title-tokenized)
                    else if($lang eq 'Sa-Ltn') then
                        functx:capitalize-first(
                            replace(
                                replace(
                                    normalize-space($title-tokenized)   (: Normalize space :)
                                , '^\*', '')                            (: Remove leading * :)
                            , '\-', '­')                                (: Hard to soft-hyphens :)
                        )                                               (: Title case :)
                    else
                        normalize-space($title-tokenized)
                    
                }
            ,
            (: Copy non-title elements :)
            $element/*[not(self::tei:title)]
        }
    
    (: Contributors :)
    (: Ignore existing contributors :)
    else if(local-name($element) = ('author', 'editor')) then
        ()
    
    (: Process imported contributors after biblScope  :)
    else if(local-name($element) eq 'biblScope') then (
    
        (: biblScope :)
        $element,
        
        (: Contributors :)
        (:for $statement in $import-text/m:authorstatement | $import-text/m:translatorstatement | $import-text/m:revision:)
        for $contributor in $import-text//m:author | $import-text//m:translator | $import-text//m:reviser
        let $contributor-ref := $contributor/@ref/string()
        let $contributor-node := local-name($contributor)
        group by $contributor-ref, $contributor-node
        let $contributor-1 := ($contributor[@xml:lang eq 'Sa-Ltn'], $contributor[not(@xml:lang eq 'Sa-Ltn')])[1]
        order by if($contributor-1[self::m:author]) then 1 else if($contributor-1[self::m:translator]) then 2 else 3 ascending
        return
        
            let $import-id := concat('tengyur-data-2021-PH', $contributor-ref ! concat('#', .))
            
            let $entity-labels :=
                for $label in $contributor
                let $label-data := $label/data()
                group by $label-data
                let $label-lang := common:valid-lang($label[1]/@xml:lang)
                order by if($label-lang eq 'Sa-Ltn') then 1 else if($label-lang eq 'bo') then 2 else 3
                    for $lang in ($label-lang[not(. eq 'Bo-Ltn')], if($label-lang eq 'bo') then 'Bo-Ltn' else ())
                    return 
                        element { QName('http://read.84000.co/ns/1.0', 'label') } {
                            attribute xml:lang { $lang },
                            attribute text-id { $import-text/@text-id/string() },
                            if($lang eq 'Bo-Ltn') then
                                common:wylie-from-bo($label-data)
                            else if($lang eq 'Sa-Ltn') then
                                functx:capitalize-first(
                                    replace(
                                        replace(
                                            normalize-space($label-data)    (: Normalize space :)
                                        , '^\*', '')                        (: Remove leading * :)
                                    , '\-', '­')                            (: Hard to soft-hyphens :)
                                )                                           (: Title case :)
                            else if($lang eq 'en' and $contributor-1[@ref eq 'anon']) then
                                'Anon'
                            else 
                                $label-data
                        }
            
            (: See if it already exists :)
            let $contributor-entity := 
                if($contributor-ref) then
                    $entities:entities/m:entity[m:source[@key eq $import-id]]
                else ()
            
            (: Add/update entity record :)
            let $new-entity := 
                (: Update the existing record :)
                if($contributor-entity) then
                    element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                        (: Copy existing :)
                        $contributor-entity/@*,
                        (: Existing labels :)
                        for $label in $contributor-entity/m:label
                        return (
                            common:ws(2),
                            $label
                        ),
                        (: Additional labels :)
                        for $label in $entity-labels
                        where $label[not(text() = $contributor-entity/m:label/text())]
                        return (
                            common:ws(2),
                            $label
                        ),
                        (: Other element :)
                        for $contributor-element in $contributor-entity/*[not(self::m:label)]
                        return (
                            common:ws(2),
                            $contributor-element
                        ),
                        common:ws(1)
                    }
                else
                    (: New record :)
                    element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                        attribute xml:id { entities:next-id() },
                        for $label in $entity-labels
                        return (
                            common:ws(2),
                            $label
                        ),
                        common:ws(2),
                        element source {
                            attribute key { $import-id }
                        },
                        common:ws(2),
                        element type {
                            attribute type { 'eft-attribution-person' }
                        },
                        common:ws(1)
                    }
                    
            let $update-entities := common:update('entity', $contributor-entity, $new-entity, $entities:entities, ())
            
            let $contributor-id := 
                if($new-entity[@xml:id]) then
                    concat('eft:', $new-entity/@xml:id)
                else
                    concat('IMPORT-ERROR:', $import-id)
            
            let $element-name :=
                if($contributor-1[self::m:reviser]) then
                    'editor'
                else
                    'author'
        
            let $contributor-role :=
                if($contributor-1[self::m:reviser]) then
                    'reviser'
                else if($contributor-1[self::m:translator]) then
                    'translatorTib'
                else ()
        
            let $contributor-revision :=
                if($contributor-1[self::m:reviser] and $contributor-1[parent::m:revision[@rev_id]]) then
                    $contributor-1/parent::m:revision/@rev_id/string()
                else ()
        
            let $contributor-key :=
                if($contributor-1[parent::*[@type][not(@type eq 'main')]]) then
                    $contributor-1/parent::*/@type/string()
                else ()
        
            return 
                element { QName('http://www.tei-c.org/ns/1.0', $element-name) } {
                    $contributor-1/@*[not(local-name(.) = ('ref', 'lang'))],
                    attribute xml:lang { common:valid-lang($contributor-1/@xml:lang) },
                    if($contributor-role) then
                        attribute role { $contributor-role }
                    else ()
                    ,
                    if($contributor-revision) then
                        attribute revision { $contributor-revision }
                    else ()
                    ,
                    if($contributor-key) then
                        attribute key { $contributor-key }
                    else ()
                    ,
                    attribute ref { $contributor-id },
                    if($contributor-1[@xml:lang eq 'en'][@ref eq 'anon']) then
                        'Anon'
                    else if($contributor-1[@xml:lang eq 'Sa-Ltn']) then
                        $contributor-1/node() ! 
                            functx:capitalize-first(
                                    replace(
                                        replace(
                                            normalize-space(.)  (: Normalize space :)
                                        , '^\*', '')            (: Remove leading * :)
                                    , '\-', '­')                (: Hard to soft-hyphens :)
                                )                               (: Title case :)
                    else 
                        $contributor-1/node() ! normalize-space(.)
                }
    )
    
    (: Notes :)
    else if(local-name($element) eq 'notesStmt') then
        element { node-name($element) } {
        
            $element/@*,
            
            (: Copy notes that are not from this import :)
            $element/*[not(@import(: eq $import-file-name:))],
            
            (: Note the import :)
            element { QName('http://www.tei-c.org/ns/1.0', 'note') } {
                attribute type { 'updated' },
                attribute update { 'import' },
                attribute value { 'fileDesc' },
                attribute import { $import-file-name },
                attribute date-time { current-dateTime() },
                attribute user { common:user-name() }
            },
            
            (: Import notes :)
            for $note in $import-text//m:note
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'note') } {
                    (:$note/@*[not(local-name(.) = ('lang', 'type'))],:)
                    attribute type { 'updated' },
                    if($note[@type]) then
                        attribute update { $note/@type }
                    else (),
                    if($note[@ref]) then
                        attribute value { $note/@ref }
                    else (),
                    attribute import { $import-file-name },
                    attribute date-time { current-dateTime() },
                    attribute user { 'admin' },
                    $note/node()
                }
        }
        
    else if(local-name($element) eq 'sourceDesc') then
    
        element { node-name($element) } {
        
            $element/@*,
            
            for $node in $element/*[not(self::tei:link)](:[not(@import eq $import-file-name)]:)
            return
                local:merge-element($node, $import-text)
            ,
            for $link in $import-text/m:rel
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'link') } {
                    $link/@type,
                    attribute target { $link/@resource }(:,
                    attribute import { $import-file-name }:)
                }
        }
    
    else
    
        (: Copy other nodes and recurse :)
        element { node-name($element) } {
            
            $element/@*,
            
            for $node in $element/node()
            return
                if($node instance of element()) then
                    local:merge-element($node, $import-text)
                else if($node instance of text() and normalize-space($node)) then
                    $node
                else ()
            
        }
};

(: DON'T FORGET TO DISABLE TRIGGER :)
element { QName('http://read.84000.co/ns/1.0', 'imported') } {
    
    let $import-texts :=
        for $import-text in $local:import-texts//m:text(:[@text-id = ('UT23703-001-001','UT23703-001-019', 'UT23703-001-046','UT23703-001-053')]:)
        let $import-file-name := $import-text/parent::m:tengyur-data/m:head[1]/m:doc[1]/@doc_id/string()
        where $import-file-name = (
            "tengyur-data-1109-1179_PH_new_v2.3.xml",
            "tengyur-data-1180-1304_PH_new_v2.3.xml",
            "tengyur-data-1305-1345_PH_new_v2.3.xml",
            "tengyur-data-1346-1400_PH_new_v2.3.xml"
        )
        return $import-text
    
    let $import-text-ids := $import-texts/@text-id/string()
    let $tei-texts := $local:tengyur-tei/id($import-text-ids)/ancestor::tei:TEI

    let $validation-issues := 
        for $import-text in $import-texts
        
        let $import-text-id := $import-text/@text-id/string()
        let $tei-text := $tei-texts/id($import-text-id)/ancestor::tei:TEI
        let $import-text-toh-keys := $import-text/m:toh/@key/string()
        let $tei-text-toh-keys := $tei-text/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key/string()
        
        order by $import-text-toh-keys[1]
        return (
            if(not($tei-text)) then
                element missing-tei-text { attribute id { $import-text-id } }
            else (),
            if(count(($import-text-toh-keys[not(. = $tei-text-toh-keys)], $tei-text-toh-keys[not(. = $import-text-toh-keys)]))) then
                element mismatch-toh-keys {
                
                    attribute id { $import-text-id },
                    
                    $tei-text-toh-keys ! element tei-toh { attribute key { . } },
                    $import-text-toh-keys ! element import-toh { attribute key { . } },
                    
                    element tei-title-bo {
                        if($tei-text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'Bo-Ltn'][@type eq 'mainTitle'][string()]) then
                            $tei-text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'Bo-Ltn'][@type eq 'mainTitle']/string()
                        else
                            $tei-text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'bo'][@type eq 'mainTitle']/string() ! common:wylie-from-bo(.)
                    },
                    element import-title-bo {
                        $import-text/m:title[@xml:lang eq 'Bo'][@type eq 'mainTitle']/string() ! common:wylie-from-bo(.)
                    }
                }
            else ()
        )
    
    return 
    if(doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers) then
        <warning>{ 'DISABLE TRIGGERS BEFORE RUNNING SCRIPT' }</warning>
    else if( $validation-issues ) then
        $validation-issues
    else
        (: Do the import :)
        for $import-text in $import-texts
            let $tei := tei-content:tei($import-text/@text-id, 'translation')
            let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
        return
        if($fileDesc) then
            let $fileDesc-merged := local:merge-element ($fileDesc, $import-text)
            return (
                (:$import-text,:)
                (:$fileDesc-merged,:)
                common:update(tei-content:id($tei), $fileDesc, $fileDesc-merged, (), ())
            )
        else
            <error>{$import-text/@text-id}</error>
        
}