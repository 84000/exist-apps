xquery version "3.0" encoding "UTF-8";
(:
    Accepts the entity-id, or filter (type|term-lang|search) parameters
    Returns glossary content xml
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
        <lang id="Bo-Ltn" short-code="Wyl">Tibetan (Wylie)</lang>
        <lang id="Sa-Ltn" short-code="Skt">Sanskrit</lang>
        <lang id="en" short-code="Eng">Our translation</lang>
    </term-langs>

let $flagged := request:get-parameter('flagged', '')
let $flag := $entities:flags//m:flag[@id eq  $flagged]

let $view-mode := request:get-parameter('view-mode', '')
let $view-mode := $glossary:view-modes/m:view-mode[@id eq $view-mode]
let $exclude-flagged := if($view-mode[@id eq 'editor']) then () else 'requires-attention'

(: The requested entity :)
let $entity-id := request:get-parameter('entity-id', '')
let $request-entity := $entities:entities//m:entity/id($entity-id)
let $request-entity-instances-exclude := $request-entity/m:instance[m:flag[@type eq $exclude-flagged]]
let $request-entity-instances := $request-entity/m:instance[@type eq 'glossary-item'] except $request-entity-instances-exclude
let $request-entity-entries := glossary:entries($request-entity-instances/@id, false())
let $request-entity-terms-sorted := 
    for $term in $request-entity-entries/m:term[@xml:lang = ('Bo-Ltn', 'Sa-Ltn')]
    where not($term/data() = $glossary:empty-term-placeholders)
    order by 
        if($term[@xml:lang eq 'Bo-Ltn']) then 1 else 2,
        string-length($term) descending
    return
        $term
let $request-entity-terms-longest := $request-entity-terms-sorted[1]

(: Search parameters :)
(: Default to find similar matches to selected entity :)
let $search-default := (
    if($flag) then '' else (),
    $request-entity-terms-longest/data(), 
    'a'
)[1]
let $search := request:get-parameter('search', $search-default) ! normalize-space(.)

let $type-default := (
    $entities:types/m:type[@id eq $request-entity/m:type[1]/@type]/@id, 
    $entities:types/m:type[1]/@id
)[1]
let $type := request:get-parameter('type[]', $type-default)
let $entity-type := $entities:types/m:type[@id = $type]
let $entity-types := common:add-selected-children($entities:types, $entity-type/@id)

let $term-lang-default := (
    if($flag) then 'en' else (),
    $request-entity-terms-longest/@xml:lang, 
    'Bo-Ltn'
)[1]
let $term-lang := request:get-parameter('term-lang', $term-lang-default) ! common:valid-lang(.)
let $term-lang := $term-langs/m:lang[@id eq  $term-lang]
let $term-langs := common:add-selected-children($term-langs, $term-lang/@id)

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary' },
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute entity-id { $request-entity/@xml:id },
        attribute term-lang { $term-lang/@id },
        attribute type { $entity-type/@id },
        attribute view-mode { $view-mode/@id },
        attribute flagged { $flag/@id },
        element search { $search },
        $entity-types,
        $term-langs,
        $view-mode
    }

let $type-glossary-type := $entity-type/@glossary-type

let $glossary-search := 
    (: Get flagged entries :)
    if($flag) then
        glossary:glossary-flagged($flag/@id, $type-glossary-type)
    (: Get glossary entries based on criteria :)
    else
        glossary:glossary-search($type-glossary-type, $term-lang/@id, $search)

let $entity-list := 
    for $gloss-id in distinct-values($glossary-search/@xml:id)
    let $instances-exclude := $entities:entities//m:instance[@id = $gloss-id][m:flag[@type eq $exclude-flagged]]
    let $instances := $entities:entities//m:instance[@id = $gloss-id] except $instances-exclude
    return
        $instances/parent::m:entity

let $related := entities:related($request-entity | $entity-list, false(), $exclude-flagged, if(not($view-mode[@id eq 'editor'])) then 'excluded' else '')

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id, 
        (
            $request,
            <show-entity xmlns="http://read.84000.co/ns/1.0">{ $request-entity }</show-entity>,
            <entities xmlns="http://read.84000.co/ns/1.0">
                { $request-entity | $entity-list }
                <related>{ $related }</related>
            </entities>,
            $entities:flags
        )
    )

return

    (: html :)
    if($request/@resource-suffix = ('html')) then (
        common:html($xml-response, concat($common:app-path, "/views/html/glossary.xsl"), ())
    )
    
    (: xml :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
