xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter and passage-id
    Returns the translation of the passage
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $passage-id := request:get-parameter('passage-id', upper-case($resource-id))
let $view-mode := request:get-parameter('view-mode', 'passage')
let $view-mode := if($resource-suffix eq 'json') then 'json-passage' else if($view-mode = ('editor','editor-passage')) then 'editor-passage' else 'passage'
let $archive-path := request:get-parameter('archive-path', ())[matches(., '^[a-zA-Z0-9\-/_]{10,40}$')]

(: Validate the resource-id :)
let $tei := tei-content:tei($resource-id, 'translation', $archive-path)

(: Get the Toh-key, in order to normalise the resource-id :)
let $source := tei-content:source($tei, $resource-id)

(: Set the view-mode which controls variations in the display :)
let $view-mode := $translation:view-modes/m:view-mode[@id eq $view-mode]

(: Validate the passage-id :)
let $passage :=  translation:passage($tei, $passage-id, $view-mode)

(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
    
        attribute model { 'passage' },
        attribute resource-id { $source/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute doc-type { $resource-suffix },
        attribute passage-id { if($passage) then $passage-id else () },
        attribute view-mode { $view-mode/@id },
        attribute archive-path { $archive-path },
        
        $view-mode
        (:,$passage:)
        
    }
    
(: String for cache invalidation :)
let $cache-key := 
    let $tei-timestamp := tei-content:last-modified($tei)
    let $entities-timestamp := xmldb:last-modified(concat($common:data-path, '/operations'), 'entities.xml')
    where $tei-timestamp instance of xs:dateTime and $entities-timestamp instance of xs:dateTime
    return 
        lower-case(
            string-join((
                $tei-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                $common:app-version ! replace(., '\.', '-')
            ),'-')
        )

(: Get parts from cache and merge passages :)
let $text-id := tei-content:id($tei)

let $outline := translation:outline-cached($tei)
let $outlines-related := translation:outlines-related($tei, $passage, ())

let $merged-parts := translation:merge-parts($outline/m:pre-processed[@type eq 'parts'], $passage)

(: Get glossaries :)
(: Compile all the translation data :)
let $translation-data :=
    element { QName('http://read.84000.co/ns/1.0', 'translation')} {
    
        attribute id { tei-content:id($tei) },
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        attribute canonical-html { translation:href($source/@key, (), (), ($request/@archive-path ! concat('id=', .), $request/@passage-id ! concat('passage=', .)), (), 'https://read.84000.co') },
        attribute cache-key { $cache-key },
        
        translation:titles($tei, $source/@key),
        $source,
        translation:toh($tei, $source/@key),
        translation:publication($tei),
        tei-content:ancestors($tei, $source/@key, 1),
        $merged-parts
        
    }

let $entities-data := translation:entities((), $passage[@type eq 'glossary']//tei:gloss/@xml:id)

(: Get caches :)
let $glossary-cached-locations := glossary:cached-locations($tei, (), false())

(: Calculated strings :)
let $strings := translation:replace-text($source/@key)

let $xml-response :=
    common:response(
        $request/@model, 
        $common:app-id,
        (
            $request,
            $translation-data,
            $entities-data,
            $outline,
            $outlines-related,
            $glossary-cached-locations,
            $entities:flags,
            $glossary:attestation-types,
            $strings
        )
    )

return
    
    (: html :)
    if($request/@resource-suffix = ('html')) then 
        common:html($xml-response, concat($common:app-path, "/views/html/passage.xsl"), ())
    
    (: xml - also returned for json :)
    else 
        common:serialize-xml($xml-response)
