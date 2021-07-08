xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $config-set := request:get-parameter('config-set', 'page-text-strings')

let $config-collection := collection($common:app-config)

let $xml-response := 
    common:response(
        'operations/sys-config', 
        'operations', 
        (
            element { QName('http://read.84000.co/ns/1.0', 'sys-config-files') }{
                element option {
                    attribute id { 'page-text-strings' },
                    attribute allow-updates { false() },
                    attribute selected { ($config-set eq 'page-text-strings') },
                    text { 'Text in page headers and footers' }
                },
                element option {
                    attribute id { 'nav-labels' },
                    attribute allow-updates { false() },
                    attribute selected { ($config-set eq 'nav-labels') },
                    text { 'Labels in the website navigation' }
                },
                element option {
                    attribute id { 'nav-descriptions' },
                    attribute allow-updates { false() },
                    attribute selected { ($config-set eq 'nav-descriptions') },
                    text { 'Descriptions in the website navigation' }
                },
                element option {
                    attribute id { 'app-strings' },
                    attribute selected { ($config-set eq 'app-strings') },
                    text { 'Text in various pages' }
                }
            },
            element { QName('http://read.84000.co/ns/1.0', 'settings') }{
                attribute config-set { $config-set },
                if($config-set eq 'page-text-strings') then (
                    for $translation at $index in $config-collection/m:eft-header/m:translation | $config-collection/m:eft-footer/m:translation
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'setting') }{
                            attribute key { $translation/@id },
                            attribute sort-index { $index[1] },
                            for $text in $translation/m:text
                            return
                                element value {
                                    attribute key { $text/@xml:lang },
                                    $text/node()
                                }
                        }
                )
                else if($config-set eq 'nav-labels') then
                    for $label-group at $index in $config-collection/m:eft-header//m:label[@key]
                        let $key := $label-group/@key
                    group by $key
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'setting') }{
                            attribute key {  $key },
                            attribute sort-index { $index[1] },
                            for $label in $label-group
                            return
                                element value {
                                    attribute key { $label/ancestor::*[@xml:lang]/@xml:lang },
                                    $label/node()
                                }
                        }
                else if($config-set eq 'nav-descriptions') then
                    for $description-group at $index in $config-collection/m:eft-header//m:description[@key]
                        let $key := $description-group/@key
                    group by $key
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'setting') }{
                            attribute key {  $key },
                            attribute sort-index { $index[1] },
                            for $description in $description-group
                            let $lang := $description/ancestor::*[@xml:lang]/@xml:lang
                            order by $lang
                            return
                                element value {
                                    attribute key { $lang },
                                    $description/node()
                                }
                        }
                else if($config-set eq 'app-strings') then
                    for $string-group at $index in $config-collection/m:texts/m:item[@key]
                        let $key := $string-group/@key
                    group by $key
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'setting') }{
                            attribute key {  $key },
                            attribute sort-index { $index[1] },
                            for $string in $string-group
                            let $lang := $string/parent::m:texts/@xml:lang
                            order by $lang
                            return
                                element value {
                                    attribute key { $lang },
                                    common:markdown($string/node(), 'http://read.84000.co/ns/1.0')
                                    (:functx:change-element-ns-deep(
                                        $string/node(),
                                        'http://www.w3.org/1999/xhtml',
                                        ''
                                    ):)
                                }
                        }
                else
                    ()
            }
        )
    )

return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/sys-config.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )