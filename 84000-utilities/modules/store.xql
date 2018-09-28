xquery version "3.0";

module namespace store = "http://utilities.84000.co/store";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace download = "http://read.84000.co/download" at "../../84000-reading-room/modules/download.xql";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare variable $store:conf := $common:environment//m:store-conf;
declare variable $store:file-group := 'utilities';
declare variable $store:file-permissions := 'rw-rw-r--';

declare function store:file($file-name as xs:string) (: as xs:string* :) {
    
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (: Get document version in data store :)
    let $store-version := download:stored-version-str($resource-id, $file-extension)
    
    (: Get TEI document version :)
    let $translation := tei-content:tei($resource-id, 'translation')
    let $tei-version := translation:version-str($translation)
    
    return
        <updated xmlns="http://read.84000.co/ns/1.0">
        {
            if(compare($store-version, $tei-version) ne 0)then
                (: generate and store the latest version :)
                if($file-extension eq 'pdf') then
                    (:'Store new pdf':)
                    let $file-path := concat($common:data-path, '/', $file-extension, '/', $resource-id, '.pdf')
                    return
                        store:store-new-pdf($file-path, $tei-version)
                else if($file-extension = ('epub', 'azw3')) then
                    (:'Store new ebooks':)
                    let $epub-file-path := concat($common:data-path, '/epub/', $resource-id, '.epub')
                    let $store-new-epub := store:store-new-epub($epub-file-path, $tei-version)
                    let $azw3-file-path := concat($common:data-path, '/azw3/', $resource-id, '.azw3')
                    let $store-new-azw3 := store:store-new-azw3($azw3-file-path, $tei-version)
                    return
                        string-join(($store-new-epub, $store-new-azw3), ' ')
                else
                    'Unknown file type'
            else
                concat('The version of ', $file-name, ' in the store is current.')
        }
        </updated>
        
};

declare function store:stored-version-str($resource-id as xs:string, $file-extension as xs:string) as xs:string {
    
    let $file-collection := concat($common:data-path, '/', $file-extension)
    let $file-name := concat($resource-id, '.', $file-extension)
    
    (: Get document version in data store :)
    let $file-versions-doc := doc(concat($file-collection, '/', $download:file-versions-file-name))
    let $file-version-node := $file-versions-doc/m:file-versions/m:file-version[@file-name eq $file-name]
    
    (: Check the file is there :)
    let $file-exists := util:binary-doc-available(concat($file-collection, '/', $file-name))
    
    return
        if($file-exists and $file-version-node) then
            $file-version-node/@version
        else
            '0'
    
};

