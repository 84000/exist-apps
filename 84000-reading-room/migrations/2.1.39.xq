xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";

declare variable $local:tei := 
    collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id eq 'UT22084-001-001']];

(
    (: Move 84000-operations/config/contributor-types.xml -> 84000-data/config/contributor-types.xml :)
    if(doc-available('/db/apps/84000-operations/config/contributor-types.xml')) then (
        xmldb:move('/db/apps/84000-operations/config', '/db/apps/84000-data/config', 'contributor-types.xml'),
        sm:chgrp(xs:anyURI('/db/apps/84000-data/config/contributor-types.xml'), 'dba'),
        sm:chmod(xs:anyURI('/db/apps/84000-data/config/contributor-types.xml'), 'rw-rw-r--'),
        'Migrated contributor-types.xml'
    )
    else 
        'contributor-types.xml already migrated'
    
    (:(\: Migrate contributor refs contributors.xml#person-123 -> EFT:PERSON-123 :\)
    (\: Migrate sponsor refs sponsors.xml#sponsor-123 -> EFT:sponsor-123 :\)
    (\: Only run after this version is on Distribution and can accept the new prefix :\)
    (\: DON'T FORGET TO SWITCH OFF THE TRIGGER!! :\),
    (# exist:batch-transaction #) {
        
        for $tei in $local:tei[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[@ref]]
        return (
            tei-content:id($tei) || ' / ' || count($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[matches(@ref, '^(sponsors|contributors)\.xml#')]),
            for $ref in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[matches(@ref, '^(sponsors|contributors)\.xml#')]/@ref
            let $new-ref-string := replace($ref/string(), '^(sponsors|contributors)\.xml#', 'eft:')
            return (
                $ref/string(),
                $new-ref-string,
                update replace $ref with attribute ref { $new-ref-string }
            )
        )
     
     }:)
)