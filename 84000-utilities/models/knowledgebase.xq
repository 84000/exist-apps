xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";

declare option exist:serialize "method=xml indent=no";

let $add-page :=
    let $form-action := request:get-parameter('form-action', '')
    let $title := request:get-parameter('title', '')
    where $form-action eq 'new-page' and $title gt ''
        let $filename := concat(replace(knowledgebase:id($title), '\-', '_'), '.xml')
        let $tei := knowledgebase:new-tei($title)
    where $filename and $tei
        let $store-file := xmldb:store($common:knowledgebase-path, $filename, $tei, 'application/xml')
        let $set-group := sm:chgrp(xs:anyURI(concat($common:knowledgebase-path, '/', $filename)), 'tei')
        let $set-permissions := sm:chmod(xs:anyURI(concat($common:knowledgebase-path, '/', $filename)), 'rw-rw-r--')
    return 
        response:redirect-to(xs:anyURI(concat($common:environment/m:url[@id eq 'utilities'], '/knowledgebase.html')))

return
    common:response(
        'utilities/knowledgebase',
        'utilities',
        (
            utilities:request(),
            knowledgebase:pages()
        )
    )
