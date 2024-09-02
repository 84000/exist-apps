xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $reindex-collections as xs:string* := 
    
    if(request:get-parameter('collection', '') eq 'tests') then
        string-join(($common:data-path, 'config', 'tests'), '/')
    else if(request:get-parameter('collection', '') eq 'linked-data') then
        string-join(($common:data-path, 'config', 'linked-data'), '/')
    else if(request:get-parameter('collection', '') eq 'operations') then
        string-join(($common:data-path, 'operations'), '/')
    else if(request:get-parameter('collection', '') eq 'local') then
        string-join(($common:data-path, 'local'), '/')
    else if(request:get-parameter('collection', '') eq 'tei') then
        $common:tei-path
    else if(request:get-parameter('collection', '') eq 'translation-memory') then
        string-join(($common:data-path, 'translation-memory'), '/')
    else if(request:get-parameter('collection', '') eq 'source') then (
        string-join(($source:source-data-path, $source:kangyur-work), '/'),
        string-join(($source:source-data-path, $source:tengyur-work), '/')
    )
    else if(request:get-parameter('collection', '') eq 'reading-room-config') then
        $common:app-config
    (:else if(request:get-parameter('collection', '') eq 'related-files') then (
        string-join(($common:data-path, 'epub'), '/'),
        string-join(($common:data-path, 'pdf'), '/'),
        string-join(($common:data-path, 'rdf'), '/'),
        string-join(($common:data-path, 'cache'), '/'),
        string-join(($common:data-path, 'json'), '/')
    ):)
    else if(request:get-parameter('collection', '') eq 'static-files') then
        $common:static-content-path
    else ()

return
    common:response(
        'utilities/reindex',
        'utilities',
        (
            utilities:request(),
            element { QName('http://read.84000.co/ns/1.0', 'result') } {
                if(common:user-in-group('dba')) then
                    for $collection in $reindex-collections
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'collection') } {
                            attribute path { $collection },
                            attribute reindexed { xmldb:reindex($collection) }
                        }
                        
                else 
                    ()
            }
        )
    )