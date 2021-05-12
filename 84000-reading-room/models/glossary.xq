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

let $glossary-types := 
    <glossary-types xmlns="http://read.84000.co/ns/1.0">
        <type id="term" entity-type="eft-glossary-term">
            <label type="singular">Term</label>
            <label type="plural">Terms</label>
        </type>
        <type id="person" entity-type="eft-glossary-person">
            <label type="singular">Person</label>
            <label type="plural">People</label>
        </type>
        <type id="place" entity-type="eft-glossary-place">
            <label type="singular">Place</label>
            <label type="plural">Places</label>
        </type>
        <type id="text" entity-type="eft-glossary-text">
            <label type="singular">Text</label>
            <label type="plural">Texts</label>
        </type>
    </glossary-types>
    
let $term-langs := 
    <term-langs xmlns="http://read.84000.co/ns/1.0">
        <lang id="Bo-Ltn" short-code="Wyl">Tibetan (Wylie)</lang>
        <lang id="Sa-Ltn" short-code="Skt">Sanskrit</lang>
        <lang id="en" short-code="Eng">Our translation</lang>
    </term-langs>

(: The requested entity :)
let $entity-id := request:get-parameter('entity-id', '')
let $request-entity := $entities:entities/m:entity[@xml:id eq $entity-id]
let $entity-show := 
    if($request-entity) then
        glossary:glossary-entities($request-entity, true())/m:entity[1]
    else ()

(: Search parameters :)
(: Default to find similar matches to selected entity :)
let $type := request:get-parameter(
    'type', (
        $glossary-types/m:type[@entity-type eq $entity-show/m:type[1]/@type]/@id, 
        $glossary-types/m:type[1]/@id
     )[1])
let $term-lang := request:get-parameter(
    'term-lang', (
        $entity-show/m:label[@primary-transliterated eq 'true'][@xml:lang eq 'Bo-Ltn']/@xml:lang, 
        $entity-show/m:label[@primary eq 'true'][@xml:lang eq 'Sa-Ltn']/@xml:lang, 
        $term-langs/m:lang[1]/@id
     )[1]) ! common:valid-lang(.)
let $search := request:get-parameter(
    'search', (
        $entity-show/m:label[@primary-transliterated eq 'true'][@xml:lang eq 'Bo-Ltn']/data(), 
        $entity-show/m:label[@primary eq 'true'][@xml:lang eq 'Sa-Ltn']/data(), 
        'a'
    )[1]) ! normalize-space(.)

let $view-mode := request:get-parameter('view-mode', '')

let $entity-list := glossary:glossary-entities($type, $term-lang, $search)

let $entity-list :=
    for $entity in $entity-list/m:entity
    let $matching-terms :=
        for $term in $entity/m:instance/m:item/m:term
            [@xml:lang eq $term-lang]
            [
                matches(
                    common:normalized-chars(data()), 
                    concat('(^|\s+)', string-join(tokenize($search, '\s+') ! common:normalized-chars(.) ! functx:escape-for-regex(.), '.*\s+'), ''), 
                    'i'
                )
            ]
        order by $term
        return
            $term
    
    (: Order by the shortest matching term, then alphabetically :)
    order by 
        min($matching-terms ! count(tokenize(data(), '\s+'))) ascending,
        $matching-terms[1]
    
    return
        $entity

let $entity-show := 
    if(not($entity-show)) then
        glossary:glossary-entities($entity-list[1], true())/m:entity[1]
    else $entity-show
    
return
    common:response(
        "glossary", 
        $common:app-id, 
        (
            <request xmlns="http://read.84000.co/ns/1.0" 
                entity-id="{ $entity-id }" 
                term-lang="{ $term-lang }" 
                type="{ $type }" 
                view-mode="{ $view-mode }">
                <search>{ $search }</search>
                {
                    common:add-selected-children($glossary-types, $type),
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
                if($entity-show) then
                    element { node-name($entity-show) }{
                        $entity-show/@*,
                        $entity-show/*[not(local-name() eq 'instance')],
                        for $instance in $entity-show/m:instance
                        return
                            element { node-name($instance) }{
                                $instance/@*,
                                $instance/*[not(local-name() eq 'item')],
                                for $item in $instance/m:item
                                return
                                    element { node-name($item) }{
                                        $item/@*,
                                        $item/*,
                                        if($item[m:text]) then
                                            let $tei := tei-content:tei($item/m:text[1]/@id, 'translation')
                                            where $tei
                                            return
                                                glossary:item-html($tei, '', $item/@id)//*[@id eq $item/@id]
                                        else ()
                                    }
                            }
                    }
                else ()
            }
            </show-entity>
        )
    )
