xquery version "3.0";

module namespace local="http://utilities.84000.co/local";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace pkg="http://expath.org/ns/pkg";
declare namespace sm = "http://exist-db.org/xquery/securitymanager";

declare function local:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function local:user-tabs(){
    let $tabs := doc(concat($common:data-path, '/translator-tools/tabs.xml'))
    let $user := sm:id()
    let $user-groups := $user//sm:real/sm:groups/sm:group
    return
        <tabs xmlns="http://read.84000.co/ns/1.0">
        {
            $tabs/m:tabs/m:tab[not(m:restriction) or m:restriction[@group = $user-groups]]
        }
        </tabs>
};

