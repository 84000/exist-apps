xquery version "3.0";

module namespace store = "http://read.84000.co/store";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace file="http://exist-db.org/xquery/file";

import module namespace common = "http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "glossary.xql";
import module namespace translations = "http://read.84000.co/translations" at "translations.xql";
import module namespace download = "http://read.84000.co/download" at "download.xql";
import module namespace deploy="http://read.84000.co/deploy" at "deploy.xql";

declare variable $store:conf := $common:environment//m:store-conf[@type eq 'master'];
declare variable $store:file-group := 'utilities';
declare variable $store:file-permissions := 'rw-rw-r--';

declare function store:master-downloads-data($translations-master-request as xs:anyURI) as element()? {
    
    let $request := <hc:request href="{ $translations-master-request }" method="GET"/>
    let $response := hc:send-request($request)
    where $response[2]/m:response//m:text
    return
        element {  QName('http://read.84000.co/ns/1.0', 'translations-master') } {
            (: attribute url { $translations-master-request }, :)
            $response[2]/m:response//m:text
        }

};

declare function store:download-master($file-name as xs:string, $translations-master-host as xs:string, $new-versions-only as xs:boolean) as element()? {
    
    (: Extract elements from the file name :)
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := $file-name-tokenized[1]
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (: look-up this existing document with this id :)
    let $tei := tei-content:tei($resource-id, 'translation')
    let $text-id := tei-content:id($tei)
    
    (: Get Tohs if UT number is passed :)
    let $toh-keys := 
        if($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]) then
            (: It's a valid Toh key :)
            lower-case($resource-id)
        else
            (: It's not a valid Toh but it got the tei so it must be a valid UT :)
            $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key ! string()
    
    (: Get local file versions :)
    let $local-downloads-data := translations:downloads($toh-keys)
    let $local-text := $local-downloads-data/m:text[@id eq $text-id][1]
    let $tei-local-version := $local-text/m:downloads[1]/@tei-version
    let $tei-local-status := $local-text/@publication-status
    
    (: Get master file versions :)
    let $master-downloads-data := store:master-downloads-data(xs:anyURI(concat($translations-master-host, '/downloads.xml?resource-ids=', string-join($toh-keys, ','))))
    let $master-text := $master-downloads-data//m:text[@id eq $text-id][1]
    let $tei-master-version := $master-text/m:downloads[1]/@tei-version
    let $tei-master-status := ($master-text/@translation-status, $master-text/@publication-status)[1]
    
    (: Download the tei from master if the versions differ :)
    let $download-tei :=
        let $local-text-path := $local-text/@document-url
        let $local-text-path-tokenized := tokenize($local-text-path, '/')
        let $tei-file-name := $local-text-path-tokenized[last()]
        let $tei-folder := string-join(subsequence($local-text-path-tokenized, 1, last()-1), '/')
        where 
            $file-extension = ('tei', 'all') 
            and $local-text 
            and $master-text 
            and $tei-file-name 
            and $tei-folder
            and (
                not($new-versions-only)
                or not(compare($tei-local-version, $tei-master-version) eq 0)
                or not(compare($tei-local-status, $tei-master-status) eq 0)
            )
        return
            store:http-download(
                concat($translations-master-host, '/translation/', $text-id, '.tei'), 
                $tei-folder, 
                $tei-file-name,
                'tei'
            )
    
    (: Download the cache :)
    let $download-cache :=
        let $master-cache := $master-text/m:downloads[1]/m:download[@type eq 'cache']
        let $local-cache := $local-text/m:downloads[1]/m:download[@type eq 'cache']
        let $store-collection := concat($common:data-path, '/', 'cache')
        let $store-file-name := tokenize($local-cache/@url, '/')[last()]
        where
            $file-extension = ('cache', 'all') 
            and $store-file-name and $store-collection
            and $master-cache[@version]
            and not($master-cache/@version = ('none', 'unknown', '')) 
            and (
                not($new-versions-only)
                or not(compare($local-cache/@version, $master-cache/@version) eq 0)
            )
        return (
            store:http-download(
                concat($translations-master-host, $master-cache/@url), 
                $store-collection,
                $store-file-name,
                'tei'
            ),
            store:store-version-str(
                $store-collection, 
                $store-file-name,
                $master-cache/@version
            ),
            util:log('info', concat('store-download-master:', $store-file-name))
        )
    
    (: Download other files :)
    let $downloadable-extensions := ('pdf', 'epub', 'rdf'(:, 'json':))
    let $download-files := 
    
        (: loop through one or all file types in the master data :)
        for $master-file in 
            if($file-extension eq 'all') then
                $master-text/m:downloads/m:download[@type = $downloadable-extensions]
            else if ($file-extension = $downloadable-extensions) then 
                $master-text/m:downloads/m:download[@type eq $file-extension]
            else ()
            
            let $master-file-resource-id := $master-file/parent::m:downloads/@resource-id
            let $file-type := $master-file/@type
            let $local-file := $local-text/m:downloads[@resource-id eq $master-file-resource-id]/m:download[@type eq $file-type]
            let $store-collection := concat($common:data-path, '/', $local-file/@type)
            let $store-file-name := tokenize($local-file/@url, '/')[last()]
            
        where 
            $store-file-name 
            and $store-collection
            and $master-file[@version]
            and not($master-file/@version = ('none', 'unknown', '')) 
            and (
                not($new-versions-only)
                or not(compare($master-file/@version, $local-file/@version) eq 0)
            )
        return 
        
            (: Download the latest file from the master and set the version :) 
            let $download-file := 
                store:http-download(
                    concat($translations-master-host, $master-file/@url), 
                    $store-collection, 
                    $store-file-name,
                    $store:file-group
                )
            
            let $store-version-string := 
                store:store-version-str(
                    $store-collection, 
                    $store-file-name, 
                    $master-file/@version
                )
            
            return (
                $download-file,
                util:log('info', concat('store-download-master:', $store-file-name))
            )
    
    where ($download-tei, $download-files)
    return
       <updated xmlns="http://read.84000.co/ns/1.0" update="store-file" resource-id="{ $resource-id }">
       {
           ($download-tei, $download-files)
       }
       </updated>
};

declare function store:create($file-name as xs:string) as element() {
    
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := $file-name-tokenized[1]
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (: Get TEI document version :)
    let $tei := tei-content:tei($resource-id, 'translation')
    let $tei-version := tei-content:version-str($tei)
    
    (: Select which file types to process :)
    let $file-types := ('pdf', 'epub', 'rdf', 'cache', 'json')
    let $file-types := 
        (: Validate the file extension :)
        if($file-types[. = $file-extension]) then
            $file-extension
        
        (: Default to all formats :)
        else
            $file-types
    
    (: Loop over Tohs if UT number is passed :)
    let $toh-keys := 
        if($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]) then
            (: It's a valid Toh :)
            $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]/@key ! string()
        else
            (: It's not a valid Toh but it got the tei so it must be a valid UT :)
            $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key ! string()
    
    let $updates := 
        
        (: loop through one or all file types :)
        for $file-type in $file-types
        return
            if($file-type eq 'cache') then
            
                (: Set the cache version number, assuming it's up to date as it's maintained by the trigger :)
                let $file-name := concat(tei-content:id($tei), '.cache')
                let $update-version-str := 
                    store:store-version-str(
                        concat($common:data-path, '/cache'), 
                        $file-name, 
                        $tei-version
                    )
                return
                    <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', concat($common:data-path, '/cache/', $file-name)) }</stored>
            
            else
                (: Loop through one or more Toh keys :)
                for $toh-key in $toh-keys
                
                (: Get document version in data store :)
                let $store-version := download:stored-version-str($toh-key, $file-type)
                
                return
                    if(compare($store-version, $tei-version) ne 0)then
                        
                        if($file-type eq 'pdf') then
                            (:'Store new pdf':)
                            let $file-path := concat($common:data-path, '/pdf/', $toh-key, '.pdf')
                            return
                                store:store-new-pdf($file-path, $tei-version)
                        
                        else if($file-type eq 'epub') then
                            (:'Store new epub':)
                            let $epub-file-path := concat($common:data-path, '/epub/', $toh-key, '.epub')
                            return 
                                store:store-new-epub($epub-file-path, $tei-version)
                        
                        else if($file-type eq 'rdf') then
                            (:'Store new rdf':)
                            let $file-path := concat($common:data-path, '/rdf/', $toh-key, '.rdf')
                            return (
                                store:store-new-rdf($file-path, $tei-version),
                                deploy:push('data-rdf', (), concat('Sync ', $toh-key, '.rdf'), ())
                            )
                        
                        else if($file-type eq 'json') then
                            (:'Store new rdf':)
                            let $file-path := concat($common:data-path, '/json/', $toh-key, '.json')
                            return (
                                store:store-new-json($file-path, $tei-version),
                                deploy:push('data-json', (), concat('Sync ', $toh-key, '.json'), ())
                            )
                            
                        else
                            <error xmlns="http://read.84000.co/ns/1.0">
                                <message>{ 'Unknown file type' }</message>
                            </error>
                    
                    else
                        <error xmlns="http://read.84000.co/ns/1.0">
                            <message>{ concat('The version of ', $toh-key,'.', $file-type, ' in the store is up to date') }</message>
                        </error>
    
    return
        <updated xmlns="http://read.84000.co/ns/1.0" update="create-file" resource-id="{ $resource-id }">
        {
            $updates
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
    let $file-exists := 
        if($file-extension = ('pdf', 'epub')) then
            util:binary-doc-available(concat($file-collection, '/', $file-name))
        else
            doc-available(concat($file-collection, '/', $file-name))
    
    return
        if($file-exists and $file-version-node) then
            $file-version-node/@version
        else
            '0'
    
};

declare function store:store-new-pdf($file-path as xs:string, $version as xs:string) as element() {
    
    let $pdf-config := $store:conf/m:pdfs
    
    return
        if($pdf-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.pdf')
            
            let $log := util:log('info', concat('store-new-pdf:', $file-name))
            
            let $options := 
                <options>
                    <workingDir>/{ $pdf-config/m:sync-path/text() }</workingDir>
                    <environment>
                        <env name="PATH" value="/{ $pdf-config/m:path/text() }"/>
                        <env name="HOME" value="/{ $pdf-config/m:home/text() }"/>
                    </environment>
                </options>
                
                (: Use node/puppeteer to generate PDF :)
                let $generate-pdf := process:execute(('node', 'generatePDF.js', $resource-id), $options)
               
                (: Upload to database :)
                let $store-file := 
                    xmldb:store(
                        $file-collection, 
                        concat($resource-id, '.pdf'), 
                        xs:anyURI(concat('file:///', $pdf-config/m:sync-path, '/', $resource-id, '.pdf')), 
                        'application/pdf'
                    )
                
                return
                    if($store-file)then
                        
                        let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                        let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                        let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                        
                        return
                            <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', $file-path) }</stored>
                            
                     else
                        <error xmlns="http://read.84000.co/ns/1.0">
                            <message>{ concat('PDF generation failed: (', $file-path, ')') }</message>
                        </error>
                    
        else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ 'PDF generation config not found' }</message>
            </error>
            
};

declare function store:store-new-epub($file-path as xs:string, $version as xs:string) as element() {
    
    let $ebook-config := $store:conf/m:ebooks
    
    return
        if($ebook-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $url := concat($ebook-config/m:epub-source-url, '/translation/', $file-name)
            
            let $log := util:log('info', concat('store-new-epub:', $file-name))
            
            let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
            
            return
                if(name($download) eq 'stored') then
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    return
                        <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', $file-path) }</stored>
                        
                else if(name($download) eq 'error') then
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('Epub generation failed: ', $download/m:message, ' (', $file-path, ')') }</message>
                    </error>
                    
                else
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('Epub generation failed (', $url, ')') }</message>
                    </error>
         
         else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ 'Epub generation failed: Ebook generation config not found (', $file-path, ')' }</message>
            </error>
};

