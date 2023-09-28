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

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $resource-id := request:get-parameter('resource-id', '')
let $part-id := request:get-parameter('part', 'none') ! replace(., '^(end\-notes|end\-note\-[a-zA-Z0-9\-]+)$', 'end-notes')
let $commentary-key := request:get-parameter('commentary', '')[. gt ''][1]
let $view-mode := request:get-parameter('view-mode', 'default')
let $archive-path := request:get-parameter('archive-path', ())[matches(., '^[a-zA-Z0-9\-/_]{10,40}$')]

(: Validate the resource-id :)
let $tei := tei-content:tei($resource-id, 'translation', $archive-path)
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
let $part := 
    $tei//id($part-id)/ancestor-or-self::tei:div[@type][not(@type eq 'translation')][last()]
    | $tei//tei:div[@type eq $part-id]


(: Set the view-mode which controls variations in the display :)
let $view-mode-validated :=
    if($resource-suffix eq 'epub') then
        $translation:view-modes/m:view-mode[@id eq 'ebook']
    else if($resource-suffix = ('txt', 'plain.txt', 'json')) then
        $translation:view-modes/m:view-mode[@id eq 'txt']
    else if($translation:view-modes/m:view-mode[@id eq $view-mode]) then
        $translation:view-modes/m:view-mode[@id eq $view-mode]
    else
        $translation:view-modes/m:view-mode[@id eq 'default']

(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'translation' },
        attribute resource-id { $source/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute doc-type { if($resource-suffix = ('txt', 'plain.txt')) then 'txt' else $resource-suffix },
        attribute part { ($part/@xml:id, $part/@type, $part-id[. = ('end-notes','citation-index')])[1] },
        attribute commentary { $commentary-source/@key },
        attribute view-mode { $view-mode-validated/@id },
        attribute archive-path { $archive-path },
        $view-mode-validated
    }

(: Suppress cache for some view modes :)
(: Don't accept archive-path parameter in cache requests, regardless of the view-mode - don't cache parameters that aren't sanitized!! :)
let $cache-key := 
    if($view-mode-validated[@cache eq 'use-cache'] and $request[not(@archive-path gt '')]) then
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
    else ()

let $cached := common:cache-get($request, $cache-key)

return 
    (: Cached html :)
    if($cached) then  $cached 
    
    (: tei :)
    else if($request[@resource-suffix eq 'tei']) then $tei
    
    (: cache :)
    else if($request[@resource-suffix eq 'cache']) then glossary:cache($tei, false())
    
    (: Compile response :)
    else
    
        let $text-id := tei-content:id($tei)

        let $canonical-id := (
        
            $request/@archive-path[. gt ''] ! concat('id=', .), 
            
            (: Keep part parameter in annotation views to maintain legacy annotations :)
            if($view-mode-validated[@id eq 'annotation']) then concat('part=', $request/@part) else $request/@part[. gt ''] ! concat('part=', .)
                
        )
        
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
                attribute relative-html { translation:relative-html($source/@key, $canonical-id) },
                attribute canonical-html { translation:canonical-html($source/@key, $canonical-id) },
                
                $source,
                translation:toh($tei, $source/@key),
                translation:titles($tei, $source/@key),
                translation:long-titles($tei, $source/@key),
                translation:publication($tei),
                tei-content:ancestors($tei, $source/@key, 1),
                translation:downloads($tei, $source/@key, 'any-version'),
                $parts
                
            }
        
        let $entities-data := translation:entities((), ($source/m:attribution/@xml:id, $parts[@id eq 'glossary']//tei:gloss/@xml:id))
        
        (: Get the cached outline of the text :)
        let $outline := translation:outline-cached($tei)
        let $outlines-related := translation:outlines-related($tei, $parts, $commentary-source/@key)
        
        (: Get glossary cache :)
        let $glossary-cache := glossary:glossary-cache($tei, (), false())
        
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
                    $glossary-cache,
                    $entities:flags,
                    $glossary:attestation-types,
                    $strings
                )
            )
        
        return
            
            (: html :)
            if($request/@resource-suffix = ('html')) then 
                common:html($xml-response, concat($common:app-path, "/views/html/translation.xsl"), $cache-key)
            
            (: xml :)
            else 
                common:serialize-xml($xml-response)
                