xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $collection-path := concat($common:data-path, '/tei/layout-checks')
let $layout-checks-tei := collection($collection-path)//tei:TEI

return
    common:response(
        'utilities/layout-checks',
        'utilities',
        (
            utilities:request(),
            <resources xmlns="http://read.84000.co/ns/1.0" collection="{ $collection-path }">
            {
                for $tei in $layout-checks-tei
                let $resource-id := tei-content:id($tei)
                return 
                    <resource id="{ $resource-id }">
                        <title>{ tei-content:title($tei) }</title>
                        <link url="/translation/{ $resource-id }.html?archive-path=layout-checks">HTML</link>
                        <link url="/translation/{ $resource-id }.html?archive-path=layout-checks&amp;view-mode=ebook">EBOOK</link>
                    </resource>
            }
            </resources>
        )
    )