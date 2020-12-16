xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    'utilities/layout-checks',
    'utilities',
    (
        utilities:request(),
        <resources xmlns="http://read.84000.co/ns/1.0">
            <resource id="UT22084-000-000">
                <link url="/translation/UT22084-000-000.html?archive-path=layout-checks">HTML</link>
                <link url="/translation/UT22084-000-000.html?archive-path=layout-checks&amp;view-mode=ebook#UT22084-000-000-33">EBOOK</link>
            </resource>
        </resources>
    )
)