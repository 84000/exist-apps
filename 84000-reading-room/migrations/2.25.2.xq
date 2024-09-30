xquery version "3.1" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace webflow="http://read.84000.co/webflow-api" at "/db/apps/84000-operations/modules/webflow-api.xql";
import module namespace store="http://read.84000.co/store" at "../modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../modules/deploy.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

declare variable $local:exec-options := 
    <option>
        <workingDir>/{ $common:environment//eft:env-vars/eft:var[@id eq 'home']/text() }/</workingDir>
    </option>;

declare function local:store-unpublished-html() {
    
    let $translations-tei := $tei-content:translations-collection//tei:TEI[not(descendant::tei:publicationStmt/tei:availability/@status = ('1', '1.a'))]
    
    for $tei in $translations-tei
    return (
        $tei//tei:sourceDesc/tei:bibl/tei:ref,
        
        if($tei[not(descendant::tei:publicationStmt/tei:availability/@status = ('1', '1.a'))]) then
            store:publication-files($tei, ('translation-html'), ())
        else ()
        ,
        
        webflow:translation-updates($tei)
    ),
    
    deploy:push('data-static', (), 'store-unpublished-html', ())
    
};

declare function local:patch-published-texts() {
    
    let $translations-tei := $tei-content:translations-collection//tei:TEI[descendant::tei:publicationStmt/tei:availability/@status = ('1', '1.a')]
    
    for $bibl in $translations-tei//tei:sourceDesc/tei:bibl[@key]
    return (
    
        $bibl/tei:ref,
        
        util:log('INFO', concat('webflow-patch-text: ', $bibl/@key)),
        webflow:patch-text($bibl/@key),
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
        
    )
    
};

declare function local:patch-catalogue-sections() {
    
    let $sections-tei := $tei-content:sections-collection//tei:TEI
    
    for $tei in $sections-tei
    let $section-id := tei-content:id($tei)
    return (
    
        $section-id,
        
        util:log('INFO', concat('webflow-patch-catalogue-section: ', $section-id)),
        webflow:patch-catalogue-section($section-id),
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
        
    )
    
};

declare function local:refresh-kb-entity-pages() {
    
    let $kb-entities := $entities:entities/eft:entity[eft:instance/@type = 'knowledgebase-article']
    
    for $entity at $index in $kb-entities
    let $source-html := concat($store:conf/@source-url, '/glossary/', $entity/@xml:id, '.html')
    let $target-folder := concat($common:static-content-path, '/glossary/named-entities/')
    let $target-file := concat($entity/@xml:id,'.html')
    where util:binary-doc-available(concat($target-folder, '/', $target-file))
    return (
        (:$source-html,:)
        util:log('INFO', $target-file),
        store:http-download($source-html, $target-folder, $target-file, $store:permissions-group),
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
    ),
    
    deploy:push('data-static', (), 'refresh-kb-entity-pages', ())
    
};

declare function local:refresh-empty-sa-titles() {
    
    let $translations-tei := $tei-content:translations-collection//tei:TEI[not(descendant::tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'][text()])]
    (:let $translations-tei := subsequence($translations-tei, 2, 1):)
    
    for $bibl in $translations-tei//tei:sourceDesc/tei:bibl[@key]
    return (
        $bibl/tei:ref/text(),
        util:log('INFO', concat('webflow-patch-text: ', $bibl/@key)),
        webflow:patch-text($bibl/@key),
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
    )

};

(: Don't run if config incorrect :)
if(not(doc('/db/apps/84000-reading-room/xslt/webpage.xsl')//xsl:variable[@name eq "local-front-end-url"][@select eq "'/frontend'"])) then (
    doc('/db/apps/84000-reading-room/xslt/webpage.xsl')//xsl:variable[@name eq "local-front-end-url"],
    'Set xsl:variable[@name eq "local-front-end-url"]!'
)

else 
    local:refresh-empty-sa-titles()
    
    