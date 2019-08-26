xquery version "3.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:permissions() {
    for $resource in collection($target || "/models") ! document-uri(.)
    return
        sm:chmod($resource, "rwxr-x---")
};

local:permissions()
