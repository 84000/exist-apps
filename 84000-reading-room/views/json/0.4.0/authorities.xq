xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../../modules/entities.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.4.0';

declare variable $local:request-entity-id := request:get-parameter('entity', '');
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

declare function local:authority($xmlId as xs:string, $heading as xs:string, $definition as xs:string?) as element(eft:authority) {
    element { QName('http://read.84000.co/ns/1.0', 'authority') } {
        attribute xmlid { $xmlId },
        attribute heading { $heading },
        attribute definition { $definition }
    }
};

declare function local:annotation($type as xs:string, $content as element()?, $datetime as xs:dateTime?, $userId as xs:string?) as element(eft:annotation) {
    element { QName('http://read.84000.co/ns/1.0', 'annotation') } {
        attribute type { $type },
        attribute created_at { $datetime },
        attribute person { $userId },
        element body { $content }
    }
};

declare function local:classification($type as xs:string, $name as xs:string, $description as xs:string?, $parent-type as xs:string?) as element(eft:authorityClassification) {
    element { QName('http://read.84000.co/ns/1.0', 'classification') } {
        attribute type { $type },
        attribute name { $name },
        attribute description { $description },
        attribute parentType { $parent-type }
    }
};

declare function local:authority-classification($authority-xmlid as xs:string, $classification as element(eft:classification)) as element(eft:authorityClassification) {
    element { QName('http://read.84000.co/ns/1.0', 'authorityClassification') } {
        attribute authorityXmlid { $authority-xmlid },
        attribute classificationType { $classification/@type }
    }
};

declare function local:object-relation($subject-xmlid as xs:string, $relation as xs:string, $object-xmlid as xs:string) as element(eft:objectRelation) {
    element { QName('http://read.84000.co/ns/1.0', 'objectRelation') } {
        attribute subjectXmlid { $subject-xmlid },
        attribute relation { $relation },
        attribute objectXmlid { $object-xmlid }
    }
};

declare function local:name($xmlid as xs:string, $language as xs:string, $type as xs:string, $content as xs:string) as element(eft:name) {
    element { QName('http://read.84000.co/ns/1.0', 'name') } {
        attribute xmlid { $xmlid },
        attribute language { $language },
        attribute type { $type },
        element content { $content }
    }
};

declare function local:authority-name($authority-xmlid as xs:string, $name-xmlid as xs:string) as element(eft:authorityName) {
    element { QName('http://read.84000.co/ns/1.0', 'authorityName') } {
        attribute authorityXmlid { $authority-xmlid },
        attribute nameXmlid { $name-xmlid }
    }
};

declare function local:names-group($name as element(eft:name), $names as element(eft:name)*) as element(eft:objectRelation)* {
    for $name-equivalent in $names except $name
    return
        local:object-relation($name/@xmlid, 'equivalentName', $name-equivalent/@xmlid)
};

