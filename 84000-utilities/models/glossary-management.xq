xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

declare option exist:serialize "method=xml indent=no";

let $type := request:get-parameter('type', 'search')
let $search := request:get-parameter('search', '')
let $search-lang := request:get-parameter('search-lang', 'en')

return
    common:response(
        'utilities/glossary-management',
        'utilities',
        (
            <request xmlns="http://read.84000.co/ns/1.0" search-lang="{ $search-lang }" type="{ $type }">
                <search>{ $search }</search>
            </request>,
            glossary:glossary-terms($type, $search-lang, $search, false())
        )
        
    )