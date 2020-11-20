xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace update-translation="http://operations.84000.co/update-translation" at "../../84000-operations/modules/update-translation.xql";
import module namespace store="http://read.84000.co/store" at "../modules/store.xql";

(: Create glossary caches for all published texts :)

declare variable $local:tei := 
    collection($common:translations-path)//tei:TEI
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id = (
            (:"UT22084-001-001"(\:Toh1-1:\),:)
            (:"UT22084-031-002"(\:Toh11:\),:)
            (:"UT22084-040-003"(\:Toh52:\),:)
            (:"UT22084-042-002"(\:Toh61:\),:)
            (:"UT22084-043-007"(\:Toh70:\),:)
            (:"UT22084-048-001"(\:Toh101:\),:)
            (:"UT22084-068-021"(\:Toh287:\),:)
            (:"UT22084-073-001"(\:Toh340:\),:)
            (:"UT22084-081-006"(\:Toh437:\),:)
            "UT22084-080-015"
         )]]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status = $tei-content:marked-up-status-ids]];

(: Remove note indexes :)
declare function local:remove-note-indexes() {
    (# exist:batch-transaction #) {
    
        for $note-index in $local:tei//tei:text//tei:note[@index]/@index
        return
            update delete $note-index
        
     }
};

(: Minor version increment should trigger section ids updates :)
declare function local:minor-version-increment() {
    for $tei in $local:tei
    return
        update-translation:minor-version-increment($tei, 'TEI migration 2.0.0')
};

(: Cache glossary :)
declare function local:cache-glossary() {
    for $tei in $local:tei
    return 
        update-translation:cache-glossary($tei, ())
};

(:local:remove-note-indexes(),:)
local:minor-version-increment(),
local:cache-glossary()