declare function store:store-new-pdf($file-path as xs:string, $version as xs:string) as xs:string* {
    
    let $pdf-config := $store:conf/m:pdfs
    
    return
        if($pdf-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.pdf')
            let $source-url := concat($pdf-config/m:html-source-url, '/translation/', $resource-id, '.html')
            let $request-url := concat($pdf-config/m:service-endpoint, '?license=', $pdf-config/m:license-key, '&amp;url=', $source-url)
            
            let $download := store:http-download($request-url, $file-collection, $file-name)
            
            return
                if(name($download) eq 'stored') then
                
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    return
                        concat('New version saved as ', $file-path)
                        
                else if(name($download) eq 'error') then
                    concat('PDF generation failed: ', $download/m:message)
                    
                else
                    'PDF generation failed.'
                
        else
            'PDF generation config not found.'
};

declare function store:store-new-epub($file-path as xs:string, $version as xs:string) as xs:string* {
    
    let $ebook-config := $store:conf/m:ebooks
    
    return
        if($ebook-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $url := concat($ebook-config/m:epub-source-url, '/translation/', $file-name)
            
            let $download := store:http-download($url, $file-collection, $file-name)
            return
                if(name($download) eq 'stored') then
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    return
                        concat('New version saved as ', $file-path)
                        
                else if(name($download) eq 'error') then
                    concat('Epub generation failed: ', $download/m:message)
                    
                else
                    'Epub generation failed.'
         
         else
            'Ebook generation config not found.'
};

declare function store:store-new-azw3($file-path as xs:string, $version as xs:string) as xs:string* {
    
    let $ebook-config := $store:conf/m:ebooks
    
    return
        if($ebook-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.azw3')
    
            (: Sync file to file system :)
            let $sync-path := $ebook-config/m:sync-path/text()
            let $sync :=
                if($sync-path) then
                    file:sync(
                        concat($common:data-path, '/epub'), 
                        concat('/', $sync-path, '/epub'), 
                        ()
                    )
                else
                    ()
            
            (: Run script to generate azw3 :)
            let $options := 
                <options>
                    <workingDir>/{ $sync-path }</workingDir>
                    <environment>
                        <env name="PATH" value="/{ $ebook-config/m:path/text() }"/>
                        <env name="HOME" value="/{ $ebook-config/m:home/text() }"/>
                    </environment>
                </options>
            
            let $generate-azw3 := 
                process:execute((
                    'ebook-convert', 
                    concat('epub/', $resource-id, '.epub'), 
                    concat('azw3/', $resource-id, '.azw3'), 
                    '--no-inline-toc', 
                    '--embed-all-fonts', 
                    '--disable-fix-indents', 
                    '--disable-dehyphenate', 
                    '--disable-remove-fake-margins'
                ), $options)
            
            (: Upload to database :)
            let $store-file := 
                xmldb:store(
                    $file-collection, 
                    concat($resource-id, '.azw3'), 
                    xs:anyURI(concat('file:///', $sync-path, '/azw3/', $resource-id, '.azw3')), 
                    'application/octet-stream'
                )
            
            return
                if($store-file)then
                    
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    
                    return
                        concat('New version saved as ', $file-path)
                        
                 else
                    'Azw3 generation failed'
                
      else
            'Ebook generation config not found.'
};

declare function store:http-download($file-url as xs:string, $collection as xs:string, $file-name as xs:string) as item()* {
    
    let $request := <hc:request href="{$file-url}" method="GET"/>
    let $response := hc:send-request($request)
    let $head := $response[1]
    
    (:let $store-response := xmldb:store($collection, concat($file-name, '.debug.xml'), <response>{ $response }</response>, 'application/xml'):)
    
    return
        (: check to ensure the remote server indicates success :)
        if ($head/@status = '200') then
            (: override the stated media type if the file is known to be .xml :)
            let $media-type := $head/hc:body/@media-type
            let $mime-type := 
                if (ends-with($file-url, '.xml') and $media-type = 'text/plain') then
                    'application/xml'
                else 
                    $media-type
            
            (: if the file is XML and the payload is binary, we need convert the binary to string :)
            let $content-transfer-encoding := $head/hc:body[@name = 'content-transfer-encoding']/@value
            let $body := $response[2]
            let $file := 
                if (ends-with($file-url, '.xml') and $content-transfer-encoding = 'binary') then 
                    util:binary-to-string($body) 
                else 
                    $body
            
            let $store-file := xmldb:store($collection, $file-name, $file, $mime-type)
            
            return
                <stored xmlns="http://read.84000.co/ns/1.0">{ $store-file }</stored>
                
        else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>Oops, something went wrong:</message>
                {$head}
            </error>
};

declare function store:store-version-str($collection as xs:string, $file-name as xs:string, $version as xs:string) as xs:string* {
    
    let $file-versions-file-path := concat($collection, '/', $download:file-versions-file-name)
    let $create-file-versions-file := 
        if(not(doc-available($file-versions-file-path))) then 
            let $create-file := xmldb:store($collection, $download:file-versions-file-name, <file-versions xmlns="http://read.84000.co/ns/1.0"/>)
            let $set-file-group:= sm:chgrp(xs:anyURI($file-versions-file-path), $store:file-group)
            let $set-file-permissions:= sm:chmod(xs:anyURI($file-versions-file-path), $store:file-permissions)
            return
                'store-created'
        else
            'store-exists'
    
    let $file-versions := doc($file-versions-file-path)/m:file-versions
    let $current := $file-versions/m:file-version[@file-name eq $file-name]
    let $new :=
        <file-version xmlns="http://read.84000.co/ns/1.0" 
            timestamp="{current-dateTime()}"
            file-name="{ $file-name }"
            version="{ $version }"/>

    return
        if($current) then
            update replace $current with $new
        else
            update insert $new into $file-versions

};
