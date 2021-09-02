xquery version "3.0";

module namespace install="http://read.84000.co/install";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare function install:base-permissions($collection as xs:string) {

    (: set collection permissions :)
    sm:chmod($collection, "rwxr-xr-x"),
    
    (: set collection group :)
    sm:chgrp($collection, 'reading-room'),
    
    (: set resource :)
    for $resource in collection($collection) ! document-uri(.)
    return
    (
        (: set group :)
        if(not(ends-with($resource, '.xconf'))) then
            sm:chgrp($resource, 'reading-room')
        else
            (),
            
        (: set permissions :)
        if(ends-with($resource, '.xql') or ends-with($resource, '.xq')) then
            sm:chmod($resource, 'rwxr-xr-x')
        else
            sm:chmod($resource, 'rw-r--r--')
    ),
    (: set resource permissions :)
    for $child in xmldb:get-child-collections($collection)
    return
        install:base-permissions(concat($collection, "/", $child))
};

declare function install:special-permissions($collection as xs:string) {

    (: Auth is restricted and referenced on calls in secured environment :)
    sm:chmod(xs:anyURI($collection || "/models/auth.xq"), "rwxr-x---"),
    
    (: Only admins can run migrations :)
    for $resource in collection($collection || "/migrations") ! document-uri(.)
    return
        sm:chmod($resource, "rwx------")
    
};

declare function install:copy-xconf($collection as xs:string){
    xmldb:copy-collection(concat($collection, "/xconf/db/apps"),"/db/system/config/db", true())
};

declare function install:reindex() {
    
    xmldb:reindex('/db/apps/84000-data/config'),
    xmldb:reindex('/db/apps/84000-data/operations'),
    xmldb:reindex('/db/apps/84000-data/tei'),
    xmldb:reindex('/db/apps/84000-data/translation-memory'),
    xmldb:reindex('/db/apps/tibetan-source/data')

};
