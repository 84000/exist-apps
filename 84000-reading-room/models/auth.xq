xquery version "3.0" encoding "UTF-8";

declare option exist:serialize "method=xml indent=no";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";

let $redirect := lower-case(request:get-parameter('redirect', '/section/lobby.html'))

return
    common:response(
        "auth", 
        $common:app-id,
        <redirect>{ $redirect }</redirect>
    )
