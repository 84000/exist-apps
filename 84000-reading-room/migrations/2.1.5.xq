xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace update-translation="http://operations.84000.co/update-translation" at "../../84000-operations/modules/update-translation.xql";
import module namespace store="http://read.84000.co/store" at "../modules/store.xql";

declare variable $local:tei := 
    collection($common:translations-path)//tei:TEI
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $tei-content:marked-up-status-ids]];

(: Cache glossary :)
declare function local:cache() {
    for $tei in $local:tei
        [m:glossary-cache](:[1]:)
        (:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id eq 'UT22084-057-004']]:)
    return (
        (: ID for debug :)
        concat(
            tei-content:id($tei), ' : ',
            tei-content:source-bibl($tei, '')/tei:location/@count-pages/string(), ' pages'
        ),
        
        (: Create new caches :)
        update-translation:minor-version-increment($tei, 'TEI migration 2.1.5'),
        update-translation:cache-glossary($tei, ()),
        
        (: Store cache version number :)
        store:store-version-str(concat($common:data-path, '/cache'), concat(tei-content:id($tei), '.cache'), tei-content:version-str($tei)),
        
        (: Clear provisional caches :)
        common:update('clear-tei-notes-cache', $tei/m:notes-cache, (), (), ()),
        common:update('clear-tei-milestones-cache', $tei/m:milestones-cache, (), (), ()),
        common:update('clear-tei-folios-cache', $tei/m:folios-cache, (), (), ()),
        common:update('clear-tei-glossary-cache', $tei/m:glossary-cache, (), (), ())
        
    )
};

local:cache()
