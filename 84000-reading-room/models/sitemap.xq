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
    
        for $tei in $active-tei
        let $tei-timestamp := tei-content:last-modified($tei)
        let $parts := translation:parts($tei, (), $translation:view-modes/eft:view-mode[@id eq 'default'], ())
        let $text-id := tei-content:id($tei)
        order by $text-id
        return 
            for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
            let $source-folios := translation:folio-refs-sorted($tei, $bibl/@key)
            return (
                
                (: Add index :)
                local:url-element(translation:canonical-html($bibl/@key, (), ()), format-dateTime($tei-timestamp, '[Y0001]-[M01]-[D01]')),
                
                (: Add parts :)
                for $part in ($parts[@content-status eq 'preview'] | $parts[@type eq 'translation']/eft:part[@content-status eq 'preview'] | $parts[@type eq 'citation-index'])
                return
                    local:url-element(translation:canonical-html($bibl/@key, $part/@id, ()), format-dateTime($tei-timestamp, '[Y0001]-[M01]-[D01]'))
                ,
                
                (: Add source :)
                for $folio in $source-folios
                return
                    local:url-element(concat('https://84000.co', source:href($bibl/@key, $folio/@index-in-resource, (), ())), format-dateTime($tei-timestamp, '[Y0001]-[M01]-[D01]'))
                
            )
        ,
        
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
