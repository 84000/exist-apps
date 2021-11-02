xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";

(: Migrate publication status to external file :)

declare function local:create-status-file(){
    
    let $teis := collection($common:translations-path)//tei:TEI
    
    (: Loop through texts with sponsor status :)
    let $publication-status := 
        element { QName('http://read.84000.co/ns/1.0', 'publication-status') } {
            for $tei in $teis
            let $text-id := tei-content:id($tei)
            order by $text-id
            return (
                common:ws(1),
                element { QName('http://read.84000.co/ns/1.0', 'publication') } {
                    attribute text-id { $text-id },
                    attribute status { ($tei//tei:teiHeader//tei:publicationStmt/@status, '0')[not(. eq '')][1] },
                    attribute updated { current-dateTime() },
                    attribute user { common:user-name() },
                    for $bibl in $tei/tei:teiHeader//tei:sourceDesc/tei:bibl
                    order by $bibl/@key
                    return (
                        common:ws(2),
                        element toh {
                            attribute key { $bibl/@key },
                            attribute parent-id { $bibl/tei:idno[@parent-id]/@parent-id },
                            attribute count-pages { $bibl/tei:location/@count-pages }
                        }
                    ),
                    common:ws(1)
                }
            ),
            $common:chr-nl
        }
    
    (: Create the entities file :)
    let $collection := concat($common:data-path, '/operations')
    let $file-name := 'publication-status.xml'
    let $create-file := xmldb:store($collection, $file-name, $publication-status)
    
    (: Set permissions :)
    let $file-uri := concat($collection, '/', $file-name)
    let $set-permissions := (
        sm:chown($file-uri, 'admin'),
        sm:chgrp($file-uri, 'operations'),
        sm:chmod($file-uri, 'rw-rw-r--')
    )
    
    return $publication-status
};

declare function local:migrate-titlestmt-refs(){
    
    (: Migrate contributor refs contributors.xml#person-123 -> EFT:PERSON-123 :)
    (: Migrate sponsor refs sponsors.xml#sponsor-123 -> EFT:sponsor-123 :)
    (: Only run after this version is on Distribution and can accept the new prefix :)
    (: DON'T FORGET TO SWITCH OFF THE TRIGGER!! :)
    (# exist:batch-transaction #) {
    
        let $teis := collection($common:translations-path)//tei:TEI[
                tei:teiHeader/tei:fileDesc
                    [tei:titleStmt/tei:*[@ref]]
                    [tei:publicationStmt/tei:idno[@xml:id eq 'UT22084-001-006']]
            ]
            
        for $tei in $teis
        return 
        
            (: DISABLE TRIGGER :)
            if(doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers) then <warning>{ 'DISABLE TRIGGERS BEFORE RUNNING SCRIPT' }</warning>
            
            (: DO THE MIGRATION :)
            else(
            
            (: Debug :)
            tei-content:id($tei) || ' / ' || count($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[matches(@ref, '^(sponsors|contributors)\.xml#')]),
            
            (: Do the update :)
            for $ref in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[matches(@ref, '^(sponsors|contributors)\.xml#')]/@ref
            let $new-ref-string := replace($ref/string(), '^(sponsors|contributors)\.xml#', 'eft:')
            let $new-ref := attribute ref { $new-ref-string }
            return (
                $ref/string(),
                $new-ref-string,
                update replace $ref with $new-ref
            )
            
        )
     
    }
    
};

(:local:create-status-file(),:)
local:migrate-titlestmt-refs()


