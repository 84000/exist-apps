xquery version "3.0" encoding "UTF-8";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";
declare namespace bcrdb="http://www.bcrdb.org/ns/1.0";

import module namespace helper="http://operations.84000.co/helper" at "../modules/helper.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../modules/update-tm.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $text-id := request:get-parameter('text-id', '')
let $first-record := request:get-parameter('first-record', '1') ! common:integer(.)

let $tei := tei-content:tei($text-id, 'translation')
let $tmx := collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]

(: If no tmx, try fixing it :)
let $tmx := 
    if(not($tmx)) then
        let $fix-mime-type := helper:fix-tm-mimetypes()
        return
            collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]
    else 
        $tmx

(: Process update :)
let $update-tm :=
    
    (: Apply revisions :)
    if($tmx and request:get-parameter('form-action', '') eq 'apply-revisions') then 
    
        helper:async-script(
            'tm-maintenance',
            <parameters xmlns="">
                <param name="text-id" value="{ $text-id}"/>
            </parameters>
        )
    
    (: Fix ids where missing :)
    else if($tmx and request:get-parameter('form-action', '') eq 'fix-ids') then 
        if($tmx/tmx:body/tmx:tu[not(@id)]) then
            update-tm:set-tu-ids($tmx)
        else ()
    
    (: Update an existing segment :)
    else if(
        $tmx
        and request:get-parameter('form-action', '') eq 'update-segment'
        and request:get-parameter('tu-id', '') gt ''
        and request:get-parameter-names()[. = 'tm-bo']
        and request:get-parameter-names()[. = 'tm-en']
    ) then
        update-tm:update-unit($tmx, request:get-parameter('tu-id', ''), request:get-parameter('tm-bo', ''), request:get-parameter('tm-en', ''), request:get-parameter('tei-location-id', ''), request:get-parameter('tm-flags[]', ''))
    
    (: Add a new segment :)
    else if(
        $tmx
        and request:get-parameter('form-action', '') eq 'add-unit'
        and request:get-parameter('tm-bo', '') gt ''
        and request:get-parameter-names()[. = 'tm-en']
    ) then
        update-tm:add-unit($tmx, request:get-parameter('tm-bo', ''), request:get-parameter('tm-en', ''), request:get-parameter('tei-location-id', ''), (), (), true())
    
    (: Delete a unit :)
    else if($tmx and request:get-parameter('remove-unit', '') gt '') then
        update-tm:remove-unit($tmx, request:get-parameter('remove-unit', '')) 
    
    else ()

(: If it was created then load again :)
let $tmx := 
    if(not($tmx)) then 
        collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]
    else
        $tmx

let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') }{
        attribute resource-suffix { request:get-parameter('resource-suffix', '') },
        attribute text-id { $text-id },
        attribute first-record { $first-record },
        attribute max-records { 100 },
        attribute filter { request:get-parameter('filter', '') },
        attribute active-record {
            if(request:get-parameter('remove-unit', '') gt '') then
                request:get-parameter('remove-unit', '')
            else ()
        }
    }

let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
        attribute id { tei-content:id($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { base-uri($tei) },
        attribute resource-type { tei-content:type($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        tei-content:titles-all($tei),
        translation:toh($tei, ''),
        tei-content:status-updates($tei)
    }

let $xml-response := 
    common:response(
        'operations/edit-tm',
        'operations', (
            $request,
            $update-tm,
            $text,
            tei-content:text-statuses-selected($text/@status, 'translation'),
            $tmx,
            $update-tm:blocking-jobs
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(helper:app-path(), '/views/edit-tm.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
