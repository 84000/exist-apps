xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace json-types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

element classifications {
    
    attribute modelType { 'classifications' },
    attribute apiVersion { $json-types:api-version },
    attribute url { concat('/rest/classifications.json?', string-join((concat('api-version=', $json-types:api-version)), '&amp;')) },
    attribute timestamp { current-dateTime() },
    
    map:keys($json-types:classification-types) ! json-types:classification(.)
    
}