declare function local:process-classifications() {

    local:classification('person', 'Person', 'Any person historical, contemporary, mythical or otherwise', ()),
    local:classification('place', 'Place', 'Any place historical, contemporary, mythical or otherwise', ()),
    local:classification('text', 'Text', 'Any text', ()),
    local:classification('term', 'Term', 'A significant term from any text', ()),
    
    local:classification('textual-person', 'Character', 'A character from any text', 'person'),
    local:classification('textual-location', 'Location', 'A location or setting from any text', 'place'),
    
    local:classification('contributor-person', 'Contributor', 'A person contributing expertise to one or more translation projects', 'person'),
    local:classification('contributor-academic', 'Academic', 'A contributor with academic credentials', 'contributor-person'),
    local:classification('contributor-practitioner', 'Practitioner', 'A contributor Dharma credentials', 'contributor-person'),
    
    local:classification('sponsor-person', 'Sponsor', 'A person making a financial contribution to the project', 'person'),
    local:classification('sponsor-sutra', 'Sutra sponsor', 'A person sponsoring one or more specific translation projects', 'sponsor-person'),
    local:classification('sponsor-matching-funds', 'Matching funds sponsor', 'An 84000 matching funds sponsor', 'sponsor-person'),
    local:classification('sponsor-founding', 'Founding sponsor', 'An 84000 founding sponsor', 'sponsor-person'),
    
    local:classification('organisation', 'Institution', 'An officially registered organisation', ()),
    local:classification('translation-team', 'Translation Team', 'A team of contributors to one or more translation projects', 'organisation'),
    $local:operations-data//eft:institution-type ! local:classification('institution-type-' || @id, string-join(eft:label/text()) ! normalize-space(.), (), 'organisation'),
    
    local:classification('region', 'Region', 'A geographical region', 'place'),
    $local:operations-data//eft:region ! local:classification('region-' || @id, string-join(eft:label/text()) ! normalize-space(.), (), 'region'),
    
    local:classification('demographic', 'Demographic', 'A social grouping', ()),
    local:classification('demographic-geo', 'Geographical Demographic', 'A geo/social grouping', 'demographic'),
    for $country in $local:operations-data//eft:country
    let $country-name-slug := local:slug(string-join($country/text()))
    group by $country-name-slug
    return
        local:classification('demographic-' || $country-name-slug, string-join($country[1]/text()) ! normalize-space(.), concat('A person in the geo/social grouping: ', string-join($country[1]/text()) ! normalize-space(.)), 'demographic-geo')
    
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
            local:authority($entity/@xml:id, ($entity/eft:label[@xml:lang eq 'en'], $entity/eft:label, text { concat('error:', $entity/@xml:id) })[1] ! string-join(text()) ! normalize-space(.), $definition-string)
        ,
        
        (: entity/@type -> Authority Classification :)
        for $entity-type-string in distinct-values($entity/eft:type/@type/string())
        let $classification := 
            if($entity-type-string eq 'eft-term') then
                $local:classifications[@type eq 'term']
            else if($entity-type-string eq 'eft-person') then
                $local:classifications[@type eq 'textual-person']
            else if($entity-type-string eq 'eft-place') then
                $local:classifications[@type eq 'textual-location']
            else if($entity-type-string eq 'eft-text') then
                $local:classifications[@type eq 'text']
            else 
                local:classification(concat('error:', $entity-type-string), $entity-type-string, (), ())
        return
            local:authority-classification($entity/@xml:id, $classification)
        ,
        
        (: content[@type="glossary-notes"] -> Annotation :)
        $entity/eft:content[@type eq 'glossary-notes'][descendant::text()[normalize-space()]] ! local:annotation('definitionNotes', element text { string-join(text()) ! normalize-space(.) }, @timestamp ! xs:dateTime(.), @user)
        ,
        
        (: content[@type="preferred-translation"] -> Annotation :)
        $entity/eft:content[@type eq 'preferred-translation'][descendant::text()[normalize-space()]] ! local:annotation('preferredTranslation', element text { string-join(text()) ! normalize-space(.) }, @timestamp ! xs:dateTime(.), @user)
        ,
        
        (: <relations/> -> Object relation :)
        for $relation in $entity/eft:relation
        let $relation-id := $relation/@id/string()
        let $relation-predicate := $relation/@predicate/string()
        group by $relation-id, $relation-predicate
        return
            local:object-relation($entity/@xml:id, $relation-predicate, $relation-id)
        ,
        
        (: <instance/> -> Object relation :)
        for $instance in $entity/eft:instance
        let $instance-id := $instance/@id/string()
        let $relation-predicate := 
            if($instance[@type eq 'glossary-item']) then
                'instanceOf'
            else if($instance[@type eq 'knowledgebase-article']) then
                'articleAbout'
            else if($instance[@type eq 'source-attribution']) then
                'attributedTo'
            else
                $instance/@type
        group by $instance-id, $relation-predicate
        return (
        
            local:object-relation($instance-id, $relation-predicate, $entity/@xml:id)
            ,
            
            (: <flag/> -> Annotation :)
            for $flag in $instance/eft:flag
            let $annotation-type := 
                if($flag[@type eq 'requires-attention']) then
                    'requiresAttention'
                else if($flag[@type eq 'hidden']) then
                    'hidden'
                else
                    $flag/@type
            return
                local:annotation($annotation-type, element xmlid { $instance-id }, $flag/@timestamp ! xs:dateTime(.), $flag/@user)
                
        )
        
        (: <source key="tengyur-data-2021-1#kukuripa"/> -> Creator ? :)
        
    )
    
};

