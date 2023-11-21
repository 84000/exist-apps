xquery version "3.1";

let $target-collection := '/db/apps/84000-cache/html/glossary-entry'

where 
    starts-with($target-collection, '/db/apps/84000-cache/html/glossary-entry')
    and xmldb:collection-available($target-collection)

return
    for $sub-collection in subsequence(xmldb:get-child-collections($target-collection),1,500)
    let $sub-collection-uri := $target-collection || '/' ||$sub-collection
    let $permissions := sm:get-permissions(xs:anyURI($sub-collection-uri))
    where $permissions/sm:permission[@group eq 'guest']
    return (
        xmldb:remove($sub-collection-uri),
        (:$permissions,:)
        'Collection cleared: ' || $sub-collection-uri
    )
