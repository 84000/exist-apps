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
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";
import module namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $passage-id := request:get-parameter('passage-id', 'none')
let $view-mode := request:get-parameter('view-mode', 'passage')
let $view-mode := if($view-mode = ('editor','editor-passage')) then 'editor-passage' else 'passage'
let $archive-path := request:get-parameter('archive-path', ())

(: Validate the resource-id :)
let $tei := tei-content:tei($resource-id, 'translation', $archive-path)

(: Get the Toh-key, in order to normalise the resource-id :)
let $source := tei-content:source($tei, $resource-id)

(: Set the view-mode which controls variations in the display :)
let $view-mode := $translation:view-modes/m:view-mode[@id eq $view-mode]

(: Validate the passage-id :)
let $content := translation:parts($tei, $passage-id, $view-mode, ()) 

(:  Sanitize the request :)
let $request := 
    element { QName('http://read.84000.co/ns/1.0', 'request')} {
    
        attribute model { 'passage' },
        attribute resource-id { $source/@key },
        attribute resource-suffix { $resource-suffix },
        attribute lang { common:request-lang() },
        attribute passage-id { if($content) then $passage-id else () },
        attribute view-mode { $view-mode/@id },
        attribute archive-path { $archive-path },
        
        $view-mode
        
    }

(: Suppress cache for some requests :)
let $cache-key := 
    if($request/m:view-mode[@cache eq 'use-cache'] and $request/@passage-id gt '') then
        let $tei-timestamp := tei-content:last-modified($tei)
        where $tei-timestamp instance of xs:dateTime
        return 
            lower-case(format-dateTime($tei-timestamp, "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]") || '-' || replace($common:app-version, '\.', '-'))
    else ()

let $cached := common:cache-get($request, $cache-key)

return 
    (: Cached html :)
    if($cached) then  $cached 
    
    (: Compile response :)
    else
    
        let $canonical-id := (
            $request/@archive-path ! concat('id=', .), 
            concat('passage=', $request/@passage-id)
        )
        
        (: Get glossaries :)
        (: Compile all the translation data :)
        let $translation-data :=
            element { QName('http://read.84000.co/ns/1.0', 'translation')} {
            
                attribute id { tei-content:id($tei) },
                attribute status { tei-content:translation-status($tei) },
                attribute status-group { tei-content:translation-status-group($tei) },
                attribute relative-html { translation:relative-html($source/@key, $canonical-id) },
                attribute canonical-html { translation:canonical-html($source/@key, $canonical-id) },
                
                translation:titles($tei),
                $source,
                translation:toh($tei, $source/@key),
                tei-content:ancestors($tei, $source/@key, 1),
                
                $content
                
            }
            
        let $entities := translation:entities((), $content[@id eq 'glossary']//tei:gloss/@xml:id)
        
        let $quotes := translation:quotes($tei, $content)
        
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
                common:html($xml-response, concat($common:app-path, "/views/html/passage.xsl"), $cache-key)
            
            (: xml :)
            else 
                common:serialize-xml($xml-response)
