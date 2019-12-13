xquery version "3.1" encoding "UTF-8";

declare function local:move-redirects(){
    if(doc-available('/db/apps/84000-data/config/redirects.xml')) then
        xmldb:move('/db/apps/84000-data/config', '/db/system/config/db/system', 'redirects.xml')
    else
        (),
    sm:chgrp(xs:anyURI('/db/system/config/db/system/redirects.xml'), 'dba'),
    sm:chmod(xs:anyURI('/db/system/config/db/system/redirects.xml'), 'rw-rw-r--'),
    'moved redirects.xml'
};

declare function local:move-reading-room-config(){
    let $target-app := '84000-reading-room'
    let $target-folder := 'config'
    let $source-path := '/db/apps/84000-data/' || $target-folder
    let $target-app-folder := '/db/apps/' || $target-app || '/' || $target-folder
    return
    (
        (: Create the new collection :)
        xmldb:create-collection('/db/apps/' || $target-app, $target-folder),
        sm:chgrp(xs:anyURI($target-app-folder), 'reading-room'),
        sm:chmod(xs:anyURI($target-app-folder), 'rwxr-xr-x'),
        (: Move the files :)
        for $resource in ('cost-groups.xml', 'page-size-ranges.xml', 'texts.en.xml', 'texts.zh.xml')
        where doc-available($source-path || '/' || $resource)
        return
        (
            xmldb:move($source-path, $target-app-folder, $resource),
            sm:chgrp(xs:anyURI($target-app-folder || '/' || $resource), 'tei'),
            sm:chmod(xs:anyURI($target-app-folder || '/' || $resource), 'rw-rw-r--'),
            'moved ' || $resource
        ),
        local:move-xconf('/db/apps/84000-reading-room/xconf', $source-path, $target-app, $target-folder, 'reading-room', 'rwxr-xr-x'),
        local:move-xconf('/db/system/config', $source-path, $target-app, $target-folder, 'dba', 'rwxr-xr-x')
    )
};

declare function local:move-xconf($xconf-path as xs:string, $source-path as xs:string, $target-app as xs:string, $target-folder as xs:string, $folder-group as xs:string, $folder-permissions as xs:string){

    (: Create the app folder :)
    xmldb:create-collection($xconf-path || '/db/apps', $target-app),
    sm:chgrp(xs:anyURI($xconf-path || '/db/apps/' || $target-app), $folder-group),
    sm:chmod(xs:anyURI($xconf-path || '/db/apps/' || $target-app), $folder-permissions),
    
    (: Create the sub folder :)
    xmldb:create-collection($xconf-path || '/db/apps/' || $target-app, $target-folder),
    sm:chgrp(xs:anyURI($xconf-path || '/db/apps/' || $target-app || '/' || $target-folder), $folder-group),
    sm:chmod(xs:anyURI($xconf-path  || '/db/apps/'|| $target-app || '/' || $target-folder), $folder-permissions),
    
    (: Move the files :)
    if(doc-available($xconf-path || $source-path || '/' || $target-app)) then
        xmldb:move($xconf-path || $source-path, $xconf-path || '/db/apps/' || $target-app)
    else
        ()
    
};

declare function local:move-operations-config(){
    let $target-app := '84000-operations'
    let $target-folder := 'config'
    let $source-path := '/db/apps/84000-data/' || $target-folder
    let $target-app-folder := '/db/apps/' || $target-app || '/' || $target-folder
    return
    (
        (: Create the new collection :)
        xmldb:create-collection('/db/apps/' || $target-app, $target-folder),
        sm:chgrp(xs:anyURI($target-app-folder), 'operations'),
        sm:chmod(xs:anyURI($target-app-folder), 'rwxr-xr-x'),
        (: Move the files :)
        for $resource in ('contributor-types.xml', 'publication-tasks.xml', 'submission-checklist.xml')
        where doc-available($source-path || '/' || $resource)
        return
        (
            xmldb:move($source-path, $target-app-folder, $resource),
            sm:chgrp(xs:anyURI($target-app-folder || '/' || $resource), 'tei'),
            sm:chmod(xs:anyURI($target-app-folder || '/' || $resource), 'rw-rw-r--'),
            'moved ' || $resource
        )
    )
};

