xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deployment="http://read.84000.co/deployment" at "../modules/deployment.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

let $action := request:get-parameter('action', '')
let $sync-resource := request:get-parameter('resource', 'all')
let $commit-msg := request:get-parameter('message', '')

return 
    common:response(
        'utilities/snapshot',
        'utilities',
        (
            deployment:snapshot($action, $sync-resource, $commit-msg),
            translations:files()
        )
    )