xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $include-acknowledgements := (request:get-parameter('include-acknowledgements', '') gt '0')

let $delete-translator-id := request:get-parameter('delete', '')

let $delete-translator := 
    if($delete-translator-id gt '') then
        contributors:delete($contributors:contributors/m:contributors/m:person[@xml:id eq $delete-translator-id])
    else
        ()

return
    common:response(
        'operations/translators', 
        'operations', 
        (
            <request xmlns="http://read.84000.co/ns/1.0" include-acknowledgements="{ $include-acknowledgements }"/>,
            contributors:persons($include-acknowledgements),
            contributors:institutions(false()),
            contributors:teams(true(), false(), false())
        )
    )
