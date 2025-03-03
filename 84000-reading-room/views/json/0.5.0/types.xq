xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace json = "http://www.json.org";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace json-types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:passages-xslt := doc("passages.xsl");

declare function local:passage-types() {
    
    let $parameters :=
        <parameters>
            <param name="api-version" value="{ $json-types:api-version }"/>
            <param name="return-types" value="{ true() }"/>
        </parameters>

    return
        transform:transform(element xhtml:html {}, $local:passages-xslt, $parameters)
    
};

element types {
    
    attribute modelType { 'types' },
    attribute apiVersion { $json-types:api-version },
    attribute url { concat('/rest/types.json?', string-join((concat('api-version=', $json-types:api-version)), '&amp;')) },
    attribute timestamp { current-dateTime() },
    
    map:keys($json-types:relation-types) ! element relationTypes { attribute json:array { true() }, $json-types:relation-types(.) },
    map:keys($json-types:creator-types) ! element creatorTypes { attribute json:array { true() }, $json-types:creator-types(.) },
    distinct-values(map:keys($json-types:annotation-types) !$json-types:annotation-types(.)) ! element authorityAnnotationTypes { attribute json:array { true() }, . },
    map:keys($json-types:title-types) ! element titleTypes { attribute json:array { true() }, $json-types:title-types(.) },
    map:keys($json-types:catalogue-section-types) ! element catalogueSectionTypes { attribute json:array { true() }, $json-types:catalogue-section-types(.) },
    map:keys($json-types:log-types) ! element logTypes { attribute json:array { true() }, $json-types:log-types(.) },
    map:keys($json-types:control-data-types) ! element controlDataTypes { attribute json:array { true() }, $json-types:control-data-types(.) },
    
    for $key in map:keys($json-types:attestation-types)
    let $attestation-type := $json-types:attestation-types($key)
    return
        element attestationTypes { 
            attribute json:array { true() }, 
            element type { $attestation-type('outputKey') }, 
            element label { $attestation-type('label') }, 
            element description { $attestation-type('description') } 
        }
    ,
    
    for $type in local:passage-types()[not(self::eft:translation)]
    return
        element { local-name($type) } { 
            attribute json:array { true() },
            $type/@type/string()
        }
    ,
    
    for $type in local:passage-types()[not(self::eft:translation)][eft:option]
    return
        element contentTypeValues { 
            attribute json:array { true() },
            $type/@type,
            $type/eft:option ! element option { attribute json:array { true() }, @value/string() }
        }
        
}