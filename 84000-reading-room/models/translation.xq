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

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../modules/translation.xql";
import module namespace search="http://read.84000.co/search" at "../modules/search.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $part := request:get-parameter('part', 'none')
let $view-mode := common:view-mode()
let $archive-path := request:get-parameter('archive-path', '')

let $part := if($view-mode = ('editor', 'annotation') or $resource-suffix = ('ebook', 'txt')) then 'all' else $part

let $tei := tei-content:tei($resource-id, 'translation', $archive-path)

return
    (: return all tei data :)
    if($resource-suffix = ('tei')) then
        $tei
    
    (: return parts of the data :)
    else 
        
        (: Get the source so we can extract the Toh :)
        let $source := tei-content:source($tei, $resource-id)
        
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
                        attribute view-mode { $view-mode }
                    },
                    
                    (: Compile all the translation data :)
                    element { QName('http://read.84000.co/ns/1.0', 'translation')} {
                        attribute id { tei-content:id($tei) },
                        attribute status { tei-content:translation-status($tei) },
                        attribute status-group { tei-content:translation-status-group($tei) },
                        attribute relative-html { translation:relative-html($source/@key) },
                        attribute canonical-html { translation:canonical-html($source/@key, $archive-path) },
                        
                        (: Data for rdf and json :)
                        if($resource-suffix = ('rdf', 'json')) then (
                            translation:titles($tei),
                            translation:long-titles($tei),
                            tei-content:source($tei, $resource-id),
                            translation:publication($tei),
                            tei-content:ancestors($tei, $source/@key, 1),
                            translation:downloads($tei, $source/@key, 'any-version'),
                            translation:summary($tei, 'show')
                        )
                        
                        (: Data for html (pdf) and epub :)
                        else (
                            translation:titles($tei),
                            translation:long-titles($tei),
                            $source,
                            translation:publication($tei),
                            tei-content:ancestors($tei, $source/@key, 1),
                            translation:downloads($tei, $source/@key, 'any-version'),
                            translation:parts($tei, $part)
                        ),
                        
                        (: Include caches :)
                        translation:notes-cache($tei, false()),
                        translation:milestones-cache($tei, false()),
                        translation:folios-cache($tei, false()),
                        translation:glossary-cache($tei, ())(:,
                        
                        (\: Include folios data if it's txt :\)
                        if($resource-suffix = ('txt')) then
                            element { QName('http://read.84000.co/ns/1.0', 'folio-refs')} {
                                translation:folio-refs-sorted($tei, $resource-id)
                            }
                        else ():)
                    },
                    
                    (: Calculated strings :)
                    element { QName('http://read.84000.co/ns/1.0', 'replace-text')} {
                        element value {
                            attribute key { '#CurrentDateTime' },
                            text { format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }
                        },
                        element value {
                            attribute key { '#LinkToSelf' },
                            text { translation:local-html($source/@key) }
                        },
                        element value {
                            attribute key { '#canonicalHTML' },
                            text { translation:canonical-html($source/@key, $archive-path) }
                        }
                    }
                )
            )

