xquery version "3.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

let $entries := 
    for $file in xmldb:xcollection(concat($common:data-path, '/translation-memory'))
        let $document-uri := document-uri($file)
        let $document-uri-tokenized := tokenize($document-uri, '/')
        let $file-name := $document-uri-tokenized[count($document-uri-tokenized)]
        let $name := substring-before($file-name, '.')
    return
        <entry name="{ concat($name, '.tmx') }" type="xml">{ $file }</entry>

let $zip := compression:zip($entries, true())

let $title := concat('TMX-84000-', format-date(current-date(), "[D01]-[M01]-[Y0001]"), '.zip')

return
    response:stream-binary($zip, 'application/xml+zip', $title)