xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    'utilities/sections',
    'utilities',
    (
        utilities:request(),
        section:child-sections(tei-content:tei('lobby', 'section'), true(), 'none'),
        tests:structure()
    )
)
