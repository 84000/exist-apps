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

declare function local:merge-element ($titleStmt as element(tei:titleStmt), $import-text as element(m:text)) {
    
    element { node-name($titleStmt) } {
    
        (: Copy attributes :)
        $titleStmt/@*,
        
        (: Import titles :)
        for $title in $import-text/m:title
        let $valid-lang := common:valid-lang($title/@xml:lang)
        let $title-text := normalize-space($title/text())
        order by if($title[@type eq 'mainTitle']) then 1 else if($title[@type eq 'longTitle']) then 2 else 3
        where $title-text gt ''
        return (
            common:ws(4),
            element title {
                if ($title[@type = ('mainTitle', 'longTitle', 'otherTitle')]) then 
                    $title/@type
                else (
                    attribute type { 'otherTitle' }
                ),
                attribute xml:lang { $valid-lang },
                if($title[matches($title-text, '^\*.*')]) then
                    attribute rend { 'reconstruction' }
                else ()
                ,
                $title/@*[not(local-name(.) = ('lang', 'type'))],
                if($valid-lang eq 'Sa-Ltn') then
                    functx:capitalize-first(
                        replace(
                            replace(
                                $title-text
                            , '^\*', '')                            (: Remove leading * :)
                        , '\-', '­')                                (: Hard to soft-hyphens :)
                    )                                               (: Title case :)
                else
                    $title-text
                
            }
        ),
        
        (: Copy non-title elements :)
        $titleStmt/*[not(self::tei:title)],
    
        (: Prettify with an indent :)
        common:ws(3)
    }
    
};

(:element { QName('http://read.84000.co/ns/1.0', 'imported') } {:)
    
    let $import-texts :=
        for $import-text in $local:import-texts//m:text
        let $import-file-name := $import-text/parent::m:tengyur-data/m:head[1]/m:doc[1]/@doc_id/string()
        where $import-file-name = (
            "tengyur-data-3981-4085_CD_v1.xml"
        )
        return $import-text
    
    let $import-text-ids := $import-texts/@text-id/string() ! upper-case(.)
    let $tei-texts := $local:tengyur-tei/id($import-text-ids)/ancestor::tei:TEI

    let $validation-issues := 
        for $import-text in $import-texts
        
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
            let $titleStmt := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt
            let $text-id := tei-content:id($tei)
        return
        if($titleStmt) then
            let $titleStmt-merged := local:merge-element($titleStmt, $import-text)
            return (
                (:$import-text,
                $titleStmt,
                $titleStmt-merged,:)
                common:update($text-id, $titleStmt, $titleStmt-merged, (), ())
            )
        else
            <error>{$import-text/@text-id}</error>
        
(:}:)