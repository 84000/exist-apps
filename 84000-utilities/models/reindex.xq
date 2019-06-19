xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare option exist:serialize "method=xml indent=no";

let $reindex-collection as xs:string := 
    if(request:get-parameter('collection', '') eq 'tei') then
        $common:tei-path
    else if(request:get-parameter('collection', '') eq 'operations') then
        concat($common:data-path, '/operations')
    else if(request:get-parameter('collection', '') eq 'translation-memory') then
        concat($common:data-path, '/translation-memory')
    else if(request:get-parameter('collection', '') eq 'config') then
        concat($common:data-path, '/config')
    else 
        ''

let $reindex := 
    if($reindex-collection gt '') then
        xmldb:reindex($reindex-collection)
    else 
        ''

return
    common:response(
        'utilities/reindex',
        'utilities',
        (
            <request xmlns="http://read.84000.co/ns/1.0" collection="{ request:get-parameter('collection', '') }" />,
            <result xmlns="http://read.84000.co/ns/1.0" collection="{ $reindex-collection }" reindexed="{ $reindex }" />
        )
        
    )