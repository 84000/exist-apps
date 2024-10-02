xquery version "3.0" encoding "UTF-8";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";
import module namespace webflow="http://read.84000.co/webflow-api" at "../modules/webflow-api.xql";

declare variable $local:resource-id external;
declare variable $local:publish-file-group external;

(: ~ Test variables :)
(:let $local:resource-id := 'UT22084-034-009'
let $local:publish-file-group := ('translation-files,source-html,glossary-html,publications-list,webflow-api'):)

let $tei := tei-content:tei($local:resource-id, 'translation')
let $publish-file-groups := tokenize($local:publish-file-group, ',')

where $tei
return (

    util:log('info', concat('store-publication-files:', $local:resource-id, ' / ', $local:publish-file-group)),
    
    store:publication-files($tei, $translation:file-groups[. = $publish-file-groups], ()),
    
    if($publish-file-groups = 'webflow-api') then 
        webflow:translation-updates($tei)
    else ()
    
)