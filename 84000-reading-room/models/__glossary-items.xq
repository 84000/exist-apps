xquery version "3.0" encoding "UTF-8";
(:
    Accepts a main-term string parameter
    Returns the occurrences of that string in the glossaries as xml
    ---------------------------------------------------------------
:)


declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../modules/glossary.xql";

declare option exist:serialize "method=xml indent=no";

    <response 
        xmlns="http://read.84000.co/ns/1.0" 
        model-type="glossary-items"
        timestamp="{current-dateTime()}"
        app-id="{ $common:app-id }"
        user-name="{ common:user-name() }" >
    {
        glossary:glossary-items(request:get-parameter('term', ''))
    }
    </response>
