xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:tengyur-tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare variable $local:import-filename := "tengyur-data-1109-1179_PH_new_v2.2.xml";
declare variable $local:import-texts := doc(concat('/db/apps/84000-data/uploads/tengyur-data/', $local:import-filename))//m:text;

declare function local:merge-element ($element as element(), $import-text as element(m:text)) {
    
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
        group by $contributor-ref
        let $contributor-1 := ($contributor[@xml:lang eq 'Sa-Ltn'], $contributor[not(@xml:lang eq 'Sa-Ltn')])[1]
        order by if($contributor-1[self::m:author]) then 1 else if($contributor-1[self::m:translator]) then 2 else 3 ascending
        return
        
            let $import-id := concat('tengyur-data-2021-PH', $contributor-ref ! concat('#', .))
            
            let $entity-labels :=
                for $label in $contributor
                    let $label-data := $label/data()
                    let $label-lang := common:valid-lang($label/@xml:lang)
                    order by if($label-lang eq 'Sa-Ltn') then 1 else if($label-lang eq 'bo') then 2 else 3
                    for $lang in ($label-lang[not(. eq 'Bo-Ltn')], if($label-lang eq 'bo') then 'Bo-Ltn' else ())
                    return 
                        element { QName('http://read.84000.co/ns/1.0', 'label') } {
                            attribute xml:lang { $lang },
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
                            else 
                                $label-data
                        }
        
            let $contributor-id := 
                
                (: See if it already exists :)
                if($contributor-ref and $entities:entities/m:entity/m:source[@key eq $import-id]) then
                    concat('eft:', $entities:entities/m:entity[m:source[@key eq $import-id]]/@xml:id)
                
                (: Add a new record :)
                else (
                    let $new-entity := 
                        element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                            attribute xml:id { entities:next-id() },
                            common:ws(2),
                            for $label in $entity-labels
                            return (
                                $label,
                                common:ws(2)
                            ),
                            element source {
                                attribute key { $import-id }
                            },
                            common:ws(2),
                            element type {
                                attribute type { 'eft-attribution-person' }
                            },
                            common:ws(1)
                        }
                    
                    let $add-entity := common:update('entity', (), $new-entity, $entities:entities, ())
                    
                    return 
                        if(local-name($add-entity) eq 'updated') then
                            concat('eft:', $new-entity/@xml:id)
                        else
                            concat('IMPORT-ERROR:', $import-id)
                        
                )
            
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
                    else 
                        $contributor-1/node()
                }
    )
    
    (: Notes :)
    else if(local-name($element) eq 'notesStmt') then
        element { node-name($element) } {
        
            $element/@*,
            
            (: Copy notes that are not from this import :)
            $element/*[not(@import (:eq $local:import-filename:))],
            
            (: Note the import :)
            element { QName('http://www.tei-c.org/ns/1.0', 'note') } {
                attribute type { 'updated' },
                attribute update { 'import' },
                attribute value { 'fileDesc' },
                attribute import { $local:import-filename },
                attribute date-time { current-dateTime() },
                attribute user { 'admin' }
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
                    attribute import { $local:import-filename },
                    attribute date-time { current-dateTime() },
                    attribute user { 'admin' },
                    $note/node()
                }
        }
    
    else
    
        (: Copy other nodes and recurse :)
        element { node-name($element) } {
            
            $element/@*,
            
            for $node in $element/node()
            return
                if($node instance of element()) then
                    local:merge-element ($node, $import-text)
                else if($node instance of text() and normalize-space($node)) then
                    $node
                else 
                    ()
            ,
            if(local-name($element) eq 'sourceDesc') then 
                for $link in $import-text/m:rel[@type eq 'isCommentaryOf']
                return
                   element { QName('http://www.tei-c.org/ns/1.0', 'link') } {
                       attribute type { 'commentaryOf' },
                       attribute target { $link/@resource }
                   }
            else ()
        }
};

(: DON'T FORGET TO DISABLE TRIGGER :)
element { QName('http://read.84000.co/ns/1.0', 'imported') } {
   
    for $import-text in $local:import-texts(:[@text-id = ('UT23703-001-001','UT23703-001-019', 'UT23703-001-046','UT23703-001-053')]:)
        let $tei := tei-content:tei($import-text/@text-id, 'translation')
        let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
        let $fileDesc-merged := local:merge-element ($fileDesc, $import-text)
    return (
        (:$import-text,:)
        (:$fileDesc-merged,:)
        common:update(tei-content:id($tei), $fileDesc, $fileDesc-merged, (), ())
    )

}