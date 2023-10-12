declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace functx="http://www.functx.com";

let $archive-tei := collection('/db/apps/84000-data/archived/tei/2.19.0/translations')
let $trigger := doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers/ex:trigger

return
    if($trigger) then 
        <warning>{ 'DISABLE TRIGGERS BEFORE BATCH UPDATING TEI' }</warning>
    
    else
    
        for $wy-term-archived in $archive-tei//tei:back//tei:gloss/tei:term[@xml:lang eq 'Bo-Ltn'][matches(text(), '[A-Z]')]
        let $wy-term-archived-text := $wy-term-archived ! normalize-space(.)
        let $wy-term-archived-bo-text := common:bo-term($wy-term-archived-text)
        let $gloss-archived := $wy-term-archived/parent::tei:gloss
        let $gloss-current := $glossary:tei//tei:back//tei:gloss/id($gloss-archived/@xml:id)
        let $gloss-current-term-match := $gloss-current/tei:term[@xml:lang eq 'Bo-Ltn'][matches(normalize-space(text()), concat('^', lower-case(functx:escape-for-regex($wy-term-archived-text)),'\s?$'))]
        where $gloss-current[not(tei:term[@xml:lang eq 'Bo-Ltn'][matches(normalize-space(text()), concat('^', functx:escape-for-regex($wy-term-archived-text),'\s?$'))])]
        return 
            element mismatch {
                attribute wy-term-archived { $wy-term-archived-text },
                attribute bo-term-regenerated { $wy-term-archived-bo-text },
                attribute wy-term-archived-replaces-n { $gloss-current-term-match/@n },
                
                if(count($gloss-current-term-match[@n]) eq 1) then (
                
                    (:(\: Update wylie :\)
                    update replace $gloss-current-term-match/text() with text { $wy-term-archived-text },
                    (\: Update unicode :\)
                    update replace $gloss-current/tei:term[@xml:lang eq 'bo'][@n eq $gloss-current-term-match/@n]/text() with text { $wy-term-archived-bo-text },:)
                    
                    attribute resolved { true() },
                    $gloss-current
                    
                )
                else (
                    attribute resolved { false() },
                    $gloss-current,
                    element archived { $gloss-archived }
                )
            }



