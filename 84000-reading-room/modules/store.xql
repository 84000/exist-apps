xquery version "3.0";

module namespace store = "http://read.84000.co/store";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace file="http://exist-db.org/xquery/file";

import module namespace common = "http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "translation.xql";
import module namespace download = "http://read.84000.co/download" at "download.xql";

import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare variable $store:conf := $common:environment//m:store-conf[@type eq 'master'];
declare variable $store:file-group := 'utilities';
declare variable $store:file-permissions := 'rw-rw-r--';

declare function store:download-master($file-name as xs:string, $translations-master-host as xs:string) as element()? {
    
    (: extract elements from the file name :)
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (: look-up this existing document with this id :)
    let $current-doc := tei-content:tei($resource-id, 'translation')
    
    let $download := 
        if($file-extension = ('tei')) then
            
            (: get the file name and location :)
            let $current-doc-path := tei-content:document-url($current-doc)
            let $current-doc-path-tokenized := tokenize($current-doc-path, '/')
            let $current-doc-file-name := $current-doc-path-tokenized[last()]
            let $current-doc-folder := string-join(subsequence($current-doc-path-tokenized, 1, last()-1), '/')
            return
                if($current-doc-file-name and $current-doc-folder)then
                    store:http-download(concat($translations-master-host, '/translation/', $file-name), $current-doc-folder, $current-doc-file-name)
                else
                    ()
                
        else if($file-extension = ('pdf', 'epub', 'azw3', 'rdf')) then
            
            (:  
                Download the latest file from the master and set the version
                NOTE: this assumes the local TEI is up to date as it uses that to set the version of the file. 
                Otherwise we would have to know the version of the file on master which is a bit long winded.
            :)
            let $file-version := translation:version-str($current-doc)
            let $file-collection := concat($common:data-path, '/', $file-extension)
            let $download-file := store:http-download(concat($translations-master-host, '/data/', $file-name), $file-collection, $file-name)
            let $store-version-string := store:store-version-str($file-collection, $file-name, $file-version)
            return
                $download-file
                
        else
            ()
    
    return
       if($download)then
           <updated xmlns="http://read.84000.co/ns/1.0" update="store-file" resource-id="{ $resource-id }">
           {
               $download
           }
           </updated>
       else
           ()
};

declare function store:create($file-name as xs:string) as element() {
    
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (: Get document version in data store :)
    let $store-version := download:stored-version-str($resource-id, $file-extension)
    
    (: Get TEI document version :)
    let $tei := tei-content:tei($resource-id, 'translation')
    let $tei-version := translation:version-str($tei)
    
    return
        <updated xmlns="http://read.84000.co/ns/1.0" update="create-file" resource-id="{ $resource-id }">
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
                else if($file-extension eq 'rdf') then
                    (:'Store new rdf':)
                    let $file-path := concat($common:data-path, '/', $file-extension, '/', $resource-id, '.rdf')
                    return
                        store:store-new-rdf($file-path, $tei-version)
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

declare function store:store-new-pdf($file-path as xs:string, $version as xs:string) as xs:string {
    
    let $pdf-config := $store:conf/m:pdfs
    
    return
        if($pdf-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.pdf')
            let $source-url := concat($pdf-config/m:html-source-url, '/translation/', $resource-id, '.html')
            let $request-url := concat($pdf-config/m:service-endpoint, '?license=', $pdf-config/m:license-key, '&amp;url=', $source-url)
            
            let $download := store:http-get-and-store($request-url, $file-collection, $file-name)
            
            (: let $download := store:http-download($request-url, $file-collection, $file-name):)
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

declare function store:store-new-epub($file-path as xs:string, $version as xs:string) as xs:string {
    
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

declare function store:store-new-azw3($file-path as xs:string, $version as xs:string) as xs:string {
    
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
                    '--disable-remove-fake-margins',
                    '--chapter', '/'
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

declare function store:store-new-rdf($file-path as xs:string, $version as xs:string) as xs:string {
    
    let $rdf-url := $store:conf/m:rdf-url/text()
    
    return
        if($rdf-url) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $url := concat($rdf-url, '/translation/', $file-name)
            
            let $download := store:http-download($url, $file-collection, $file-name)
            return
                if(name($download) eq 'stored') then
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    return
                        concat('New version saved as ', $file-path)
                        
                else if(name($download) eq 'error') then
                    concat('RDF generation failed: ', $download/m:message)
                    
                else
                    'RDF generation failed.'
         
         else
            'RDF generation config not found.'
};

declare function store:http-download($file-url as xs:string, $collection as xs:string, $file-name as xs:string) as item()* {

    let $request := <hc:request href="{$file-url}" method="GET"/>
    let $response := hc:send-request($request)
    let $head := $response[1]
    let $body := $response[2]
    
    (:let $store-response := xmldb:store($collection, concat($file-name, '.debug.xml'), <response>{ $response }</response>, 'application/xml'):)
    
    return
        (: check to ensure the remote server indicates success :)
        if ($head/@status = '200') then
            (: override the stated media type if the file is known to be .xml :)
            let $media-type := $head/hc:body/@media-type
            let $mime-type := 
                if (contains(lower-case($file-url), '.xml') and $media-type = 'text/plain') then
                    'application/xml'
                else 
                    $media-type
            
            (: if the file is XML and the payload is binary, we need convert the binary to string :)
            let $content-transfer-encoding := $head/hc:body[@name = 'content-transfer-encoding']/@value
            
            let $file := 
                if (contains(lower-case($file-url), '.xml') and $content-transfer-encoding = 'binary') then 
                    util:binary-to-string($body) 
                else if(contains(lower-case($file-url), '.tei')) then
                    document {
                        <?xml-model href="../../../schema/current/translation.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>,
                        $body
                    }
                else 
                    $body
            
            let $store-file := xmldb:store($collection, $file-name, $file, $mime-type)
            
            return
                <stored xmlns="http://read.84000.co/ns/1.0">{ $store-file }</stored>
        
        else if ($head/@status = '504') then
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>The request took too long and has timed out.</message>
                {$head}
            </error>
        
        else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>Oops, something went wrong:</message>
                {$head}
            </error>
};

declare function store:http-get-and-store($file-url as xs:string, $collection as xs:string, $file-name as xs:string)  as item()* {

    let $response := httpclient:get(xs:anyURI($file-url), false(),())
    
    let $headers := $response//httpclient:headers/httpclient:header
    let $body := $response//httpclient:body
    
    return
        (: check to ensure the remote server indicates success :)
        if ($response/@statusCode = '200' and $body) then
        
            let $mime-type := 
                if (contains(lower-case($file-url), '.xml') and $body/@mimetype = 'text/plain') then
                    'application/xml'
                else 
                    $body/@mimetype
            
            (: if the file is XML and the payload is binary, we need convert the binary to string :)
            let $content-transfer-encoding := $headers[lower-case(@name) = 'content-transfer-encoding']/@value
            
            let $file := 
                if (contains(lower-case($file-url), '.xml') and lower-case($content-transfer-encoding) = 'binary') then 
                    util:binary-to-string($body)
                else 
                    xs:base64Binary($body/text())
            
            let $store-file := xmldb:store($collection, $file-name, $file, $mime-type)
            
            return
                <stored xmlns="http://read.84000.co/ns/1.0">
                    { $store-file }
                </stored>
        
        else if ($response/@statusCode = '504') then
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>The request took too long and has timed out.</message>
                { $headers }
            </error>
        
        else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>Oops, something went wrong:</message>
                { $headers }
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
        common:update('version-str', $current, $new, $file-versions, ())
};
