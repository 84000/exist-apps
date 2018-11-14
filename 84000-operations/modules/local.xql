xquery version "3.0";

module namespace local="http://operations.84000.co/local";
declare namespace pkg="http://expath.org/ns/pkg";

declare function local:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function local:get-status-parameter(){
    let $post-status := request:get-parameter('status[]', '')
    let $get-status := tokenize(request:get-parameter('status', ''), ',')
    return
        if (count($get-status)) then
            $get-status
        else
            $post-status
};

declare function local:user-groups() as xs:string* {
    let $user := sm:id()
    return $user//sm:real/sm:groups/sm:group
};

