xquery version "3.1";

declare
function local:scan($path) as xs:string* {
    local:find-in-collection($path, ())
};

declare
function local:resource ($collection as xs:string, $resource as xs:string) as xs:string* {
    try {
        (:let $test := doc($collection || '/' || $resource)/* ! local-name():)
        let $test := doc($collection || '/' || $resource)//*:aside/* ! local-name(.)
        return 
            (:if(matches($resource, '^listing.*')) then 
                $collection || '/' || $resource
            else
                $collection || '/' || $resource :) (:$test:) ()
    }
    catch * {
        'Error:' || $collection || '/' || $resource
    }
};

declare
function local:find-in-collection ($collection as xs:string, $sub-collection as xs:string?) as xs:string* {
    let $path := string-join(($collection, $sub-collection), '/')
    return
        if (xmldb:collection-available($path))
        then (
            for $child-collection in xmldb:get-child-collections($path)
            return
                local:find-in-collection($path, $child-collection)
            ,
            for $child-resource in xmldb:get-child-resources($path)
            return
                local:resource($path, $child-resource)
            
        )
        else ($path || " not found or insufficient permissions to read")
};

local:scan('/db/apps/84000-cache/html')
