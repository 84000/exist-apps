xquery version "3.0";

module namespace download = "http://read.84000.co/download";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "translation.xql";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare variable $download:file-versions-file-name := "file-versions.xml";

declare function download:file-path($requested-file as xs:string) as xs:string* {
    
    (: Sanitize the file name i.e. toh and extension only :)
    let $file-name := replace(lower-case($requested-file), '_.*\.', '.')
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])
    
    (:
    
    In development: generate and cache downloads
    
    let $file-collection := concat($common:data-path, '/', $file-extension)
    let $file-path := concat($file-collection, '/', $file-name)
    
    (: Get document version in data store :)
    let $file-versions-doc := doc(concat($file-collection, '/', $download:file-versions-file-name))
    let $store-version := 
        if($file-versions-doc/m:file-versions/m:file-version[@file-path eq $file-path]) then
            $file-versions-doc/m:file-versions/m:file-version[@file-path eq $file-path]/@version
        else
            '0'
    
    (: Get TEI document version :)
    let $translation := tei-content:tei($resource-id, 'translation')
    let $edition := data($translation//tei:editionStmt/tei:edition[1])
    let $tei-version := replace(normalize-space(replace($edition, '[^a-z0-9\s\.]', ' ')), '\s', '-')
    
    let $store-new-file := 
        if(compare($store-version, $tei-version) ne 0)then
            (: generate and store the latest version :)
            if($file-extension eq 'pdf') then
                download:store-new-pdf($file-path, $tei-version)
            else if($file-extension = ('epub', 'azw3')) then
                download:store-new-ebook($file-path, $tei-version)
            else
                'Unknown file type'
        else
            'The data store version is current'
    :)
    return
        concat($common:data-collection, '/', $file-extension, '/', $file-name)
        
};

declare function download:store-new-pdf($file-path as xs:string, $version as xs:string) as xs:string* {
    let $pdf-service := 'https://pdfmyurl.com/api'
    let $license-key := 'ebSLYb5dKn7W'
    let $file-path-tokenized := tokenize($file-path, '/')
    let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
    let $file-name := lower-case($file-path-tokenized[last()])
    let $resource-id := substring-before($file-name, '.pdf')
    let $url := concat('http://read.84000.co', '/translation/', $resource-id, '.html')
    let $request := concat($pdf-service, '?license=', $license-key, '&amp;url=', $url)
    let $response := httpclient:get($request, false(), <headers/>)
    let $pdf as item() := $response//httpclient:body
    let $store-file := download:store-file($pdf, $file-path, $version)
    return
        'pdf created and stored'
};

declare function download:store-new-ebook($file-path as xs:string, $version as xs:string) as xs:string* {
    let $epub-file-path := $file-path
    let $azw3-file-path := $file-path
    let $epub := 'get new epub' (: get epub :)
    let $store-file := download:store-file($epub, $epub-file-path, $version)
    let $azw3 := 'get new azw3' (: convert epub to azw3 :)
    let $store-file := download:store-file($azw3, $azw3-file-path, $version)
    return
        'ebooks created and stored'
};

declare function download:store-file($file, $file-path as xs:string, $version as xs:string) as xs:string* {
    let $file-path-tokenized := tokenize($file-path, '/')
    let $file-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
    let $file-name := lower-case($file-path-tokenized[last()])
    let $store-file := xmldb:store-as-binary($file-collection, $file-name, $file)
    let $file-group:= sm:chgrp(xs:anyURI($file-path), 'guest')
    let $file-permissions:= sm:chmod(xs:anyURI($file-path), 'rw-rw-rw-')
    let $store-version-number := download:store-version-number($file-path, $version)
    return
        'file stored'
};

declare function download:store-version-number($file-path as xs:string, $version as xs:string) as xs:string* {
    
    let $file-path-tokenized := tokenize($file-path, '/')
    let $store-collection := string-join(subsequence($file-path-tokenized, 1, count($file-path-tokenized) - 1), '/')
    let $store-path := concat($store-collection, '/', $download:file-versions-file-name)
    let $store-created := 
        if(not(doc-available($store-path))) then 
            xmldb:store($store-collection, $download:file-versions-file-name, <file-versions xmlns="http://read.84000.co/ns/1.0"/>)
        else
            ()
    
    let $file-group:= sm:chgrp(xs:anyURI($store-path), 'guest')
    let $file-permissions:= sm:chmod(xs:anyURI($store-path), 'rw-rw-rw-')
    
    let $store := doc($store-path)/m:file-versions
    let $current := $store/m:file-version[@file-path eq $file-path]
    let $new :=
        <file-version xmlns="http://read.84000.co/ns/1.0" 
            timestamp="{current-dateTime()}"
            file-path="{ $file-path }"
            version="{ $version }"/>

    return
        if($current) then
            update replace $current with $new
        else
            update insert $new into $store

};
