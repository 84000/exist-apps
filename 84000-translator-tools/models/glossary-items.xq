xquery version "3.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace local="http://translator-tools.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

declare option exist:serialize "method=xml indent=no";

let $glossary-items := glossary:glossary-items(request:get-parameter('term', ''), request:get-parameter('lang', ''))

let $internal-refs := transform:transform($glossary-items, doc(concat($common:app-path, "/xslt/internal-refs.xsl")), <parameters/>)

return
    common:response(
        'translator-tools/glossary-items',
        'translator-tools',
        $internal-refs 
    )
