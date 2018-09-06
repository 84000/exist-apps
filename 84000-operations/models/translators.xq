xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translators="http://read.84000.co/translators" at "../../84000-reading-room/modules/translators.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $include-acknowledgements := (request:get-parameter('include-acknowledgements', '') gt '0')

let $delete-translator-id := request:get-parameter('delete', '')

let $dummy := 
    if($delete-translator-id gt '') then
        translators:delete($translators:translators/m:translators/m:translator[@xml:id eq $delete-translator-id])
    else
        ()

return
    common:response(
        'operations/translators', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0" include-acknowledgements="{ $include-acknowledgements }"/>,
            translators:translators($include-acknowledgements),
            translators:institutions(),
            translators:teams(false())
        )
    )
