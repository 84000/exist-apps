xquery version "3.1" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace webflow="http://read.84000.co/webflow-api" at "/db/apps/84000-operations/modules/webflow-api.xql";
import module namespace store="http://read.84000.co/store" at "../modules/store.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../modules/deploy.xql";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

declare function local:store-unpublished-html() {
    
    let $translations-tei := $tei-content:translations-collection//tei:TEI[descendant::tei:publicationStmt/tei:availability/@status = ('1', '1.a')]
    
    for $tei in $translations-tei
    return (
        $tei//tei:sourceDesc/tei:bibl/tei:ref,
        
        (:if($tei[not(descendant::tei:publicationStmt/tei:availability/@status = ('1', '1.a'))]) then
            store:publication-files($tei, ('translation-html'), ())
        else ()
        ,:)
        
        webflow:translation-updates($tei)
    )
    
    (:deploy:push('data-static', (), 'store-unpublished-html', ()):)
    
};

(: Don't run if config incorrect :)
if(not(doc('/db/apps/84000-reading-room/xslt/webpage.xsl')//xsl:variable[@name eq "local-front-end-url"][@select eq "'/frontend'"])) then (
    doc('/db/apps/84000-reading-room/xslt/webpage.xsl')//xsl:variable[@name eq "local-front-end-url"],
    'Set xsl:variable[@name eq "local-front-end-url"]!'
)

else 
    local:store-unpublished-html()
    
    