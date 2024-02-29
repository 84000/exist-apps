xquery version "3.0";

module namespace utilities="http://utilities.84000.co/utilities";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace pkg="http://expath.org/ns/pkg";

declare function utilities:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function utilities:request() as element(m:request) {
    utilities:request(())
};

declare function utilities:request($request as element(m:request)?)  as element(m:request) {
    <request xmlns="http://read.84000.co/ns/1.0">
    {
        
        $request/@*,
        $request/node(),
        
        if(request:exists()) then (
            for $request-parameter in common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
            where not($request-parameter = ('password', $request/m:parameter/@name/string()))
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
        )
        else ()
    }
    </request>

};