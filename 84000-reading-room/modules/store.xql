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
import module namespace deploy="http://read.84000.co/deploy" at "deploy.xql";

declare variable $store:conf := $common:environment//m:store-conf[@type eq 'master'];
declare variable $store:permissions-group := 'operations';
declare variable $store:file-permissions := 'rw-rw-r--';
declare variable $store:folder-permissions := 'rwxrwxr-x';
declare variable $store:binary-types := ('pdf','epub','json','xlsx','txt','dict','html');
declare variable $store:file-versions := doc(string-join(($common:data-path, 'local', 'file-versions.xml'),'/'))/m:file-versions;

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
    let $translation-files := translation:files($tei, 'translation-files', ())
    
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
        let $store-file-name := $text-id ! concat(., '.xml')
        where
            $file-extension = ('cache', 'all') 
            and $store-file-name 
            and $master-cache[@version]
            and not($master-cache/@version = ('none', 'unknown', '')) 
            and (
                not($new-versions-only)
                or not(compare($local-cache/@version, $master-cache/@version) eq 0)
            )
        return (
            store:http-download(
                concat($translations-master-host, $master-cache/@url), 
                $glossary:cached-locations-path,
                $store-file-name,
                'tei'
            ),
            local:store-version-str(
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
                    $store:permissions-group
                )
            
            let $store-version-string := 
                local:store-version-str(
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

declare function store:stored-version-str($file-collection as xs:string, $file-name as xs:string) as xs:string {
    
    (: Get document version in data store :)
    let $log := util:log('INFO', $file-collection)
    let $log := util:log('INFO', $file-name)
    let $file-version := $store:file-versions/m:file-version[@file-name eq $file-name]
    let $file-extension := tokenize($file-name, '\.')[last()]
    
    (: Check the file is there :)
    let $file-exists := 
        if($file-extension = $store:binary-types) then
            util:binary-doc-available(concat($file-collection, '/', $file-name))
        else
            doc-available(concat($file-collection, '/', $file-name))
    
    return
        if($file-exists and $file-version) then
            $file-version/@version
        else
            '0'
    
};

(:declare function store:create($file-name as xs:string) as element() {
    
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := $file-name-tokenized[1]
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (\: Get TEI document version :\)
    let $tei := tei-content:tei($resource-id, 'translation')
    let $tei-version := tei-content:version-str($tei)
    let $text-id := tei-content:id($tei)
    
    (\: Select which file types to process :\)
    let $file-types := ('pdf', 'epub', 'rdf', 'cache', 'json')
    let $file-types := 
        (\: Validate the file extension :\)
        if($file-types[. = $file-extension]) then
            $file-extension
        
        (\: Default to all formats :\)
        else
            $file-types
    
    (\: Loop over Tohs if UT number is passed :\)
    let $toh-keys := 
        if($tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]) then
            (\: It's a valid Toh :\)
            $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]/@key ! string()
        else
            (\: It's not a valid Toh but it got the tei so it must be a valid UT :\)
            $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key ! string()
    
    let $updates := 
        
        (\: loop through one or all file types :\)
        for $file-type in $file-types
        return
            if($file-type eq 'cache') then
            
                (\: Set the cache version number, assuming it's up to date :\)
                let $file-name := concat($text-id, '.cache')
                let $update-version-str := 
                    store:store-version-str(
                        concat($common:data-path, '/cache'), 
                        $file-name, 
                        $tei-version
                    )
                return
                    <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', concat($common:data-path, '/cache/', $file-name)) }</stored>
            
            else if($file-type eq 'json') then
                
                let $file-path := concat($common:data-path, '/json/', $text-id, '.json')
                return (
                    store:store-new-json($file-path, $tei-version),
                    deploy:push('data-json', (), concat('Sync ', $text-id, '.json'), ())
                )
            
            else
                (\: Loop through one or more Toh keys :\)
                for $toh-key in $toh-keys
                return
                    
                    if($file-type eq 'pdf') then
                        (\:'Store new pdf':\)
                        let $file-path := concat($common:data-path, '/pdf/', $toh-key, '.pdf')
                        return
                            store:store-new-pdf($file-path, $tei-version)
                    
                    else if($file-type eq 'epub') then
                        (\:'Store new epub':\)
                        let $epub-file-path := concat($common:data-path, '/epub/', $toh-key, '.epub')
                        return 
                            store:store-new-epub($epub-file-path, $tei-version)
                    
                    else if($file-type eq 'rdf') then
                        (\:'Store new rdf':\)
                        let $file-path := concat($common:data-path, '/rdf/', $toh-key, '.rdf')
                        return (
                            store:store-new-rdf($file-path, $tei-version),
                            deploy:push('data-rdf', (), concat('Sync ', $toh-key, '.rdf'), ())
                        )
                        
                    else
                        <error xmlns="http://read.84000.co/ns/1.0">
                            <message>{ 'Unknown file type' }</message>
                        </error>
                
    return
        <updated xmlns="http://read.84000.co/ns/1.0" update="create-file" resource-id="{ $resource-id }">
        {
            $updates
        }
        </updated>
        
};:)

(:declare function store:store-new-pdf($file-path as xs:string, $tei-version as xs:string) as element() {
    
    let $pdf-config := $store:conf/m:pdfs
    
    return
        if($pdf-config) then
            
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.pdf')
            let $url := concat($pdf-config/m:pdf-source-url/text(), '/translation/', $file-name)
            
            (\: Get document version in data store :\)
            let $store-version := store:stored-version-str($resource-id, 'pdf')
            
            return
                if(compare($store-version, $tei-version) ne 0) then
                    
                    let $log := util:log('info', concat('store-new-pdf:', $file-name))
                    
                    let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
                    
                    return
                        if(name($download) eq 'stored') then
                            let $store-version-number := store:store-version-str($file-collection, $file-name, $tei-version)
                            return
                                <stored xmlns="http://read.84000.co/ns/1.0">{ concat('New version saved as ', $file-path) }</stored>
                         
                         else if(name($download) eq 'error') then
                            <error xmlns="http://read.84000.co/ns/1.0">
                                <message>{ concat('PDF generation failed: ', $download/m:message, ' (', $url, ')') }</message>
                            </error>
                         
                         else
                            <error xmlns="http://read.84000.co/ns/1.0">
                                <message>{ concat('PDF generation failed: (', $file-path, ')') }</message>
                            </error>
                
                else
                    <error xmlns="http://read.84000.co/ns/1.0">
                        <message>{ concat('The version of ', $file-name, ' in the store is up to date') }</message>
                    </error>
                    
        else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ 'PDF generation config not found' }</message>
            </error>
            
};

declare function store:store-new-epub($file-path as xs:string, $tei-version as xs:string) as element() {
    
    let $ebook-config := $store:conf/m:ebooks
    
    return
        if($ebook-config) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.epub')
            let $url := concat($ebook-config/m:epub-source-url/text(), '/translation/', $file-name)
            
            (\: Get document version in data store :\)
            let $store-version := store:stored-version-str($resource-id, 'epub')
            
            return
                if(compare($store-version, $tei-version) ne 0) then
                        
                    let $log := util:log('info', concat('store-new-epub:', $file-name))
                    
                    let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
                    
                    return
                        if(name($download) eq 'stored') then
                            let $store-version-number := store:store-version-str($file-collection, $file-name, $tei-version)
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
                        <message>{ concat('The version of ', $file-name, ' in the store is up to date') }</message>
                    </error>
                    
         else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ 'Epub generation failed: Ebook generation config not found (', $file-path, ')' }</message>
            </error>
};

declare function store:store-new-rdf($file-path as xs:string, $tei-version as xs:string) as element() {
    
    let $rdf-url := $store:conf/m:rdf-url/text()
    
    return
        if($rdf-url) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := lower-case($file-path-tokenized[last()])
            let $resource-id := substring-before($file-name, '.rdf')
            let $url := concat($rdf-url, '/translation/', $file-name)
            
            (\: Get document version in data store :\)
            let $store-version := store:stored-version-str($resource-id, 'rdf')
            
            return
                if(compare($store-version, $tei-version) ne 0) then
                    
                    let $log := util:log('info', concat('store-new-rdf:', $file-name))
                    
                    let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
                    return
                        if(name($download) eq 'stored') then
                            let $store-version-number := store:store-version-str($file-collection, $file-name, $tei-version)
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
                        <message>{ concat('The version of ', $file-name, ' in the store is up to date') }</message>
                    </error>
                 
         else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ concat('RDF generation failed: RDF generation config not found (', $file-path,')') }</message>
            </error>
};

declare function store:store-new-json($file-path as xs:string, $tei-version as xs:string) as element() {
    
    let $json-url := $store:conf/m:json-url/text()
    
    return
        if($json-url) then
        
            let $file-path-tokenized := tokenize($file-path, '/')
            let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
            let $file-name := $file-path-tokenized[last()]
            let $resource-id := substring-before($file-name, '.json')
            let $url := concat($json-url, '/translation/', $file-name, '?annotate=false')
            
            (\: Get document version in data store :\)
            let $store-version := store:stored-version-str($resource-id, 'json')
            
            return
                if(compare($store-version, $tei-version) ne 0) then
                    
                    let $log := util:log('info', concat('store-new-json:', $file-name))
                    
                    let $download := store:http-download($url, $file-collection, $file-name, $store:file-group)
                    
                    return
                        if(name($download) eq 'stored') then
                            let $store-version-number := store:store-version-str($file-collection, $file-name, $tei-version)
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
                        <message>{ concat('The version of ', $file-name, ' in the store is up to date') }</message>
                    </error>
                    
         else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>{ concat('JSON generation failed: JSON generation config not found (', $json-url,')') }</message>
            </error>
         
};
:)

