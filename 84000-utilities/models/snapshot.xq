xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $action := request:get-parameter('action', '')
let $sync-resource := request:get-parameter('resource', 'all')
let $commit-msg := request:get-parameter('message', '')

return 
    common:response(
        'utilities/snapshot',
        'utilities',
        (
            $deploy:snapshot-conf/m:view-repo-url,
            deploy:commit-data($action, $sync-resource, $commit-msg),
            translations:files($tei-content:published-statuses)
        )
    )