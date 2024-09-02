xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace store = "http://read.84000.co/store" at "../../modules/store.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";

declare variable $resource-id := request:get-parameter('resource-id', '');
declare variable $resource-requested := request:get-parameter('resource-requested', '') ! lower-case(.) ! replace(., '[^a-zA-Z0-9\-_\.]', '');
declare variable $pdf-config := $store:conf/eft:pdfs;

declare function local:generate-pdf($source-key as xs:string) as xs:base64Binary? {

    let $options := 
        <options>
            <workingDir>/{ $pdf-config/eft:sync-path/text() }</workingDir>
            <environment>
                <env name="PATH" value="/{ $pdf-config/eft:path/text() }"/>
                <env name="HOME" value="/{ $pdf-config/eft:home/text() }"/>
            </environment>
        </options>
    
    (: Use node/puppeteer to generate PDF :)
    let $generate-pdf := process:execute(('node', 'generatePDF.js', $source-key), $options)
    
    return 
        file:read-binary(xs:anyURI(concat('file:///', $pdf-config/eft:sync-path/text(), '/', $source-key, '.pdf')))  

};

let $tei := tei-content:tei($resource-id, 'translation')

where $tei

(: Force resource-id to source-key :)
let $source-key := tei-content:source-bibl($tei, $resource-id)/@key
let $translation-pdf := translation:files($tei, 'translation-files', $source-key)/eft:file[@type eq 'pdf']
let $file-path := string-join(($translation-pdf/@target-folder, $translation-pdf/@target-file), '/')

where $translation-pdf
return
    (: Generate latest pdf :)
    if(
        (: Master database :)
        $pdf-config
        (: Authorised user :)
        (:and common:user-in-group('operations'):)
        and sm:id()
    ) then
        let $pdf := local:generate-pdf($source-key)
        return
            response:stream-binary($pdf, 'application/pdf', $resource-requested)
    
    (: Return the latest file if there is one :)
    else if($translation-pdf/@timestamp gt '') then
        let $pdf := util:binary-doc($file-path)
        return
            response:stream-binary($pdf, 'application/pdf', $resource-requested)
            
    else 
        let $exception :=
            element { QName('http://read.84000.co/ns/1.0','exception') } {
                element path { '/db/apps/84000-reading-room/views/pdf/translation.xq' },
                element message { 'PDF not found (' || $file-path || ')'}
            }
        return
            common:html(common:response('error',common:app-id(), $exception), concat($common:app-path, '/views/html/error.xsl'))
