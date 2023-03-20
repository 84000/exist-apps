xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $collection-path := concat($common:data-path, '/tei/layout-checks')
let $layout-checks-tei := collection($collection-path)//tei:TEI
let $reading-room-path := $common:environment/m:url[@id eq 'reading-room']/text()

return
common:response(
    'utilities/tests',
    'utilities',
    (
        utilities:request(),
        <layout-checks xmlns="http://read.84000.co/ns/1.0" collection="{ $collection-path }">
            {
                for $tei in $layout-checks-tei
                let $text-id := tei-content:id($tei)
                return
                for $toh-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                order by $toh-key
                return 
                    <resource id="{ $text-id }" toh-key="{ $toh-key }">
                        <title>{ translation:title($tei, $toh-key) }</title>
                        <link url="{ $reading-room-path }/translation/{ $toh-key }.html">View html</link>
                        <link url="{ $reading-room-path }/translation/{ $toh-key }.html?view-mode=editor">View html in editor mode</link>
                        <link url="{ $reading-room-path }/translation/{ $toh-key }.epub">View epub</link>
                        <link url="/test-translations.html?translation-id={ $text-id }">Run automated tests</link>
                    </resource>
            }
        </layout-checks>
    )
)