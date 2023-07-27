xquery version "3.0" encoding "UTF-8";
(:
    Returns data for combined glossary downloads
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xls="urn:schemas-microsoft-com:office:spreadsheet";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";

declare option exist:serialize "method=xml indent=no";

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

(: Check if there's something in the cache :)
let $cache-key := common:cache-key-latest($request)

where $cache-key
return
    
    if($request/@resource-suffix = ('xlsx')) then
        
        let $spreadsheet := common:cache-get($request, $cache-key) 
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || concat($cache-key, '.xlsx')),
            response:stream-binary($spreadsheet, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        )
    
    else if($request/@resource-suffix eq 'txt') then
        
        let $txt := common:cache-get($request, $cache-key) 
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || concat($cache-key, '-', $request/@key, '.txt')),
            response:stream-binary($txt, 'text/plain')
        )
    
    else if($request/@resource-suffix eq 'dict') then
        
        let $dict := common:cache-get($request, $cache-key) 
        return (
            response:set-header("Content-Disposition", "attachment; filename=" || concat($cache-key, '-', $request/@key, '.dict.zip')),
            response:stream-binary($dict, 'application/zip')
        )
    
    (: Default return xml :)
    else
        let $xml := common:cache-get($request, $cache-key) 
        return(
            response:set-header("Content-Disposition", "attachment; filename=" || concat($cache-key, '.xml')),
            common:serialize-xml($xml)
        )

    
    