declare function store:http-download($file-url as xs:string, $collection as xs:string, $file-name as xs:string, $permissions-group as xs:string) as item()* {
    
    try {
        
        let $file-suffix := tokenize($file-name, '\.')[last()]
                
        (:let $request := <hc:request href="{ $file-url }" method="GET"/>:)
        let $request := 
            element { QName('http://expath.org/ns/http-client', 'request') }{
                attribute href { $file-url },
                attribute method { 'GET' },
                if($file-suffix eq 'html') then
                    attribute override-media-type { 'application/octet-stream' }
                else ()
            }
        
        let $response := hc:send-request($request)
        let $head := $response[1]
        let $body := $response[2]
        
        let $validate-collection :=
            if(not(xmldb:collection-available($collection))) then
                store:create-missing-collection($collection)
            else true()
        
        where $validate-collection
        return
            (: check to ensure the remote server indicates success :)
            if ($head/@status = '200') then
            
                let $mime-type := 
                    if($file-suffix = ('xml','tei')) then
                        'application/xml'
                    
                    (: Store html as plain text as html5 can't be validated :)
                    else if($file-suffix eq 'html') then
                        'text/plain'
                    
                    else if($file-suffix eq 'json') then
                        'application/json'
                    
                    else if($file-suffix eq 'txt') then
                        'text/plain'
                    
                    else if($file-suffix eq 'pdf') then
                        'application/pdf'
                    
                    else if($file-suffix eq 'rdf') then
                        'application/rdf+xml'
                    
                    else if($file-suffix eq 'epub') then
                        'application/epub+zip'
                    
                    else if($file-suffix eq 'xlsx') then
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                    
                    else if($file-suffix = ('dict', 'zip')) then
                        'application/zip'
                    
                    else
                        $head/hc:body/@media-type
                
                (: if the file is XML and the payload is binary, we need convert the binary to string :)
                let $content-transfer-encoding := $head/hc:body[@name = 'content-transfer-encoding']/@value
                
                let $file := 
                    (: Convert some binary content to string :)
                    if ($content-transfer-encoding eq 'binary' and $file-suffix = ('xml','html')) then 
                        util:binary-to-string($body)
                    
                    (: Add processing instructions to TEI :)
                    else if($file-suffix eq 'tei') then
                        document {
                            <?xml-model href="../../../schema/current/translation.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>,
                            $body
                        }
                    
                    (: Not used as we get html as binary :)
                    (:else if($file-suffix eq 'html') then
                        let $html-serialization-options :=
                            element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{ 
                                element method { attribute value { "html5" } }, 
                                element html-version { attribute value { "5.0" } },
                                element media-type { attribute value { "text/html" } }, 
                                element indent { attribute value { "yes" } } 
                            }
                        return
                            serialize($body, $html-serialization-options):)
                    
                    else 
                        $body
                
                let $target-path := concat($collection, '/', $file-name)
                let $store-file := xmldb:store($collection, $file-name, $file, $mime-type)
                let $set-file-group:= sm:chgrp(xs:anyURI($target-path), $permissions-group)
                let $set-file-permissions:= sm:chmod(xs:anyURI($target-path), $store:file-permissions)
                
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
                
    }
    catch * {
        <error xmlns="http://read.84000.co/ns/1.0">
            <message>Oops, something went wrong!</message>
        </error>
    }
};

declare function store:http-download-to-filesystem($file-url as xs:string, $target-path as xs:string, $file-name as xs:string) as item()* {

    let $file-extension := tokenize($file-name, '\.')[last()]
    
    let $request := 
        element { QName('http://expath.org/ns/http-client', 'request') }{
            attribute href { $file-url },
            attribute method { 'GET' },
            if($file-extension eq 'html') then
                attribute override-media-type { 'application/octet-stream' }
            else ()
        }
    
    let $response := hc:send-request($request)
    let $head := $response[1]
    let $body := $response[2]
    
    let $validate-collection :=
        if(not(file:is-directory($target-path))) then
            file:mkdirs($target-path)
        else true()
    
    where $validate-collection
    return
        (: check to ensure the remote server indicates success :)
        if ($head/@status = '200') then
            
            (: if the file is XML and the payload is binary, we need convert the binary to string :)
            let $content-transfer-encoding := $head/hc:body[@name = 'content-transfer-encoding']/@value
                
            let $content := 
                (: Convert some binary content to string :)
                if ($file-extension = ('xml','html') and $content-transfer-encoding eq 'binary') then 
                    util:binary-to-string($body)
                
                (: Add processing instructions to TEI :)
                else if($file-extension eq 'tei') then
                    document {
                        <?xml-model href="../../../schema/current/translation.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>,
                        $body
                    }
                
                else 
                    $body
            
            let $store-file := 
                if($file-extension = $store:binary-types) then
                    file:serialize-binary($content, concat($target-path, '/', $file-name))
                else
                    file:serialize($content, concat($target-path, '/', $file-name), ('method=xml','indent=yes','media-type=application/xml'))
            
            return
                <stored xmlns="http://read.84000.co/ns/1.0">{ concat($target-path, '/', $file-name) }</stored>
        
        else if ($head/@status = '504') then
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>The request took too long and has timed out.</message>
                { $head }
            </error>
        
        else
            <error xmlns="http://read.84000.co/ns/1.0">
                <message>Oops, something went wrong:</message>
                { $head }
            </error>
   
};

declare function store:create-missing-collection($collection as xs:string) as xs:boolean {
    
    let $collection-dirs := tokenize($collection, '/')
    
    (: Loop through structure making sure collections are present with permissions set :)
    let $verify-dirs :=
        for $nesting in 1 to count($collection-dirs)
        let $dir := $collection-dirs[$nesting]
        let $parent := string-join(subsequence($collection-dirs, 1, ($nesting - 1)), '/')
        where not(xmldb:collection-available(string-join(($parent, $dir), '/')))
        return (
            (:string-join(($parent, $dir), '/'),:)
            xmldb:create-collection($parent, $dir),
            sm:chgrp(xs:anyURI(string-join(($parent, $dir), '/')), $store:permissions-group),
            sm:chmod(xs:anyURI(string-join(($parent, $dir), '/')), $store:folder-permissions),
            util:log('info', concat('Cache folder created: ', string-join(($parent, $dir), '/')))
        )
    return 
        true()
        
};

declare function local:store-version-str($file-name as xs:string, $tei-version as xs:string) as element()? {
    
    let $current := $store:file-versions/m:file-version[@file-name eq $file-name]
    let $new :=
        <file-version xmlns="http://read.84000.co/ns/1.0" 
            timestamp="{ current-dateTime() }"
            file-name="{ $file-name }"
            version="{ $tei-version }"/>
    
    where $store:file-versions
    return
        if($current) then
            update replace $current with $new
        else
            update insert (text { $common:chr-tab }, $new, text { $common:chr-nl }) into $store:file-versions
            
};

(:declare function store:download-file-path($requested-file as xs:string) as xs:string {
    
    (\: Sanitize the file name i.e. toh and extension only :\)
    
    let $file-name := replace(lower-case($requested-file), '_.*\.', '.')
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    return
        if($file-extension = ('rdf','json')) then
            string-join(($common:data-path, $file-extension, $file-name),'/')
        else if($file-extension = ('pdf','epub')) then
            string-join(($common:static-content-path, 'translation', $resource-id, $file-name),'/')
        else ()
        
};:)

declare function store:publication-file($tei as element(tei:TEI), $file-type as xs:string, $file-group as xs:string) {
    
    let $translation-files := translation:files($tei, $file-group, ())//m:file[@type eq $file-type]
    
    for $translation-file in $translation-files
    return
        store:publication-files($tei, $translation:file-groups, $translation-file/@target-file)
    
};

declare function store:publication-files($tei as element(tei:TEI), $store-file-groups as xs:string*, $store-file-name as xs:string?) {
    
    let $text-id := tei-content:id($tei)
    let $tei-version := tei-content:version-str($tei)
    let $tei-timestamp := tei-content:last-modified($tei)
    let $translation-files := translation:files($tei, $store-file-groups, ())
    let $execute-options := 
        <option>
            <workingDir>/{ $common:environment//m:env-vars/m:var[@id eq 'home']/text() }/</workingDir>
        </option>
    let $commit-msg := concat('Publication: ', string-join(($text-id, $tei-version, $tei-timestamp ! format-dateTime(., '[Y0001]-[M01]-[D01] [H01]:[m01]')), ' / '))
    
    where $store:conf[@source-url]
    return
        let $log-request := util:log('info', concat('store-publication-files:', $text-id))
        
        let $store-files :=
            for $file in $translation-files/m:file
            let $source-url := concat($store:conf/@source-url, $file/@source)
            let $target-folder := $file/@target-folder
            where $file[@publish][not(@up-to-date)][@group = $store-file-groups][not($store-file-name) or @target-file eq $store-file-name]
            return (
                
                util:log('info', concat('store-publication-files:', $file/@target-file)),
                
                if($file[not(@action = ('scheduled','manual'))]) then
                    store:http-download($source-url, $target-folder, $file/@target-file, $store:permissions-group)
                else ()
                ,
                
                if($file/@group = ('translation-files')) then
                    local:store-version-str($file/@target-file, $tei-version)
                else ()
                ,
                
                process:execute(('sleep', '0.5'), $execute-options) ! ((: return empty :))
                
            )
        
        let $deploy-files := 
            if($store-files) then (
                deploy:push('data-static', (), $commit-msg, ()),
                (:deploy:push('data-rdf', (), $commit-msg, ()),
                deploy:push('data-json', (), $commit-msg, ()),:)
                process:execute(('sleep', '0.5'), $execute-options) ! ((: return empty :))
            )
            else()
        
        return (
            $store-files,
            $deploy-files
        )
};

declare function store:file($collection as xs:string, $filename as xs:string, $data as item(), $mime-type as xs:string) as element() {
    
    let $validate-collection := store:create-missing-collection($collection)
    let $store-file := xmldb:store($collection, $filename, $data, $mime-type)
    let $store-file-uri := xs:anyURI(concat($collection, '/', $filename))
    let $set-file-group:= sm:chgrp($store-file-uri, $store:permissions-group)
    let $set-file-permissions:= sm:chmod($store-file-uri, $store:file-permissions)
    return
        <stored xmlns="http://read.84000.co/ns/1.0">{ $store-file-uri }</stored>
        
};

declare function store:glossary-downloads() as element()* {
    
    let $glossary-downloads := glossary:downloads()
    
    let $execute-options := 
        <option>
            <workingDir>/{ $common:environment//m:env-vars/m:var[@id eq 'home']/text() }/</workingDir>
        </option>
    
    (: If the glossary xml is older than today the re-load it :)
    let $glossary-download-xml := $glossary-downloads/m:download[@type eq 'xml']
    let $update-xml :=
        if(($glossary-download-xml/@age-in-days[. gt ''], '1')[1] ! xs:integer(.) ge 1) then (
            let $glossary-xml := glossary:glossary-combined()
            return (
                store:file($glossary-download-xml/@collection, $glossary-download-xml/@filename, $glossary-xml, 'application/xml'),
                process:execute(('sleep', '1'), $execute-options) ! ((: return empty :))
            )
        )
        else 
            <up-to-date xmlns="http://read.84000.co/ns/1.0">{ $glossary-download-xml/@filename }</up-to-date>
    
    let $xml-last-modified := 
        if(local-name($update-xml) eq 'stored') then
            current-dateTime()
        else
            $glossary-download-xml/@last-modified[. gt ''] ! xs:dateTime(.)
    
    let $glossary-download-xlsx := $glossary-downloads/m:download[@type eq 'xlsx']
    
    let $update-xlsx := 
        if($glossary-download-xlsx[not(@last-modified[. gt ''])] or $glossary-download-xlsx/@last-modified[. gt ''] ! xs:dateTime(.) lt $xml-last-modified) then (
            let $spreadsheet-data := glossary:spreadsheet-data()
            let $spreadsheet-zip := $spreadsheet-data ! common:spreadsheet-zip(.)
            where $spreadsheet-data
            return (
                store:file($glossary-download-xlsx/@collection, $glossary-download-xlsx/@filename, $spreadsheet-zip, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
                process:execute(('sleep', '1'), $execute-options) ! ((: return empty :))
            )
        )
        else 
            <up-to-date xmlns="http://read.84000.co/ns/1.0">{ $glossary-download-xlsx/@filename }</up-to-date>
    
    let $update-txt :=
        for $key in ('bo', 'wy')
        let $glossary-download-txt := $glossary-downloads/m:download[@type eq 'txt'][@lang-key eq $key]
        return 
            if($glossary-download-txt[not(@last-modified[. gt ''])] or $glossary-download-txt/@last-modified[. gt ''] ! xs:dateTime(.) lt $xml-last-modified) then
                let $glossary-txt := glossary:combined-txt($key)
                let $glossary-txt := string-join($glossary-txt, '')
                return (
                    store:file($glossary-download-txt/@collection, $glossary-download-txt/@filename, $glossary-txt, 'text/plain'),
                    process:execute(('sleep', '1'), $execute-options) ! ((: return empty :))
                )
                
            else 
                <up-to-date xmlns="http://read.84000.co/ns/1.0">{ $glossary-download-txt/@filename }</up-to-date>
    
    let $update-dict :=
        for $key in ('bo', 'wy')
        let $glossary-download-dict := $glossary-downloads/m:download[@type eq 'dict'][@lang-key eq $key]
        return 
            if($glossary-download-dict[not(@last-modified[. gt ''])] or $glossary-download-dict/@last-modified[. gt ''] ! xs:dateTime(.) lt $xml-last-modified) then
                let $glossary-dict := glossary:combined-dict($key)
                return (
                    store:file($glossary-download-dict/@collection, $glossary-download-dict/@filename, $glossary-dict, 'application/zip'),
                    process:execute(('sleep', '1'), $execute-options) ! ((: return empty :))
                )
                
            else 
                <up-to-date xmlns="http://read.84000.co/ns/1.0">{ $glossary-download-dict/@filename }</up-to-date>
    
    return (
        (:element debug { $xml-last-modified },
        $glossary-downloads ! m:download,:)
        $update-xml,
        $update-xlsx,
        $update-txt,
        $update-dict
    )
    
};

(: ~ Deprecated AZW3 generation 
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