xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $section-id := request:get-parameter('section-id', 'all')

return 
    common:response(
        'utilities/test-sections',
        'utilities',
        (
            local:request(),
            tests:sections($section-id),
            section:descendants(tei-content:tei('lobby', 'section'), false())
        )
    )