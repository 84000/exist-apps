xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../../modules/glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../../modules/entities.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.4.0';

declare variable $local:request-entity-id := request:get-parameter('id', '');
declare variable $local:request-data-mode := request:get-parameter('data-mode', 'all')[. = ('authorities', 'classifications', 'annotations', 'all')];

declare variable $local:operations-data := collection(concat($common:data-path, '/operations'));
declare variable $local:entities := $local:operations-data//eft:entities;
declare variable $local:contributors := $local:operations-data//eft:contributors;
declare variable $local:sponsors := $local:operations-data//eft:sponsors;

declare variable $local:request-entity := $local:operations-data/id($local:request-entity-id);

declare variable $local:xslt := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));
declare variable $local:html5-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'html5' }
        },
        element media-type { 
            attribute value { 'text/html' }
        },
        element suppress-indentation { 
            attribute value { 'yes' }
        }
    };

declare function local:slug($text as xs:string) as xs:string {
    $text ! normalize-space(.) ! lower-case(.) ! replace(., '[^a-zA-Z0-9]', '-') ! replace(., '\-+', '-') ! replace(., '^\-|\-$', '')
};

declare function local:authority($xmlId as xs:string, $lastUpdated as xs:dateTime?, $heading as xs:string, $definition as xs:string?) as element(eft:authority) {
    element { QName('http://read.84000.co/ns/1.0', 'authority') } {
        attribute xmlid { $xmlId },
        attribute lastUpdated { ($lastUpdated, xs:dateTime("2024-12-01T00:00:00"))[1] }(:$lastUpdated[. instance of xs:dateTime] ! attribute lastUpdated { . }:),
        if(not($xmlId eq $local:request-entity-id)) then
            attribute url { concat('/rest/authorities.json?', string-join((concat('api-version=', $local:api-version),  concat('id=', $xmlId), concat('data-mode=', $local:request-data-mode)), '&amp;')) }
        else ()
        ,
        element heading { $heading },
        element definition { $definition }
    }
};

declare function local:annotation($xmlId as xs:string, $subject-xmlId as xs:string, $type as xs:string, $content as element()?, $datetime as xs:dateTime?, $userId as xs:string?) as element(eft:annotation) {
    element { QName('http://read.84000.co/ns/1.0', 'annotation') } {
        attribute xmlid { $xmlId },
        attribute subjectXmlid { $subject-xmlId },
        attribute type { $type },
        attribute created_at { $datetime },
        attribute person { $userId },
        element body { $content }
    }
};

declare function local:classification($type as xs:string, $name as xs:string, $description as xs:string?, $parent-type as xs:string?) as element(eft:authorityClassification) {
    element { QName('http://read.84000.co/ns/1.0', 'classification') } {
        attribute xmlid { string-join(('classification', $type), '/') },
        attribute type { $type },
        attribute name { $name },
        attribute description { $description },
        attribute parent { $parent-type }
    }
};

(:declare function local:authority-classification($authority-xmlid as xs:string, $classification as element(eft:classification)) as element(eft:authorityClassification) {
    element { QName('http://read.84000.co/ns/1.0', 'authorityClassification') } {
        attribute authorityXmlid { $authority-xmlid },
        attribute classificationType { $classification/@type }
    }
};:)

declare function local:object-relation($subject-xmlid as xs:string, $relation as xs:string, $object-xmlid as xs:string) as element(eft:objectRelation) {
    element { QName('http://read.84000.co/ns/1.0', 'objectRelation') } {
        attribute xmlid { string-join(($subject-xmlid, 'relation', $object-xmlid), '|') },
        attribute subjectXmlid { $subject-xmlid },
        attribute relation { $relation },
        attribute objectXmlid { $object-xmlid }
    }
};

declare function local:name($xmlId as xs:string, $language as xs:string, $type as xs:string, $content as xs:string) as element(eft:name) {
    element { QName('http://read.84000.co/ns/1.0', 'name') } {
        attribute xmlid { $xmlId },
        attribute language { $language },
        (:attribute type { $type },:)
        element content { $content }
    }
};

