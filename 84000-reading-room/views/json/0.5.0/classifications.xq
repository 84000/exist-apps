xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';

let $response := 
    element classifications {
        
        attribute modelType { 'classifications' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/classifications.json?', string-join((concat('api-version=', $types:api-version)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        map:keys($types:classification-types) ! types:classification(.)
        
    }

return
    if($local:request-store eq 'store') then
        helpers:store($response, concat($response/@modelType, '.json'), ())
    else
        $response