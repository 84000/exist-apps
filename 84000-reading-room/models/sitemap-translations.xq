xquery version "3.0" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace sitemap = "http://www.sitemaps.org/schemas/sitemap/0.9";

import module namespace common = "http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../modules/translation.xql";

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
    
        for $tei in $active-tei
        let $tei-timestamp := tei-content:last-modified($tei)
        let $parts := translation:parts($tei, (), $translation:view-modes/eft:view-mode[@id eq 'default'], ())
        let $text-id := tei-content:id($tei)
        order by $text-id
        return 
            for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
            return (
                
                (: Add index :)
                local:url-element(translation:canonical-html($bibl/@key, (), ()), format-dateTime($tei-timestamp, '[Y0001]-[M01]-[D01]')),
                
                (: Add parts :)
                for $part in ($parts[@content-status eq 'preview'] | $parts[@type eq 'translation']/eft:part[@content-status eq 'preview'] | $parts[@type eq 'citation-index'])
                return
                    local:url-element(translation:canonical-html($bibl/@key, $part/@id, ()), format-dateTime($tei-timestamp, '[Y0001]-[M01]-[D01]'))
                
            )
        ,
        
        $common:chr-nl
        
    )
}