declare function local:distinct-names($entity as element(), $name-type as xs:string, $default-lang as xs:string?) as element(eft:name)* {

    let $names := (
        
        for $label at $label-index in $entity/eft:label
        let $label-id := string-join(($entity/@xml:id, 'label', $label-index), '/')
        return
            local:name($label-id, ($label/@xml:lang, $default-lang, 'en')[1], $name-type, string-join($label/text()) ! normalize-space(.))
        ,
        
        for $instance in $entity/eft:instance(:[@type = ('source-attribution','translation-contribution','translation-sponsor')]:)
        let $tei-target := $tei-content:translations-collection/id($instance/@id)
        return
            if($tei-target[self::tei:gloss][not(@mode eq 'surfeit')]) then
                for $term in $tei-target/tei:term
                let $term-lang := ($term/@xml:lang, $default-lang, 'en')[1]
                let $term-lang-index := functx:index-of-node($tei-target/tei:term[(@xml:lang/string(), 'en')[1] eq $term-lang], $term)
                let $label-id := string-join(($tei-target/@xml:id, $term-lang, $term-lang-index), '/')
                let $term-text := string-join($term/text()) ! normalize-space(.)
                let $name-type := concat(lower-case(local-name($tei-target)), 'Name')
                where $term-text
                return
                    local:name($label-id, $term-lang, $name-type, $term-text)
                
            else (: tei:sponsor, tei:author, tei:editor etc. :)
                let $label-id := string-join(($entity/@xml:id, $entity/@xml:id), '/')
                let $name-type := concat(lower-case(local-name($tei-target)), 'Name')
                where $tei-target[descendant::text()[normalize-space()]]
                return
                    local:name($label-id, ($default-lang, 'en')[1], $name-type, string-join($tei-target/text()) ! normalize-space(.))
            
    )
        
    return
        for $name in $names
        let $name-lang := $name/@language
        let $name-content := string-join($name/eft:content/text()) ! normalize-space(.)
        group by $name-content, $name-lang
        return 
            $name[1]
};

(:declare function local:names-group($name as element(eft:name), $names as element(eft:name)*) as element(eft:objectRelation)* {
    for $name-equivalent in $names except $name
    return
        local:object-relation($name/@xmlid, 'equivalentName', $name-equivalent/@xmlid, ())
};:)

declare function local:process-classifications() {

    local:classification('person', 'Person', 'Any person historical, contemporary, mythical or otherwise', ()),
    local:classification('place', 'Place', 'Any place historical, contemporary, mythical or otherwise', ()),
    local:classification('text', 'Text', 'Any text', ()),
    local:classification('term', 'Term', 'A significant term from any text', ()),
    
    local:classification('textual/person', 'Character', 'A character from any text', 'person'),
    local:classification('textual/location', 'Location', 'A location or setting from any text', 'place'),
    
    local:classification('contributor/person', 'Contributor', 'A person contributing expertise to one or more translation projects', 'person'),
    local:classification('contributor/academic', 'Academic', 'A contributor with academic credentials', 'contributor-person'),
    local:classification('contributor/practitioner', 'Practitioner', 'A contributor Dharma credentials', 'contributor-person'),
    
    local:classification('sponsor/person', 'Sponsor', 'A person making a financial contribution to the project', 'person'),
    local:classification('sponsor/person/sutra', 'Sutra sponsor', 'A person sponsoring one or more specific translation projects', 'sponsor/person'),
    local:classification('sponsor/person/matching-funds', 'Matching funds sponsor', 'An 84000 matching funds sponsor', 'sponsor/person'),
    local:classification('sponsor/person/founding', 'Founding sponsor', 'An 84000 founding sponsor', 'sponsor/person'),
    
    local:classification('organisation', 'Institution', 'An officially registered organisation', ()),
    local:classification('translation/team', 'Translation Team', 'A team of contributors to one or more translation projects', 'organisation'),
    $local:operations-data//eft:institution-type ! local:classification('organisation-type/' || @id, string-join(eft:label/text()) ! normalize-space(.), (), 'organisation'),
    
    local:classification('region', 'Region', 'A geographical region', 'place'),
    $local:operations-data//eft:region ! local:classification('region/' || @id, string-join(eft:label/text()) ! normalize-space(.), (), 'region'),
    
    local:classification('demographic', 'Demographic', 'A social grouping', ()),
    local:classification('demographic/geo', 'Geographical Demographic', 'A geo/social grouping', 'demographic'),
    for $country in $local:operations-data//eft:country
    let $country-name-slug := local:slug(string-join($country/text()))
    where $country-name-slug[. gt '']
    group by $country-name-slug
    return
        local:classification('demographic/geo/' || $country-name-slug, string-join($country[1]/text()) ! normalize-space(.), concat('A person in the geo/social grouping: ', string-join($country[1]/text()) ! normalize-space(.)), 'demographic/geo')
    ,
    
    local:classification('attestation', 'Attestation', 'Attestation in the source text', ()),
    for $attestation-type in $glossary:attestation-types/eft:attestation-type
    return
        local:classification(string-join(('attestation', $attestation-type/@id), '/'), $attestation-type/eft:label/text(), $attestation-type/eft:description/text(), 'attestation')
    
};

