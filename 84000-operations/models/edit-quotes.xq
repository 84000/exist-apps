xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml indent=no";

let $resource-id := request:get-parameter('resource-id', '')
let $part-id := request:get-parameter('part', '')
let $tei := tei-content:tei($resource-id, 'translation')

let $request :=
    element { QName('http://read.84000.co/ns/1.0', 'request') }{
        attribute resource-suffix { request:get-parameter('resource-suffix', 'html') },
        attribute resource-id { if($tei) then $resource-id else () },
        attribute part { 
            if($tei//tei:div[@type eq 'translation']/tei:div[@xml:id eq $part-id]) then 
                $part-id 
            else 
                $tei//tei:div[@type eq 'translation']/tei:div[@xml:id][1]/@xml:id
        }
    }

let $text-id := tei-content:id($tei)
let $source := tei-content:source($tei, $request/@resource-id)

let $updates := 
    element { QName('http://read.84000.co/ns/1.0', 'updates') } {}

let $text := 
    element { QName('http://read.84000.co/ns/1.0', 'text') }{
    
        attribute id { $text-id },
        attribute tei-version { tei-content:version-str($tei) },
        attribute document-url { tei-content:document-url($tei) },
        attribute locked-by-user { tei-content:locked-by-user($tei) },
        attribute status { tei-content:translation-status($tei) },
        attribute status-group { tei-content:translation-status-group($tei) },
        
        tei-content:titles($tei),
        translation:toh($tei, ''),
        translation:parts($tei, $request/@part, $translation:view-modes/m:view-mode[@id eq 'passage'], 'body')
        
    }

let $quotes := translation:outline-cached($tei)/m:pre-processed[@type eq 'quotes']

let $part-quote-refs := $text/m:part[@id eq 'translation']/m:part[@id eq $request/@part]//tei:ptr[@type eq 'quote-ref']/@xml:id
let $part-quote-refs-chunked := common:ids-chunked($part-quote-refs)
let $part-quotes := 
    for $key in map:keys($part-quote-refs-chunked)
    return
        $quotes/m:quote[@id = map:get($part-quote-refs-chunked, $key)]

let $root-texts :=
    element { QName('http://read.84000.co/ns/1.0', 'root-texts') }{
        for $location-part in distinct-values($part-quotes/m:source/@location-part)
        let $resource-id := ($part-quotes/m:source[@location-part eq $location-part])[1]/@resource-id
        return
            local:root-html($resource-id, $location-part, $source/@key)
    }

let $quotes-with-responses :=
    element { QName('http://read.84000.co/ns/1.0', 'quotes') } {
    
        $quotes/@*,
        
        for $quote in $part-quotes
        
        let $html-part := $root-texts/m:html[@part-id eq $quote/m:source/@location-part]
        let $html-passage := ($html-part//*[@data-location-id eq $quote/m:source/@location-id][not(ancestor::*[@data-location-id])] | $html-part//*[@id eq $quote/m:source/@location-id])
        let $html-highlights := $html-passage[descendant::xhtml:span[@data-quote-id = $quote/@id]]
        let $highlight-spans := $html-highlights/descendant::xhtml:span[@data-quote-id = $quote/@id]
        let $link-status := 
            if($quote[m:highlight]) then
                if(not($highlight-spans)) then
                    'none'
                else if($quote/m:highlight[not(xs:integer(@index) = $highlight-spans/@data-quote-highlight ! xs:integer(.))]) then
                    'partial'
                else
                    'complete'
            else 
                if(not($html-passage)) then
                    'none'
                else
                    'complete'
        
        let $tei-part := $root-texts/m:tei[@part-id eq $quote/m:source/@location-part]
        
        return 
            element { node-name($quote) }{
            
                $quote/@*,
                attribute status { $link-status },
                
                $quote/*,
                element source-html { 
                    
                    (: Return the highlights :)
                    if($quote/m:highlight and $html-highlights) then    
                        $html-highlights
                    
                    (: If the highlight wasn't found return the passage :)
                    else if($html-passage) then
                        $html-passage
                    
                    (: If the passage wasn't found return the part :)
                    else 
                        ($html-part//xhtml:div[contains(@class, 'rw-section-head')])[1]
                
                },
                
                element source-tei {
                    let $root-milestone := $tei-part/id($quote/m:source/@location-id)
                    return (
                        $root-milestone/following-sibling::tei:*[preceding-sibling::tei:milestone[1][@xml:id eq $quote/m:source/@location-id]]
                    )
                }
                
            }
    }

let $xml-response := 
    common:response(
        'operations/quotes',
        'operations', (
            $request,
            $updates,
            $text,
            $quotes-with-responses
        )
    )
    
return

    (: return html data :)
    if($request/@resource-suffix eq 'html') then (
        common:html($xml-response, concat(local:app-path(), '/views/edit-quotes.xsl'))
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )
