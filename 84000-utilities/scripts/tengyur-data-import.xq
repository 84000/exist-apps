xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

declare variable $local:tengyur-tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare variable $local:import-filename := "tengyur-data-1109-1179_PH_new_v2.xml";
declare variable $local:import-texts := doc(concat('/db/apps/84000-data/uploads/tengyur-data/', $local:import-filename))//m:text;

declare function local:merge-element ($element as element(), $import-text as element(m:text)) {
    
    (: Titles :)
    if(local-name($element) eq 'titleStmt') then
        element { node-name($element) } {
            $element/@*,
            for $title in $import-text/m:title
            order by if($title[@type eq 'mainTitle']) then 1 else if($title[@type eq 'longTitle']) then 2 else 3
            where $title[not(@xml:lang/string() eq 'Bo-Ltn')]
            for $lang in (common:valid-lang($title/@xml:lang), if($title[@xml:lang = ('Bo', 'bo')]) then 'Bo-Ltn' else ())
            return
                element title {
                    $title/@*[not(local-name(.) = ('lang', 'type'))],
                    if ($title[@type = ('mainTitle', 'longTitle', 'otherTitle')]) then 
                        $title/@type
                    else (
                        attribute type { 'otherTitle' },
                        attribute group { $title/@type/string() }
                    )
                    ,
                    attribute xml:lang { $lang },
                    if($lang eq 'Bo-Ltn') then
                        common:wylie-from-bo($title/data())
                    else 
                        $title/node()
                }
        }
    
    (: Notes :)
    else if(local-name($element) eq 'notesStmt') then
        element { node-name($element) } {
        
            $element/@*,
            $element/*[not(@import eq $local:import-filename)],
            
            (: Skip notes that are from this import :)
            for $note in $import-text//m:note
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'note') } {
                    (:$note/@*[not(local-name(.) = ('lang', 'type'))],:)
                    attribute type { 'import' },
                    attribute date-time { current-dateTime() },
                    attribute user { 'admin' },
                    attribute import { $local:import-filename },
                    if($note[@type]) then
                        attribute import-type { $note/@type }
                    else ()
                    ,
                    if($note[@ref]) then
                        attribute ref { $note/@ref }
                    else ()
                    ,
                    $note/node()
                }
        }
    
    (: Contributors :)
    (: Ignore existing contributors :)
    else if(local-name($element) = ('author', 'translator', 'reviser')) then
        ()
    
    (: Process imported contributors after biblScope  :)
    else if(local-name($element) eq 'biblScope') then (
    
        (: biblScope :)
        $element,
        
        (: Contributors :)
        for $contributor in $import-text//m:author | $import-text//m:translator | $import-text//m:reviser
            
            let $element-name :=
                if($contributor[self::m:reviser]) then
                    'editor'
                else
                    'author'
            
            let $contributor-role :=
                if($contributor[self::m:reviser]) then
                    'reviser'
                else if($contributor[self::m:translator]) then
                    'translatorTib'
                else ()
            
            let $contributor-key :=
                if($contributor[parent::*[@type][not(@type eq 'main')]]) then
                    $contributor/parent::*/@type/string()
                else ()
            
            let $import-id := concat('tengyur-data-2021-PH', $contributor[@ref] ! concat('#', $contributor/@ref))
            
            let $contributor-id := 
                
                (: See if it already exists :)
                if($contributor[@ref] and $entities:entities/m:entity/m:source[@key eq $import-id]) then
                    concat('EFT:', $entities:entities/m:entity[m:source[@key eq $import-id]]/@xml:id)
                
                (: Add a new record :)
                else (
                    let $new-entity := 
                        element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                            attribute xml:id { entities:next-id() },
                            common:ws(2),
                            element label {
                                ($contributor/@ref/string(), $contributor/text())[1]
                            },
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
                    
                    let $add-entity := common:update('entity', (), $new-entity, $entities:entities, ())
                    
                    return 
                        if(local-name($add-entity) eq 'updated') then
                            concat('EFT:', $new-entity/@xml:id)
                        else
                            concat('IMPORT-ERROR:', $import-id)
                        
                )
        
        where $contributor[not(@xml:lang/string() eq 'Bo-Ltn')]
        return (
            for $lang in (common:valid-lang($contributor/@xml:lang), if($contributor[@xml:lang = ('Bo', 'bo')]) then 'Bo-Ltn' else ())
            return
            element { QName('http://www.tei-c.org/ns/1.0', $element-name) } {
                $contributor/@*[not(local-name(.) = ('lang', 'ref'))],
                if($contributor-role) then
                    attribute role { $contributor-role }
                else ()
                ,
                if($contributor-key) then
                    attribute key { $contributor-key }
                else ()
                ,
                attribute xml:lang { $lang },
                attribute ref { $contributor-id },
                if($lang eq 'Bo-Ltn') then
                    common:wylie-from-bo($contributor/data())
                else 
                    $contributor/node()
            }
            
        )
    )
    
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
        }
};

(: DON'T FORGET TO DISABLE TRIGGER :)
element { QName('http://read.84000.co/ns/1.0', 'imported') } {
   
    for $import-text in $local:import-texts(:[@text-id = ('UT23703-001-001','UT23703-001-019', 'UT23703-001-046')]:)
        let $tei := tei-content:tei($import-text/@text-id, 'translation')
        let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
        let $fileDesc-merged := local:merge-element ($fileDesc, $import-text)
    return (
        (:$import-text,:)
        (:$fileDesc-merged,:)
        common:update(tei-content:id($tei), $fileDesc, $fileDesc-merged, (), ())
    )

}