xquery version "3.0" encoding "UTF-8";
(:
    Returns data for combined glossary downloads
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xls="urn:schemas-microsoft-com:office:spreadsheet";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../modules/glossary.xql";

let $resource-suffix := request:get-parameter('resource-suffix', '')

let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary-download' },
        (: Validate suffix :)
        attribute resource-suffix { $resource-suffix },
        (: Add key for txt and dict :)
        if($resource-suffix = ('txt', 'dict')) then
            attribute key { (request:get-parameter('key', 'bo')[. = ('bo', 'wy')], 'bo')[1] }
        else ()
    }
    
let $glossary-downloads := glossary:downloads()

where $glossary-downloads
return
    
    if($request/@resource-suffix = ('xlsx')) then
        
        let $glossary-download := $glossary-downloads/m:download[@type eq 'xlsx']
        let $spreadsheet := $glossary-download ! util:binary-doc(concat(@collection, '/', @filename))
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || $glossary-download/@filename),
            response:stream-binary($spreadsheet, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        )
    
    else if($request/@resource-suffix eq 'txt' and $request/@key  gt '') then
        
        let $glossary-download := $glossary-downloads/m:download[@type eq 'txt'][@lang-key eq $request/@key]
        let $txt := $glossary-download ! util:binary-doc(concat(@collection, '/', @filename))
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || $glossary-download/@filename),
            response:stream-binary($txt, 'text/plain')
        )
    
    else if($request/@resource-suffix eq 'dict' and $request/@key  gt '') then
        
        let $glossary-download := $glossary-downloads/m:download[@type eq 'dict'][@lang-key eq $request/@key]
        let $dict := $glossary-download ! util:binary-doc(concat(@collection, '/', @filename))
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || $glossary-download/@filename),
            response:stream-binary($dict, 'application/zip')
        )
    
    (: Default return xml :)
    else
        let $glossary-download := $glossary-downloads/m:download[@type eq 'xml']
        let $xml := $glossary-download ! doc(concat(@collection, '/', @filename))/m:glossary-combined
        let $entry := <entry name="{ $glossary-download/@filename }" type="xml">{ $xml }</entry>
        let $zip := compression:zip($entry, true())
        where $xml
        return(
            response:set-header("Content-Disposition", "attachment; filename=" || $glossary-download/@filename || '.zip'),
            response:stream-binary($zip, 'application/zip')
        )

    
    