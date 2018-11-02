xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

(: 
 TO DO:
 Select statuses this in the UI.
 For now default to 1 and 2.a.
:)
let $text-statuses := request:get-parameter('text-statuses', ('1', '2.a'))

let $translation-id := request:get-parameter('translation-id', 'all')

return 
    common:response(
        'utilities/test-translations',
        'utilities',
        (
            <request xmlns="http://read.84000.co/ns/1.0" translation-id="{$translation-id}" />,
            tests:translations($text-statuses, $translation-id),
            translations:files($text-statuses)
        )
    )