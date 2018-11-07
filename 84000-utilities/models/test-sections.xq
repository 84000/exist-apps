xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";

declare option exist:serialize "method=xml indent=no";

let $section-id := request:get-parameter('section-id', 'all')

let $lobby := tei-content:tei('lobby', 'section')

return 
    common:response(
        'utilities/test-sections',
        'utilities',
        (
            <request xmlns="http://read.84000.co/ns/1.0" section-id="{$section-id}" />,
            tests:sections($section-id),
            section:descendants($lobby, 1, false())
        )
    )