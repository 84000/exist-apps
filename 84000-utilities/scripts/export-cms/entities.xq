xquery version "3.1";

(: Export entities content to JSON file for importing into CMS :)

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace functx = "http://www.functx.com";

declare function local:label($text as xs:string, $lang as xs:string?) as element(eft:label) {
    element {QName('http://read.84000.co/ns/1.0', 'label')} {
        attribute langEncoding {$lang},
        element content {$text}
    }
};

declare function local:reference($type as xs:string?, $id as xs:string, $flags as element(eft:flag)*) as element(eft:reference) {
    element {QName('http://read.84000.co/ns/1.0', 'reference')} {
        attribute xmlId {$id},
        (:local:id('reference', $id),:)
        attribute uri {'https://purl.84000.co/resource/id/' || $id},
        $type ! attribute type {.},
        $flags ! local:property('content-flag', 'content-flag-' || @type, @user, @timestamp)
    }
};

declare function local:property($type as xs:string, $value as xs:string, $user as xs:string?, $timestamp as xs:dateTime?) as element(eft:property) {
    element {QName('http://read.84000.co/ns/1.0', 'property')} {
        attribute type {$type},
        attribute content {$value},
        $user ! attribute person {.},
        $timestamp ! attribute date {.}
    }
};

declare function local:annotation($type as xs:string, $user as xs:string?, $timestamp as xs:dateTime?, $content as element()*) as element(eft:annotation) {
    element {QName('http://read.84000.co/ns/1.0', 'annotation')} {
        attribute type {$type},
        $user ! attribute person {.},
        $timestamp ! attribute date {.},
        $content ! element content {string-join(node() ! serialize(.)) ! normalize-space(.)}
    }
};

declare function local:relation($type as xs:string, $id as xs:string) as element(eft:entityRelation) {
    element {QName('http://read.84000.co/ns/1.0', 'entityRelation')} {
        attribute entityRelationshipType {$type},
        local:reference('legacyEntity', $id, ())
    }
};

declare function local:definition($element-name as xs:string, $type as xs:string, $user as xs:string?, $timestamp as xs:dateTime?, $rend as xs:string?, $content as element()*, $references as element(eft:reference)*) as element() {
    element {QName('http://read.84000.co/ns/1.0', $element-name)} {
        attribute type {$type},
        $user ! attribute person {.},
        $timestamp ! attribute date {.},
        $rend ! attribute rend {.},
        $content ! element content {string-join(node() ! serialize(.)) ! normalize-space(.)},
        $references
    }
};

declare function local:resource-id($element-type as xs:string, $id as xs:string) {
    element {$element-type || 'Id'} {
        attribute xmlId {$id}
    }
};

declare function local:entity($element-name as xs:string, $entity-id as xs:string, $names as element()*, $definitions as element()*, $notes as element(eft:annotation)*, $relations as element(eft:entityRelation)*, $properties as element(eft:property)*, $references as element(eft:reference)*) as element() {
    element {QName('http://read.84000.co/ns/1.0', $element-name)} {
        local:resource-id($element-name, $entity-id),
        $names,
        $definitions,
        $notes,
        $relations,
        $properties,
        $references
    }
};

declare function local:person($entity-id as xs:string, $names as element()*, $definitions as element()*, $notes as element(eft:annotation)*, $relations as element(eft:entityRelation)*, $properties as element(eft:property)*, $references as element(eft:reference)*) as element(eft:person) {
    local:entity('person', $entity-id, $names, $definitions, $notes, $relations, $properties, $references)
};

declare function local:place($entity-id as xs:string, $names as element()*, $definitions as element()*, $notes as element(eft:annotation)*, $relations as element(eft:entityRelation)*, $properties as element(eft:property)*, $references as element(eft:reference)*) as element(eft:place) {
    local:entity('place', $entity-id, $names, $definitions, $notes, $relations, $properties, $references)
};

declare function local:name($element-name as xs:string, $type as xs:string, $labels as element(eft:label)*, $references as element(eft:reference)*) as element() {
    element {QName('http://read.84000.co/ns/1.0', $element-name)} {
        attribute nameType {$type},
        $labels,
        $references
    }
};

declare function local:property-name($id as xs:string, $groups as xs:string*, $labels as element(eft:label)*) as element(eft:propertyName) {
    element {QName('http://read.84000.co/ns/1.0', 'propertyName')} {
        attribute propertyId {$id},
        $groups ! element propertyGroup {.},
        $labels
    }
};

