xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

declare function local:update-project($text-id as xs:string) as element()* {
    
    let $parent := $sponsorship:data/m:sponsorship
    
    let $existing-value := $parent/m:project[@id eq request:get-parameter('sponsorship-project-id', '')]
    
    let $new-value := sponsorship:project-posted($text-id)
        
        where $parent and ($existing-value or $new-value)
    return
        (: Do the update :)
        common:update('update-project', $existing-value, $new-value, $parent, ())
        (:(
            element update-debug {
                element existing-value { $existing-value }, 
                element new-value { $new-value }, 
                element parent { $parent }
            }
        ):)

};

(: Request parameters :)
let $resource-suffix := request:get-parameter('resource-suffix', '')
let $request-id := request:get-parameter('id', '') (: in get :)
let $post-id := request:get-parameter('post-id', '') (: in post :)
let $form-action := request:get-parameter('form-action', '')
let $tei := 
    if($post-id) then
        tei-content:tei($post-id, 'translation')
    else
        tei-content:tei($request-id, 'translation')

let $text-id := tei-content:id($tei)

let $document-uri := base-uri($tei)
let $document-uri-tokenised := tokenize($document-uri, '/')
let $document-filename := $document-uri-tokenised[last()]
let $document-path := substring-before($document-uri, $document-filename)
let $tei-locked-by-user := xmldb:document-has-lock(concat("xmldb:exist://", $document-path), $document-filename)

(: Process input :)
let $updated := 
    if($post-id and $tei and $text-id and $form-action eq 'update-sponsorship') then (
        
        (: Update TEI :)
        update-tei:title-statement($tei), 
        
        (: Update sponsorship :)
        (
        
            let $parent := $sponsorship:data/m:sponsorship
            let $existing-value := $parent/m:project[@id eq request:get-parameter('sponsorship-project-id', '')]
            let $new-value := sponsorship:project-posted($text-id)
            where $parent and ($existing-value or $new-value)
            return
                common:update('update-project', $existing-value, $new-value, $parent, ())
                
        )
     )
     else ()

(: Return output :)
let $acknowledgment := translation:acknowledgment($tei)

let $xml-response := 
    common:response(
        'operations/edit-text-sponsors', 
        'operations', 
        (
            <request 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"/>,
            <updates
                xmlns="http://read.84000.co/ns/1.0" >
                { $updated }
            </updates>,
            <translation 
                xmlns="http://read.84000.co/ns/1.0" 
                id="{ $text-id }"
                document-url="{ tei-content:document-url($tei) }" 
                locked-by-user="{ tei-content:locked-by-user($tei) }"
                status="{ tei-content:translation-status($tei) }">
                { translation:titles($tei) }
                { translation:sponsors($tei, true()) }
                { translation:publication($tei) }
                { translation:toh($tei, '') }
            </translation>,
            sponsors:sponsors('all', false(), true()),
            sponsorship:text-status($text-id, true())
        )
    )
    
return

    (: return html data :)
    if($resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-text-sponsors.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )    
    