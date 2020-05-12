xquery version "3.0";

module namespace local="http://operations.84000.co/local";
declare namespace pkg="http://expath.org/ns/pkg";

declare function local:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function local:get-status-parameter() as xs:string* {
    let $post-status := request:get-parameter('status[]', '')
    let $get-status := tokenize(request:get-parameter('status', ''), ',')
    return
        if (count($get-status) gt 0) then
            $get-status
        else
            $post-status
};