declare function local:process-entities() {

    for $entity in $local:entities/eft:entity
    where not($local:request-entity-id gt '') or $entity[@xml:id eq $local:request-entity-id]
    return (
        
        (: entity -> Authority :)
        let $definitions := $entity/eft:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]
        let $definition-tei := $definitions ! element { QName('http://www.tei-c.org/ns/1.0', 'p') } { . }
        let $definition-html := $definition-tei ! transform:transform(., $local:xslt, <parameters/>)
        let $definition-string := string-join($definition-html ! serialize(., $local:html5-serialization-parameters) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')) ! normalize-space(.)                       
        return
            local:authority($entity/@xml:id, $entity/@timestamp, ($entity/eft:label[@xml:lang eq 'en'], $entity/eft:label, text { concat('error:', $entity/@xml:id) })[1] ! string-join(text()) ! normalize-space(.), $definition-string)
        ,
        
        (: entity/@type -> Authority Classification :)
        for $entity-type-string in distinct-values($entity/eft:type/@type/string())
        let $classification := 
            if($entity-type-string eq 'eft-term') then
                $local:classifications[@type eq 'term']
            else if($entity-type-string eq 'eft-person') then
                $local:classifications[@type eq 'textual/person']
            else if($entity-type-string eq 'eft-place') then
                $local:classifications[@type eq 'textual/location']
            else if($entity-type-string eq 'eft-text') then
                $local:classifications[@type eq 'text']
            else 
                local:classification(concat('error:', $entity-type-string), $entity-type-string, (), ())
        return
            (:local:authority-classification($entity/@xml:id, $classification):)
            local:object-relation($entity/@xml:id, 'classifiedAs', $classification/@xmlid)
        ,
        
        (: content[@type="glossary-notes"] -> Annotation :)
        $entity/eft:content[@type eq 'glossary-notes'][descendant::text()[normalize-space()]] ! local:annotation(string-join(($entity/@xml:id, 'contentGlossaryNotes'),'/'), $entity/@xml:id, 'definitionNotes', element text { string-join(text()) ! normalize-space(.) }, @timestamp ! xs:dateTime(.), @user)
        ,
        
        (: content[@type="preferred-translation"] -> Annotation :)
        $entity/eft:content[@type eq 'preferred-translation'][descendant::text()[normalize-space()]] ! local:annotation(string-join(($entity/@xml:id, 'contentPreferredTranslation'),'/'), $entity/@xml:id, 'preferredTranslation', element text { string-join(text()) ! normalize-space(.) }, @timestamp ! xs:dateTime(.), @user)
        ,
        
        (: <relations/> -> Object relation :)
        for $relation in $entity/eft:relation
        let $relation-id := $relation/@id/string()
        let $relation-predicate := $relation/@predicate/string()
        group by $relation-id, $relation-predicate
        return
            local:object-relation($entity/@xml:id, $relation-predicate, $relation-id)
        ,
        
        (: Names :)
        let $distinct-names := local:distinct-names($entity, 'entityName', 'en')
        return (
        
            (: Name -> isNameOf -> Entity :)
            for $name in $distinct-names
            return (
                $name,
                local:object-relation($name/@xmlid, 'isNameOf', $entity/@xml:id)
            ),
            
            (: <instance/> -> Object relation :)
            for $instance in $entity/eft:instance
            let $instance-id := $instance/@id/string()
            let $instance-type := $instance/@type/string()
            group by $instance-id, $instance-type
            return (
            
                if($instance-type eq 'glossary-item') then (
                    
                    let $gloss := $tei-content:translations-collection/id($instance-id)
                    where $gloss[self::tei:gloss][not(@mode eq 'surfeit')][@xml:id]
                    return (
                    
                        local:object-relation($gloss/@xml:id, 'instanceOf', $entity/@xml:id),
                        
                        (: Glossary -> usesName -> Name :)
                        for $term in $gloss/tei:term
                        let $term-text := string-join($term/text()) ! normalize-space(.)
                        let $term-lang := ($term/@xml:lang, 'en')[1]
                        let $name := $distinct-names[@language eq $term-lang][eft:content/text() eq $term-text]
                        let $relation := 
                            if($term[@type eq 'translationMain']) then 
                                'headName'
                            else if($term[@type eq 'translationAlternative']) then 
                                'hiddenName'
                            else
                                'usesName'
                        
                        let $object-relation := local:object-relation($gloss/@xml:id, $relation, ($name/@xmlid, string-join(('error', $term-lang, $term-text), ':'))[1])
                        return (
                            $object-relation,
                            $local:classifications[@type eq concat('attestation/', $term/@type)] ! local:object-relation($object-relation/@xmlid, 'classifiedAs', @xmlid)
                        )
                    )
                )
                
                else if($instance-type eq 'knowledgebase-article') then
                    local:object-relation($instance-id, 'articleAbout', $entity/@xml:id)
                
                else if($instance-type eq 'source-attribution') then
                    let $attribution := $tei-content:translations-collection/id($instance-id)
                    let $text-id := $attribution/ancestor::tei:TEI ! tei-content:id(.)
                    let $relation :=
                        if($attribution[@role eq 'translatorTib']) then
                            'tibetanTranslator'
                        else if($attribution[@role eq 'reviser']) then
                            'tibetanReviser'
                        else if($attribution[@role eq 'authorContested']) then
                            'tibetanAuthorContested'
                        else 
                            'tibetanAuthor'
                    let $object-relation := local:object-relation($text-id, $relation, $entity/@xml:id)
                    return (
                    
                        $object-relation,
                        
                        let $attribution-text := string-join($attribution/text()) ! normalize-space(.)
                        let $attribution-lang := ($attribution/@xml:lang, 'en')[1]
                        let $name := $distinct-names[@language eq $attribution-lang][eft:content/text() eq $attribution-text]
                        return
                            local:object-relation($object-relation/@xmlid, 'usesName', ($name/@xmlid, string-join(('error', $attribution-lang, $attribution-text), ':'))[1])
                            
                    )
                else
                    local:object-relation($instance-id, $instance/@type, $entity/@xml:id)
            
                ,
                
                (: <flag/> -> Annotation :)
                for $flag in $instance/eft:flag
                return
                    if($flag[@type eq 'requires-attention']) then
                        local:annotation(string-join(($instance-id, 'flagRequiresAttention'),'/'), $instance-id, 'flag', element text { 'requiresAttention' }, $flag/@timestamp ! xs:dateTime(.), $flag/@user)
                    else if($flag[@type eq 'hidden']) then
                        local:annotation(string-join(($instance-id, 'flagHidden'),'/'), $instance-id, 'access', element text { 'internal' }, $flag/@timestamp ! xs:dateTime(.), $flag/@user)
                    else
                        local:annotation(string-join(($instance-id, concat('flag', $flag/@type)),'/'), $instance-id, 'flag', element text { $flag/@type }, $flag/@timestamp ! xs:dateTime(.), $flag/@user)
                
                    
            )
        )
        (: <source key="tengyur-data-2021-1#kukuripa"/> -> Creator ? :)
        
    )
    
};

