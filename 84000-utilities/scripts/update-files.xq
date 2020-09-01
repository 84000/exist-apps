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
                'application/xml'
            ),
            concat($file, ' converted to xml')
        )
        else
            concat('ALREADY XML: ', $file)
};

(: Sets group and permissions for all files in collection with the given file extension :)
declare function local:files-permissions($collection-uri as xs:string, $file-extension as xs:string, $group as xs:string, $permissions as xs:string){
    for $file in xmldb:get-child-resources($collection-uri)
    order by $file
    where ends-with($file, '.' || $file-extension)
    return(
        sm:chgrp(xs:anyURI(concat($collection-uri, '/', $file)), $group),
        sm:chmod(xs:anyURI(concat($collection-uri, '/', $file)), $permissions),
        concat($file, ' group:', $group, ' permissions:', $permissions)
    )
};

local:files-mimetype-xml('/db/apps/84000-data/translation-memory', 'tmx'),
local:files-permissions('/db/apps/84000-data/translation-memory', 'tmx', 'translation-memory', 'rw-rw-r--')