xquery version "3.0";

module namespace download = "http://read.84000.co/download";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "translation.xql";
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare variable $download:file-versions-file-name := "file-versions.xml";

declare function download:file-path($requested-file as xs:string) (: as xs:string* :) {
    
    (: Sanitize the file name i.e. toh and extension only :)
    let $file-name := replace(lower-case($requested-file), '_.*\.', '.')
    let $file-name-tokenized := tokenize($file-name, '\.')
    let $resource-id := lower-case($file-name-tokenized[1])
    let $file-extension := lower-case($file-name-tokenized[last()])

    return
        concat($common:data-collection, '/', $file-extension, '/', $file-name)
};

declare function download:stored-version-str($resource-id as xs:string, $file-extension as xs:string) as xs:string {
    
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
        else if($file-exists) then
            'unknown'
        else
            'none'
    
};
