xquery version "3.1";

declare
function local:scan-for-changes($path as xs:string*, $cutoff as xs:dateTime) as xs:string* {
    $path ! local:find-in-collection(., (), $cutoff)
};

declare
function local:resource ($collection as xs:string, $resource as xs:string, $cutoff as xs:dateTime) as xs:string? {
    let $timestamp := xmldb:last-modified($collection, $resource)
    return
        if ($timestamp gt $cutoff) then 
            $collection || '/' || $resource || ' - ' || $timestamp
        else ()
};

declare
function local:find-in-collection ($collection as xs:string, $sub-collection as xs:string?, $cutoff as xs:dateTime) as xs:string* {
    let $path := string-join(($collection, $sub-collection), '/')
    return
        if (xmldb:collection-available($path))
        then (
            for-each(
                xmldb:get-child-collections($path),
                local:find-in-collection($path, ?, $cutoff)
            ),
            for-each(
                xmldb:get-child-resources($path),
                local:resource($path, ?, $cutoff)
            )
        )
        else ($path || " not found or insufficient permissions to read")
};

local:scan-for-changes(('/db/apps/84000-data', '/db/apps/84000-import-data'), xs:dateTime('2025-04-23T09:00:00.000'))