xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:permissions() {

    (: Login required to access models :)
    for $resource in collection($target || "/models") ! document-uri(.)
    return
        
        (: Allow scheduler to archive logs :)
        if(ends-with($resource, 'archive-logs.xq')) then
            sm:chmod($resource, "rwsr-xr-x")
            
        (: Only admins can deploy - therefore no need for SetUID :)
        else if(ends-with($resource, 'deployment.xq')) then
            sm:chmod($resource, "rwx------")
            
        (: SetUID to allow interaction with the file system for git integration :)
        else if(ends-with($resource, 'snapshot.xq')) then
            sm:chmod($resource, "rwsr-x---")
            
        (: SetUID to allow interaction with the file system for ebook creation :)
        else if(ends-with($resource, 'translations.xq')) then
            sm:chmod($resource, "rwsr-x---")
        
        (: Access restricted to the group :)
        else
            sm:chmod($resource, "rwxr-x---"),
    
    (: Only admins can run scripts :)
    for $resource in collection($target || "/scripts") ! document-uri(.)
    return
        sm:chmod($resource, "rwx------")
    
};

local:permissions(),
xmldb:reindex('/db/apps/84000-data/utilities')