(:
declare function store:store-new-azw3($file-path as xs:string, $version as xs:string) as element() {
    
    let $ebook-config := $store:conf/m:ebooks
    
    return
        if($ebook-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.azw3')
            
            let $log := util:log('info', concat('store-new-azw3:', $file-name))
    
            (\: Sync file to file system :\)
            let $sync-path := $ebook-config/m:sync-path/text()
            let $sync :=
                if($sync-path) then
                    file:sync(
                        concat($common:data-path, '/epub'), 
                        concat('/', $sync-path, '/epub'), 
                        ()
                    )
                else ()
            
            (\: Run script to generate azw3 :\)
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
            
            (\: Upload to database :\)
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
                        <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', $file-path) }</stored>
                        
                 else
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('Azw3 generation failed: (', $file-path, ')') }</message>
                    </error>
                
      else
        <error xmlns="http://read.84000.co/ns/1.0">
            <message>{ concat('Azw3 generation failed: Ebook generation config not found (', $file-path, ')') }</message>
        </error>
};:)

declare function store:store-new-rdf($file-path as xs:string, $version as xs:string) as element() {
    
    let $rdf-url := $store:conf/m:rdf-url/text()
    
    return
        if($rdf-url) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $url := concat($rdf-url, '/translation/', $file-name)
            
            let $log := util:log('info', concat('store-new-rdf:', $file-name))
            
            let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
            return
                if(name($download) eq 'stored') then
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    return
                        <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', $file-path) }</stored>
                        
                else if(name($download) eq 'error') then
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('RDF generation failed: ', $download/m:message, '(', $url,')') }</message>
                    </error>
                    
                    
                else
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('RDF generation failed: (', $file-path,')') }</message>
                    </error>
         
         else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ concat('RDF generation failed: RDF generation config not found (', $file-path,')') }</message>
            </error>
};

