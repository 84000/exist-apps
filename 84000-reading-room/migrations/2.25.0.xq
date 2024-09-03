xquery version "3.1" encoding "UTF-8";

(: ~ Version 2.25.0 - Static site generator

    - Create 84000-static
    - Move existing static files to new structure
    - Refactor glossary cached locations
    - Merge version files into /db/apps/84000-data/local
    - Seed 84000-static with all current published files
    
:)

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace store="http://read.84000.co/store" at "../modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../modules/deploy.xql";
import module namespace trigger="http://exist-db.org/xquery/trigger" at "../triggers.xql";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

declare function local:create-file-structure() {

    for $path in (
        'translation', 'source', 'catalogue', 
        'glossary/combined', 'glossary/named-entities', 'glossary/cached-locations', 
        'rdf/translation', 'json/translation', 
        'frontend/css/2.25.0', 'frontend/js/2.25.0', 'frontend/favicon', 'frontend/fonts', 'frontend/imgs', 
        'images', 'audio'
    )
    return
        store:create-missing-collection(string-join(($common:static-content-path, $path), '/'))

};

declare function local:move-static-files() {
    
    for $type in ('epub','pdf','rdf','json')
    let $source-path := string-join(($common:data-path, $type), '/')
    return
    
        for $resource in xmldb:get-child-resources($source-path)
        where (: File conforms to expected pattern to filter out unwanted files :)
            (:tokenize($resource, '\.')[1] = ('toh1-1','UT22084-001-001') and:)
            (
                ($type = ('epub','pdf','rdf') and matches($resource, concat('^toh.+\.', $type, '$')))
                or ($type = ('json') and matches($resource, concat('^UT.+\.', $type, '$')))
            )
        return
        
            let $target-path := 
                if($type = ('epub','pdf')) then
                    string-join(($common:static-content-path, 'translation', tokenize($resource, '\.')[1]), '/')
                else
                    string-join(($common:static-content-path, $type, 'translation'), '/')
            
            let $target-path-validated := store:create-missing-collection($target-path)
            
            where ((: Not already copied :)
                ($type = ('epub','pdf','json') and not(util:binary-doc-available($target-path || '/' || $resource)))
                or ($type = ('rdf') and not(doc-available($target-path || '/' || $resource)))
            )
            
            return (
                xmldb:move($source-path, $target-path, $resource),
                sm:chown(xs:anyURI($target-path || '/' || $resource), 'admin'),
                sm:chgrp(xs:anyURI($target-path || '/' || $resource), $store:permissions-group),
                sm:chmod(xs:anyURI($target-path || '/' || $resource), $store:file-permissions),
                'moved ' || $resource
            )
    
};

declare function local:move-glossary-cached-locations() {
    
    let $target-path-validated := store:create-missing-collection($glossary:cached-locations-path)
    let $source-path := string-join(($common:data-path, 'cache'), '/')
    
    for $resource in xmldb:get-child-resources($source-path)[matches(., '\.cache$')](:[. = ('UT22084-001-001.cache','UT22084-066-009.cache','UT22084-060-001.cache')]:)
    let $target-filename := tokenize($resource, '\.')[1] ! concat(., '.xml')
    
    where not(doc-available($target-path || '/' || $target-filename))
    return
        
        let $glossary-cache := doc(string-join(($source-path, $resource), '/'))/eft:cache/eft:glossary-cache
        where $glossary-cache[eft:gloss]
        return
            let $glossary-pointers := <glossary-cached-locations xmlns="http://read.84000.co/ns/1.0">{ ($glossary-cache/@*, $glossary-cache/eft:gloss ! (common:ws(1), .), common:ws(0) ) }</glossary-cached-locations>
            return (
                xmldb:store($target-path, $target-filename, $glossary-pointers, 'application/xml'),
                (:xmldb:touch($target-path, $target-filename, xmldb:last-modified($source-path, $resource)),:)
                sm:chgrp(xs:anyURI($target-path || '/' || $target-filename), 'operations'),
                sm:chmod(xs:anyURI($target-path || '/' || $target-filename), 'rw-rw-r--'),
                'moved ' || $resource
            )
    
    ,
    
    'Delete old cache files'
    
};

