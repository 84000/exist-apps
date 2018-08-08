xquery version "3.0" encoding "UTF-8";
(:
    Returns the entire cumulative glossary
    ---------------------------------------------------------------
:)

import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

let $entries := 
    <entry name="cumulative-glossary.xml" type="xml">
    { 
        glossary:cumulative-glossary()
    }
    </entry>

let $zip := compression:zip($entries, true())

let $title := concat('84000-cumulative-glossary-', format-date(current-date(), "[D01]-[M01]-[Y0001]"), '.zip')

return
    response:stream-binary($zip, 'application/xml+zip', $title)
