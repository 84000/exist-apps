xquery version "3.0";

module namespace download = "http://read.84000.co/download";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "common.xql";

declare variable $download:file-versions-file-name := "file-versions.xml";
declare variable $download:file-versions-azw3 := doc(concat($common:data-path, '/azw3/', $download:file-versions-file-name));
declare variable $download:file-versions-cache := doc(concat($common:data-path, '/cache/', $download:file-versions-file-name));
declare variable $download:file-versions-epub := doc(concat($common:data-path, '/epub/', $download:file-versions-file-name));
declare variable $download:file-versions-pdf := doc(concat($common:data-path, '/pdf/', $download:file-versions-file-name));
declare variable $download:file-versions-rdf := doc(concat($common:data-path, '/rdf/', $download:file-versions-file-name));

declare function download:file-path($requested-file as xs:string) as xs:string {
    
    (: Sanitize the file name i.e. toh and extension only :)
    let $file-name := replace(lower-case($requested-file), '_.*\.', '.')
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])

    return
        concat($common:data-collection, '/', $file-extension, '/', $file-name)
};

declare function download:stored-version-str($resource-id as xs:string, $file-type as xs:string) as xs:string {
    
    (: Get document version in data store :)
    let $file-versions-doc :=
        if($file-type eq 'azw3') then
            $download:file-versions-azw3
        else if($file-type eq 'cache') then
            $download:file-versions-cache
        else if($file-type eq 'epub') then
            $download:file-versions-epub
        else if($file-type eq 'pdf') then
            $download:file-versions-pdf
        else if($file-type eq 'rdf') then
            $download:file-versions-rdf
        else
            doc(concat($common:data-path, '/', $file-type, '/', $download:file-versions-file-name))
    
    let $file-name := concat($resource-id, '.', $file-type)
    let $file-version-node := $file-versions-doc/m:file-versions/m:file-version[@file-name eq $file-name (:range:field(("file-version-file-name"), "eq", $file-name):)]
    
    (: Check the file is there :)
    let $file-uri := concat($common:data-path, '/', $file-type, '/', $file-name)
    let $file-exists := 
        if($file-type = ('xml', 'rdf', 'html', 'cache')) then
            doc-available($file-uri)
        else
            util:binary-doc-available($file-uri)
    
    return
        if($file-exists and $file-version-node) then
            $file-version-node/@version
        else if($file-exists) then
            'unknown'
        else
            'none'
    
};
