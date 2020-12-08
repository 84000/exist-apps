xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../../modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')

return
    common:response(
        "widget/section-checkbox", 
        $common:app-id,
        section:section-tree(tei-content:tei('lobby', 'section'), true(), 'descendants-published')
        
    )
