xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:permissions() {

    (: Login required to access models :)
    for $resource in collection($target || "/models") ! document-uri(.)
    return
        
        (: SetUID to allow interaction with the file system for epub generation :)
        if(ends-with($resource, 'edit-text-header.xq')) then
            sm:chmod($resource, "rwsr-x---")
        
        (: SetUID to allow interaction with the file system for oxgarage local installation :)
        else if(ends-with($resource, 'edit-text-submission.xq')) then
            sm:chmod($resource, "rwsr-x---")
        
        (: Access restricted to the group :)
        else
            sm:chmod($resource, "rwxr-x---")
};

local:permissions()
