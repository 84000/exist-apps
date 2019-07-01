xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/prototype", 
    $common:app-id,
    (
       element { QName('http://read.84000.co/ns/1.0', 'editable') } {
           common:local-text('source.folio.ekangyur-description-content', 'en')
       },
       element { QName('http://read.84000.co/ns/1.0', 'input') } {
            request:get-parameter('contenteditable', '')
       }
    )
)
