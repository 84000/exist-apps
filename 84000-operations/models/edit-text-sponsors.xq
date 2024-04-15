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
        let $parent := $sponsorship:data/m:sponsorship
        let $existing-value := $parent/m:project[@id eq request:get-parameter('sponsorship-project-id', '')]
        let $new-value := sponsorship:project-posted($text-id)
        where $parent and ($existing-value or $new-value)
        return
            common:update('update-project', $existing-value, $new-value, $parent, ())
            
     )
     else ()

(: Return output :)
let $acknowledgment := translation:acknowledgment($tei)

let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') } {
        
        attribute id { $text-id },
        attribute document-url { base-uri($tei) },
        attribute resource-type { tei-content:type($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:publication-status($tei) },
        attribute status-group { tei-content:publication-status-group($tei) },
        attribute tei-version { tei-content:version-str($tei) },
        
        translation:titles($tei, ()),
        translation:toh($tei, ''),
        translation:sponsors($tei, true()),
        translation:publication($tei)
        
    }

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
            $text,
            sponsors:sponsors('all', true()),
            sponsorship:text-status($text-id, true()),
            tei-content:text-statuses-selected(tei-content:publication-status($tei), 'translation')
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
    