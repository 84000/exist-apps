xquery version "3.0";

module namespace file-upload="http://operations.84000.co/file-upload";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translation-status="http://operations.84000.co/translation-status" at "../modules/translation-status.xql";
import module namespace functx="http://www.functx.com";

declare namespace m="http://read.84000.co/ns/1.0";

declare variable $file-upload:app-user-group as xs:string := "operations";
declare variable $file-upload:app-user as xs:string := "84000-import";
declare variable $file-upload:word-converter as xs:anyURI := xs:anyURI("https://oxgarage2.tei-c.org/ege-webservice/Conversions/docx%3Aapplication%3Avnd.openxmlformats-officedocument.wordprocessingml.document/TEI%3Atext%3Axml/");
declare variable $file-upload:xslx-converter as xs:anyURI := xs:anyURI("https://oxgarage2.tei-c.org/ege-webservice/Conversions/xlsx%3Aapplication%3Avnd.openxmlformats-officedocument.spreadsheetml.sheet/TEI%3Atext%3Axml/");
declare variable $file-upload:document-stylesheet as xs:string := string-join(($common:import-data-path, 'xsl', 'oxGto84000.xsl'), '/');
declare variable $file-upload:spreadsheet-stylesheet as xs:string := string-join(($common:import-data-path, 'xsl', 'oxGto84000-gloss.xsl'), '/');

declare function file-upload:download-file-path() as xs:string {
    let $text-id := upper-case(request:get-parameter('text-id', ''))
    let $submission-id := lower-case(request:get-parameter('submission-id', ''))
    let $files-collection := concat($common:import-data-collection, '/', $text-id)
    let $text := translation-status:texts($text-id)
    let $submissions := translation-status:submissions($text)
    let $file-name := $submissions[@id eq $submission-id]/@file-name
    return
        if($file-name) then
            concat($files-collection, '/', xmldb:encode($file-name))
        else
            ''
};

declare function file-upload:unique-file-name($submissions as element()*, $file-name as xs:string) as xs:string {
    
    let $file-name-normalized := translation-status:file-name-normalized($file-name)
    
    return
        (: See if it's taken :)
        if($submissions[@id = $file-name-normalized]) then
            (: It's taken so try to make a new file name :)
            let $file-name-tokenized := tokenize($file-name-normalized, '\.')
            let $file-name-suffix := $file-name-tokenized[last()]
            let $file-name-without-suffix := string-join(subsequence($file-name-tokenized, 1, count($file-name-tokenized)-1), '.')
            (: Look for numbers in square brackets :)
            let $increment-matches := functx:get-matches($file-name-without-suffix, '\[\d+\]')
            (: Get the last one :)
            let $current-increment := 
                if(count($increment-matches) gt 0 and functx:is-a-number(replace($increment-matches[last()], '\D', ''))) then
                    xs:integer(replace($increment-matches[last()], '\D', ''))
                else
                    ()
            (: replace the current number with the next number :)
            let $new-file-stem := 
                if($current-increment) then
                    replace($file-name-without-suffix, concat('\[', xs:string($current-increment),'\]'), concat('[', xs:string($current-increment + 1),']'))
                else
                    concat($file-name-without-suffix, '[1]')
            (: re-compile the file name :)
            let $new-file-name := concat($new-file-stem, '.', $file-name-suffix)
            return
                (: See if this one is taken :)
                file-upload:unique-file-name($submissions, $new-file-name)
        else
            (: It's not taken :)
            $file-name-normalized
};

declare function file-upload:process-upload($text-id as xs:string) as element()? {
    
    if('submit-translation-file' = request:get-parameter-names()) then
    
        let $upload-name as xs:string := request:get-uploaded-file-name('submit-translation-file')
        let $upload-size as xs:double := request:get-uploaded-file-size('submit-translation-file')
        
        (: Check this file name doesn't exist. If so force a new one. :)
        let $text := translation-status:texts($text-id)
        let $submissions := translation-status:submissions($text)
        let $submission-id := translation-status:file-name-normalized(file-upload:unique-file-name($submissions, $upload-name))
        let $upload-name-unique as xs:string := xmldb:encode($submission-id)
        
        (: Check the text-id has an upload directory. If not create one and set permissions :)
        let $upload-directory as xs:string := concat($common:import-data-path, '/', upper-case($text-id))
        let $collection-exists := 
            if (not(xmldb:collection-available($upload-directory))) then
            (
                xmldb:create-collection($common:import-data-path, upper-case($text-id)),
    		    sm:chgrp(xs:anyURI($upload-directory), $file-upload:app-user-group),
    		    sm:chmod(xs:anyURI($upload-directory), 'rwxrwxr--')
    		)
            else
                ()
        
        (: Store file and set permissions :)
        let $stored-file := 
        (
            xmldb:store-as-binary(
                $upload-directory, 
                $upload-name-unique, 
                request:get-uploaded-file-data('submit-translation-file')
            ),
            sm:chgrp(xs:anyURI(concat($upload-directory, '/', $upload-name-unique)), $file-upload:app-user-group),
            sm:chmod(xs:anyURI(concat($upload-directory, '/', $upload-name-unique)), 'rw-rw-r--')
        )
        
        (: Register the upload in the translation status :)
        (: Setting this attribute will trigger the update when translation-status:update() is called in edit-text-header.xq :)
        let $set-submission-id-attribute := request:set-attribute('submission-id', $submission-id)
        
        return 
            <updated xmlns="http://read.84000.co/ns/1.0" update="upload-file" file-upload="{ $upload-name-unique }" directory="{ $upload-directory }" />
    else
        ()

};

declare function file-upload:delete-file($text-id as xs:string, $submission-id as xs:string) as element()? {
    
    let $submission := translation-status:submission($text-id, $submission-id)
    
    return
        if($submission) then
        
            (: Delete the TEI :)
            let $remove-tei := 
                if($submission/m:tei-file/@file-name gt '' and $submission/m:tei-file/@file-exists eq 'true') then
                    xmldb:remove($submission/@file-collection, xmldb:encode($submission/m:tei-file/@file-name))
                else
                    ()
            
            (: Delete the file :)
            let $remove-file := xmldb:remove($submission/@file-collection, xmldb:encode($submission/@file-name))
            
            return
                <updated xmlns="http://read.84000.co/ns/1.0" update="delete-file" file-deleted="{ $submission/@file-name }" directory="{ $submission/@file-collection }" />
     else
        ()
};

declare function file-upload:generate-tei($text-id as xs:string, $submission-id as xs:string) as element()? {

    if(request:get-parameter('checklist[]', '') = 'generate-tei') then
    
        let $submission := translation-status:submission($text-id, $submission-id)
        
        return
            if($submission/m:tei-file/@file-name gt '' and $submission/m:tei-file/@file-exists eq 'false' and $submission/@file-type = ('spreadsheet', 'document')) then
                
                let $tei-from-conversion := 
                    if($common:environment//m:conversion-conf) then
                        file-upload:conversion-local($submission)
                    else
                        file-upload:conversion-webservice($submission)
                
                return 
                    if($tei-from-conversion) then
                        
                        let $xslt :=
                            if($submission/@file-type eq 'spreadsheet') then
                                doc($file-upload:spreadsheet-stylesheet)
                            else
                                doc($file-upload:document-stylesheet)
                        
                        let $tei-from-transform as item() := transform:transform($tei-from-conversion, $xslt, ())
                        
                        let $store-tei := xmldb:store($submission/@file-collection, xmldb:encode($submission/m:tei-file/@file-name), $tei-from-transform)
                        
                        let $set-permissions :=
                            (
                                sm:chown(xs:anyURI(concat($submission/@file-collection, '/', xmldb:encode($submission/m:tei-file/@file-name))), $file-upload:app-user),
                                sm:chgrp(xs:anyURI(concat($submission/@file-collection, '/', xmldb:encode($submission/m:tei-file/@file-name))), $file-upload:app-user-group),
                                sm:chmod(xs:anyURI(concat($submission/@file-collection, '/', xmldb:encode($submission/m:tei-file/@file-name))), 'rw-rw-r--')
                            )
                        
                        return 
                            <updated xmlns="http://read.84000.co/ns/1.0" update="generate-file" tei-generated="{ $submission/m:tei-file/@file-name }" directory="{ $submission/@file-collection }"/>
                    else
                        ()
            else
                ()
    else
        ()
};

declare function file-upload:conversion-local($submission as element()) as node() {

    (: Sync this file to the file system :)
    let $sync-path := concat('/', $common:environment//m:conversion-conf/m:sync-path, '/', $submission/@text-id)
    let $sync := 
        file:sync(
            $submission/@file-collection, 
            $sync-path, 
            ()
        )
   
    (: Execute conversion :)
    let $script-path :=
        if($submission/@file-type eq 'spreadsheet') then 
            concat('/', $common:environment//m:conversion-conf/m:tei-stylsheets-path, '/bin/xlsxtotei')
        else
            concat('/', $common:environment//m:conversion-conf/m:tei-stylsheets-path, '/bin/docxtotei')
    
    let $convert :=
        process:execute(
            (
                $script-path, 
                concat($sync-path, '/', encode-for-uri($submission/@file-name)), 
                concat($sync-path, '/', encode-for-uri($submission/m:tei-file/@file-name))
            ),
            ()
        )
    
    (: Return file contents :)
    return
        parse-xml(file:read(concat($sync-path, '/', encode-for-uri($submission/m:tei-file/@file-name))))
};

declare function file-upload:conversion-webservice($submission as element()) as item()? {
    
    let $stored-file := util:binary-doc(concat($submission/@file-collection, '/', xmldb:encode-uri($submission/@file-name)))
    
    let $endpoint := 
        if($submission/@file-type eq 'spreadsheet') then 
            $file-upload:xslx-converter 
        else 
            $file-upload:word-converter
    
    let $request := 
        <hc:request 
            method="post" 
            href="{ $endpoint }" 
            override-media-type="application/xml">
            <hc:multipart media-type="multipart/form-data" boundary="existdb">
              <hc:header name="Accept" value="application/xml"/>
              <hc:header name="Cache-Control" value="no-cache" />
              <hc:header name="Content-Disposition" value="form-data; name=upload; filename={ $submission/@file-name }"/>
              <hc:body media-type="application/vnd.openxmlformats-officedocument.wordprocessingml.document">
                   { $stored-file }
              </hc:body>
            </hc:multipart>
        </hc:request>
    
    let $response := hc:send-request($request)
    let $response-headers := $response[1]
    let $response-tei as item() := $response[2]
    
    return
        $response-tei
        
};