declare function store:store-new-json($file-path as xs:string, $version as xs:string) as element() {
    
    let $json-url := $store:conf/m:json-url/text()
    
    return
        if($json-url) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $url := concat($json-url, '/translation/', $file-name)
            
            let $log := util:log('info', concat('store-new-json:', $file-name))
            
            let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
            return
                if(name($download) eq 'stored') then
                    let $set-file-group:= sm:chgrp(xs:anyURI($file-path), $store:file-group)
                    let $set-file-permissions:= sm:chmod(xs:anyURI($file-path), $store:file-permissions)
                    let $store-version-number := store:store-version-str($file-collection, $file-name, $version)
                    return
                        <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', $file-path) }</stored>
                        
                else if(name($download) eq 'error') then
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('JSON generation failed: ', $download/m:message, '(', $url,')') }</message>
                    </error>
                    
                else
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('JSON generation failed: (', $file-path,')') }</message>
                    </error>
         
         else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ concat('JSON generation failed: JSON generation config not found (', $file-path,')') }</message>
            </error>
};

declare function store:http-download($file-url as xs:string, $collection as xs:string, $file-name as xs:string, $auth-group as xs:string) as item()* {

    let $request := <hc:request href="{ $file-url }" method="GET"/>
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
                if ($content-transfer-encoding = 'binary' and contains(lower-case($file-url), '.xml')) then 
                    util:binary-to-string($body) 
                else if(contains(lower-case($file-url), '.tei')) then
                    document {
                        <?xml-model href="../../../schema/current/translation.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>,
                        $body
                    }
                else 
                    $body
            
            let $store-file := xmldb:store($collection, $file-name, $file, $mime-type)
            let $store-file-uri := xs:anyURI(concat($collection, '/', $file-name))
            let $set-file-group:= sm:chgrp($store-file-uri, $auth-group)
            let $set-file-permissions:= sm:chmod($store-file-uri, $store:file-permissions)
            
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

declare function store:store-version-str($collection as xs:string, $file-name as xs:string, $version as xs:string) as element()? {
    
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
