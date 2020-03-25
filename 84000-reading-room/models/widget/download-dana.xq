xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')

return
    common:response(
        "widget/download-dana", 
        $common:app-id,
        element { QName('http://read.84000.co/ns/1.0', 'title') } {
            tei-content:title(tei-content:tei($resource-id, 'translation'))
        }
        
    )
