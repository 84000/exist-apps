xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";

(: Export entities content to JSON file for importing into Hygraph :)
(: Authors (entities), contributors and sponsors :)

declare function local:label($text as xs:string, $lang as xs:string?) as element(eft:label) {
    element { QName('http://read.84000.co/ns/1.0','label') } {
        attribute lang { $lang },
        text { $text }
    }
};

declare function local:property($type as xs:string, $value as xs:string, $user as xs:string?, $timestamp as xs:dateTime?) as element(eft:property) {
    element { QName('http://read.84000.co/ns/1.0','property') } {
        attribute type { $type },
        attribute value { $value },
        $user ! attribute user { $user },
        $timestamp ! attribute timestamp { $timestamp }
    }
};

declare function local:ref($type as xs:string, $id as xs:string, $flags as element(eft:flag)*) as element(eft:link) {
    element { QName('http://read.84000.co/ns/1.0','link') } {
        attribute type { $type },
        attribute ref { $id },
        $flags ! local:property('content-flag', @type, @user, @timestamp)
    }
};

declare function local:rel($type as xs:string, $id as xs:string, $label as element(eft:label)?) as element(eft:relation) {
    element { QName('http://read.84000.co/ns/1.0','relation') } {
        attribute type { $type },
        attribute ref { $id },
        $label ! local:label(text(), @xml:lang)
    }
};

declare function local:note($type as xs:string, $text as xs:string) as element(eft:note) {
    element { QName('http://read.84000.co/ns/1.0','note') } {
        attribute type { $type },
        text { $text }
    }
};

declare function local:content($type as xs:string, $user as xs:string?, $timestamp as xs:dateTime?, $content as node()*) as element(eft:content) {
    element { QName('http://read.84000.co/ns/1.0','content') } {
        attribute type { $type },
        $user ! attribute user { $user },
        $timestamp ! attribute timestamp { $timestamp },
        string-join($content ! serialize(.)) ! normalize-space(.)
    }
};

declare function local:source($key as xs:string) as element(eft:content) {
    element { QName('http://read.84000.co/ns/1.0','source') } {
        attribute key { $key }
    }
};

let $entities := doc(concat($common:data-path, '/operations/entities.xml'))
let $contributors := doc(concat($common:data-path, '/operations/contributors.xml'))
let $sponsors := doc(concat($common:data-path, '/operations/sponsors.xml'))

return
element { QName('http://read.84000.co/ns/1.0','export') } {

    attribute type { 'export-eft-entities' },
    attribute data-source { 'collaboration' },
    attribute timestamp { current-dateTime() },
    attribute app-version { $common:app-version },
    
    for $entity in $entities/eft:entities/eft:entity
    return
        element entity {
            attribute id { $entity/@xml:id },
            $entity/eft:type ! local:property('entity-type', replace(@type, '^eft\-', ''), (), ()),
            $entity/eft:label ! local:label(text(), @xml:lang),
            $entity/eft:instance ! local:ref(@type, @id, eft:flag),
            $entity/eft:relation ! local:rel(@predicate, @id, eft:label),
            $entity/eft:source ! local:source(@key),
            $entity/eft:content ! local:content(@type, @user, @timestamp, node())
        }
    ,
    
    for $contributor in $contributors/eft:contributors/eft:person
    return
        element entity {
            attribute id { $contributor/@xml:id },
            local:property('entity-type', 'person', (), ()),
            local:property('person-type', 'contributor', (), ()),
            $contributor/eft:affiliation ! local:property('contributor-type', @type, (), ()),
            $contributor/eft:label ! local:label(text(), @xml:lang),
            $contributor/eft:institution ! local:ref('institution',  @id, ()),
            $contributor/eft:team ! local:ref('team', @id, ()),
            $contributor/eft:instance ! local:ref(@type, @id, ())
        }
    ,
    
    for $sponsor in $sponsors/eft:sponsors/eft:sponsor
    return
        element entity {
            attribute id { $sponsor/@xml:id },
            local:property('entity-type', 'person', (), ()),
            local:property('person-type', 'sponsor', (), ()),
            $sponsor/eft:type ! local:property('sponsor-type', @id, (), ()),
            $sponsor/eft:label ! local:label(text(), @xml:lang),
            $sponsor/eft:internal-name ! local:note('internal-name', string-join(text(), '')),
            $sponsor/eft:country ! local:note('country', string-join(text(), '')),
            $sponsor/eft:instance ! local:ref(@type, @id, ())
        }
    ,
    
    for $team in $contributors/eft:contributors/eft:team
    return
        element entity {
            attribute id { $team/@xml:id },
            local:property('entity-type', 'team', (), ()),
            $team/@rend ! local:property('rend', string(), (), ()),
            $team/eft:label ! local:label(text(), @xml:lang),
            $team/eft:instance ! local:ref(@type, @id, ())
        }
    ,
    
    for $institution in $contributors/eft:contributors/eft:institution
    return
        element entity {
            attribute id { $institution/@xml:id },
            local:property('entity-type', 'institution', (), ()),
            $institution/@institution-type-id ! local:property('institution-type', 'institution-type-' || ., (), ()),
            $institution/@region-id ! local:property('institution-region', 'institution-region-' || ., (), ()),
            $institution/eft:label ! local:label(text(), 'en')
        }
    ,
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'person' },
        local:label('Person', 'en')
    },
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'place' },
        local:label('Place', 'en')
    },
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'text' },
        local:label('Text', 'en')
    },
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'collection' },
        local:label('Collection', 'en')
    },
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'term' },
        local:label('Term', 'en')
    },
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'team' },
        local:label('Team', 'en')
    },
    
    element property-definition {
        attribute type { 'entity-type' },
        attribute id { 'institution' },
        local:label('Institution', 'en')
    },
    
    element property-definition {
        attribute type { 'person-type' },
        attribute id { 'contributor' },
        local:label('Contributor', 'en')
    },
    
    element property-definition {
        attribute type { 'person-type' },
        attribute id { 'sponsor' },
        local:label('Sponsor', 'en')
    },
    
    element property-definition {
        attribute type { 'contributor-type' },
        attribute id { 'academic' },
        local:label('Academic', 'en')
    },
    
    element property-definition {
        attribute type { 'contributor-type' },
        attribute id { 'practitioner' },
        local:label('Practitioner', 'en')
    },
    
    element property-definition {
        attribute type { 'sponsor-type' },
        attribute id { 'sutra' },
        local:label('Sutra sponsor', 'en')
    },
    
    element property-definition {
        attribute type { 'sponsor-type' },
        attribute id { 'matching-funds' },
        local:label('Matching funds sponsor', 'en')
    },
    
    element property-definition {
        attribute type { 'sponsor-type' },
        attribute id { 'founding' },
        local:label('Founding sponsor', 'en')
    },
    
    element property-definition {
        attribute type { 'rend' },
        attribute id { 'hidden' },
        local:label('Hidden', 'en')
    },
    
    element property-definition {
        attribute type { 'content-flag' },
        attribute id { 'requires-attention' },
        local:label('Requires attention', 'en')
    },
    
    for $institution-type in $contributors/eft:contributors/eft:institution-type
    return
        element property-definition {
            attribute type { 'institution-type' },
            attribute id { 'institution-type-' || $institution-type/@id },
            $institution-type/eft:label ! local:label(text(), 'en')
        }
     ,
    
    for $institution-region in $contributors/eft:contributors/eft:region
    return
        element property-definition {
            attribute type { 'institution-region' },
            attribute id { 'institution-region-' || $institution-region/@id },
            $institution-region/eft:label ! local:label(text(), 'en')
        }
}