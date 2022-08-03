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
import module namespace contributors="http://read.84000.co/contributors" at "../modules/contributors.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $resource-id := request:get-parameter('resource-id', '')
let $archive-path := request:get-parameter('archive-path', ())
let $part-id := request:get-parameter('part', 'none') ! replace(., '^(end\-notes|end-note\-[a-zA-Z0-9\-]+)$', 'end-notes')
let $view-mode := request:get-parameter('view-mode', 'default')

(: Validate the resource-id :)
let $tei-type := 'translation'
let $tei := tei-content:tei($resource-id, $tei-type, $archive-path)

(: Get the Toh-key :)
let $source := tei-content:source($tei, $resource-id)

(: Validate the part-id :)
let $part := 
    $tei//id($part-id)/ancestor-or-self::tei:div[@type][not(@type eq 'translation')][last()]
    | $tei//tei:div[@type eq $part-id]

(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'translation' },
        attribute resource-id { $source/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute doc-type { request:get-parameter('resource-suffix', 'html') },
        attribute part { ($part/@xml:id, $part/@type, $part-id[. = ('end-notes')])[1] },
        attribute view-mode { $view-mode },
        attribute archive-path { $archive-path },
        
        (: Set the view-mode which controls variations in the display :)
        if($resource-suffix eq 'epub') then
            $translation:view-modes/m:view-mode[@id eq 'ebook']
        
        else if($resource-suffix eq 'txt') then
            $translation:view-modes/m:view-mode[@id eq 'txt']
        
        else if($translation:view-modes/m:view-mode[@id eq $view-mode]) then
            $translation:view-modes/m:view-mode[@id eq $view-mode]
        
        else
            $translation:view-modes/m:view-mode[@id eq 'default']
        ,
        
        element highlight {
            request:get-parameter('highlight', '')
        }
        
    }

(: Suppress cache for some view modes :)
let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache']) then
        let $tei-timestamp := tei-content:last-modified($tei)
        where $tei-timestamp instance of xs:dateTime
        return 
            lower-case(format-dateTime($tei-timestamp, "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]") || '-' || replace($common:app-version, '\.', '-'))
    else ()

let $cached := common:cache-get($request, $cache-key)

return 
    (: Cached html :)
    if($cached) then  $cached 
    
    (: tei :)
    else if($resource-suffix = ('tei')) then $tei
    
    (: cache :)
    else if($resource-suffix = ('cache')) then tei-content:cache($tei, false())
    
    (: Compile response :)
    else

        let $canonical-id := (
            $request/@archive-path ! concat('id=', .), 
            concat('part=', $request/@part)
        )
        
        let $parts := 
            if($resource-suffix = ('rdf', 'json')) then 
                translation:summary($tei)
            else 
                translation:parts($tei, $part-id, $request/m:view-mode)
        
        (: Compile all the translation data :)
        let $translation-data :=
            element { QName('http://read.84000.co/ns/1.0', 'translation')} {
            
                attribute id { tei-content:id($tei) },
                attribute status { tei-content:translation-status($tei) },
                attribute status-group { tei-content:translation-status-group($tei) },
                attribute relative-html { translation:relative-html($source/@key, $canonical-id) },
                attribute canonical-html { translation:canonical-html($source/@key, $canonical-id) },
                
                $source,
                translation:toh($tei, $source/@key),
                translation:titles($tei),
                translation:long-titles($tei),
                translation:publication($tei),
                tei-content:ancestors($tei, $source/@key, 1),
                translation:downloads($tei, $source/@key, 'any-version'),
                $parts
                
            }
        
        let $entities := translation:entities($source/m:attribution/@ref ! contributors:contributor-id(.), $parts[@id eq 'glossary']//tei:gloss/@xml:id)
        
        let $quotes := translation:quotes($tei, $parts)
        
        (: Get caches :)
        let $cache := tei-content:cache($tei, false())/m:*
        
        (: Calculated strings :)
        let $strings := translation:replace-text($source/@key)
        
        let $xml-response :=
            common:response(
                $request/@model, 
                $common:app-id,
                (
                    $request,
                    $translation-data,
                    $entities,
                    $quotes,
                    $entities:flags,
                    $cache,
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
                