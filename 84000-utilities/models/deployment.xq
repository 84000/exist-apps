xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $admin-password := request:get-parameter('password', '')
let $commit-msg := request:get-parameter('message', '')
let $get-app := request:get-parameter('app', '')

return 
    common:response(
        'utilities/deployment',
        'utilities',
        (
            utilities:request(),
            $deploy:deployment-conf/m:view-repo-url,
            $deploy:deployment-conf/m:apps,
            if(common:user-in-group('dba') and $admin-password gt '') then
                deploy:deploy-apps($admin-password, $commit-msg, $get-app)
            else
                ()
        )
    )

