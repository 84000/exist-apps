xquery version "3.0" encoding "UTF-8";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";
declare namespace bcrdb="http://www.bcrdb.org/ns/1.0";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../modules/update-tm.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

declare option exist:serialize "method=xml indent=no";

let $text-id := request:get-parameter('text-id', '')
(:let $part-id := request:get-parameter('part-id', ''):)

let $tei := tei-content:tei($text-id, 'translation')
let $tmx := collection($update-tm:tm-path)//tmx:tmx[tmx:header/@eft:text-id eq $text-id]

(: Process update :)
let $update-tm :=
    (: Update an existing segment :)
    if(
        $tmx
        and request:get-parameter('form-action', '') eq 'update-segment'
        and request:get-parameter('tu-id', '') gt ''
        and request:get-parameter-names()[. = 'tm-bo']
        and request:get-parameter-names()[. = 'tm-en']
    ) then
        update-tm:update-unit($tmx, request:get-parameter('tu-id', ''), request:get-parameter('tm-bo', ''), request:get-parameter('tm-en', ''), request:get-parameter('tei-location-id', ''))
    
    (: Add a new segment :)
    else if(
        $tmx
        and request:get-parameter('form-action', '') eq 'add-unit'
        and request:get-parameter('tm-bo', '') gt ''
        and request:get-parameter-names()[. = 'tm-en']
    ) then
        update-tm:add-unit($tmx, request:get-parameter('tm-bo', ''), request:get-parameter('tm-en', ''), request:get-parameter('tei-location-id', ''), ())
    
    (: Delete a unit :)
    else if($tmx and request:get-parameter('remove-tu', '') gt '') then
        update-tm:remove-unit($tmx, request:get-parameter('remove-tu', '')) 
    
    (: Fix ids where missing :)
    else if($tmx and request:get-parameter('form-action', '') eq 'fix-ids') then 
        if($tmx/tmx:body/tmx:tu[not(@id)]) then
            update-tm:set-tu-ids($tmx)
        else ()
    
    (: Apply revisions :)
    else if($tmx and request:get-parameter('form-action', '') eq 'apply-revisions') then 
        let $tm-units-aligned := update-tm:tm-units-aligned($tei, $tmx)
        return 
            update-tm:apply-revisions($tm-units-aligned[self::eft:tm-unit-aligned], $tmx)
    
    (: Create a new TM file :)
    (:else if(
        not($tmx) 
        and request:get-parameter('form-action', '') eq 'new-tmx'
        and request:get-parameter('bcrd-resource', '') gt ''
    ) then
        let $bcrd-resource := doc(concat($common:data-path, '/BCRDCORPUS/', request:get-parameter('bcrd-resource', '')))//bcrdb:bcrdCorpus
        where $bcrd-resource
        return
            update-tm:new-tmx-from-bcrdCorpus($tei, $bcrd-resource):)

        
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
        attribute text-id { $text-id }(:,
        attribute part-id { $part-id }:)
    }

let $tm-units-aligned := 
    element { QName('http://read.84000.co/ns/1.0', 'tm-units-aligned') }{ 
        update-tm:tm-units-aligned($tei, $tmx)
    }

let $translation := 
    element { QName('http://read.84000.co/ns/1.0', 'translation') }{
        attribute id { tei-content:id($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { tei-content:document-url($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        tei-content:titles($tei),
        translation:toh($tei, '')
    }

(: If it was created then load again :)
(:let $bcrdb-source-files := 
    if(not($tmx)) then 
        element { QName('http://read.84000.co/ns/1.0', 'bcrd-resources') } {
            for $bcrd-resource in collection(concat($common:data-path, '/BCRDCORPUS'))//bcrdb:bcrdCorpus
            let $document-name := util:document-name($bcrd-resource)
            (\: Exclude source files that already have a tmx created :\)
            where not(collection($update-tm:tm-path)//tmx:tmx/tmx:header/@eft:source-ref eq $document-name)
            return 
                element bcrd-resource {
                    attribute document-name { $document-name },
                    $bcrd-resource/bcrdb:head
                }
        }
    else ():)

let $xml-response := 
    common:response(
        'operations/edit-tm',
        'operations', (
            $request,
            $update-tm,
            $translation,
            $tmx,
            $tm-units-aligned
        )
    )

return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-tm.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )