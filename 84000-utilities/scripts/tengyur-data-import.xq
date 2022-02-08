xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:tengyur-tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare variable $local:import-texts := collection('/db/apps/84000-data/uploads/tengyur-import');

(: ~ Standalone xquery to check what's been done

declare namespace tei="http://www.tei-c.org/ns/1.0";

for $note in collection('/db/apps/84000-data/tei/translations/tengyur/placeholders')//tei:notesStmt/tei:note[@import]
let $import-id := $note/@import/string()
group by $import-id
return $import-id

:)

declare function local:merge-element ($element as element(), $import-text as element(m:text), $import-key as xs:string, $indent as xs:integer) {
    
    let $import-file-name := $import-text/parent::m:tengyur-data/m:head[1]/m:doc[1]/@doc_id/string()
    where $import-file-name
    return 
    
    (: Titles :)
    if(local-name($element) eq 'titleStmt') then (
        
        (: Prettify with an indent :)
        common:ws($indent),
            
        element { node-name($element) } {
        
            (: Copy attributes :)
            $element/@*,
            
            (: Import titles :)
            for $title in $import-text/m:title
            order by if($title[@type eq 'mainTitle']) then 1 else if($title[@type eq 'longTitle']) then 2 else 3
            where $title[not(@xml:lang/string() eq 'Bo-Ltn')]
            for $lang in (common:valid-lang($title/@xml:lang), if($title[@xml:lang = ('Bo', 'bo')]) then 'Bo-Ltn' else ())
            for $title-tokenized at $token-index in tokenize($title/data(), '/')
            return (
                common:ws($indent + 1),
                element title {
                    $title/@*[not(local-name(.) = ('lang', 'type'))],
                    attribute xml:lang { $lang },
                    if ($title[@type = ('mainTitle', 'longTitle', 'otherTitle')] and $token-index eq 1) then 
                        $title/@type
                    else (
                        attribute type { 'otherTitle' }(:,
                        attribute group { $title/@type/string() }:)
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
            )
            ,
            (: Copy non-title elements :)
            $element/*[not(self::tei:title)]
            ,
        
            (: Prettify with an indent :)
            common:ws($indent)
        }
    )
    (: Contributors :)
    (: Ignore existing contributors :)
    else if(local-name($element) = ('author', 'editor')) then
        ()
    
    (: Process imported contributors after biblScope  :)
    else if(local-name($element) eq 'biblScope') then (
        
        (: biblScope :)
        (: Prettify with an indent :)
        common:ws($indent),
        $element,
        
        (: Contributors :)
        (: Collect all the contributors in a text and de-dupe :)
        for $contributor in $import-text//m:author | $import-text//m:translator | $import-text//m:reviser
        let $contributor-ref := $contributor/@ref/string()
        let $contributor-node := local-name($contributor)
        (: Group translations of the name together :)
        group by $contributor-ref, $contributor-node
        let $contributor-1 := $contributor[1]
        (: List them author first in the TEI :)
        order by if($contributor-node eq 'author') then 1 else if($contributor-node eq 'translator') then 2 else 3 ascending
        return
            
            (: A unique reference for this import record :)
            let $import-id := concat($import-key, $contributor-ref ! concat('#', .))
            
            (: Process all the labels :)
            let $contributor-labels :=
                for $label in $contributor
                let $label-data := $label/data()
                group by $label-data
                let $label-lang := common:valid-lang($label[1]/@xml:lang)
                order by 
                    if($label-lang eq 'Sa-Ltn') then 1 else if($label-lang eq 'bo') then 2 else 3 ascending,
                    string-length($label-data) ascending
                return 
                    (: Normalise Sanskrit :)
                    if($label-lang eq 'Sa-Ltn') then
                        element { QName('http://read.84000.co/ns/1.0', 'label') } {
                            attribute xml:lang { 'Sa-Ltn' },
                            text {
                                functx:capitalize-first(
                                    replace(
                                        replace(
                                            normalize-space($label-data)    (: Normalize space :)
                                        , '^\*', '')                        (: Remove leading * :)
                                    , '\-', '­')                            (: Hard to soft-hyphens :)
                                )                                           (: Title case :)
                            }
                        }
                    (: Skip Bo-Ltn if there's a bo already :)
                    else if($label-lang eq 'Bo-Ltn' and $contributor[common:valid-lang(@xml:lang) eq 'bo']) then
                        ()
                    (: Generate Bo-Ltn if there's bo :)
                    else if($label-lang eq 'bo') then (
                        element { QName('http://read.84000.co/ns/1.0', 'label') } {
                            attribute xml:lang { 'Bo-Ltn' },
                            text { common:wylie-from-bo($label-data) ! replace(., '/$', '') }
                        }
                    )
                    else if($label-lang eq 'en' and $contributor-1[@ref eq 'anon']) then
                        element { QName('http://read.84000.co/ns/1.0', 'label') } {
                            attribute xml:lang { 'en' },
                            text { 'Anon' }
                        }
                    else
                        element { QName('http://read.84000.co/ns/1.0', 'label') } {
                            attribute xml:lang { $label-lang },
                            text { normalize-space($label-data) }
                        }
            
            let $contributor-label := $contributor-labels[1]
            
            (: See if it already exists :)
            let $contributor-entity := 
                if($contributor-ref) then
                    $entities:entities/m:entity[m:source[@key eq $import-id]]
                else ()
            
            (: Handle entity record :)
            let $new-entity := 
                if(not($contributor-entity)) then (
                    element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                        attribute xml:id { entities:next-id() },
                        $contributor-label,
                        common:ws(2),
                        element source {
                            attribute key { $import-id }
                        },
                        common:ws(2),
                        element type {
                            attribute type { 'eft-person' }
                        },
                        common:ws(1)
                    }
                )
                (: Update entity exists already :)
                else ()
            
            (: Create entity :)
            let $update-entity := 
                if($new-entity) then
                    common:update('entity', $contributor-entity, $new-entity, $entities:entities, ())
                else ()
            
            (: Create the reference for the TEI :)
            let $contributor-id := 
                if($new-entity[@xml:id] and $update-entity) then
                    concat('eft:', $new-entity/@xml:id)
                else if($contributor-entity[@xml:id]) then
                    concat('eft:', $contributor-entity/@xml:id)
                else
                    concat('IMPORT-ERROR:', $import-id)
            
            let $contributor-role :=
                if($contributor-node eq 'reviser') then
                    'reviser'
                else if($contributor-node eq 'translator') then
                    'translatorTib'
                else ()
        
            let $contributor-revision :=
                if($contributor-node eq 'reviser' and $contributor-1[parent::m:revision[@rev_id]]) then
                    $contributor-1/parent::m:revision/@rev_id/string()
                else ()
        
            let $contributor-key :=
                if($contributor-1[parent::*[@type][not(@type eq 'main')]]) then
                    $contributor-1/parent::*/@type/string()
                else ()
        
            return (
                common:ws($indent),
                element { QName('http://www.tei-c.org/ns/1.0', if($contributor-node eq 'reviser') then 'editor' else 'author') } {
                    (: Calculated attributes :)
                    if($contributor-role) then
                        attribute role { $contributor-role }
                    else ()
                    ,
                    attribute ref { $contributor-id },
                    attribute xml:lang { $contributor-label/@xml:lang },
                    if($contributor-revision) then
                        attribute revision { $contributor-revision }
                    else ()
                    ,
                    if($contributor-key) then
                        attribute key { $contributor-key }
                    else ()
                    ,
                    (: Any other attributes :)
                    $contributor-1/@*[not(local-name(.) = ('ref', 'lang'))],
                    $contributor-label/text()
                }
            )
    )
    
    (: Notes :)
    else if(local-name($element) eq 'notesStmt') then (
        
        (: Prettify with an indent :)
        common:ws($indent),
            
        element { node-name($element) } {
        
            $element/@*,
            
            (: Copy notes that are not from this import :)
            for $node in $element/*[not(@import(: eq $import-file-name:))]
            return (
                common:ws($indent + 1),
                $node
            )
            ,
            
            common:ws($indent + 1),
            
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
            return (
                common:ws($indent + 1),
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
            ),
            
            (: Prettify with an indent :)
            common:ws($indent)
            
        }
    )
    else if(local-name($element) eq 'sourceDesc') then (
    
        (: Prettify with an indent :)
        common:ws($indent),
    
        element { node-name($element) } {
        
            $element/@*,
            
            for $node in $element/*[not(self::tei:link)](:[not(@import eq $import-file-name)]:)
            return
                local:merge-element($node, $import-text, $import-key, $indent + 1)
            ,
            for $link in $import-text/m:rel
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'link') } {
                    $link/@type,
                    attribute target { $link/@resource }(:,
                    attribute import { $import-file-name }:)
                }
            ,
            (: Prettify with an indent :)
            common:ws($indent)
            
        }
    )
    else (
    
        (: Prettify with an indent :)
        if(not(local-name($element) eq 'fileDesc')) then
            common:ws($indent)
        else ()
        ,
        
        (: Copy other nodes and recurse :)
        element { node-name($element) } {
            
            $element/@*,
            
            for $node in $element/node()
            return
                if($node instance of element()) then
                    local:merge-element($node, $import-text, $import-key, $indent + 1)
                else if($node instance of text() and normalize-space($node)) then
                    $node
                else ()
            ,
            
            (: Prettify with an indent :)
            if($element/*) then
                common:ws($indent)
            else ()
            
        }
    )
};

(:element { QName('http://read.84000.co/ns/1.0', 'imported') } {:)
    
    let $import-texts :=
        for $import-text in $local:import-texts//m:text(:[@text-id = ('UT23703-001-001','UT23703-001-019', 'UT23703-001-046','UT23703-001-053')]:)
        let $import-file-name := $import-text/parent::m:tengyur-data/m:head[1]/m:doc[1]/@doc_id/string()
        where $import-file-name = (
            (:"tengyur-data-1109-1179_PH_new_v2.4.xml",
            "tengyur-data-1180-1304_PH_new_v2.4.xml",
            "tengyur-data-1305-1345_PH_new_v2.4.xml",
            "tengyur-data-1346-1400_PH_new_v2.4.xml",
            "tengyur-data-1401-1424_PH_new_v2.3.xml",
            "tengyur-data-1425-1540_PH_new_v2.4.xml",
            "tengyur-data-1541-1606_PH_new_v2.4.xml",
            "tengyur-data-1607-1682_PH_new_v2.4.xml",
            "tengyur-data-1683-1783_PH_new_v2.4.xml",
            "tengyur-data-1784-1917_PH_new_v2.4.xml",
            "tengyur-data-1918-2089_PH_new_v2.4.xml",
            "tengyur-data-2090-2216_PH_new_v2.4.xml",
            "tengyur-data-2217-2254_PH_new_v2.4.xml",
            "tengyur-data-2255-2302_PH_new_v2.4.xml",
            "tengyur-data-2303-2325_PH_new_v2.4.xml",
            "tengyur-data-2326-2372_PH_new_v2.4.xml",
            "tengyur-data-2373-2449_PH_new_v2.4.xml",
            "tengyur-data-2450-2500_PH_new_v2.4.xml",
            "tengyur-data-2501-2531_PH_new_v2.4.xml",
            "tengyur-data-2532-2622_PH_new_v2.4.xml",
            "tengyur-data-2623-2669_PH_new_v2.4.xml",
            "tengyur-data-2670-2696_PH_new_v2.4.xml",
            "tengyur-data-2697-2740_PH_new_v2.4b.xml",
            "tengyur-data-2741-2847_PH_new_v2.4.xml",
            "tengyur-data-2848-2864_PH_new_v2.4.xml",
            "tengyur-data-2865-2905_PH_new_v2.4.xml",
            "tengyur-data-2906-2975_PH_new_v2.4.xml",
            "tengyur-data-2976-3051_PH_new_v2.4.xml",
            "tengyur-data-3052-3067_PH_new_v2.4.xml",
            "tengyur-data-3068-3116_PH_new_v2.4.xml",
            "tengyur-data-3117-3139_PH_new_v2.4.xml",
            "tengyur-data-3140-3222_PH_new_v2.4.xml",
            "tengyur-data-3223-3305_PH_new_v2.4.xml",
            "tengyur-data-3306-3399_PH_new_v2.4.xml",
            "tengyur-data-3400-3485_PH_new_v2.4.xml",
            "tengyur-data-3486-3565_PH_new_v2.4.xml",
            "tengyur-data-3566-3644_PH_new_v2.4.xml",
            "tengyur-data-3645-3706_PH_new_v2.4.xml",
            "tengyur-data-3707-3785_PH_new_v2.4.xml",
            "tengyur-data-3786-3823_PH_new_v2.4.xml",
            "tengyur-data-3824-3980_PH_new_v2.4.xml",:)
            "tengyur-data-3981-4019_PH_new_v2.4.xml",
            "tengyur-data-4020-4085_PH_new_v2.4.xml"(:,
            "tengyur-data-4086-4103_PH_new_v2.4.xml",
            "tengyur-data-4104-4149_PH_new_v2.4.xml",
            "tengyur-data-4150-4157_PH_new_v2.4.xml",
            "tengyur-data-4158-4202_PH_new_v2.4.xml",
            "tengyur-data-4203-4268_PH_new_v2.4.xml",
            "tengyur-data-4269-4305_PH_new_v2.4.xml",
            "tengyur-data-4306-4312_PH_new_v2.4.xml",
            "tengyur-data-4313-4327_PH_new_v2.4.xml",
            "tengyur-data-4328-4397_PH_new_v2.4.xml",
            "tengyur-data-4398-4464_PH_new_v2.4.xml":)
        )
        return $import-text
    
    let $import-text-ids := $import-texts/@text-id/string() ! upper-case(.)
    let $tei-texts := $local:tengyur-tei/id($import-text-ids)/ancestor::tei:TEI

    let $validation-issues := 
        for $import-text in $import-texts[1]
        
        let $import-text-id := $import-text/@text-id/string() ! upper-case(.)
        let $tei-text := $tei-texts/id($import-text-id)/ancestor::tei:TEI
        let $import-text-toh-keys := $import-text/m:toh/@key/string() ! lower-case(.)
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
    
    (: RESOLVE VALIDATION ISSUES :)
    if( $validation-issues ) then $validation-issues
    
    (: DISABLE TRIGGER :)
    else if(doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers) then <warning>{ 'DISABLE TRIGGERS BEFORE RUNNING SCRIPT' }</warning>
    
    (: DO THE IMPORT :)
    else
        for $import-text in $import-texts
            let $tei := tei-content:tei($import-text/@text-id ! upper-case(.), 'translation')
            let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
        return
        if($fileDesc) then
            let $fileDesc-merged := local:merge-element($fileDesc, $import-text, 'tengyur-data-2021-1', 2)
            return (
                (:$import-text,:)
                $fileDesc-merged,
                common:update(tei-content:id($tei), $fileDesc, $fileDesc-merged, (), ())
            )
        else
            <error>{$import-text/@text-id}</error>
        
(:}:)