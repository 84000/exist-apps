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
let $part := request:get-parameter('part', 'none')
let $view-mode-id := request:get-parameter('view-mode', 'default')
let $archive-path := request:get-parameter('archive-path', ())

let $tei := tei-content:tei($resource-id, 'translation', $archive-path)

return
    (: return all tei data :)
    if($resource-suffix = ('tei')) then
        $tei
        
    else if($resource-suffix = ('cache')) then
        translation:cache($tei, false())
    
    (: return parts of the data :)
    else 
        
        (: Get the source so we can extract the Toh :)
        let $source := tei-content:source($tei, $resource-id)
        
        (: Set the view-mode which controls variations in the display :)
        let $view-mode :=
            if(request:get-parameter('resource-suffix', '') eq 'epub') then
                $translation:view-modes/m:view-mode[@id eq 'ebook']
                
            else if(request:get-parameter('resource-suffix', '') eq 'txt') then
                $translation:view-modes/m:view-mode[@id eq 'txt']
                
            else if($translation:view-modes/m:view-mode[@id eq $view-mode-id]) then
                $translation:view-modes/m:view-mode[@id eq $view-mode-id]
                
            else
                $translation:view-modes/m:view-mode[@id eq 'default']
        
        let $parts := translation:parts($tei, $part, $view-mode)
        
        let $canonical-id := (
            $archive-path ! concat('id=', .), 
            $parts//descendant-or-self::m:part[@prefix][@render eq 'show'][1] ! concat('part=', @id)
        )
        
        where $source
        return
            
            common:response(
                'translation',
                $common:app-id,
                (
                    (: Include request parameters :)
                    element { QName('http://read.84000.co/ns/1.0', 'request')} {
                        attribute resource-id { $resource-id },
                        attribute resource-suffix { $resource-suffix },
                        attribute doc-type { request:get-parameter('resource-suffix', 'html') },
                        attribute part { $part },
                        attribute archive-path { $archive-path },
                        $view-mode
                    },
                    
                    (: Compile all the translation data :)
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
                            if (not($view-mode[@parts eq 'passage'])) then (
                                translation:long-titles($tei),
                                translation:publication($tei),
                                tei-content:ancestors($tei, $source/@key, 1),
                                translation:downloads($tei, $source/@key, 'any-version')
                            )
                            else ()
                            ,
                            $parts
                        ),
                        
                        (: Include caches :)
                        translation:notes-cache($tei, false(), false()),
                        translation:milestones-cache($tei, false(), false()),
                        translation:folios-cache($tei, false(), false()),
                        translation:glossary-cache($tei, (), false())
                        
                    },
                    
                    (: Entities :)
                    entities:entities($parts[@id eq 'glossary']/tei:div[@type eq 'glossary']/tei:gloss/@xml:id/string()),
                    
                    (: Calculated strings :)
                    translation:replace-text($source/@key)
                )
            )
            