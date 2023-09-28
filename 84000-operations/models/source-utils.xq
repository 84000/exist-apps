xquery version "3.0" encoding "UTF-8";
(:
    Utilities for the source editor mode
    ---------------------------------------------------------------
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";
import module namespace machine-translation="http://read.84000.co/machine-translation" at "../../84000-reading-room/modules/machine-translation.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $text-id := request:get-parameter('text-id', '')
let $tei := tei-content:tei($text-id, 'translation')

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { "source/utils" }, 
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute lang { common:request-lang() },
        attribute util { request:get-parameter('util', '')[. = ('glossary-builder','tm-search','machine-translation')] },
        $tei ! attribute text-id { tei-content:id(.) },
        attribute ref-index { request:get-parameter('ref-index', '')[functx:is-a-number(.)] ! xs:integer(.) },
        attribute first-record { (request:get-parameter('first-record', 1)[functx:is-a-number(.)], 1)[1] },
        attribute records-per-page { 10 },
        
        let $segment := request:get-parameter('segment', '')
        return (
            element segment { $segment },
        
            let $phrases := tokenize($segment, '\s+') ! replace(., '།', '')
            for $phrase in $phrases
            let $syllables := tokenize($phrase, '་')[matches(., '[\p{L}]+', 'i')]
            let $syllables-count := count($syllables)
            for $syllable at $index in $syllables
            for $scope in $index to $syllables-count
            return
                element search-string {
                    string-join($syllables[position() ge $index][position() le $scope], '་')
                }
            )
    }

let $result :=
    if($request[@util eq 'glossary-builder']) then
    
        (:let $query :=
            <query>
                {
                    for $term in tokenize($request/m:segment, '\s+')
                    return
                        <term>{ $term }</term>
                }
            </query>
        
        let $gloss-matches := $glossary:tei//tei:back/tei:div[@type eq 'glossary']//tei:term[ft:query(., $query)][@xml:lang eq 'bo']/parent::tei:gloss:)
        
        (:let $regex := concat('^(',string-join($combinations, '|'),')(ར|ས|འི)?(\s*)?(།)?$'):)
        (:let $regex := concat('(^|[^\p{L}])(', string-join(tokenize($request/m:segment/text(), '\s+') ! replace(., '།\s*$', '') ! normalize-space(.) ! functx:escape-for-regex(.), '|'), ')(ར|ས|འི)?([^\p{L}]+|$)'):)
        
        let $regex := concat('^(',string-join(distinct-values($request/m:search-string/text()), '|'),')(།)?$')
        
        let $gloss-matches := 
            for $term in $glossary:tei//tei:back/tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:term[matches(., $regex, 'i')][@xml:lang eq 'bo']
            let $gloss-id := $term/parent::tei:gloss/@xml:id
            group by $gloss-id
            (: Prioritise the longest match :)
            order by string-length($term/text()) descending
            return
                $term[1]/parent::tei:gloss
        
        let $existing-entities := $entities:entities//m:instance[@id = $tei//@xml:id]/parent::m:entity
        
        let $matched-entities := 
            for $gloss at $index in $gloss-matches
            let $instances := $entities:entities//m:instance[@id = $gloss/@xml:id]
            let $instances-entity := $instances/parent::m:entity except $existing-entities
            let $instances-entity-id := $instances-entity[1]/@xml:id
            where $instances-entity
            group by $instances-entity-id
            order by min($index)
            return
                $instances-entity[1]
        
        (:return if(true()) then $matched-entities else:)
        
        (: Extract a subset :)
        let $matched-entities-subset := subsequence($matched-entities, $request/@first-record, $request/@records-per-page)
        
        return
            element { QName('http://read.84000.co/ns/1.0', 'entities')} {
            
                attribute first-record { $request/@first-record },
                attribute max-records { $request/@records-per-page },
                attribute count-records { count($matched-entities) },
                (:element debug { $regex },:)
                
                $matched-entities-subset,
                
                element related { 
                    entities:related($matched-entities-subset, false(), ('glossary','knowledgebase'), (), 'excluded')
                }
                
            }
            
        (:search:search($request/m:segment/text(), $search:data-types/m:type[@id eq 'glossary'], '', $request/@first-record, $request/@records-per-page):)
    
    else if($request[@util eq 'tm-search']) then
        search:tm-search($request/m:segment/text(), 'bo', $request/@first-record, $request/@records-per-page, false())
    
    else if($request[@util eq 'machine-translation']) then
        machine-translation:dharmamitra-translation($request/m:segment/text())
    
    else ()

let $translation-data := $tei ! 
    element { QName('http://read.84000.co/ns/1.0', 'translation')} {
        attribute id { tei-content:id(.) },
        attribute status { tei-content:publication-status(.) },
        attribute status-group { tei-content:publication-status-group(.) },
        translation:titles(., ()),
        translation:toh(., '')
    }

let $xml-response :=
    common:response(
        $request/@model,
        $common:app-id,
        (
            $request,
            $result,
            $translation-data
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