declare function local:process-contributors() {

    for $contributor in $local:contributors/eft:person
    where not($local:request-entity-id gt '') or $contributor[@xml:id eq $local:request-entity-id]
    let $distinct-names := local:distinct-names($contributor, 'personName', 'en')
    return (
        
        local:authority($contributor/@xml:id, $contributor/@timestamp, ($contributor/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        for $affiliation-type-string in distinct-values($contributor/eft:affiliation/@type/string())
        let $classification := 
            if($affiliation-type-string eq 'academic') then
                $local:classifications[@type eq 'contributor/academic']
            else if($affiliation-type-string eq 'practitioner') then
                $local:classifications[@type eq 'contributor/practitioner']
            else 
                local:classification(concat('error:', $affiliation-type-string), $affiliation-type-string, (), ())
        return
            (:local:authority-classification($contributor/@xml:id, $classification):)
            local:object-relation($contributor/@xml:id, 'classifiedAs', $classification/@xmlid)
        ,
        
        (: <label/>, <internal-name/> -> Name & authorityName :)
        for $name in $distinct-names
        return (
            $name,
            local:object-relation($name/@xmlid, 'isNameOf', $contributor/@xml:id)(:,
            local:names-group($name, $names-distinct):)
        ),
        
        (: <instance/> -> Object relation :)
        for $instance in $contributor/eft:instance
        let $contribution := $tei-content:translations-collection/id($instance/@id)
        let $text-id := tei-content:id($contribution/ancestor::tei:TEI)
        let $contribution-text := string-join($contribution/text()) ! normalize-space(.)
        let $name := $distinct-names[string-join(eft:content/text()) ! normalize-space(.) eq $contribution-text]
        let $relation-predicate := 
            if ($contribution[@role eq 'dharmaMaster']) then
                'englishDharmaMaster'
            else if ($contribution[@role eq 'advisor']) then
                'englishAdvisor'
            else if ($contribution[@role eq 'projectManager']) then
                'englishProjectManager'
            else if ($contribution[@role eq 'reviser']) then
                'englishReviser'
            else if ($contribution[@role eq 'TEImarkupEditor']) then
                'englishMarkup'
            else if ($contribution[@role eq 'finalReviewer']) then
                'englishFinalReviewer'
            else if ($contribution[@role eq 'copyEditor']) then
                'englishCopyEditor'
            else if ($contribution[@role eq 'proofreader']) then
                'englishProofReader'
            else if ($contribution[@role eq 'associateEditor']) then
                'englishAssociateEditor'
            else if ($contribution[@role eq 'projectEditor']) then
                'englishProjectEditor'
            else if ($contribution[@role eq 'externalReviewer']) then
                'englishExternallyReviewer'
            else
                'englishTranslator'
        let $object-relation := local:object-relation($contributor/@xml:id, $relation-predicate, $text-id)
        return (
            $object-relation,
            local:object-relation($object-relation/@xmlid, 'usesName', $name/@xmlid)
        ),
        
        (: <institution/> -> Object relation  :)
        $contributor/eft:institution ! local:object-relation($contributor/@xml:id, 'isMemberOf', @id)
        ,
        
        (: <team/> -> Object relation  :)
        $contributor/eft:team ! local:object-relation($contributor/@xml:id, 'isMemberOf', @id)
        
    )
    
};

declare function local:process-teams() {

    for $team in $local:contributors/eft:team
    where not($local:request-entity-id gt '') or $team[@xml:id eq $local:request-entity-id]
    let $distinct-names := local:distinct-names($team, 'teamName', 'en')
    return (
        
        local:authority($team/@xml:id, $team/@timestamp, ($team/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        $local:classifications[@type eq 'translation/team'] ! local:object-relation($team/@xml:id, 'classifiedAs', @xmlid)(:local:authority-classification($team/@xml:id, .):),
        
        for $name in $distinct-names 
        return (
            $name,
            local:object-relation($name/@xmlid, 'isNameOf', $team/@xml:id)
        ),
        
        (: <instance/> -> Object relation :)
        for $instance in $team/eft:instance
        let $instance-id := $instance/@id/string()
        let $relation-predicate := 
            if($instance[@type eq 'translation-contribution']) then
                'translationTeam'
            else
                $instance/@type
        group by $instance-id, $relation-predicate
        let $text-id := $tei-content:translations-collection/id($instance-id)/ancestor::tei:TEI ! tei-content:id(.)
        return 
            local:object-relation($text-id, $relation-predicate, $team/@xml:id)
        ,
        
        $team[@rend eq 'hidden'] ! local:annotation(string-join(($team/@xml:id, 'attributeRend'),'/'), $team/@xml:id, 'access', element text { 'internal' }, (), ())
        
    )
    
};

declare function local:process-institutions() {

    for $institution in $local:contributors/eft:institution
    where not($local:request-entity-id gt '') or $institution[@xml:id eq $local:request-entity-id]
    return (
    
        local:authority($institution/@xml:id, $institution/@timestamp, ($institution/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        $local:classifications[@type eq $institution/@institution-type-id ! concat('organisation-type/', .)] ! local:object-relation($institution/@xml:id, 'classifiedAs', @xmlid) (:local:authority-classification($institution/@xml:id, .):),
        
        $local:classifications[@type eq $institution/@region-id ! concat('region/', .)] ! local:object-relation($institution/@xml:id, 'classifiedAs', @xmlid) (:local:authority-classification($institution/@xml:id, .):),
        
        let $distinct-names := local:distinct-names($institution, 'institutionName', 'en')
        for $name in $distinct-names 
        return (
            $name,
            local:object-relation($name/@xmlid, 'isNameOf', $institution/@xml:id)
        )
    )
    
};

declare function local:process-sponsors() {

    for $sponsor in $local:sponsors/eft:sponsor
    where not($local:request-entity-id gt '') or $sponsor[@xml:id eq $local:request-entity-id]
    return (
    
        (: <sponsor/> -> authority :)
        local:authority($sponsor/@xml:id, $sponsor/@timestamp, ($sponsor/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        (: <internal-name/> -> name & object relation :)
        for $label at $label-index in $sponsor/eft:label
        let $label-id := string-join(($sponsor/@xml:id, 'label', $label-index), '/')
        let $name := local:name($label-id, 'en', 'personName', string-join($label/text()) ! normalize-space(.))
        return (
            $name,
            local:object-relation($name/@xmlid, 'isNameOf', $sponsor/@xml:id)
        ),
        
        (: <internal-name/> -> name & object relation :)
        for $internal-name at $internal-name-index in $sponsor/eft:internal-name
        let $label-id := string-join(($sponsor/@xml:id, 'internal', $internal-name-index), '/')
        let $name := local:name($label-id, 'en', 'personName', string-join($internal-name/text()) ! normalize-space(.))
        return (
            $name,
            local:object-relation($name/@xmlid, 'isInternalNameOf', $sponsor/@xml:id)
        ),
        
        (: sponsor/@type -> classification & object relation :)
        for $sponsor-type-string in distinct-values($sponsor/eft:type/@id/string())
        let $classification := 
            if($sponsor-type-string eq 'sutra') then
                $local:classifications[@type eq 'sponsor/person/sutra']
            else if($sponsor-type-string eq 'matching-funds') then
                $local:classifications[@type eq 'sponsor/person/matching-funds']
            else if($sponsor-type-string eq 'founding') then
                $local:classifications[@type eq 'sponsor/person/founding']
            else 
                local:classification(concat('error:', $sponsor-type-string), $sponsor-type-string, (), ())
        return
            (:local:authority-classification($sponsor/@xml:id, $classification):)
            local:object-relation($sponsor/@xml:id, 'classifiedAs', $classification/@xmlid)
        ,
        
        (: <instance/> -> object relation :)
        for $instance in $sponsor/eft:instance
        let $instance-id := $instance/@id/string()
        let $relation-predicate := 
            if($instance[@type eq 'translation-sponsor']) then
                'sponsoredBy'
            else
                $instance/@type
        group by $instance-id, $relation-predicate
        let $text-id := $tei-content:translations-collection/id($instance-id)/ancestor::tei:TEI ! tei-content:id(.)
        return 
            local:object-relation($text-id, $relation-predicate, $sponsor/@xml:id)
        ,
        
        (: <country/> -> object relation :)
        for $country in $sponsor/eft:country
        let $country-name-slug := local:slug(string-join($country/text()))
        let $classification := $local:classifications[@type eq 'demographic/geo/' || $country-name-slug]
        where $classification
        return
            (:local:authority-classification($sponsor/@xml:id, $classification):)
            local:object-relation($sponsor/@xml:id, 'classifiedAs', $classification/@xmlid)
        
    )

};

declare variable $local:classifications := local:process-classifications();

declare function local:classifications-tree($xmlids as xs:string*) {
    
    let $classifications := $local:classifications[@xmlid = $xmlids]
    
    return (
        if($classifications[@parent gt '']) then
            local:classifications-tree($local:classifications[@type = $classifications/@parent]/@xmlid)
        else ()
        ,
        $classifications
    )
};

let $data := 
    if($local:request-data-mode = ('authorities', 'all')) then (
        local:process-entities(),
        local:process-contributors(),
        local:process-teams(),
        local:process-institutions(),
        local:process-sponsors()
    )
    else ()

return 
    element authorities {
    
        attribute modelType { 'authorities' },
        attribute apiVersion { $local:api-version },
        attribute url { concat('/rest/authorities.json?', string-join((concat('api-version=', $local:api-version),  $local:request-entity/@xml:id ! concat('id=', .), concat('data-mode=', $local:request-data-mode)), '&amp;')) },
        
        if($local:request-data-mode = ('authorities', 'all')) then 
            $data[self::eft:authority]
        else ()
        ,
        
        if($local:request-data-mode = ('all')) then (
            $data[self::eft:name],
            $data[self::eft:objectRelation],
            $data[self::eft:annotation]
        )
        else ()
        ,
        
        if($local:request-data-mode eq 'classifications') then
            $local:classifications
        
        else if($local:request-data-mode = ('authorities', 'all')) then 
            local:classifications-tree(distinct-values($data[self::eft:objectRelation]/@subjectXmlid | $data[self::eft:objectRelation]/@objectXmlid))
        
        else ()
        
    }
    