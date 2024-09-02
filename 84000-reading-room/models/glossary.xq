xquery version "3.0" encoding "UTF-8";
(:
    Accepts the entity-id
    -------------------------------------------------------------------
    For SEO purposes we allow for single page presentation of the 
    entities e.g. entity-id=entity-123. 
    Links to these individual entities are exposed through the browse page.
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace devanagari="http://read.84000.co/devanagari" at "devanagari.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', 'search')
let $resource-suffix := request:get-parameter('resource-suffix', '')

let $term-langs := 
    <term-langs xmlns="http://read.84000.co/ns/1.0">
        <lang id="bo" short-code="Tib" filter="true">Tibetan</lang>
        <lang id="Sa-Ltn" short-code="Skt" filter="true">Sanskrit</lang>
        <lang id="en" short-code="Eng" filter="true">Our Translation</lang>
    </term-langs>

let $flagged := request:get-parameter('flagged', '')
let $flag := $entities:flags//m:flag[@id eq  $flagged]

let $view-mode := request:get-parameter('view-mode', 'default')
let $view-mode := $glossary:view-modes/m:view-mode[@id eq $view-mode]
let $exclude-flagged := if($view-mode[@id eq 'editor']) then () else 'requires-attention'
let $exclude-status := if(not($view-mode[@id eq 'editor'])) then 'excluded' else ''

let $term-lang-default := (if($flag) then 'en' else (), 'bo')[1]
let $term-lang := request:get-parameter('term-lang', '') ! common:valid-lang(.)
(: If invalid request set default:)
let $term-lang := ($term-langs/m:lang[@id eq  $term-lang], $term-langs/m:lang[@id eq  $term-lang-default])[1]
let $term-langs := common:add-selected-children($term-langs, $term-lang/@id)

let $term-types := request:get-parameter('term-type[]', $entities:types/m:type[@glossary-type]/@id)[. = $entities:types/m:type[@glossary-type]/@id]
let $entity-types := common:add-selected-children($entities:types, $entities:types/m:type[@id = $term-types]/@id)

let $search := request:get-parameter('search', '') ! normalize-space(.) ! common:normalize-unicode(.)

let $letter := request:get-parameter('letter', '')

let $alphabet :=
    element { QName('http://read.84000.co/ns/1.0', 'alphabet') } {
        attribute xml:lang { if($term-lang/@id eq 'Bo-Ltn') then 'bo' else $term-lang/@id },
        for $regex at $index in 
            if($term-lang/@id eq 'bo') then
                ('ཀ','ཁ','ག','ང','ཅ','ཆ','ཇ','ཉ','ཏ','ཐ','ད','ན','པ','ཕ','བ','མ','ཙ','ཚ','ཛ','ཝ','ཞ','ཟ','འ','ཡ','ར','ལ','ཤ','ས','ཧ','ཨ')
            else if ($term-lang/@id eq 'Sa-Ltn') then
                ('a','ā','i','ī','u','ū','ṛ','ṝ','ḷ','ḹ','e','ai','o','au', 'k[^h]','kh','g[^h]','gh','ṅ','c[^h]','ch','j[^h]','jh','ñ','ṭ[^h]','ṭh','ḍ[^h]','ḍh','ṇ','t[^h]','th','d[^h]','dh','n','p[^h]','ph','b[^h]','bh','m','y','r','l','v','ś','ṣ','s','h')
            else
                ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
        
        let $display := replace(replace($regex, '\[.+\]', ''), '\|.+', '') ! normalize-space(.) ! common:normalize-unicode(.) ! concat(., if($term-lang/@id eq 'bo') then '་' else '')
        return
            element letter {
                attribute index { $index },
                attribute regex { 
                    if($term-lang/@id eq 'en') then
                        concat('^(The\s+|A\s+|An\s+)?\s*', $regex)
                    else
                        concat('^\s*', $regex)
                },
                if(not($search gt '') and $index ! xs:string(.) eq $letter) then
                    attribute selected { 'selected' }
                else (),
                if($term-lang/@id eq 'bo') then
                    attribute wylie { common:wylie-from-bo($display) }
                else (),
                $display
            }
    }

let $first-record := 
    if(functx:is-a-number(request:get-parameter('first-record', 1))) then
        request:get-parameter('first-record', 1)
    else 1

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary' },
        attribute resource-id { $resource-id },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute term-lang { $term-lang/@id },
        attribute term-type { string-join($term-types, ',') },
        attribute view-mode { $view-mode/@id },
        attribute flagged { $flag/@id },
        attribute letter { $alphabet/m:letter[@selected]/@index },
        attribute sort { request:get-parameter('sort', 'term')[. = ('term','frequency')] },
        attribute first-record { $first-record },
        attribute records-per-page { 20 },
        attribute template { request:get-parameter('template', 'website-page')[. = ('website-page','embedded')] },
        
        element search { if(not($flag) and not($resource-id eq 'downloads') and $search gt '') then $search else '' },
        
        if($term-lang/@id eq 'bo') then
            element search-bo { 
                if(not(common:string-is-bo($search))) then
                    $search ! lower-case(.) ! common:bo-from-wylie(.) ! replace(., '་$', '') 
                else
                    $search
            }
        
        else if($term-lang/@id eq 'Sa-Ltn') then
            element search-sa { 
                if(devanagari:string-is-dev($search)) then
                    $search ! devanagari:to-iast($search)
                else
                    $search
            }
        
        else ()
        ,
        $entity-types,
        $term-langs,
        $view-mode,
        $alphabet
    }

