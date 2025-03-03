xquery version "3.0" encoding "UTF-8";
(:
    Returns translation as pre-processed xml or html
    - Always returns the structure of the whole text
    - Only returns specified content based on part and view-mode
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../modules/glossary.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../modules/contributors.xql";
import module namespace functx = "http://www.functx.com";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $resource-id := request:get-parameter('resource-id', '')
let $part-id := request:get-parameter('part', 'none')[not(. = ('','index'))][1]
let $commentary-key := request:get-parameter('commentary', '')[not(. = ('','index'))][1]
let $view-mode := request:get-parameter('view-mode', 'default')
let $archive-path := request:get-parameter('archive-path', ())[matches(., '^[a-zA-Z0-9\-/_\.]{10,100}$')]

(: Validate the resource-id :)
let $tei := tei-content:tei($resource-id, 'translation', $archive-path)
let $text-id := tei-content:id($tei)
(: Get the Toh-key :)
let $source := tei-content:source($tei, $resource-id)

(: Validate the commentary key :)
let $commentary-tei := $commentary-key ! tei-content:tei(., 'translation')
let $commentary-tei := 
    if(not($commentary-tei) and $commentary-key) then
        collection($common:tei-path)/id($commentary-key)/ancestor::tei:TEI
    else
        $commentary-tei

let $commentary-source := $commentary-tei[1] ! tei-content:source(., '')

(: Derive the root part (section/chapter) based on the id requested
   - Use this derived root to process further
   - Cache key is the same for all requests contained in that part
:)
let $part-id := (
    (: Get the top section of any xml:id :)
    $tei//id($part-id)/ancestor-or-self::tei:div[@type][not(@type eq 'translation')][last()]/@xml:id[1]/string(), 
    (: Get the xml:id of any part type :)
    $tei//tei:div[@type eq $part-id]/@xml:id/string(),
    (: Citation index is derived so can't be looked up :)
    $part-id[. eq concat($text-id, '-citation-index')],
    (: End notes is derived so can't be looked up :)
    $part-id[. eq concat($text-id, '-end-notes')]
    (:(\: DANGER ! Only enable for debug! :\),$part-id:)
)

(: Set the view-mode which controls variations in the display :)
let $view-mode-validated := (
    ((: View modes that vary from input :)
    if($resource-suffix eq 'epub') then
        $translation:view-modes/m:view-mode[@id eq 'ebook']
    else if($resource-suffix = ('txt', 'plain.txt')) then
        $translation:view-modes/m:view-mode[@id eq 'txt']
    
    (: Default to requested view mode :)
    else
        $translation:view-modes/m:view-mode[@id eq $view-mode]
    
    (: Check view mode is not disabled :)
    )[not(@id eq $common:environment/m:disable[@type eq 'view-mode']/@id)],
    
    (: Default :)
    $translation:view-modes/m:view-mode[@id eq 'default']
    
)[1]

(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'translation' },
        attribute resource-id { $source/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute doc-type { if($resource-suffix = ('txt', 'plain.txt')) then 'txt' else if($resource-suffix = ('html', 'xhtml')) then 'html' else $resource-suffix },
        attribute part { $part-id },
        attribute commentary { $commentary-source/@key },
        attribute view-mode { $view-mode-validated/@id },
        attribute archive-path { $archive-path },
        $view-mode-validated
    }

(: String for cache invalidation :)
let $cache-key := translation:cache-key($tei, $request/@archive-path)

(: Suppress cache for some view modes :)
(: Don't accept archive-path parameter in cache requests, regardless of the view-mode - don't cache parameters that aren't sanitized!! :)
let $cached := 
    if($view-mode-validated[@cache eq 'use-cache'] and $request[not(@archive-path gt '')]) then
        common:cache-get($request, $cache-key)
    else ()

return 
    (: Cached html :)
    if($cached) then 
        $cached 
    
    (: tei :)
    else if($request[@resource-suffix eq 'tei']) then 
        $tei
    
    (: glossary locations - if requested as .cache return in legacy format :)
    else if($request[@resource-suffix eq 'glossary-locations.xml']) then 
        glossary:cached-locations($tei, false())
    else if($request[@resource-suffix eq 'cache']) then 
        let $glossary-cached-locations := glossary:cached-locations($tei, false())
        let $glossary-cached-locations-legacy := transform:transform($glossary-cached-locations, doc(concat($common:app-path, "/views/xml/glossary-locations-legacy.xsl")), <parameters/>)
        return
            common:serialize-xml($glossary-cached-locations-legacy)
            
    (: Compile response :)
    else

        let $canonical-html :=
            (: Maintain legacy canonical url for Hypothesis integration :)
            (: Keep part parameter in annotation even if there is no value :)
            if($view-mode-validated[@annotation eq 'web']) then
                concat('https://read.84000.co', concat('/translation/', $resource-id, '.html', string-join(($request/@archive-path[. gt ''] ! concat('id=', .), concat('part=', $request/@part)), '&amp;')[. gt ''] ! concat('?', .)))
            else
                translation:canonical-html($source/@key, $request/@part[. gt ''], $request/@commentary[. gt ''])
        
        let $parts := 
            if($request[@resource-suffix eq 'rdf']) then 
                translation:summary($tei)
            else 
                translation:parts($tei, $request/@part, $view-mode-validated, ())
        
        (: Compile all the translation data :)
        let $translation-data :=
            element { QName('http://read.84000.co/ns/1.0', 'translation')} {
            
                attribute id { $text-id },
                attribute status { tei-content:publication-status($tei) },
                attribute status-group { tei-content:publication-status-group($tei) },
                attribute canonical-html { $canonical-html },
                attribute cache-key { $cache-key },
                
                $source,
                translation:toh($tei, $source/@key),
                translation:titles($tei, $source/@key),
                translation:long-titles($tei, $source/@key),
                translation:publication($tei),
                tei-content:ancestors($tei, $source/@key, 1),
                (:translation:downloads($tei, $source/@key, 'any-version'),:)
                translation:files($tei, 'translation-files', $source/@key),
                $parts
                
            }
        
        let $entities-data := translation:entities((), ($source/m:attribution/@xml:id, $parts[@type eq 'glossary']//tei:gloss/@xml:id))
        
        (: Get the cached outline of the text :)
        let $outline := translation:outline-cached($tei)
        let $outlines-related := translation:outlines-related($tei, $parts, $commentary-source/@key)
        
        (: Get glossary cache :)
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
            if($request/@resource-suffix = ('html','xhtml')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/translation.xsl"), $cache-key)

            (: xml :)
            else 
                common:serialize-xml($xml-response)


