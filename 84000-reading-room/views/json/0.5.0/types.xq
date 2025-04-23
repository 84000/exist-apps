xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace json = "http://www.json.org";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:passages-xslt := doc("passages.xsl");

declare function local:passage-types() {
    
    let $parameters :=
        <parameters>
            <param name="api-version" value="{ $types:api-version }"/>
            <param name="return-types" value="{ true() }"/>
        </parameters>

    return
        transform:transform(element eft:html-sections { element xhtml:html {} }, $local:passages-xslt, $parameters)
    
};

let $response := 
    element types {
        
        attribute modelType { 'types' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/types.json?', string-join((concat('api-version=', $types:api-version)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        map:keys($types:relation-types) ! element relationTypes { attribute json:array { true() }, $types:relation-types(.) },
        map:keys($types:creator-types) ! element creatorTypes { attribute json:array { true() }, $types:creator-types(.) },
        distinct-values(map:keys($types:annotation-types) !$types:annotation-types(.)) ! element authorityAnnotationTypes { attribute json:array { true() }, . },
        map:keys($types:title-types) ! element titleTypes { attribute json:array { true() }, $types:title-types(.) },
        map:keys($types:catalogue-section-types) ! element catalogueSectionTypes { attribute json:array { true() }, $types:catalogue-section-types(.) },
        map:keys($types:log-types) ! element logTypes { attribute json:array { true() }, $types:log-types(.) },
        map:keys($types:control-data-types) ! element controlDataTypes { attribute json:array { true() }, $types:control-data-types(.) },
        
        for $key in map:keys($types:attestation-types)
        let $attestation-type := $types:attestation-types($key)
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
            element annotationContentTypesValues { 
                $type/eft:option ! element { $type/@type } { attribute json:array { true() }, @value/string() }
            }
            
    }

return
    helpers:store($local:request-store, $response, concat($response/@modelType, '.json'), ())

