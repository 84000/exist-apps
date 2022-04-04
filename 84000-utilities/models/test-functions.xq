xquery version "3.0";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

common:response(
    'utilities/archive-logs',
    'utilities',
    test:suite(
        inspect:module-functions(xs:anyURI("../../84000-reading-room/modules/common.xql"))
    )
)
