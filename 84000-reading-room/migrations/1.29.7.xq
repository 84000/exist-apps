xquery version "3.1" encoding "UTF-8";
import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

declare variable $collection-uri := concat($common:data-path, '/translation-memory');

declare function local:set-mimetypes(){
    for $file in xmldb:get-child-resources($collection-uri)
    where not($file eq 'README.md')
    order by $file
    return
        if(not(xmldb:get-mime-type(xs:anyURI(concat($collection-uri, '/', $file))) eq 'application/xml')) then
        (
            xmldb:store(
                $collection-uri, 
                $file, 
                util:binary-to-string(util:binary-doc(concat($collection-uri, '/', $file))), 
                'application/xml'
            ),
            sm:chgrp(xs:anyURI(concat($collection-uri, '/', $file)), 'translation-memory'),
            sm:chmod(xs:anyURI(concat($collection-uri, '/', $file)), 'rw-rw-r--'),
            concat($file, ' (', xmldb:get-mime-type(xs:anyURI(concat($collection-uri, '/', $file))), ') converted to xml')
        )
        else
            concat('ALREADY XML: ', $file)
};

declare function local:set-text-ids(){

    for $tmx in collection($collection-uri)/tmx:tmx
        let $base-uri := base-uri($tmx)
        let $base-uri-tokenized := tokenize($base-uri, '/')
        let $file-name := $base-uri-tokenized[last()]
        let $file-name-tokenized := tokenize($file-name, '-')
        let $file-name-toh := $file-name-tokenized[1]
        let $resource-id := lower-case(replace($file-name-toh, '_', ''))
        let $tmx-header := $tmx/tmx:header
    order by $resource-id
    return
        if($tmx-header[@eft:text-id]) then
            concat('ALREADY MAPPED: ', $resource-id, ' TO ', $tmx-header/@eft:text-id)
        else
            local:update-header($resource-id, $tmx-header)
};

declare function local:set-text-ids-again(){

    for $tmx in collection(concat($common:data-path, '/translation-memory-generator'))/tmx:tmx[1]
        let $base-uri := base-uri($tmx)
        let $base-uri-tokenized := tokenize($base-uri, '/')
        let $file-name := $base-uri-tokenized[last()]
        let $file-name-tokenized := tokenize($file-name, '\.')
        let $resource-id := $file-name-tokenized[1]
        let $tmx-header := $tmx/tmx:header
    order by $resource-id
    return
        if($tmx-header[@eft:text-id]) then
            concat('ALREADY MAPPED: ', $resource-id, ' TO ', $tmx-header/@eft:text-id)
        else
            local:update-header($resource-id, $tmx-header)
            
};

declare function local:update-header($resource-id as xs:string, $tmx-header as element(tmx:header)){
    
    let $tei := tei-content:tei($resource-id, 'translation')
    let $text-id := tei-content:id($tei)
    
    let $tmx-header-new :=
        element { QName('http://www.lisa.org/tmx14', 'header') } {
            $tmx-header/@*,
            attribute eft:text-id { $text-id },
            $tmx-header/*
        }
    
    return
        if($text-id and $tmx-header) then
        (
            update replace $tmx-header with $tmx-header-new,
            concat('MAPPED: ', $resource-id, ' TO ', $text-id)(::)
        )
        else
            concat('MISSING: ', $resource-id)
};

local:set-mimetypes()(:,
local:set-text-ids():)(:,
local:set-text-ids-again():)


