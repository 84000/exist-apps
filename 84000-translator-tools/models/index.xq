xquery version "3.0" encoding "UTF-8";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace local="http://translator-tools.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace search="http://read.84000.co/search" at "../../84000-reading-room/modules/search.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $tabs := local:user-tabs()
let $tab := $tabs//m:tab[@id eq request:get-parameter('tab','')]/@id
let $tab := 
    if(not($tab gt ''))then
        if($tabs//m:tab[@home][1]) then
            $tabs//m:tab[@home][1]/@id
        else
            $tabs//m:tab[1]/@id
    else
        $tab

return
    common:response(
        concat('translator-tools/', $tab),
        'translator-tools',
        (
            <request xmlns="http://read.84000.co/ns/1.0" tab="{ $tab }"/>,
            $tabs,
            doc(concat($common:data-path, '/translator-tools/sections/', $tab, '.xml'))
        )
    )