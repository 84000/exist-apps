xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deployment="http://read.84000.co/deployment" at "../modules/deployment.xql";

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
            $deployment:deployment-conf/m:view-repo-url,
            $deployment:deployment-conf/m:apps,
            deployment:deploy-apps($admin-password, $commit-msg, $get-app)
        )
    )

