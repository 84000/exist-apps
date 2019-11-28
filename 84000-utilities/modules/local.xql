xquery version "3.0";

module namespace local="http://utilities.84000.co/local";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare namespace pkg="http://expath.org/ns/pkg";

declare function local:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function local:request(){
    <request xmlns="http://read.84000.co/ns/1.0">
    {
        for $request-parameter in common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
        return
            <parameter name="{ $request-parameter }">{ request:get-parameter($request-parameter, '') }</parameter>
        ,
        let $user := sm:id()//sm:real
        return
            <authenticated-user name="{ $user/sm:username/text() }">
            {
               for $group in $user/sm:groups/sm:group/text()
               return
                   <group name="{ $group }"/>
            }
            </authenticated-user>
            
    }
    </request>
};