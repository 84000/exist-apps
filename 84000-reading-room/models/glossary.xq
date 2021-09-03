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

(: The requested entity :)
let $entity-id := request:get-parameter('entity-id', '')
let $view-mode := request:get-parameter('view-mode', '')
let $flagged := request:get-parameter('flagged', '')
let $flag := $entities:flags//m:flag[@id eq  $flagged]

let $request-entity := $entities:entities//m:entity[@xml:id eq $entity-id]
let $request-entity := entities:entity($request-entity, true(), true(), true())
let $entity-show := 
    if($request-entity) then
        $request-entity
    else ()

(: Search parameters :)
(: Default to find similar matches to selected entity :)
let $search-default := (
        $entity-show/m:label[@primary-transliterated eq 'true'][@xml:lang eq 'Bo-Ltn']/data(), 
        $entity-show/m:label[@primary eq 'true'][@xml:lang eq 'Sa-Ltn']/data(),
        if($flag) then '' else (),
        'a'
    )[1]
let $search := request:get-parameter('search', $search-default) ! normalize-space(.)

let $type-default := (
        $entities:types/m:type[@id eq $entity-show/m:type[1]/@type]/@id, 
        $entities:types/m:type[1]/@id
    )[1]
let $type := request:get-parameter('type[]', $type-default)

let $term-lang-default := (
        $entity-show/m:label[@primary-transliterated eq 'true'][@xml:lang eq 'Bo-Ltn']/@xml:lang, 
        $entity-show/m:label[@primary eq 'true'][@xml:lang eq 'Sa-Ltn']/@xml:lang, 
        if($flag) then 'en' else (),
        'Bo-Ltn'
    )[1]
    
let $term-lang := request:get-parameter('term-lang', $term-lang-default) ! common:valid-lang(.)

let $type-glossary-type := $entities:types/m:type[@id = $type]/@glossary-type
let $glossary-search := 
    if(not($flag)) then
        glossary:glossary-search($type-glossary-type, $term-lang, $search)
    else()

let $entity-list := 
    if($flag) then
        entities:flagged($flagged, true(), true(), false())
    else
        entities:entities($glossary-search/@xml:id, true(), true(), false())

(:return if(true()) then $entity-list else:)

(: Sort the results :)
let $entity-list :=
    for $entity in $entity-list/m:entity
    (: Get relevant terms :)
    let $matching-terms :=
        for $term in $entity/m:instance/m:item/m:term
            [@xml:lang eq $term-lang]
            [
                matches(
                    string-join(tokenize(data(), '\s+') ! common:normalized-chars(.) ! common:alphanumeric(.), ' '),
                    concat(if(string-length($search) gt 1) then '(?:^|\s+)' else '^', string-join(tokenize($search, '\s+') ! common:normalized-chars(.) ! common:alphanumeric(.), '.*\s+'), ''), 
                    'i'
                )
            ]
        order by $term
        return
            $term ! common:normalized-chars(.) ! common:alphanumeric(.)
    (: Order by the fewest words / shortest relevant term, then alphabetically :)
    order by 
        if(string-length($search) gt 1) then min($matching-terms ! count(tokenize(data(), '\s+'))) else 1 ascending,
        (:min($matching-terms ! string-length(.)) ascending,:)
        lower-case($matching-terms[1]),
        $entity/m:instance[1]/m:item/m:sort-term
    
    return
        $entity

(: Show the first result :)
let $entity-show := 
    if(not($entity-show)) then
        entities:entity($entity-list[1], true(), true(), true())
    else 
        $entity-show

let $entity-types := common:add-selected-children($entities:types, $type)
let $term-langs := common:add-selected-children($term-langs, $term-lang)
return
    common:response(
        "glossary", 
        $common:app-id, 
        (
            <request xmlns="http://read.84000.co/ns/1.0" 
                entity-id="{ $entity-id }" 
                term-lang="{ $term-lang }" 
                view-mode="{ $view-mode }"
                flagged="{ $flagged }">
                <search>{ $search }</search>
                {
                    $entity-types,
                    $term-langs,
                    $glossary:view-modes/m:view-mode[@id eq $view-mode]
                }
            </request>,
            <browse-entities xmlns="http://read.84000.co/ns/1.0">{ $entity-list }</browse-entities>,
            <show-entity xmlns="http://read.84000.co/ns/1.0">{ $entity-show }</show-entity>,
            $entities:flags
        )
    )
