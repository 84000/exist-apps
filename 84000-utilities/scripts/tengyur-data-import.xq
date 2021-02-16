xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare variable $local:tengyur-tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT23703'];

declare function local:merge-element ($element as element(), $import-text as element(m:text), $import-filename as xs:string) {
    
    (: Titles :)
    (: TO DO: groups :)
    if(local-name($element) eq 'titleStmt') then
        element { node-name($element) } {
            $element/@*,
            for $title in $import-text/m:title
            return
            element title {
                $title/@*[not(local-name(.) eq 'lang')],
                attribute xml:lang {
                    common:valid-lang($title/@xml:lang)
                },
                $title/node()
            }
        }
    
    (: Notes :)
    else if(local-name($element) eq 'notesStmt') then
        element { node-name($element) } {
        
            $element/@*,
            $element/*,
            
            (: Skip notes that are from this import :)
            for $note in $import-text//m:note[not(@import eq $import-filename)]
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'note') } {
                    $note/@*[not(local-name(.) = ('lang', 'type'))],
                    attribute type { 'import' },
                    attribute import-type { $note/@type },
                    attribute date-time { current-dateTime() },
                    attribute user { 'admin' },
                    attribute import { $import-filename },
                    $note/node()
                }
        }
    
    (: Authors :)
    (: TO DO: create entities in seperate file for easy editing :)
    else if(local-name($element) = ('author', 'translator', 'reviser')) then
        if(not($element/following-sibling::tei:author)) then (
            for $contributor in $import-text//m:author | $import-text//m:translator | $import-text//m:reviser
            return
                element { QName('http://www.tei-c.org/ns/1.0', local-name($contributor)) } {
                    $contributor/@*[not(local-name(.) eq 'lang')],
                    attribute xml:lang {
                        common:valid-lang($contributor/@xml:lang)
                    },
                    $contributor/node()
                }
        )
        else ()
    else
    
    (: Copy other nodes and recurse :)
    element { node-name($element) } {
        
        $element/@*,
        
        for $node in $element/node()
        return
            if($node instance of element()) then
                local:merge-element ($node, $import-text, $import-filename)
            else if($node instance of text() and normalize-space($node)) then
                $node
            else 
                ()
    }
};

element { QName('http://read.84000.co/ns/1.0', 'imported') } {
    
    let $import-filename := "tengyur-data-1109-1179_PH_new.xml"
    let $import-texts := doc(concat('/db/apps/84000-data/uploads/tengyur-data/', $import-filename))//m:text
    for $import-text in $import-texts[@text-id eq 'UT23703-001-001']
    let $tei := tei-content:tei($import-text/@text-id, 'translation')
    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    let $fileDesc-merged := local:merge-element ($fileDesc, $import-text, $import-filename)
    return (
        $fileDesc-merged,
        $import-text
    )

}