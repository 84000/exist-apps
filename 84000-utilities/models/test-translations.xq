xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $translation-id := request:get-parameter('translation-id', 'in-markup')
let $translation-tests := tests:translations($translation-id)
let $translation-files := translations:files($translation:marked-up-status-ids)

return 
    common:response(
        'utilities/test-translations',
        'utilities',
        (
            utilities:request(),
            $translation-tests,
            $translation-files
        )
    )