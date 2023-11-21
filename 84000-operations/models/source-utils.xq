xquery version "3.0" encoding "UTF-8";
(:
    Utilities for the source editor mode
    ---------------------------------------------------------------
:)

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";
import module namespace machine-translation="http://read.84000.co/machine-translation" at "../../84000-reading-room/modules/machine-translation.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../modules/update-tm.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace translation-status="http://operations.84000.co/translation-status" at "../modules/translation-status.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $text-id := request:get-parameter('text-id', '')
let $tei := tei-content:tei($text-id, 'translation')
let $tmx := collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]
let $segment-ids := request:get-parameter('segment-id[]', '')[. = $tmx//tmx:tu/@id]
let $term-types := request:get-parameter('term-type[]', $entities:types/eft:type[@glossary-type]/@id)[. = $entities:types/eft:type[@glossary-type]/@id]
let $glossary-types := $entities:types/eft:type[@id = $term-types]/@glossary-type

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
    
        attribute model { "operations/source-utils" }, 
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() },
        $tei ! attribute text-id { tei-content:id(.) },
        attribute folio-index { request:get-parameter('folio-index', 1)[functx:is-a-number(.)] ! xs:integer(.) },
        attribute util { request:get-parameter('util', '')[. = ('resources','glossary','glossary-builder','tm-search','machine-translation','translate','review-folios','annotate-source'(:,'source-split':),'source-join','bibliography','help')] },
        
        common:add-selected-children($entities:types, $entities:types/eft:type[@id = $term-types]/@id),
        
        (:element segment { request:get-parameter('segment', '') ! replace(., '&#8203;', '') }:)
        let $unit-indexes := $tmx//tmx:tu[@id = $segment-ids] ! functx:index-of-node($tmx//tmx:tu, .)
        let $unit-index-first := min($unit-indexes)
        let $unit-index-last := max($unit-indexes)
        for $tu at $index in $tmx//tmx:tu
        where 
            $index ge $unit-index-first
            and $index le $unit-index-last
            and normalize-space($tu/tmx:tuv[@xml:lang eq 'bo']/tmx:seg/text())
        return (
            element segment { 
                $tu/@id,
                text { normalize-space($tu/tmx:tuv[@xml:lang eq 'bo']/tmx:seg/text()) ! replace(., '\{{2}[^\{\}]+\}{2}', '') }
            }
        )
        
    }

let $updates :=
    (: Add translation:)
    if(request:get-parameter('form-action', '') eq 'translate' and count($request/eft:segment) eq 1) then
        update-tm:update-english($tmx, $request/eft:segment/@id, request:get-parameter('translation', ''))
    
    (: Add glossary items :)
    (: ~ Needs a function for creating multiple items based on default settings
    else if(request:get-parameter('form-action', 'glossary-add-items')) then
        update-tei:glossary-add-items($tei)
        
    else:)
    (: Split a segment :)    
    (: ~ Problematic: wylie key? bcrd segment id? Associated annotations? Disabled for now.
    else if(request:get-parameter('form-action', '') eq 'source-split' and count($request/eft:segment) eq 1) then
        update-tm:update-tibetan($tmx, $request/eft:segment/@id, request:get-parameter('source-split', '')):)
    
    (: Join segments :)
    else if(request:get-parameter('form-action', '') eq 'source-join' and count($request/eft:segment) gt 1) then
        update-tm:merge-segments($tmx, $request/eft:segment/@id)
    
    (: Annotate etext :)
    else if(request:get-parameter('form-action', '') eq 'etext-note' and count($request/eft:segment) eq 1) then
        translation-status:update($request/@text-id)
    
    (: Annotate source :)
    else if(request:get-parameter('form-action', '') eq 'source-note' and count($request/eft:segment) eq 1) then
        translation-status:update($request/@text-id)
    
    else ()
    
let $glossary-existing := translation:glossary($tei, 'glossary', $translation:view-modes/eft:view-mode[@id eq 'editor'], ())

