declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace update-entity = "http://operations.84000.co/update-entity" at "../../84000-operations/modules/update-entity.xql";

let $text-id := 'UT22084-068-021'
let $glossary := $glossary:tei/id($text-id)/ancestor::tei:TEI//tei:back//tei:gloss

for $gloss in subsequence($glossary, 1, 40)

    let $existing-entity := $entities:entities//m:entity[m:instance/@id eq $gloss/@xml:id]
    
    where not($existing-entity)
    return (:if(true()) then $gloss else :)
    
        (: Is there a matching Sanskrit term? :)
        let $search-terms-sa := $gloss/tei:term[@xml:lang eq 'Sa-Ltn'][text()]
        let $regex-sa := concat('^\s*(', string-join($search-terms-sa, '|'), ')\s*$')
        let $matches-sa := 
            if(count($search-terms-sa) gt 0) then
                $glossary:tei//tei:back//tei:gloss
                    [tei:term[@xml:lang eq 'Sa-Ltn'][matches(., $regex-sa, 'i')]]
            else ()
        
        (: Is there a matching Tibetan term? :)
        let $search-terms-bo := distinct-values(($gloss/tei:term[@xml:lang eq 'Bo-Ltn'][text()], $gloss/tei:term[@xml:lang eq 'bo'][text()] ! common:wylie-from-bo(.)))
        let $regex-bo := concat('^\s*(', string-join($search-terms-bo, '|'), ')\s*$')
        let $matches-bo := 
            if(count($search-terms-bo) gt 0) then
                $glossary:tei//tei:back//tei:gloss
                    [tei:term[@xml:lang eq 'Bo-Ltn'][matches(., $regex-bo, 'i')]]
            else ()
        
        (: Does it match both Tibetan, Sanskrit and type? :)
        let $matches-full := $matches-sa[@xml:id = $matches-bo/@xml:id][@type eq $gloss/@type]
        
        (: Does it have an entity? :)
        let $matches-entity := $entities:entities//m:entity[m:instance/@id = $matches-full/@xml:id]
        
        (: If it's an unambigous, full match, with an entity (and a term) then merge :)
        let $action :=
            if($gloss[@type eq 'term'] and count($matches-entity) eq 1) then
                'merge'
            else
                'create'
        
        (: If there is some match then it requires some attention :)
        let $flag := if(count($matches-sa[@type eq $gloss/@type] | $matches-bo[@type eq $gloss/@type]) gt 0) then 'requires-attention' else ''
        
        let $do-update := 
            if($action eq 'merge') then
                update-entity:match-instance($matches-entity/@xml:id, $gloss/@xml:id, 'glossary-item')
            else
                update-entity:create($gloss, $flag)
                
        return 
            element update {
                attribute action { $action },
                attribute flag { $flag },
                $gloss,
                element match {
                    (:$matching-gloss,:)
                    $matches-entity
                },
                $do-update,
                element debug {
                    attribute glossary-editor-url { 'https://projects.84000-translate.org/edit-glossary.html?resource-id=' || $text-id || '&amp;resource-type=translation&amp;max-records=1&amp;glossary-id=' || $gloss/@xml:id },
                    element sa {$regex-sa},
                    element bo {$regex-bo}
                }
            }
        