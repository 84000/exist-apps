xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $text-statuses := request:get-parameter('text-statuses', 'published')

let $text-status-ids :=
    if($text-statuses eq 'published') then
        $translation:published-status-ids
    else if($text-statuses eq 'in-markup') then
        $translation:marked-up-status-ids[not(string() = $translation:published-status-ids/string())]
    else if($text-statuses eq 'marked-up') then
        $translation:marked-up-status-ids
    else ()

let $texts := translations:texts($text-status-ids, (), '', '', '', true())

return
    common:response(
        'utilities/folios',
        'utilities',
        (
            utilities:request(),
            $texts
        )
    )