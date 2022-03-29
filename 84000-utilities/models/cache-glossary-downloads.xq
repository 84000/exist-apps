xquery version "3.0" encoding "UTF-8";
(:
    Returns data for combined glossary downloads
:)

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xls="urn:schemas-microsoft-com:office:spreadsheet";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

declare option exist:serialize "method=xml indent=no";

let $cache-key := concat("84000-glossary-", format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]"))
(:let $cache-key := "2022-03-28-10-11-07":)

(: Cache xml :)
let $request-xml := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'glossary-download' },
        attribute resource-suffix { 'xml' }
    }

let $cached-xml := common:cache-get($request-xml, $cache-key)

let $glossary-combined := 
    if(not($cached-xml)) then
        let $content := glossary:combined()
        let $cache-put := common:cache-put($request-xml, $content, $cache-key)
        return
            $content
    else
        $cached-xml//m:glossary-combined

where $glossary-combined
(: Return the request element for each cached file :)
return 
    element { QName('http://read.84000.co/ns/1.0', 'cached') } {
    
        attribute cache-key { $cache-key },
        
        $request-xml,
    
        (: Cache xlsx :)
        let $request-xlsx := 
            element { QName('http://read.84000.co/ns/1.0', 'request')} {
                attribute model { 'glossary-download' },
                attribute resource-suffix { 'xlsx' }
            }
        
        let $spreadsheet-data := glossary:spreadsheet-data($glossary-combined)

        let $spreadsheet-zip := common:spreadsheet-zip($spreadsheet-data)
        
        let $cache-put := common:cache-put($request-xlsx, $spreadsheet-zip, $cache-key)
        
        return 
            $request-xlsx
    ,
    
    for $key in ('bo', 'wy')
    return 
        
        (: Cache txt :)
        let $request-txt := 
            element { QName('http://read.84000.co/ns/1.0', 'request')} {
                attribute model { 'glossary-download' },
                attribute resource-suffix { 'txt' },
                attribute key { $key }
            }
        
        let $glossary-txt := glossary:combined-txt($glossary-combined, $request-txt/@key)
        
        let $glossary-txt := string-join($glossary-txt, '')
        
        let $cache-put := common:cache-put($request-txt, $glossary-txt, $cache-key)
        
        return (
            $request-txt,
            
            let $pyglossary-file := concat('/', $common:environment/m:glossary-downloads-conf/m:pyglossary-path)
            let $sync-folder := concat('/', $common:environment/m:glossary-downloads-conf/m:sync-path)
            where $pyglossary-file and $sync-folder
            
            (: Cache dict :)
            let $request-dict := 
                element { QName('http://read.84000.co/ns/1.0', 'request')} {
                    attribute model { 'glossary-download' },
                    attribute resource-suffix { 'dict' },
                    attribute key { $key }
                }
            
            let $cache-filename-txt := common:cache-filename($request-txt, $cache-key)
            let $cache-collection-txt := common:cache-collection($request-txt)
            let $cache-collection-txt-rel := substring-after($cache-collection-txt, concat($common:data-path, '/'))
            let $cache-filename-dict := common:cache-filename($request-dict, $cache-key)
            let $cache-collection-dict := common:cache-collection($request-dict)
            let $sync-folder-txt := concat($sync-folder, '/', $cache-collection-txt-rel)
            let $sync-filename-key := concat('84000-glossary-', $key)
            let $sync-folder-dict := concat($sync-folder, '/dict')
            let $dict-filename-zip := concat($sync-filename-key, '.zip')
            let $upload-dict-zip-path := concat('file://', $sync-folder-dict, '/', $dict-filename-zip)
            
            let $exec-pyglossary-options := 
                <options>
                    <workingDir>{$sync-folder}</workingDir>
                </options>
            
            let $exec-pyglossary := (
                'python3', 
                $pyglossary-file, 
                concat($sync-folder-txt, '/', $cache-filename-txt), 
                concat($sync-folder-dict, '/', $sync-filename-key),
                '--read-format=Tabfile',
                '--write-format=Stardict',
                '--no-interactive'
            )
            
            let $exec-zip-options := 
                <options>
                    <workingDir>{$sync-folder-dict}</workingDir>
                </options>
            
            let $exec-zip := (
                'zip', 
                '-rj', 
                $dict-filename-zip,
                $sync-filename-key
            )
            
            let $generate-dict := (
                (: Clear the existing files :)
                file:delete($sync-folder-txt),
                (: Sync to file system :)
                file:sync($cache-collection-txt, $sync-folder-txt, ()),
                (: Ensure the target directory exists :)
                file:mkdirs(concat($sync-folder-dict, '/', $sync-filename-key)),
                (: Generate dict resources :)
                process:execute($exec-pyglossary, $exec-pyglossary-options),
                (: Create a zip :)
                process:execute($exec-zip, $exec-zip-options),
                (: Add zip to the db :)
                let $dict-data := file:read-binary($upload-dict-zip-path)
                return
                    common:cache-put($request-dict, $dict-data, $cache-key)
            )
            
            return ( 
                $request-dict,
                element debug {
                    string-join($exec-pyglossary, ' '),
                    $exec-pyglossary-options,
                    string-join($exec-zip, ' '),
                    $exec-zip-options(:,
                    for $resource in xmldb:get-child-resources($cache-collection-dict)
                    let $path-tokenized := tokenize($cache-collection-dict, '/')
                    where 
                        count($path-tokenized) gt 6
                        and $path-tokenized[last() -1] eq 'glossary-download'
                        and util:binary-doc-available(concat($cache-collection-dict, '/', $resource))
                    return
                        element resource {
                            attribute path-tokenized-count { count($path-tokenized) },
                            attribute path-tokenized-last { $path-tokenized[last() -1] },
                            concat($cache-collection-dict, '/', $resource)
                        }:)
                }
            )
        )
    }

    
    