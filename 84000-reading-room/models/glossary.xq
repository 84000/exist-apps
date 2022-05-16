xquery version "3.0" encoding "UTF-8";
(:
    Accepts the entity-id, or filter (type|term-lang|search) parameters
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
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $term-langs := 
    <term-langs xmlns="http://read.84000.co/ns/1.0">
        <!--<lang id="bo" short-code="Tib" filter="false">Tibetan (Unicode)</lang>-->
        <lang id="Bo-Ltn" short-code="Wyl" filter="true">Tibetan</lang>
        <lang id="Sa-Ltn" short-code="Skt" filter="true">Sanskrit</lang>
        <lang id="en" short-code="Eng" filter="true">Our translation</lang>
    </term-langs>

let $flagged := request:get-parameter('flagged', '')
let $flag := $entities:flags//m:flag[@id eq  $flagged]

let $view-mode := request:get-parameter('view-mode', 'default')
let $view-mode := $glossary:view-modes/m:view-mode[@id eq $view-mode]
let $exclude-flagged := if($view-mode[@id eq 'editor']) then () else 'requires-attention'

(: The requested entity :)
let $entity-id := request:get-parameter('entity-id', '')
let $request-entity := $entities:entities//m:entity/id($entity-id)[1]

let $term-lang-default := (if($flag) then 'en' else (), 'Bo-Ltn')[1]
let $term-lang := request:get-parameter('term-lang', $term-lang-default) ! common:valid-lang(.)
let $term-lang := ($term-langs/m:lang[@id eq  $term-lang], $term-langs/m:lang[@id eq  $term-lang-default])[1]
let $term-langs := common:add-selected-children($term-langs, $term-lang/@id)

let $downloads := request:get-parameter('downloads', '')

let $search := request:get-parameter('search', '') ! normalize-space(.) ! common:normalize-unicode(.)
let $request-is-search := (
    not($request-entity) 
    and not($flag) 
    and not($downloads eq 'downloads') 
    and (string-length($search) eq 0 or string-length($search) gt 1) 
    and $term-lang[not(@id eq 'bo')]
)

let $term-type-defaults := 
    if($request-is-search) then 
        $entities:types/m:type/@id
    else if($flag) then 
        $entities:types/m:type[1]/@id
    else if($request-entity[m:type]) then
        $entities:types/m:type[@id eq $request-entity/m:type[1]/@type]/@id
    else 
        $entities:types/m:type[1]/@id
        
let $term-types := request:get-parameter('term-type[]', $term-type-defaults)
let $entity-types := common:add-selected-children($entities:types, $entities:types/m:type[@id = $term-types]/@id)

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary' },
        attribute resource-suffix { request:get-parameter('resource-suffix', 'html') },
        attribute entity-id { $request-entity/@xml:id },
        attribute term-lang { $term-lang/@id },
        attribute term-type { string-join($entity-types/m:type[@selected]/@id, ',')},
        attribute view-mode { $view-mode/@id },
        attribute flagged { $flag/@id },
        attribute downloads { $downloads },
        attribute search { $search },
        attribute request-is-search { $request-is-search },
        $entity-types,
        $term-langs,
        $view-mode
    }

(: Cache for a day :)
let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache'] and not($request-is-search)) then
        format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]") || '-' || replace($common:app-version, '\.', '-')
    else ()

let $cached := common:cache-get($request, $cache-key)

return if($cached) then $cached else

let $type-glossary-type := $entity-types/m:type[@selected]/@glossary-type

(: Do search :)
let $glossary-search := 
    if($flag) then
        glossary:glossary-flagged($flag/@id, $type-glossary-type)
    else if(not($request-entity) and not($flag) and not($downloads eq 'downloads')) then
        glossary:glossary-search($type-glossary-type, $term-lang/@id, $search, if(not($view-mode[@id eq 'editor'])) then 'excluded' else '')
    else ()

(: Convert glossary search to entities :)
let $glossary-search-entities := 
    for $gloss-id in distinct-values($glossary-search/@xml:id)
    let $instances-exclude := $entities:entities//m:instance[@id = $gloss-id][m:flag[@type eq $exclude-flagged]]
    let $instances := $entities:entities//m:instance[@id = $gloss-id] except $instances-exclude
    return
        $instances/parent::m:entity

let $entities-related := entities:related($request-entity | $glossary-search-entities, false(), $exclude-flagged, if(not($view-mode[@id eq 'editor'])) then 'excluded' else '')

let $downloads := 
    if($request[@downloads eq 'downloads']) then
        glossary:downloads()
    else ()

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id, 
        (
            $request,
            element { QName('http://read.84000.co/ns/1.0', 'entities')} {
                $request-entity | $glossary-search-entities ,
                element related {
                    $entities-related
                }
            },
            $entities:flags,
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
