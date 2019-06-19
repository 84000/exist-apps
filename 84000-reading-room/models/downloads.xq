xquery version "3.0" encoding "UTF-8";
(:
    Accepts the status-id parameter
    Returns translation versions xml for that status
    --------------------------------------------------------------
    Used on Distribution to get Collaboration files for comparison
:)

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../modules/translations.xql";

declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $resource-ids := request:get-parameter('resource-ids', '')

return
    common:response(
        'downloads',
        $common:app-id,
        translations:downloads(tokenize($resource-ids, ','))
    )