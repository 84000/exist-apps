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
let $glossary-id := request:get-parameter('glossary-id', '')
let $start-letter := request:get-parameter('start-letter', '')
let $item-tab := request:get-parameter('tab-id', 'expressions')
let $form-action := request:get-parameter('form-action', '')

let $resource-id := 
    if(not($resource-id)) then
        translations:files($tei-content:marked-up-status-ids)/m:file[1]/@id
    else
        $resource-id

let $tei := tei-content:tei($resource-id, 'translation')

(: Get the next xml:id :)
let $glossary-id := 
    if($glossary-id eq '') then
        tei-content:next-xml-id($tei)
    else
        $glossary-id

(: Process the input :)
let $update-glossary := 
    if($form-action = ('update-glossary', 'cache-expressions')) then
        update-translation:update-glossary($tei, $glossary-id)
    else
        ()

(: Get the glossary from the tei :)
let $selected-glossary-tei := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id eq $glossary-id]
(: Validate there is a record :)
let $glossary-id := $selected-glossary-tei/@xml:id

(: Set a start letter :)
let $start-letter := 
    if($start-letter eq '') then
        if($selected-glossary-tei) then
            upper-case(substring(glossary:sort-term($selected-glossary-tei), 1, 1))
        else
            'A'
    else
        $start-letter

(: Get all the glossaries for the page :)
let $translation-glossary := 
    if($tei) then
        translation:glossary($tei, $start-letter)
    else
        ()

(: Get glossaries with the same entity :)
let $matched-glossary-ids := $translation-glossary/m:item[@uid eq $glossary-id]/m:entity/m:definition/@id/string()
let $matched-glossaries := 
    element { QName('http://read.84000.co/ns/1.0', 'matched-glossaries') }{
        glossary:items(($matched-glossary-ids, $glossary-id), true())
    }

(: Get similar glossaries using data accross matches :)
let $similar-glossaries := 
    element { QName('http://read.84000.co/ns/1.0', 'similar-glossaries') }{
        if($matched-glossaries/m:item) then
            glossary:similar-items($matched-glossaries/m:item)
        else
            ()
    }

(: Add extra data about the selected glossary - markdown :)
let $selected-glossary-item :=
    element { QName('http://read.84000.co/ns/1.0', 'selected-glossary') }{
        if($glossary-id gt '') then
        (
            $matched-glossaries/m:item[@uid eq $glossary-id],
            element markdown {
                for $definition in $matched-glossaries/m:item[@uid eq $glossary-id]/m:definition
                return 
                    element { node-name($definition) }{
                        $definition/@*,
                        common:markdown($definition/node(), 'http://www.tei-c.org/ns/1.0')
                    }
            }
        )
        else
            ()
    }

(: Compile the translation data - we need text-id and toh-key :)
let $text-id := tei-content:id($tei)
let $source := tei-content:source($tei, $resource-id)
let $toh-key := $source/@key

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
                        page-url="{ translation:canonical-html($toh-key) }">
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
                <param name="use-cache" value="false"/>
            </parameters>
        )
    else
        ()

(: Extract nodes with marked elements :)
let $expressions := 
    element { QName('http://read.84000.co/ns/1.0', 'expressions') }{     
    
        (: Specify the context :)
        attribute text-id { $text-id },
        attribute toh-key { $toh-key },
        attribute reading-room-url { $common:environment/m:url[@id eq 'reading-room']/text() },
        
        (: Expression items :)
        for $match at $match-position in $translation-glossarized//tei:match[@requested-glossary eq 'true']
        
            (: Expand to the node containing the match :)
            let $match-context := ($match/ancestor-or-self::*[@nearest-milestone][1], $match/ancestor-or-self::*[@uid][1])[1]
            
            (: Group by nearest id - either milestone or glossary id :)
            let $nearest-xml-id := ($match-context/@nearest-milestone, $match-context/@uid)[1]
            
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
            
            group by $nearest-xml-id
            
            (: Retain the position :)
            order by $match-position[1]
        
        return
            
            (: Return an item per nearest milestone :)
            element { QName('http://read.84000.co/ns/1.0', 'item') }{
                
                attribute nearest-xml-id { $nearest-xml-id },
                
                (: Return the milestone :)
                $translation-glossarized//tei:milestone[@xml:id eq $nearest-xml-id],
                
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
            element { QName('http://read.84000.co/ns/1.0', 'request') }{
                attribute resource-id { request:get-parameter('resource-id', '') },
                attribute start-letter { request:get-parameter('start-letter', '') },
                attribute glossary-id { request:get-parameter('glossary-id', '') },
                attribute item-tab { request:get-parameter('tab-id', 'expressions') }
            },
            element { QName('http://read.84000.co/ns/1.0', 'text') }{
                attribute id { $text-id },
                attribute toh-key { $toh-key},
                element { QName('http://read.84000.co/ns/1.0', 'title') }{
                    tei-content:title($tei)
                }
            },
            $translation-glossary,
            $selected-glossary-item,
            $expressions,
            $matched-glossaries,
            $similar-glossaries,
            $update-glossary
        )
    )