declare function local:process-entity($entity as element(eft:entity), $entity-type as xs:string) as element() {
    
    let $glossary-entries := $local:tei/id($entity/eft:instance/@id)/self::tei:gloss[not(@mode eq 'surfeit')]
    let $source-attributions := $local:tei/id($entity/eft:instance/@id)[self::tei:author | self::tei:editor]
    
    let $names := (
    
        let $entity-labels :=
            for $entity-label in $entity/eft:label
            let $entity-label-text := string-join($entity-label/text() ! common:normalized-chars(.), '') ! normalize-space(.)
            let $entity-label-lang := ($entity-label/@xml:lang, 'en')[1]
            where $entity-label-text gt ''
            group by $entity-label-text, $entity-label-lang
            order by if ($entity-label-lang eq 'en') then 1 else 0 descending, $entity-label-lang, $entity-label-text
            return
                local:label($entity-label-text, $entity-label-lang)
        
        return
            local:name('authorityName', 'entityLabel', $entity-labels, ())
        ,
        
        for $glossary-entry in $glossary-entries
        let $glossary-entry-labels := element labels {$glossary-entry/tei:term[node()][not(@xml:lang eq 'bo')] ! local:label(string-join(text() ! common:normalized-chars(.), '') ! normalize-space(.), (@xml:lang, 'en')[1])}
        let $entity-ref := $entity/eft:instance[@id = $glossary-entry/@xml:id] ! local:reference(@type, @id, eft:flag)
        let $labels-key := local:labels-key('glossaryTerm', $glossary-entry-labels/eft:label)
        group by $labels-key
        return
            local:name('nameVariant', 'glossaryTerm', $glossary-entry-labels[1]/eft:label, $entity-ref)
        ,
        
        for $attribution in $source-attributions
        let $attribution-type :=
            if ($attribution[@role eq 'translatorTib']) then
                'sourceTranslator'
            else if ($attribution[@role eq 'reviser']) then
                'sourceReviser'
            else if ($attribution[@role eq 'authorContested']) then
                'sourceAuthorContested'
            else
                'sourceAuthor'
        let $attribution-labels := element labels {local:label(string-join($attribution/text() ! common:normalized-chars(.), '') ! normalize-space(.), ($attribution/@xml:lang, 'en')[1])}
        let $attribution-ref := $entity/eft:instance[@id = $attribution/@xml:id] ! local:reference(@type, @id, eft:flag)
        let $labels-key := local:labels-key($attribution-type, $attribution-labels/eft:label)
        group by $labels-key
        return
            local:name('nameVariant', $attribution-type[1], $attribution-labels[1]/eft:label, $attribution-ref)
    
    )
    
    let $defintions := (
    
        let $standard-definition := $entity/eft:content[@type eq 'glossary-definition'][node()]
        where $standard-definition
        return
            local:definition('authorityDefinition', 'standardDefinition', ($standard-definition/@user)[1], ($standard-definition/@timestamp)[1], (), $standard-definition, ())
        ,
        
        for $glossary-entry in $glossary-entries[tei:note[@type eq 'definition'][not(@rend eq 'override')][node()]]
        let $glossary-entry-definition := element definition {$glossary-entry/tei:note/tei:p}
        let $glossary-entry-definition-key := string-join(($glossary-entry/tei:note/@rend, string-join($glossary-entry-definition//text() ! common:normalized-chars(.), ' ') ! normalize-space(.)), ':')
        let $glossary-entry-ref := $entity/eft:instance[@id = $glossary-entry/@xml:id] ! local:reference(@type, @id, eft:flag)
        group by $glossary-entry-definition-key
        return
            local:definition('authorityDefinition', 'glossaryDefinition', (), (), ($glossary-entry/tei:note/@rend)[1], $glossary-entry-definition[1]/tei:p, $glossary-entry-ref)
        
    )
    
    let $notes :=
        for $content in $entity/eft:content[not(@type eq 'glossary-definition')]
        let $content-type :=
            if ($content/@type eq 'glossary-notes') then
                'entityNote'
            else if ($content/@type eq 'preferred-translation') then
                    'preferredTranslation'
            else
                $content/@type
        group by $content-type
        return
            local:annotation($content-type, ($content/@user)[1], ($content/@timestamp)[1] ! xs:dateTime(.), $content)
        
    let $relations := (
    
        (:local:relation('sameAs', $entity/@xml:id),:)
        
        for $relation in $entity/eft:relation
        let $relation-id := $relation/@id
        let $relation-predicate := $relation/@predicate
            group by $relation-id, $relation-predicate
        return
            local:relation($relation-predicate, $relation-id)
    
    )
    
    let $properties := $entity/eft:source ! local:property('import-ref', @key, (), ())
    
    let $references := $entity/eft:instance[not(@type = ('glossary-item', 'source-attribution'))] ! local:reference(@type, @id, eft:flag)
    
    return
        local:entity($entity-type, $entity/@xml:id, $names, $defintions, $notes, $relations, $properties, $references)

};

declare function local:labels-key($label-type as xs:string, $labels as element(eft:label)*) as xs:string {
    string-join(($label-type,
    sort($labels, (), function ($item) {
        $item/@lang/string()
    }) ! concat(@lang, ':', eft:value)), '/')
};

declare variable $local:entities := doc(concat($common:data-path, '/operations/entities.xml'));
declare variable $local:contributors := doc(concat($common:data-path, '/operations/contributors.xml'));
declare variable $local:sponsors := doc(concat($common:data-path, '/operations/sponsors.xml'));
declare variable $local:tei := $tei-content:translations-collection//tei:TEI;
declare variable $local:export-types := ('person','place','text','term','collection');
declare variable $local:json-serialization-parameters :=
    element {QName('http://www.w3.org/2010/xslt-xquery-serialization', 'serialization-parameters')} {
        element method {
            attribute value {'json'},
            attribute encoding {'UTF-8'},
            attribute indent {'yes'}
        }
    };

for $export-type in $local:export-types
let $export :=
    element {QName('http://read.84000.co/ns/1.0', 'export')} {
        
        attribute export-class {'export-eft-entities'},
        attribute export-type {string-join($export-type, '-')},
        attribute data-source {'collaboration'},
        attribute timestamp {current-dateTime()},
        attribute app-version {$common:app-version},
        
        (: Entities file :)
        for $entity-type in $local:entities/eft:entities/eft:entity/eft:type
        let $entity := $entity-type/parent::eft:entity
        return (
            if($entity-type[@type eq 'eft-person'] and $export-type = 'person') then
                local:process-entity($entity, 'person')
            else ()
            ,
            if($entity-type[@type eq 'eft-place'] and $export-type = 'place') then
                local:process-entity($entity, 'place')
            else ()
            ,
            if($entity-type[@type eq 'eft-text'] and $export-type = 'text') then
                local:process-entity($entity, 'text')
            else ()
            ,
            if ($entity-type[@type eq 'eft-collection'] and $export-type = 'collection') then
                local:process-entity($entity, 'collection')
            else ()
            ,
            if ($entity-type[@type eq 'eft-term'] and $export-type = 'term') then
                local:process-entity($entity, 'term')
            else ()
        ),
        
        (: Contributors file :)
        if($export-type = 'person') then
            for $contributor in $local:contributors/eft:contributors/eft:person
            let $contributor-names := (
            
                let $entity-labels := $contributor/eft:label ! local:label(string-join(text()) ! normalize-space(.), (@xml:lang, 'en')[1])
                return
                    local:name('authorityName', 'entityLabel', $entity-labels, ())
                ,
                
                for $contribution in $local:tei/id($contributor/eft:instance/@id)[self::tei:author | self::tei:editor | self::tei:consultant]
                let $contribution-role :=
                    if ($contribution[@role eq 'dharmaMaster']) then
                        'dharmaMaster'
                    else if ($contribution[@role eq 'advisor']) then
                        'translationAdvisor'
                    else if ($contribution[@role eq 'projectManager']) then
                        'projectManager'
                    else if ($contribution[@role eq 'reviser']) then
                        'translationReviser'
                    else if ($contribution[@role eq 'TEImarkupEditor']) then
                        'translationMarkup'
                    else if ($contribution[@role eq 'finalReviewer']) then
                        'translationFinalReviewer'
                    else if ($contribution[@role eq 'copyEditor']) then
                        'translationCopyEditor'
                    else if ($contribution[@role eq 'proofreader']) then
                        'translationProofReader'
                    else if ($contribution[@role eq 'associateEditor']) then
                        'translationAssociateEditor'
                    else if ($contribution[@role eq 'projectEditor']) then
                        'translationProjectEditor'
                    else if ($contribution[@role eq 'externalReviewer']) then
                        'translationExternalReviewer'
                    else
                        'englishTranslator'
                let $contribution-labels := element labels {local:label(string-join($contribution/text() ! common:normalized-chars(.), '') ! normalize-space(.), ($contribution/@xml:lang, 'en')[1])}
                let $contribution-ref := $contributor/eft:instance[@id = $contribution/@xml:id] ! local:reference(@type, @id, eft:flag)
                let $labels-key := local:labels-key($contribution-role, $contribution-labels/eft:label)
                group by $labels-key
                return
                    local:name('nameVariant', $contribution-role[1], $contribution-labels[1]/eft:label, $contribution-ref)
                
            )
            let $relations := (
                $contributor/eft:institution ! local:relation('isMemberOf', @id),
                $contributor/eft:team ! local:relation('isMemberOf', @id)
            )
            
            let $properties := (
                $contributor/eft:affiliation ! local:property('contributor-type', 'contributor-type-' || @type, (), ())
            )
            
            return
                local:person($contributor/@xml:id, $contributor-names, (), (), $relations, $properties, ())
            
        else ()
        ,
        
        (: Sponsors file :)
        if($export-type = 'person') then
            for $sponsor in $local:sponsors/eft:sponsors/eft:sponsor
            let $sponsor-names := (
            
                let $entity-labels := $sponsor/eft:label ! local:label(string-join(text()) ! normalize-space(.), (@xml:lang, 'en')[1])
                where $entity-labels
                return
                    local:name('authorityName', 'entityLabel', $entity-labels, ())
                ,
                
                let $internal-name-label := $sponsor/eft:internal-name ! local:label(string-join(text()) ! normalize-space(.), (@xml:lang, 'en')[1])
                where $internal-name-label
                return
                    local:name('nameVariant','internalName', $internal-name-label, ())
                ,
                
                for $sponsorship in $local:tei/id($sponsor/eft:instance/@id)[self::tei:sponsor]
                let $sponsorship-labels := element labels {string-join($sponsorship/text() ! common:normalized-chars(.), '') ! normalize-space(.) ! local:label(., ($sponsorship/@xml:lang, 'en')[1])}
                let $sponsorship-ref := $sponsor/eft:instance[@id = $sponsorship/@xml:id] ! local:reference(@type, @id, eft:flag)
                let $labels-key := local:labels-key('translationSponsor', $sponsorship-labels/eft:label)
                group by $labels-key
                return
                    local:name('nameVariant', 'sponsorshipName', $sponsorship-labels[1]/eft:label, $sponsorship-ref)
                    
            )
            
            let $notes := $sponsor/eft:country ! local:annotation('residenceCountry', (), (), .)
            
            let $properties := $sponsor/eft:type ! local:property('sponsor-type', 'sponsor-type-' || @id, (), ())
            
            let $references := $sponsor/eft:instance[not(@id = $sponsor-names/descendant::eft:reference/@xmlId)] ! local:reference(@type, @id, eft:flag)
            
            return
                local:person($sponsor/@xml:id, $sponsor-names, (), $notes, (), $properties, $references)
            
        else ()
        ,
        
        if($export-type = 'person') then
            for $team in $local:contributors/eft:contributors/eft:team
            return
                element team {
                    local:resource-id('team', $team/@xml:id),
                    let $team-labels := $team/eft:label ! local:label(string-join(text()) ! normalize-space(.), (@xml:lang, 'en')[1])
                    where $team-labels
                    return
                        local:name('authorityName', 'entityLabel', $team-labels, ())
                    ,
                    $team/@rend ! local:property('content-flag', 'content-flag-' || ., (), ()),
                    $local:tei/id($team/eft:instance/@id) ! local:reference("translation-team", @xml:id, ())
                }
        else ()
        ,
        
        if($export-type = 'person') then
            for $institution in $local:contributors/eft:contributors/eft:institution
            return
                element institution {
                    local:resource-id('institution', $institution/@xml:id),
                    let $institution-labels := $institution/eft:label ! local:label(string-join(text()) ! normalize-space(.), (@xml:lang, 'en')[1])
                    where $institution-labels
                    return
                        local:name('authorityName', 'entityLabel', $institution-labels, ())
                    ,
                    $institution/@institution-type-id ! local:property('institution-type', 'institution-type-' || ., (), ()),
                    $institution/@region-id ! local:property('institution-region', 'institution-region-' || ., (), ())
                }
        else ()
        ,
        
        (: Properties :)
        if($export-type = 'person') then (
            local:property-name('contributor-type-academic', ('contributor-type'), local:label('Academic', 'en')),
            local:property-name('contributor-type-practitioner', ('contributor-type'), local:label('Practitioner', 'en')),
            local:property-name('sponsor-type-sutra', ('sponsor-type'), local:label('Sutra sponsor', 'en')),
            local:property-name('sponsor-type-matching-funds', ('sponsor-type'), local:label('Matching funds sponsor', 'en')),
            local:property-name('sponsor-type-founding', ('sponsor-type'), local:label('Founding sponsor', 'en')),
            local:property-name('content-flag-requires-attention', ('content-flag'), local:label('Requires attention', 'en')),
            local:property-name('content-flag-hidden', ('content-flag'), local:label('Hidden', 'en')),
            $local:contributors/eft:contributors/eft:institution-type ! local:property-name('institution-type-' || @id, ('institution-type'), eft:label ! local:label(string-join(text()) ! normalize-space(.), 'en')),
            $local:contributors/eft:contributors/eft:region ! local:property-name('institution-region-' || @id, ('institution-region'), eft:label ! local:label(string-join(text()) ! normalize-space(.), 'en'))
        )
        else ()
    }
    
return
    xmldb:store('/db/apps/84000-data/uploads/export-to-cms', concat(string-join(('entities',$export-type), '-'),'.json'), serialize($export, $local:json-serialization-parameters), 'application/json')