let $analysis := (

    (: Glossary matches :)
    if($request[@util eq 'glossary-builder'] and count($request/eft:segment) eq 1) then
        
        let $glossary-existing-bo := $glossary-existing//tei:term[@xml:lang eq 'bo'] ! replace(., '(་)?།$', '')
        let $segments-filtered := string-join($request/eft:segment, ' ') ! replace(., concat('(', string-join($glossary-existing-bo ! concat(., '(་)?(།)?'), '|'), ')'), '')
        
        let $search-strings :=
            for $phrase at $phrase-index in tokenize($segments-filtered, '\s+') ! replace(., '།', '')
            let $syllables := tokenize($phrase, '་')[matches(., '[\p{L}]+', 'i')]
            let $syllables-count := count($syllables)
            for $syllable at $syllable-index in $syllables
            for $length in 1 to ($syllables-count - ($syllable-index - 1))
            let $search-string := string-join($syllables[position() ge $syllable-index][position() le $length], '་') ! replace(., '(ར|ས|འི)$', '')
            where not($search-string = ('','ར','ས','འི','་','།'))
            return
                element search-string {
                    (:attribute phrase { $phrase-index },
                    attribute syllable { $syllable-index },
                    attribute length { $length },:)
                    (:attribute orig {  },:)
                    $search-string
                }
        
        let $regex := concat('^(', string-join(distinct-values($search-strings/text()) ! concat(., '(ར|ས|འི)?'), '|'),')་?།?$')
        
        let $gloss-matches := 
            for $term in $glossary:tei//tei:back/tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:term[matches(., $regex, 'i')][@xml:lang eq 'bo'][normalize-space(.)]
            let $gloss := $term/parent::tei:gloss
            let $gloss-id := $gloss/@xml:id
            group by $gloss-id
            where $gloss[@type = $glossary-types]
            order by 
                functx:index-of-match-first($request/eft:segment/text(), functx:escape-for-regex(replace($term[1], '(ར|ས|འི)?(་)?(།)?$', ''))) ascending,
                (: Prioritise the longest match :)
                string-length(string-join($term[1]/text())) descending
            return
                $term[1]/parent::tei:gloss
        
        let $entities-existing := $entities:entities//eft:instance[@id = $glossary-existing//@xml:id]/parent::eft:entity
        
        let $entities-suggested := 
            for $gloss at $index in $gloss-matches
            let $instances := $entities:entities//eft:instance[@id = $gloss/@xml:id]
            let $instances-entity := $instances/parent::eft:entity except $entities-existing
            let $instances-entity-id := $instances-entity[1]/@xml:id
            where $instances-entity
            group by $instances-entity-id
            order by min($index)
            return
                $instances-entity[1]
        
        (:return if(true()) then $matched-entities else:)
        
        return
            element { QName('http://read.84000.co/ns/1.0', 'entities')} {
            
                element regex { $regex },
                
                $entities-existing | $entities-suggested,
                
                element related { 
                    entities:related($entities-suggested, false(), ('glossary','knowledgebase'), (), 'excluded')
                }
                
            }
        
    else 
        element { QName('http://read.84000.co/ns/1.0', 'entities')} {
            
            $entities:entities//eft:instance[@id = $glossary-existing//@xml:id]/parent::eft:entity
            
        }
    ,
    
    (: TM search :)
    if($request[@util eq 'tm-search'] and count($request/eft:segment) gt 0) then
        search:tm-search(string-join($request/eft:segment, ' '), 'bo', 1, 100, false(), $tmx)
    else ()
    ,
    
    (: Machine translation :)
    if($request[@util eq 'machine-translation'] and count($request/eft:segment) gt 0) then
        machine-translation:dharmamitra-translation(string-join($request/eft:segment, ' '))
    else ()
    ,
    
    (: Annotations :)
    if($request[@util = ('review-folios', 'annotate-source')] and count($request/eft:segment) eq 1) then
        element { QName('http://read.84000.co/ns/1.0', 'translation-status') } {
            translation-status:texts($request/@text-id, false())
        }
    else ()
    
)

let $toh := $tei ! translation:toh(., '')
let $translation-data := $tei ! 
    element { QName('http://read.84000.co/ns/1.0', 'translation')} {
        attribute id { tei-content:id(.) },
        attribute status { tei-content:publication-status(.) },
        attribute status-group { tei-content:publication-status-group(.) },
        translation:titles(., ()),
        $toh,
        translation:location($tei, $toh/@key),
        $glossary-existing
    }

let $xml-response :=
    common:response(
        $request/@model,
        $common:app-id,
        (
            $request,
            $tmx,
            $analysis,
            $translation-data,
            $translation-data ! source:bdrc-rdf(eft:toh),
            $tei ! translation:outline-cached(.)
        
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/source-utils.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )