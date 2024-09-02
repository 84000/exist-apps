declare namespace file = "http://exist-db.org/xquery/file";

import module namespace store = "http://read.84000.co/store" at "/db/apps/84000-reading-room/modules/store.xql";

let $source-path := '/home/existdb/exist-sync/data-static/source'
let $source-pattern := '**/*.html'
let $target-collection := '/db/apps/84000-static/source'

let $files-to-store := file:directory-list($source-path, $source-pattern)/file:file
(: Throttle in case it's very many :)
let $files-to-store := subsequence($files-to-store, 1, 50)

for $file in $files-to-store 
let $source-file := string-join(($source-path, $file/@subdir, $file/@name), '/')
let $target-path := string-join(($target-collection, $file/@subdir), '/')
return
    if(util:binary-doc-available($target-path || '/' || $file/@name)) then
        concat('Skipping: ', $source-file)
    else
        let $validate-collection :=
            if(not(xmldb:collection-available($target-path))) then
                store:create-missing-collection($target-path)
            else true()
        
        let $file-content := file:read-binary($source-file) ! util:binary-to-string(.)
        let $store-file := xmldb:store($target-path, $file/@name, $file-content, 'text/plain')
        
        let $set-permissions := (
            sm:chown(xs:anyURI($target-path || '/' || $file/@name), 'admin'),
            sm:chgrp(xs:anyURI($target-path || '/' || $file/@name), $store:permissions-group),
            sm:chmod(xs:anyURI($target-path || '/' || $file/@name), $store:file-permissions)
        )
        return
            concat($source-file, ' -> ', $target-path, '/', $file/@name)

(: Alternative method doesn't set permission :)
(:,xmldb:store-files-from-pattern('/db/apps/84000-static/source', '/home/existdb/exist-sync/data-static/source', 'toh52/*.html', 'text/plain', true()):)