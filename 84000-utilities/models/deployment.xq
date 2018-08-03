xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deployment="http://read.84000.co/deployment" at "../modules/deployment.xql";

declare option exist:serialize "method=xml indent=no";

let $action := request:get-parameter('action', '')
let $commit-msg := request:get-parameter('message', '')

return 
    common:response(
        'utilities/deployment',
        'utilities',
        deployment:push-app($action, $commit-msg)
    )

