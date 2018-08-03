xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $tab := request:get-parameter('tab', 'translation')
let $translation-id := request:get-parameter('translation-id', '')
let $translation := translation:tei($translation-id)

let $updated := 
    if($tab eq 'titles') then
        translation:update($translation, ('title-en', 'title-bo', 'title-sa', 'title-long-en', 'title-long-bo', 'title-long-bo-ltn', 'title-long-sa-ltn'))
    else if($tab eq 'source') then
        translation:update($translation, ('toh', 'series', 'scope', 'range', 'authors'))
    else ()
    
return
    common:response(
        'utilities/translation-edit',
        'utilities',
        (
            <request xmlns="http://read.84000.co/ns/1.0" tab="{$tab}"/>,
            <updates xmlns="http://read.84000.co/ns/1.0">{ $updated }</updates>,
            <translation xmlns="http://read.84000.co/ns/1.0" id="{ $translation-id }">
            {
                if($tab eq 'titles') then
                    translation:titles($translation)
                else ()
            }
            {
                if($tab eq 'titles') then
                    translation:long-titles($translation)
                else ()
            }
            {
                if($tab eq 'source') then
                    translation:source($translation)
                else ()
            }
            </translation>
        )
    )
    