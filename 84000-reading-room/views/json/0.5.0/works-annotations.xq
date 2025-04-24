xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';

declare function local:works() {
    for $tei in $tei-content:translations-collection//tei:TEI
    where $tei//tei:notesStmt[tei:note]
    let $text-id := tei-content:id($tei)
    return
        $tei//tei:notesStmt/tei:note[text()] ! types:annotation($text-id, (@type, 'note')[1], helpers:normalize-text(.), @date-time ! xs:dateTime(.), @user)
};

let $response :=
    element works-annotations {
        
        attribute modelType { 'works-annotations' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/works-annotations.json?', string-join((concat('api-version=', $types:api-version)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        local:works()
        
    }

return
    helpers:store($local:request-store, $response, concat($response/@modelType, '.json'), ())