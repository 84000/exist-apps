xquery version "3.1" encoding "UTF-8";

(:
   Add functions here for manipulating files
:)

(: Sets xml mimetype for all files in a collection with the given file extension :)
declare function local:files-mimetype-xml($collection-uri as xs:string, $file-extension as xs:string){
    for $file in xmldb:get-child-resources($collection-uri)
    order by $file
    where ends-with($file, '.' || $file-extension)
    return
        if(not(xmldb:get-mime-type(xs:anyURI(concat($collection-uri, '/', $file))) eq 'application/xml')) then(
            xmldb:store(
                $collection-uri, 
                $file, 
                util:binary-to-string(util:binary-doc(concat($collection-uri, '/', $file))), 
                (:doc(concat($collection-uri, '/', $file)), :)
                'application/xml'
            ),
            concat('CONVERTED TO XML: ', $file)
        )
        else
            concat('ALREADY XML: ', $file)
};

(: Sets group and permissions for all files in collection with the given file extension :)
declare function local:files-permissions($collection-uri as xs:string, $file-extension as xs:string, $owner as xs:string, $group as xs:string, $permissions as xs:string){
    for $file in xmldb:get-child-resources($collection-uri)
    let $file-uri := xs:anyURI(concat($collection-uri, '/', $file))
    order by $file
    where ends-with($file, '.' || $file-extension)
    return(
        sm:get-permissions($file-uri)(:,
        sm:chown($file-uri, $owner),
        sm:chgrp($file-uri, $group),
        sm:chmod($file-uri, $permissions),
        concat($file-uri, ' owner:', $owner, ' group:', $group, ' permissions:', $permissions):)
    )
};

(:local:files-permissions('/db/apps/84000-data/tei/translations/kangyur/translations', 'xml', 'admin', 'tei', 'rw-rw-r--'):)
local:files-mimetype-xml('/db/apps/84000-data/cache', 'cache')
(:local:files-permissions('/db/apps/84000-data/azw3', 'azw3', 'admin', 'utilities', 'rw-rw-r--'),:)
(:local:files-permissions('/db/apps/84000-data/cache', 'cache', 'admin', 'tei', 'rw-rw-r--'),
local:files-permissions('/db/apps/84000-data/epub', 'epub', 'admin', 'utilities', 'rw-rw-r--'),
local:files-permissions('/db/apps/84000-data/pdf', 'pdf', 'admin', 'utilities', 'rw-rw-r--'),
local:files-permissions('/db/apps/84000-data/rdf', 'rdf', 'admin', 'utilities', 'rw-rw-r--'):)