declare function local:merge-version-files() {

    let $copy-pdf-file := xmldb:copy-resource('/db/apps/84000-data/pdf', 'file-versions.xml', '/db/apps/84000-data/local', 'file-versions.xml', true())
    
    let $new-file := doc('/db/apps/84000-data/local/file-versions.xml')
    
    let $other-versions-data := (
        doc('/db/apps/84000-data/cache/file-versions.xml')//eft:file-version,
        doc('/db/apps/84000-data/epub/file-versions.xml')//eft:file-version,
        doc('/db/apps/84000-data/json/file-versions.xml')//eft:file-version,
        doc('/db/apps/84000-data/rdf/file-versions.xml')//eft:file-version
    )
    
    return (
        $copy-pdf-file,
        update insert $other-versions-data into $new-file/eft:file-versions,
        'Rename *.cache as *.xml in file-versions.xml'
    )
    
};

declare function local:trigger-published-tei() {

    for $tei in $tei-content:translations-collection//tei:TEI
    (:where tei-content:id($tei) = ('UT22084-001-001'):)
    return
        trigger:after-update-document(base-uri($tei))
    
};

declare function local:store-publication-files() {
    
    let $translations-tei := $tei-content:translations-collection//tei:TEI
    (:let $translations-tei := subsequence($translations-tei, 1, 50):)
    
    for $tei in $translations-tei
    (:where tei-content:id($tei) = ('UT22084-066-009', 'UT23703-113-010', 'UT22084-029-001'):)
    return
        store:publication-files($tei, ('translation-html'(:,'translation-files','source-html',:)(:'glossary-html','glossary-files','publications-list':)), ())
    
};

declare function local:store-entity-pages() {
    
    let $entities := $entities:entities/eft:entity
    (:let $entities := subsequence($entities, 1,2):)
    
    let $glossaries := $tei-content:translations-collection//tei:back/tei:div[@type eq 'glossary'][not(@status = 'excluded')]
    
    let $exec-options := 
        <option>
            <workingDir>/{ $common:environment//eft:env-vars/eft:var[@id eq 'home']/text() }/</workingDir>
        </option>
    
    for $entity at $index in $entities
    let $glossary-entries := $glossaries//id($entity/eft:instance[not(eft:flag)]/@id)[not(@mode eq 'surfeit')]
    let $source-html := concat($store:conf/@source-url, '/glossary/', $entity/@xml:id, '.html')
    let $target-folder := concat($common:static-content-path, '/glossary/named-entities/')
    let $target-file := concat($entity/@xml:id,'.html')
    where $glossary-entries and not(util:binary-doc-available(concat($target-folder, '/', $target-file)))
    return (
        (:$source-html,:)
        store:http-download($source-html, $target-folder, $target-file, $store:permissions-group),
        process:execute(('sleep', '0.5'), $exec-options) ! ()
    ),
    
    deploy:push('data-static', (), 'store-glossary-named-entity-pages', ())
    
};

(: Don't run if config incorrect :)
if(not(doc('/db/apps/84000-reading-room/xslt/webpage.xsl')//xsl:variable[@name eq "local-front-end-url"][@select eq "'/frontend'"])) then (
    doc('/db/apps/84000-reading-room/xslt/webpage.xsl')//xsl:variable[@name eq "local-front-end-url"],
    'Set xsl:variable[@name eq "local-front-end-url"]!'
)

else (

    'Reconfigure related indexes',
    'Update front end path environment setting',
    
    (:local:create-file-structure(),:)
    (:local:move-static-files(),:)
    (:local:move-glossary-cached-locations(),:)
    (:local:merge-version-files(),:)
    (:local:trigger-published-tei(),:)
    (:local:store-publication-files(),:)
    (:local:store-entity-pages(),:)
    
    'Reconfigure scheduled tasks',
    'Remove deprecated files'
)