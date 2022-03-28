xquery version "3.0" encoding "UTF-8";
(:
    Accepts the resource-id parameter
    Returns the translation data
    -------------------------------------------------------------
    This does pre-processing of the TEI into a simple xml mode. 
    This should then be transformed into json/html/pdf/epub
    or other formats.
:)

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $view-mode := request:get-parameter('view-mode', 'default')
let $archive-path := request:get-parameter('archive-path', ())
let $passage-id := request:get-parameter('part', 'none') ! replace(., '^(end\-notes|end-note\-[a-zA-Z0-9\-]+)$', 'end-notes')

(: Validate the resource-id :)
let $tei := tei-content:tei($resource-id, 'translation', $archive-path)
(: Get the Toh-key :)
let $source := tei-content:source($tei, $resource-id)
(: Get the part - if the passage-id is a part :)
let $part := 
    $tei//id($passage-id)/ancestor-or-self::tei:div[@type][not(@type eq 'translation')][last()]
    | $tei//tei:div[@type eq $passage-id]
    
(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
        attribute model { 'translation' },
        attribute resource-id { $source/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute doc-type { request:get-parameter('resource-suffix', 'html') },
        attribute part { ($part/@xml:id, $part/@type, $passage-id[. = ('end-notes')])[1] },
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
        
        element passage {
            attribute id { $passage-id }
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

        (: Compile all the translation parts :)
        let $parts := translation:parts($tei, $passage-id, $request/m:view-mode)
        
        let $canonical-id := (
            $request/@archive-path ! concat('id=', .), 
            concat('part=', $request/@part)
        )
        
        (: Get entities :)
        let $glossary-entities := 
            element { QName('http://read.84000.co/ns/1.0', 'entities') }{
                if($common:environment/m:enable[@type eq 'glossary-of-terms']) then
                    for $gloss in
                        if($request/m:view-mode[@parts eq 'passage']) then
                            $parts[@id eq 'glossary']//tei:gloss/id($passage-id)
                        else
                            $parts[@id eq 'glossary']//tei:gloss
                    let $instance := $entities:entities//m:instance[@id = $gloss/@xml:id]
                    return
                        $instance[1]/parent::m:entity
                else ()
            }
        
        (: Compile all the translation data :)
        let $translation-data :=
            element { QName('http://read.84000.co/ns/1.0', 'translation')} {
                attribute id { tei-content:id($tei) },
                attribute status { tei-content:translation-status($tei) },
                attribute status-group { tei-content:translation-status-group($tei) },
                attribute relative-html { translation:relative-html($source/@key, $canonical-id) },
                attribute canonical-html { translation:canonical-html($source/@key, $canonical-id) },
                
                (: Data for rdf and json :)
                if($resource-suffix = ('rdf', 'json')) then (
                    translation:titles($tei),
                    $source,
                    translation:long-titles($tei),
                    translation:publication($tei),
                    tei-content:ancestors($tei, $source/@key, 1),
                    translation:downloads($tei, $source/@key, 'any-version'),
                    translation:summary($tei)
                )
                
                (: Data for html (pdf) and epub :)
                else (
                    
                    translation:titles($tei),
                    $source,
                    translation:toh($tei, $source/@key),
                    (: Don't need these for a passage :)
                    if (not($request/m:view-mode[@parts eq 'passage'])) then (
                        translation:long-titles($tei),
                        translation:publication($tei),
                        tei-content:ancestors($tei, $source/@key, 1),
                        translation:downloads($tei, $source/@key, 'any-version')
                    )
                    else ()
                    ,
                    $parts
                )
                
            }
        
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
                    $glossary-entities,
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