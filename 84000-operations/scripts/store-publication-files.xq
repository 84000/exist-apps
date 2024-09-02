xquery version "3.0" encoding "UTF-8";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace webflow="http://read.84000.co/webflow-api" at "../modules/webflow-api.xql";

declare variable $local:resource-id external;
declare variable $local:exclude-file-group external;

(: ~ Test variables :)
(:let $local:resource-id := 'UT22084-034-009'
let $local:exclude-file-group := ('translation-files,source-html,glossary-html,glossary-files,publications-list,webflow-api'):)

let $tei := tei-content:tei($local:resource-id, 'translation')
let $exclude-file-groups := tokenize($local:exclude-file-group, ',')

where $tei
return (

    util:log('info', concat('store-publication-files:', $local:resource-id, ' / ', string-join($translation:file-groups[not(. = $exclude-file-groups)], ', '))),
    
    store:publication-files($tei, $translation:file-groups[not(. = $exclude-file-groups)], ()),
    
    if(not($exclude-file-groups = 'webflow-api')) then 
        webflow:translation-updates($tei)
    else ()
    
)