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
let $request-entity := entities:entity($entities:entities/m:entity[@xml:id eq $entity-id], true(), true())
let $entity-show := 
    if($request-entity) then
        $request-entity
    else ()

(: Search parameters :)
(: Default to find similar matches to selected entity :)
let $search := 
    request:get-parameter('search', 
        (
            $entity-show/m:label[@primary-transliterated eq 'true'][@xml:lang eq 'Bo-Ltn']/data(), 
            $entity-show/m:label[@primary eq 'true'][@xml:lang eq 'Sa-Ltn']/data(), 
            'a'
        )[1]
    ) ! normalize-space(.)
        
let $type := 
    request:get-parameter('type[]', 
        (
            $entities:types/m:type[@id eq $entity-show/m:type[1]/@type]/@id, 
            $entities:types/m:type[1]/@id
        )[1]
    )

let $term-lang := 
    request:get-parameter('term-lang',
        (
            $entity-show/m:label[@primary-transliterated eq 'true'][@xml:lang eq 'Bo-Ltn']/@xml:lang, 
            $entity-show/m:label[@primary eq 'true'][@xml:lang eq 'Sa-Ltn']/@xml:lang, 
            'Bo-Ltn'
         )[1]
    ) ! common:valid-lang(.)

let $view-mode := request:get-parameter('view-mode', '')

let $entity-list := glossary:glossary-entities($entities:types/m:type[@id = $type]/@glossary-type, $term-lang, $search)

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
        $matching-terms[1]
    
    return
        $entity

(: Show the first result :)
let $entity-show := 
    if(not($entity-show)) then
        $entity-list[1]
    else $entity-show
    
return
    common:response(
        "glossary", 
        $common:app-id, 
        (
            <request xmlns="http://read.84000.co/ns/1.0" 
                entity-id="{ $entity-id }" 
                term-lang="{ $term-lang }" 
                view-mode="{ $view-mode }">
                <search>{ $search }</search>
                {
                    common:add-selected-children($entities:types, $type),
                    common:add-selected-children($term-langs, $term-lang)
                }
            </request>,
            <browse-entities xmlns="http://read.84000.co/ns/1.0">
            {
                $entity-list
            }
            </browse-entities>,
            <show-entity xmlns="http://read.84000.co/ns/1.0">
            {
                $entity-show
            }
            </show-entity>
        )
    )
