xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $section-id := request:get-parameter('section-id', 'lobby')
let $published-only := request:get-parameter('published-only', false())
let $include-descendants := request:get-parameter('include-descendants', false())

return
    common:response(
        'utilities/section-texts',
        'utilities',
        (
            utilities:request(),
            section:texts($section-id, $published-only, $include-descendants)
        )
    )