(: Cache for a day :)
let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache'] and not($flag) and not($request[@resource-id eq 'downloads']) and not($request/m:search/text() gt '')) then
        let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
        where $entities-timestamp instance of xs:dateTime
        return
            lower-case(
                string-join((
                    current-dateTime() ! format-dateTime(., "[Y0001]-[M01]-[D01]"),
                    $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                    $common:app-version ! replace(., '\.', '-')
                ),'-')
            )
    else ()

let $cached := common:cache-get($request, $cache-key)

return 
    if($cached) then $cached 
    
    else
        
        let $glossary-types := $entity-types/m:type[@selected]/@glossary-type
        
        (: Get matching terms :)
        let $term-matches := 
            if($flag) then ()
            
            else if($request/m:search[text() gt '']) then
                glossary:glossary-search($glossary-types, $term-lang/@id, $request/m:search, $exclude-status)
                
            else if($alphabet/m:letter[@selected]) then
                glossary:glossary-startletter($glossary-types, $term-lang/@id, $alphabet/m:letter[@selected]/@regex, $exclude-status)
            
            else if($view-mode[@id eq 'editor'] and count($glossary-types) eq 1) then
                glossary:glossary-startletter($glossary-types, $term-lang/@id, '.*', $exclude-status)
            
            else ()
        
        (: Convert terms to entries :)
        let $glossary-matches := 
            if($flag) then
                glossary:glossary-flagged($flag/@id, $glossary-types)
            
            else if($term-matches) then
                
                (: Sort logic :)
                let $term-matches-sorted :=
                    for $term in $term-matches
                    
                    let $sort-term := 
                        if(not($term/@xml:lang) or $term/@xml:lang eq 'en') then
                            $term/text() ! normalize-space(.) ! lower-case(.) ! common:normalized-chars(.) ! replace(., '^\s*(The\s+|A\s+|An\s+)', '', 'i')
                        else if($term/@xml:lang eq 'bo') then
                            $term/text() ! normalize-space(.) ! common:wylie-from-bo(.) ! common:alphanumeric(.)
                        else if($term/text() gt '') then
                            $term/text() ! normalize-space(.) ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.)
                        else ()
                    
                    let $sort-regex := 
                        if($alphabet/m:letter[@selected]) then 
                            $alphabet/m:letter[@selected]/@regex
                        else if(not($term/@xml:lang)) then
                            $request/m:search ! lower-case(.) ! common:normalized-chars(.) ! replace(., '^\s*(The\s+|A\s+|An\s+)', '', 'i') ! functx:escape-for-regex(.)
                        else if($term/@xml:lang eq 'bo') then 
                            $request/m:search ! common:wylie-from-bo(.) ! common:alphanumeric(.) ! functx:escape-for-regex(.)
                        else if(common:alphanumeric($request/m:search) gt '') then
                            $request/m:search ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.) ! functx:escape-for-regex(.)
                        else if($request/m:search gt '') then
                            $request/m:search ! common:normalized-chars(.) ! functx:escape-for-regex(.)
                        else ()
                    
                    let $sort-index := $sort-term[. gt ''] ! $sort-regex[. gt ''] ! functx:index-of-match-first($sort-term, $sort-regex)
                    
                    order by if($sort-index eq 1) then 0 else 1, $sort-term
                    return $term
                
                for $term at $index in $term-matches-sorted
                let $gloss := $term/parent::tei:gloss
                let $gloss-id := $gloss/@xml:id
                where $gloss-id
                group by $gloss-id
                order by min($index)
                return
                    $gloss[1]
                    
            else ()
        
        (: Convert entries to entities :)
        let $matched-entities := 
            for $gloss at $index in $glossary-matches
            let $instances-exclude := $entities:entities//m:instance[@id = $gloss/@xml:id][m:flag[@type eq $exclude-flagged]]
            let $instances := $entities:entities//m:instance[@id = $gloss/@xml:id] except $instances-exclude
            let $instances-entity := $instances/parent::m:entity
            let $instances-entity-id := $instances-entity[1]/@xml:id
            group by $instances-entity-id
            let $instances-count := count($glossary:tei/id(($instances-entity/m:instance except $instances-exclude)/@id))
            order by 
                if($request[@sort eq 'frequency']) then -$instances-count 
                else if($request[@sort eq 'usage']) then min($index)
                else min($index),
                min($index)
            return
                $instances-entity[1]
        
        (: Extract a subset :)
        let $matched-entities-subset := subsequence($matched-entities, $first-record, $request/@records-per-page)
        
        (: Get related entities :)
        let $entities-related := entities:related($matched-entities-subset, false(), ('glossary','knowledgebase'), $exclude-flagged, $exclude-status)
        
        let $downloads := 
            if($request[@resource-id eq 'downloads']) then
                glossary:downloads()
            else ()
        
        let $xml-response :=
            common:response(
                $request/@model,
                $common:app-id, 
                (
                    $request,
                    element { QName('http://read.84000.co/ns/1.0', 'entities')} {
                        attribute count-entities { count($matched-entities) },
                        $matched-entities-subset,
                        element related { 
                            $entities-related
                        }
                    },
                    $entities:flags,
                    $glossary:attestation-types,
                    $downloads
                )
            )
        
        return
        
            (: html :)
            if($request/@resource-suffix = ('html')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/glossary.xsl"), $cache-key)
            
            (: xml :)
            else 
                common:serialize-xml($xml-response)
