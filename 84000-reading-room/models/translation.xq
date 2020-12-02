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
import module namespace search="http://read.84000.co/search" at "../modules/search.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $part := request:get-parameter('part', 'none')
let $view-mode := request:get-parameter('view-mode', '')
let $archive-path := request:get-parameter('archive-path', ())

let $tei := tei-content:tei($resource-id, 'translation', $archive-path)

return
    (: return all tei data :)
    if($resource-suffix = ('tei')) then
        $tei
    
    (: return parts of the data :)
    else 
        
        (: Get the source so we can extract the Toh :)
        let $source := tei-content:source($tei, $resource-id)

        (: Set the client mode :)
        let $client-mode :=
            if($view-mode = ('passage', 'passage-bypass-cache', 'tests', 'pdf', 'app')) then 
                'no-client'
            else 
                'client'
        
        (: Set the layout mode :)
        let $layout-mode :=
            if($view-mode = ('tests', 'pdf', 'app')) then 
                'machine'
            else if($view-mode = ('passage', 'passage-bypass-cache')) then 
                'passage'
            else if($view-mode = ('annotation')) then 
                'expanded-fixed'
            else if($view-mode = ('editor')) then 
                'expanded'
            else 
                'fully-functional'
        
        (: Set the glossary mode :)
        let $glossary-mode := 
            if($view-mode = ('pdf')) then
                'suppress'
            else if ($view-mode = ('annotation')) then
                'defer'
            else if ($view-mode = ('editor')) then
                'defer-bypass-cache'
            else if ($view-mode = ('passage-bypass-cache')) then
                'bypass-cache'
            else 
                'use-cache'
        
        let $canonical-id := $archive-path
        (:let $canonical-id := string-join(($archive-path, $part-root), '-') :)
        
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
                        attribute view-mode { $view-mode },
                        attribute client-mode { $client-mode },
                        attribute layout-mode { $layout-mode },
                        attribute glossary-mode { $glossary-mode }
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
                            
                            (: Don't need these for a passage :)
                            if (not($view-mode = ('passage', 'passage-bypass-cache'))) then (
                                translation:long-titles($tei),
                                translation:publication($tei),
                                tei-content:ancestors($tei, $source/@key, 1),
                                translation:downloads($tei, $source/@key, 'any-version')
                            )
                            else ()
                            ,
                            translation:parts($tei, $part, $view-mode)
                        ),
                        
                        (: Include caches :)
                        translation:notes-cache($tei, false()),
                        translation:milestones-cache($tei, false()),
                        translation:folios-cache($tei, false()),
                        translation:glossary-cache($tei, ())
                        
                    },
                    
                    (: Calculated strings :)
                    element { QName('http://read.84000.co/ns/1.0', 'replace-text')} {
                        element value {
                            attribute key { '#CurrentDateTime' },
                            text { format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }
                        },
                        element value {
                            attribute key { '#LinkToSelf' },
                            text { translation:local-html($source/@key, $canonical-id) }
                        },
                        element value {
                            attribute key { '#canonicalHTML' },
                            text { translation:canonical-html($source/@key, $canonical-id) }
                        }
                    }
                )
            )
            