xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-translation="http://operations.84000.co/update-translation" at "../modules/update-translation.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $start-letter := request:get-parameter('start-letter', '')
let $glossary-id := request:get-parameter('glossary-id', '')
let $test-alternative := request:get-parameter('test-alternative', '')
let $item-tab := request:get-parameter('tab-id', 'expressions')
let $form-action := request:get-parameter('form-action', '')

let $translation-files := translations:files($tei-content:marked-up-status-ids)

let $resource-id := 
    if(not($resource-id)) then
        $translation-files/m:file[1]/@id
    else
        $resource-id

let $tei := tei-content:tei($resource-id, 'translation')
let $selected-glossary-tei := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id eq $glossary-id]

(: Process the input :)
let $update-glossary := 
    if($selected-glossary-tei and request:get-parameter('form-action', '') = ('cache-expressions')) then
        update-translation:update-glossary($selected-glossary-tei)
    else
        ()

let $selected-glossary-start-letter := upper-case(substring($selected-glossary-tei/tei:term[not(@type)][not(@xml:lang) or @xml:lang eq ''][1], 1, 1))
let $start-letter := 
    if($start-letter eq '') then
        if($selected-glossary-start-letter gt '') then
            $selected-glossary-start-letter
        else
            'A'
    else
        $start-letter

let $translation-glossary := 
    if($tei) then
        translation:glossary($tei, $start-letter)
    else
        ()

let $entities := entities:entities($translation-glossary/m:item/@uid/string())

let $entity-id := 
    if($glossary-id gt '') then
        $entities/m:entity[m:definition/@id = $glossary-id]/@xml:id/string()
    else
        ''

let $matched-glossary-ids := 
    if($entity-id gt '') then
        $entities/m:entity[@xml:id eq $entity-id]/m:definition/@id/string()
    else
        ()

let $matched-glossaries := 
    element { QName('http://read.84000.co/ns/1.0', 'matched-glossaries') }{
        glossary:items(($matched-glossary-ids, $glossary-id), true())
    }

let $selected-glossary-item :=
    element { QName('http://read.84000.co/ns/1.0', 'selected-glossary') }{
        if($glossary-id gt '') then
        (
            $matched-glossaries/m:item[@uid eq $glossary-id],
            $selected-glossary-tei
        )
        else
            ()
    }

let $similar-glossaries := 
    element { QName('http://read.84000.co/ns/1.0', 'similar-glossaries') }{
        if($matched-glossaries/m:item) then
            glossary:similar-items($matched-glossaries/m:item)
        else
            ()
    }

let $similar-entities := 
    element { QName('http://read.84000.co/ns/1.0', 'similar-entities') }{
        if($matched-glossaries/m:item) then
            entities:entities($similar-glossaries/m:item/@uid/string())/m:entity
        else
            ()
    }

(: Compile the translation data :)
let $text-id := tei-content:id($tei)
let $source := tei-content:source($tei, $resource-id)

(: Parse the glossary using the transformation :)
let $translation-glossarized := 
    if($glossary-id) then
        transform:transform(
            transform:transform(
                transform:transform(
                    <translation 
                        xmlns="http://read.84000.co/ns/1.0" 
                        id="{ $text-id }"
                        status="{ tei-content:translation-status($tei) }"
                        status-group="{ tei-content:translation-status-group($tei) }"
                        page-url="{ translation:canonical-html($source/@key) }">
                        {(
                            translation:titles($tei),
                            $source,
                            translation:preface($tei),
                            translation:introduction($tei),
                            translation:prologue($tei),
                            translation:body($tei),
                            translation:colophon($tei),
                            translation:appendix($tei),
                            translation:abbreviations($tei),
                            translation:notes($tei),
                            translation:glossary($tei)
                        )}
                    </translation>,
                    doc(concat($common:app-path, "/xslt/milestones.xsl")), 
                    <parameters/>
                ),
                doc(concat($common:app-path, "/xslt/internal-refs.xsl")), 
                <parameters/>
            ),
            doc(concat($common:app-path, "/xslt/glossarize.xsl")), 
            <parameters>
                <param name="glossary-id" value="{ $glossary-id }"/>
                <param name="additional-term" value="{ $test-alternative }"/>
            </parameters>
        )
    else
        ()

(: Extract nodes with marked elements :)
let $expressions := 
    element { QName('http://read.84000.co/ns/1.0', 'expressions') }{     
    
        (: Specify the context :)
        attribute text-id { $text-id },
        attribute toh-key { $source/@key },
        attribute reading-room-url { $common:environment/m:url[@id eq 'reading-room']/text() },
        
        (: Expression items :)
        for $match at $match-position in $translation-glossarized//tei:match[@requested-glossary eq 'true']
        
            (: Expand to the node containing the match :)
            let $match-context := $match/ancestor-or-self::*[self::tei:p |  self::tei:q |  self::tei:lg |  self::tei:list |  self::tei:table |  self::tei:label |  self::tei:trailer][1]
            
            (: Also account for matches in glossary definitions :)
            let $match-context := 
                if(not($match-context))then
                    $match/ancestor-or-self::*[@uid][1]
                else
                    $match-context
            
            (: Get the nearest milestone :)
            let $nearest-milestone := $match-context/ancestor-or-self::*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]
            
            (: Group by nearest id - either milestone or glossary id :)
            let $nearest-xmlid := 
                if($nearest-milestone) then
                    $nearest-milestone/@xml:id
                else
                    $match-context/@uid
            
            (: Get the nearest milestone :)
            let $nearest-ref := 
                if($match-context[descendant::tei:ref[@ref-index]]) then
                    (: It's already in the text :)
                    (:$match-context/descendant::tei:ref[@ref-index][1]:)
                    ()
                else if($match-context/preceding-sibling::*[descendant::tei:ref[@ref-index]]) then
                    $match-context/preceding-sibling::*[descendant::tei:ref[@ref-index]][1]/descendant::tei:ref[@ref-index][1]
                else
                    (: To do: find the preceding folio outside of the scope of this match-context :)
                    ()
            
            group by $nearest-xmlid
            
            (: Retain the position :)
            order by $match-position[1]
        
        return
            
            (: Return an item per nearest milestone :)
            element { QName('http://read.84000.co/ns/1.0', 'item') }{
                
                (: Return the milestone :)
                $nearest-milestone[1],
                
                (: Return the data - this needs grouping as a context may have multiple matches, but a milestone may have multiple contexts :)
                for $match-context-single at $context-position in $match-context
                    group by $match-context-single
                    order by $context-position[1]
                return
                    element { node-name($match-context-single) } {
                        $match-context-single/@*,
                        
                        (: prepend the preceding source ref :)
                        if($context-position[1] eq 1) then (
                            $nearest-ref[1],
                            text { ' ' }
                        )
                        else ()
                        ,
                        
                        $match-context-single/node()
                    }
                
            }
                
    }
    
return
    common:response(
        'operations/glossary',
        'operations',
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                resource-id="{ $resource-id }"
                start-letter="{ $start-letter }"
                glossary-id="{ $glossary-id }"
                test-alternative="{ $test-alternative }"
                item-tab="{ $item-tab }"/>,
            $translation-glossary,
            $selected-glossary-item,
            $entities,
            $matched-glossaries,
            $similar-glossaries,
            $similar-entities,
            $expressions,
            $translation-files
        )
    )
