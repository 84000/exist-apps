xquery version "3.0";
(:
    Accepts the resource-id parameter
    Returns the translation tei
    -------------------------------------------------------------
    Simply return the TEI.
:)

declare option exist:serialize "method=xml indent=no";

import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";

tei-content:tei(request:get-parameter('resource-id', ''), 'translation')