declare function local:process-contributors() {

    for $contributor in $local:contributors/eft:person
    where not($local:request-entity-id gt '') or $contributor[@xml:id eq $local:request-entity-id]
    return (
        
        local:authority($contributor/@xml:id, ($contributor/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        for $affiliation-type-string in distinct-values($contributor/eft:affiliation/@type/string())
        let $classification := 
            if($affiliation-type-string eq 'academic') then
                $local:classifications[@type eq 'contributor-academic']
            else if($affiliation-type-string eq 'practitioner') then
                $local:classifications[@type eq 'contributor-practitioner']
            else 
                local:classification(concat('error:', $affiliation-type-string), $affiliation-type-string, (), ())
        return
            local:authority-classification($contributor/@xml:id, $classification)
        ,
        
        (: <label/>, <internal-name/> -> Name & authorityName :)
        let $names := (
            
            for $label at $label-index in $contributor/eft:label
            let $label-id := string-join(($contributor/@xml:id, 'label', $label-index), '/')
            return
                local:name($label-id, 'en', 'personName', string-join($label/text()) ! normalize-space(.))
            ,
            
            for $instance in $contributor/eft:instance
            let $contribution := $tei-content:translations-collection/id($instance/@id)[normalize-space(text())]
            let $label-id := string-join(($contributor/@xml:id, $contribution/@xml:id), '/')
            return 
                local:name($label-id, 'en', 'personName', string-join($contribution/text()) ! normalize-space(.))
            
        )
        
        let $names-distinct :=
            for $name in $names
            let $name-content := string-join($name/eft:content/text()) ! normalize-space(.)
            group by $name-content
            return 
                $name[1]
        
        return (
        
            for $name in $names-distinct
            return (
                $name,
                local:authority-name($contributor/@xml:id, $name/@xmlid)(:,
                local:names-group($name, $names-distinct):)
            ),
            
            (: <instance/> -> Object relation :)
            for $instance in $contributor/eft:instance
            let $contribution := $tei-content:translations-collection/id($instance/@id)
            let $text-id := tei-content:id($contribution/ancestor::tei:TEI)
            let $contribution-text := string-join($contribution/text()) ! normalize-space(.)
            let $name := $names-distinct[string-join(eft:content/text()) ! normalize-space(.) eq $contribution-text]
            let $relation-predicate := 
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
            return (
                local:object-relation($contributor/@xml:id, $relation-predicate, $text-id),
                local:authority-name($text-id, $name/@xmlid)
            )
            
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
    return (
        
        local:authority($team/@xml:id, ($team/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        $local:classifications[@type eq 'translation-team'] ! local:authority-classification($team/@xml:id, .)
        ,
        
        (: <instance/> -> Object relation :)
        for $instance in $team/eft:instance
        let $instance-id := $instance/@id/string()
        let $relation-predicate := 
            if($instance[@type eq 'translation-contribution']) then
                'contributedBy'
            else
                $instance/@type
        group by $instance-id, $relation-predicate
        return 
            local:object-relation($instance-id, $relation-predicate, $team/@xml:id)
        
    )
    
};

declare function local:process-institutions() {

    for $institution in $local:contributors/eft:institution
    where not($local:request-entity-id gt '') or $institution[@xml:id eq $local:request-entity-id]
    return (
    
        local:authority($institution/@xml:id, ($institution/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        $local:classifications[@type eq $institution/@institution-type-id] ! local:authority-classification($institution/@xml:id, .),
        
        $local:classifications[@type eq $institution/@region-id] ! local:authority-classification($institution/@xml:id, .)
        
    )
    
};

declare function local:process-sponsors() {

    for $sponsor in $local:sponsors/eft:sponsor
    where not($local:request-entity-id gt '') or $sponsor[@xml:id eq $local:request-entity-id]
    return (
    
        (: <sponsor/> -> authority :)
        local:authority($sponsor/@xml:id, ($sponsor/eft:label)[1] ! string-join(text()) ! normalize-space(.), ()),
        
        (: <label/>, <internal-name/> -> Name & authorityName :)
        let $names := (
            
            for $label at $label-index in $sponsor/eft:label
            let $label-id := string-join(($sponsor/@xml:id, 'label', $label-index), '/')
            return
                local:name($label-id, 'en', 'personName', string-join($label/text()) ! normalize-space(.))
            ,
            
            for $internal-name at $internal-name-index in $sponsor/eft:internal-name
            let $label-id := string-join(($sponsor/@xml:id, 'internal', $internal-name-index), '/')
            return 
                local:name($label-id, 'en', 'personNameInternal', string-join($internal-name/text()) ! normalize-space(.))
                
        )
        for $name in $names
        return (
            $name,
            local:authority-name($sponsor/@xml:id, $name/@xmlid),
            local:names-group($name, $names)
        ),
        
        (: sponsor/@type -> classification & authorityClassification :)
        for $sponsor-type-string in distinct-values($sponsor/eft:type/@id/string())
        let $classification := 
            if($sponsor-type-string eq 'sutra') then
                $local:classifications[@type eq 'sponsor-sutra']
            else if($sponsor-type-string eq 'matching-funds') then
                $local:classifications[@type eq 'sponsor-matching-funds']
            else if($sponsor-type-string eq 'founding') then
                $local:classifications[@type eq 'sponsor-founding']
            else 
                local:classification(concat('error:', $sponsor-type-string), $sponsor-type-string, (), ())
        return
            local:authority-classification($sponsor/@xml:id, $classification)
        ,
        
        (: <instance/> -> Object relation :)
        for $instance in $sponsor/eft:instance
        let $instance-id := $instance/@id/string()
        let $relation-predicate := 
            if($instance[@type eq 'translation-sponsor']) then
                'sponsoredBy'
            else
                $instance/@type
        group by $instance-id, $relation-predicate
        return 
            local:object-relation($instance-id, $relation-predicate, $sponsor/@xml:id)
        ,
        
        (: <country/> -> Authority classification :)
        for $country in $sponsor/eft:country
        let $country-name-slug := local:slug(string-join($country/text()))
        let $classification := $local:classifications[@type eq 'demographic-' || $country-name-slug]
        where $classification
        return
            local:authority-classification($sponsor/@xml:id, $classification)
        
    )

};

declare variable $local:classifications := local:process-classifications();

let $data := (
    
    local:process-entities(),
    local:process-contributors(),
    local:process-teams(),
    local:process-institutions(),
    local:process-sponsors()
    
)

return 
    element authorities {
    
        attribute modelType { 'authorities' },
        attribute apiVersion { $local:api-version },
        attribute url { concat('/rest/authorities.json?', string-join(( $local:request-entity/@xml:id ! concat('entity-id=', .), concat('data-mode=', $local:request-data-mode), concat('api-version=', $local:api-version)), '&amp;')) },
        
        if($local:request-data-mode = ('classifications', 'all')) then (
            $local:classifications[@type = distinct-values($data[self::eft:authorityClassification]/@classificationType)],
            $data[self::eft:authorityClassification]
        )
        else ()
        ,
        
        if($local:request-data-mode = ('annotations', 'all')) then
            $data[self::eft:annotation]
        else ()
        ,
        
        if($local:request-data-mode = ('authorities', 'all')) then 
            $data[self::eft:authority]
        else ()
        ,
        
        if($local:request-data-mode = ('all')) then (
            $data[self::eft:objectRelation],
            $data[self::eft:name],
            $data[self::eft:authorityName]
        )
        else ()
    }
    