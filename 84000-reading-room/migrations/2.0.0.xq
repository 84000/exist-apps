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

(: Remove note indexes :)
declare function local:remove-note-indexes() {
    (# exist:batch-transaction #) {
     
        for $note-index in $local:tei//tei:text//tei:note[@index]/@index
        return
            update delete $note-index
     
     }
};

(: Minor version increment should trigger section ids updates and caching :)
declare function local:minor-version-increment() {
    for $tei in $local:tei[not(m:notes-cache)]
    return (
        tei-content:id($tei),
        update-translation:minor-version-increment($tei, 'TEI migration 2.0.0')
    )
};

(: Cache glossary :)
declare function local:cache-glossary() {
    for $tei in $local:tei[[not(m:glossary-cache/m:gloss/m:location)]]
    return (
        tei-content:id($tei),
        update-translation:cache-glossary($tei, ())
    )
};

(:local:remove-note-indexes(),:)
(:local:minor-version-increment(),:)
local:cache-glossary()
