xquery version "3.0" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace sitemap = "http://www.sitemaps.org/schemas/sitemap/0.9";

import module namespace common = "http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace source="http://read.84000.co/source" at "../modules/source.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";

declare option exist:serialize "method=xml indent=yes";

declare function local:url-element($loc as xs:string, $lastmod as xs:string?) {
    
    (: Prettify with whitespace :)
    common:ws(1),
    
    element { QName('http://www.sitemaps.org/schemas/sitemap/0.9','url') } {
        element loc { $loc },
        $lastmod ! element lastmod { . }
    }
    
};

element { QName('http://www.sitemaps.org/schemas/sitemap/0.9','urlset') } {
    
    let $active-tei := $tei-content:translations-collection//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability[@status = $translation:published-status-ids][not(tei:p/@type eq 'tantricRestriction')]]
    (:let $active-tei := subsequence($active-tei, 1, 50):)
    
    return (
    
        let $active-glosses := $active-tei//tei:div[@type eq 'glossary'][not(@status = 'excluded')]//tei:gloss[not(@mode eq 'surfeit')]
        (:let $active-glosses := subsequence($active-glosses, 1, 500):)
        
        for $entity in $entities:entities//eft:entity[@xml:id]
        let $instance-ids := $entity/eft:instance/@id/string()
        where $active-glosses/id($instance-ids)
        (:let $entity-int := $entity/@xml:id ! replace(., '^entity-', '') ! xs:int(.)
        order by $entity-int:)
        return
            (: Create glossary:canonical-html function :)
            local:url-element(string-join(('https://84000.co', 'glossary', $entity/@xml:id ! replace(., '^entity-', '')), '/'), ())
        ,
        
        $common:chr-nl
        
    )
}
