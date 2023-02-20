declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";

declare function local:check-skt-term-content() {
    $glossary:tei//tei:back//tei:gloss[tei:term[@xml:lang eq 'Sa-Ltn'][count(node()) gt 1]]
};

declare function local:update-skt-term-case() {

    for $tei in $glossary:tei
    
    let $text-id := tei-content:id($tei)
    
    let $gloss-uppercase-skt := 
        for $gloss in $tei//tei:back//tei:gloss
        where $gloss/tei:term[@xml:lang eq 'Sa-Ltn'][matches(text(), '^[ABCDEFGHIJKLMNOPQRSTUVWXYZĀḌÉḤĪḶḸṂṆÑṄṚṜṢŚṬŪṀ]')]
        return
            $gloss
    
    where $gloss-uppercase-skt
    return (
        (:$text-id,:)
        (:for $gloss in $gloss-uppercase-skt
        let $terms-skt := $gloss/tei:term[@xml:lang eq 'Sa-Ltn']
        return (
            (\:$gloss:\)
            for $term-skt in $terms-skt
            return 
                concat($gloss/@xml:id, ',', $term-skt/text(), ',', lower-case($term-skt/text()))
        ),:)
        
        util:log('info', concat('update-skt-term-case:', $text-id)),
        
        (: Update the file and the trigger will correct the terms, and flag it for deployment :)
        update-tei:minor-version-increment($tei, 'correct-sanskrit-terms-case')
        
    )
    
};

(:local:check-skt-term-content():)
local:update-skt-term-case()