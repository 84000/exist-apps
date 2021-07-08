xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:kangyur-work-id := 'UT4CZ5369';
declare variable $local:kangyur-tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work = $local:kangyur-work-id]];
declare variable $local:import-texts := doc('/db/apps/84000-data/uploads/kangyur-import/new-kangyur-data.xml')/m:attributions/m:text[@id][@id eq 'UT22084-033-001'];

let $lowest-toh := 12
let $highest-toh := 12

let $validation-issues := 
    for $import-text in $local:import-texts
    let $import-text-id := $import-text/@id/string()
    let $tei-text := $local:kangyur-tei/id($import-text-id)/ancestor::tei:TEI
    let $import-text-toh-keys := $import-text/m:bibl[@type eq 'toh']/@key/string()
    let $tei-text-toh-keys := $tei-text/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work = $local:kangyur-work-id]/@key/string()
    order by $import-text-toh-keys[1]
    return (
        
        (: Check the text matches some TEI :)
        if(not($tei-text)) then
            element { QName('http://read.84000.co/ns/1.0', 'issue') } { 
                attribute type { 'missing-tei-text' },
                attribute id { $import-text-id }
            }
        else (),
        
        (: Check the Tohs are the same :)
        let $mismatch-toh-keys := count(($import-text-toh-keys[not(. = $tei-text-toh-keys)], $tei-text-toh-keys[not(. = $import-text-toh-keys)]))
        where $mismatch-toh-keys
        return
            element { QName('http://read.84000.co/ns/1.0', 'issue') } { 
                attribute type { 'mismatch-toh-keys' },
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
        ,
        
        (: Check labels :)
        let $attribution-labels-without-lang := $import-text//m:work[@type eq 'tibetanSource']/m:attribution/m:label[not(@lang)]
        let $sa-labels-with-whitespace := $import-text//m:work[@type eq 'tibetanSource']/m:attribution/m:label[@lang eq 'sa-Latn'][matches(data(), '.\s+.')]
        where $attribution-labels-without-lang | $sa-labels-with-whitespace
        return
            element { QName('http://read.84000.co/ns/1.0', 'issue') } { 
                attribute type { 'attribution-label-lang' },
                attribute id { $import-text-id },
                $attribution-labels-without-lang,
                $sa-labels-with-whitespace
            }
        (:,
        
        (\: Check for URIs :\)
        let $attribution-without-uri := $import-text//m:work[@type eq 'tibetanSource']/m:attribution[not(owl:sameAs[@rdf:resource])]
        where $attribution-without-uri
        return
            element { QName('http://read.84000.co/ns/1.0', 'issue') } { 
                attribute type { 'attribution-without-uri' },
                attribute id { $import-text-id },
                $attribution-without-uri
            }:)
    )

return

(: Check triggers are disabled :)
if(doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers) then
    element { QName('http://read.84000.co/ns/1.0', 'warning') } { 'DISABLE TRIGGERS BEFORE RUNNING SCRIPT' }

(: Check for validation issues :)
else if( $validation-issues ) then
    $validation-issues

(: Process the import :)
else
    
    let $import-id := 'kangyur-data-2021-WD'
    
    let $texts-imported :=
        for $import-text in $local:import-texts
        
        let $tei := tei-content:tei($import-text/@id, 'translation')
        
        let $bibls := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location[@work = $local:kangyur-work-id]]
        
        let $tohs := 
            for $bibl in $bibls
            return translation:toh($tei, $bibl/@key)
        let $tohs-1 := $tohs[1]
        let $toh-number := $tohs-1/@number[. gt ''] ! xs:integer(.)
        
        where 
            $toh-number ge $lowest-toh
            and $toh-number le $highest-toh
        
        order by 
            $toh-number, 
            $tohs-1/@letter, 
            $tohs-1/@chapter-number[. gt ''] ! xs:integer(.),
            $tohs-1/@chapter-letter
        
        return
            element { QName('http://read.84000.co/ns/1.0', 'text') } {

                for $import-bibl in $import-text/m:bibl
                
                let $tei-bibl := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq $import-bibl/@key]
                
                let $tei-bibl-authors-new := 
                    for $attribution in $import-bibl/m:work[@type eq 'tibetanSource']/m:attribution
                    
                    let $attribution-import-id := concat($import-id, '#', substring-after($attribution/@resource, 'eft:'))
                    
                    (: Create/find an entity based in the BDRC URI :)
                    let $contributor-entity := 
                        if($attribution[owl:sameAs[@rdf:resource]]) then
                            $entities:entities/m:entity[owl:sameAs[@rdf:resource eq $attribution/owl:sameAs/@rdf:resource]][1]
                        else if($attribution[@resource]) then
                            $entities:entities/m:entity[m:source[@key eq $attribution-import-id]][1]
                        else ()
                    
                    let $import-entity-labels := 
                        for $label in $attribution/m:label
                        let $label-data := $label/data()
                        group by $label-data
                        let $label-lang := common:valid-lang($label[1]/@lang)
                        order by if($label-lang eq 'Sa-Ltn') then 1 else if($label-lang eq 'bo') then 2 else 3
                        return 
                            element { QName('http://read.84000.co/ns/1.0', 'label') } {
                                attribute xml:lang { $label-lang },
                                attribute text-id { $import-text/@id/string() },
                                if($label-lang eq 'Sa-Ltn') then
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
                    
                    (: Add/update entity record :)
                    let $new-entity := 
                        (: Update the existing record :)
                        if($contributor-entity) then
                            element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                            
                                (: Copy existing :)
                                $contributor-entity/@*,
                                for $label in $contributor-entity/m:label
                                return (
                                    common:ws(2),
                                    $label
                                ),
                                
                                (: Additional labels :)
                                for $label in $import-entity-labels
                                where $label[not(text() = $contributor-entity/m:label/text())]
                                return (
                                    common:ws(2),
                                    $label
                                ),
                                
                                (: Other elements :)
                                for $contributor-element in $contributor-entity/*[not(self::m:label)]
                                return (
                                    common:ws(2),
                                    $contributor-element
                                ),
                                
                                common:ws(1)
                            }
                        
                        (: New record :)
                        else if($attribution[owl:sameAs[@rdf:resource]] | $attribution[@resource]) then
                            element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                                attribute xml:id { entities:next-id() },
                                
                                (: labels :)
                                for $label in $import-entity-labels
                                return (
                                    common:ws(2),
                                    $label
                                ),
                                
                                (: reference :)
                                if($attribution[owl:sameAs[@rdf:resource]]) then (
                                    for $sameAs in $attribution/owl:sameAs[@rdf:resource]
                                    return (
                                        common:ws(2),
                                        $sameAs
                                    )
                                )
                                else ()
                                ,
                                
                                (: source :)
                                common:ws(2),
                                element source {
                                    attribute key { $attribution-import-id }
                                },
                                
                                (: type :)
                                common:ws(2),
                                element type {
                                    attribute type { 'eft-person' }
                                },
                                common:ws(1)
                            }
                        else ()
                    
                    let $update-entities := 
                        if($new-entity) then 
                            common:update('entity', $contributor-entity, $new-entity, $entities:entities, ())
                        else ()
                    
                    
                    let $contributor-id := 
                        if($new-entity[@xml:id]) then
                            concat('eft:', $new-entity/@xml:id)
                        else ()
                    
                    let $element-name :=
                        if($attribution[@role = ('translationplace', 'revisionplace')]) then
                            'place'
                        else if($attribution[matches(@role, '^reviser\.*')]) then
                            'editor'
                        else
                            'author'
                    
                    let $element-role :=
                        if($attribution[@role = ('translationplace')]) then
                            'translation'
                        else if($attribution[@role = ('revisionplace')]) then
                            'revision'
                        else if($attribution[matches(@role, '^translator\.*Pandita$')]) then
                            'translatorPandita'
                        else if($attribution[matches(@role, '^translator\.*')]) then
                            'translatorTib'
                        else if($attribution[matches(@role, '^reviser\.*Pandita$')]) then
                            'reviserPandita'
                        else if($attribution[matches(@role, '^reviser\.*')]) then
                            'reviser'
                        else if($attribution[matches(@role, '^reciter\.*')]) then
                            'reciter'
                        else
                            'author'
                    
                    return
                        element { QName('http://www.tei-c.org/ns/1.0', $element-name) } {
                            $import-entity-labels[1]/@xml:lang,
                            if(not($element-role eq 'author')) then
                                attribute role { $element-role }
                            else (),
                            if($attribution[@revision]) then
                                $attribution/@revision
                            else (),
                            if($contributor-id) then 
                                attribute ref { $contributor-id }
                            else (),
                            $import-entity-labels[1]/text()
                        }
                
                let $tei-bibl-new := 
                    element { node-name($tei-bibl) } {
                        $tei-bibl/@*,
                        for $tei-bibl-node in $tei-bibl/*[not(self::tei:author | self::tei:editor | self::tei:place)]
                        return (
                            common:ws(5),
                            $tei-bibl-node,
                            if($tei-bibl-node[self::tei:biblScope]) then (
                                for $tei-bibl-author-new in $tei-bibl-authors-new
                                return (
                                    common:ws(5),
                                    $tei-bibl-author-new
                                )
                            )
                            else ()
                        ),
                        common:ws(4)
                    }
                
                return (
                    (: Visual check :)
                    $tei-bibl/tei:ref,
                    $import-bibl/m:label,
                    
                    (: Do the update :)
                    common:update($import-text/@id, $tei-bibl, $tei-bibl-new, (), ())
                )
            }
            
    return
        element { QName('http://read.84000.co/ns/1.0', 'import-kangyur-data') }{
        
            attribute count-import-texts { count($local:import-texts) },
            attribute count-texts-imported { count($texts-imported) },
            attribute lowest-toh { $lowest-toh },
            attribute highest-toh { $highest-toh },
            $texts-imported
            
        }