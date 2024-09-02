xquery version "3.1";

(: Export glossary entries as CSV for importing into Supabase :)

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace glossary="http://read.84000.co/glossary" at "/db/apps/84000-reading-room/modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "/db/apps/84000-reading-room/modules/entities.xql";
import module namespace functx = "http://www.functx.com";

let $tei-gloss :=
    $tei-content:translations-collection//tei:TEI
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability
            [@status = $glossary:translation-render-status]
        ]//tei:div[@type eq 'glossary'][not(@status = 'excluded')]//tei:gloss[not(@mode eq 'surfeit')]

(:let $tei-gloss := subsequence($tei-gloss,1,10000):)

let $glossary-entries :=
    for $glossary-entry in $tei-gloss
    let $entity := $entities:entities//eft:instance[@id eq $glossary-entry/@xml:id]/parent::eft:entity
    return
        for $term-wy in $glossary-entry/tei:term[@xml:lang eq 'Bo-Ltn']
        let $term-wy-text := normalize-space(string-join($term-wy/text(),''))
        where $term-wy-text
        group by $term-wy-text
        order by $term-wy-text
        return
            (:let $entry :=:)
            element entry {
                element xmlId { $glossary-entry/@xml:id/string() },
                element entityId { $entity/@xml:id/string() },
                element type { $glossary-entry/@type/string() },
                element term-Bo-Ltn { $term-wy-text }, 
                element term-bo { common:bo-from-wylie($term-wy-text) }, 
                element term-en { ($glossary-entry/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type eq 'translationAlternative')][normalize-space(text())])[1] ! normalize-space(string-join(text())) ! concat('"', ., '"') }, 
                element term-Sa-Ltn { string-join(distinct-values($glossary-entry/tei:term[@xml:lang eq 'Sa-Ltn'][normalize-space(text())]/text() ! normalize-space(.)), ', ') ! concat('"', ., '"') }, 
                element term-zh { string-join(distinct-values($glossary-entry/tei:term[@xml:lang eq 'zh'][normalize-space(text())]/text() ! normalize-space(.)), ', ') ! concat('"', ., '"') }, 
                element term-Pi-Ltn { string-join(distinct-values($glossary-entry/tei:term[@xml:lang eq 'Pi-Ltn'][normalize-space(text())]/text() ! normalize-space(.)), ', ') ! concat('"', ., '"') }, 
                element text-definition { normalize-space(string-join(string-join($glossary-entry/tei:note[@type eq 'definition']/tei:p/descendant::text()), ' '))[. gt ''] ! concat('"', ., '"') }
            }
            (:return
            try { $entry } catch * { $glossary-entry/@xml:id/string() }:)

let $glossary-entries-csv := (
    string-join($glossary-entries[1]/* ! local-name(.), ','),
    for $glossary-entry in $glossary-entries
    return
        string-join($glossary-entry/*/string(), ',')
)

let $glossary-entities := 
    for $glossary-entry in $tei-gloss
    let $entity := $entities:entities//eft:instance[@id eq $glossary-entry/@xml:id]/parent::eft:entity
    let $entity-id := $entity/@xml:id/string()
    where $entity
    group by $entity-id
    return
        element entity {
            element entityID { $entity-id },
            element internal-label { ($entity/eft:label[@xml:lang eq 'en'], $entity/eft:label)[normalize-space(text())][1] ! string-join(text()) ! normalize-space(.)[. gt ''] ! concat('"', ., '"') }, 
            element types { string-join($entity/eft:type/@type/string(), ',') ! concat('"', ., '"') }, 
            element shared-definition { normalize-space(string-join(string-join($entity/eft:content[@type eq 'glossary-definition']/descendant::text()), ' '))[. gt ''] ! concat('"', ., '"') }
        }

let $glossary-entities-csv := (
    string-join($glossary-entities[1]/* ! local-name(.), ','),
    for $glossary-entity in $glossary-entities
    return
        string-join($glossary-entity/*/string(), ',')
)

return (
    (:xmldb:store('/db/apps/84000-data/uploads', 'glossary-entries.xml', element glossary-entries { $glossary-entries }, 'application/xml'),:)
    xmldb:store('/db/apps/84000-data/uploads', 'glossary-entries.csv', string-join($glossary-entries-csv, $common:chr-nl), 'text/csv'),
    (:xmldb:store('/db/apps/84000-data/uploads', 'glossary-entities.xml', element glossary-entities { $glossary-entities }, 'application/xml'),:)
    xmldb:store('/db/apps/84000-data/uploads', 'glossary-entities.csv', string-join($glossary-entities-csv, $common:chr-nl), 'text/csv')
)