declare function local:move-tests(){
    (: Create the new collection :)
    xmldb:create-collection('/db/apps/84000-data/config', 'tests'),
    sm:chgrp(xs:anyURI('/db/apps/84000-data/config/tests'), 'utilities'),
    sm:chmod(xs:anyURI('/db/apps/84000-data/config/tests'), 'rwxr-xr-x'),
    
    (: Move lucene-tests.xml :)
    if(doc-available('/db/apps/84000-data/utilities/lucene-tests.xml')) then
        xmldb:move('/db/apps/84000-data/utilities', '/db/apps/84000-data/config/tests', 'lucene-tests.xml')
    else
        (),
    sm:chgrp(xs:anyURI('/db/apps/84000-data/config/tests/lucene-tests.xml'), 'utilities'),
    sm:chmod(xs:anyURI('/db/apps/84000-data/config/tests/lucene-tests.xml'), 'rw-rw-r--'),
    'moved lucene-tests.xml',
    
    (: Move sections-structure.xml :)
    if(doc-available('/db/apps/84000-data/operations/sections-structure.xml')) then
        xmldb:move('/db/apps/84000-data/operations', '/db/apps/84000-data/config/tests', 'sections-structure.xml')
    else
        (),
    sm:chgrp(xs:anyURI('/db/apps/84000-data/config/tests/sections-structure.xml'), 'dba'),
    sm:chmod(xs:anyURI('/db/apps/84000-data/config/tests/sections-structure.xml'), 'rw-rw-r--'),
    'moved sections-structure.xml'
};

declare function local:move-linked-data-refs(){
    (: Create the new collection :)
    xmldb:create-collection('/db/apps/84000-data/config', 'linked-data'),
    sm:chgrp(xs:anyURI('/db/apps/84000-data/config/linked-data'), 'operations'),
    sm:chmod(xs:anyURI('/db/apps/84000-data/config/linked-data'), 'rwxr-xr-x'),
    
    (: Move text-refs.xml :)
    if(doc-available('/db/apps/84000-data/operations/text-refs.xml')) then
        xmldb:move('/db/apps/84000-data/operations', '/db/apps/84000-data/config/linked-data', 'text-refs.xml')
    else
        (),
    sm:chgrp(xs:anyURI('/db/apps/84000-data/config/linked-data/text-refs.xml'), 'operations'),
    sm:chmod(xs:anyURI('/db/apps/84000-data/config/linked-data/text-refs.xml'), 'rw-r--r--'),
    'moved text-refs.xml',
    
    (: Move collection-refs.xml :)
    if(doc-available('/db/apps/84000-data/operations/collection-refs.xml')) then
        xmldb:move('/db/apps/84000-data/operations', '/db/apps/84000-data/config/linked-data', 'collection-refs.xml')
    else
        (),
    sm:chgrp(xs:anyURI('/db/apps/84000-data/config/linked-data/collection-refs.xml'), 'operations'),
    sm:chmod(xs:anyURI('/db/apps/84000-data/config/linked-data/collection-refs.xml'), 'rw-r--r--'),
    'moved collection-refs.xml'
};

declare function local:move-translation-status(){

    (: Move text-refs.xml :)
    if(doc-available('/db/apps/84000-data/operations/translation-status.xml')) then
        xmldb:move('/db/apps/84000-data/operations', '/db/apps/84000-data/local', 'translation-status.xml')
    else
        (),
    'moved translation-status.xml'
};

local:move-redirects()
(:local:move-tests():)
(:local:move-linked-data-refs():)
(:local:move-translation-status():)
(: No need to move reading-room config!!! It's deployed in the app??? local:move-reading-room-config() :)
(: No need to move operations config!!! It's deployed in the app??? local:move-operations-config():)


