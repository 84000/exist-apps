xquery version "3.0";

module namespace helper="http://operations.84000.co/helper";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace pkg="http://expath.org/ns/pkg";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "../modules/update-tm.xql";

declare function helper:app-path() as xs:string {

    let $servlet-path := system:get-module-load-path()
    let $tokens := tokenize($servlet-path, '/')
    return 
        string-join(subsequence($tokens, 1, count($tokens) - 1), '/')
    
};

declare function helper:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function helper:get-status-parameter() as xs:string* {
    let $post-status := request:get-parameter('status[]', '')
    let $get-status := tokenize(request:get-parameter('status', ''), ',')
    return
        if (count($get-status) gt 0) then
            $get-status
        else
            $post-status
};

declare function helper:async-script($script-name as xs:string, $parameters as element(parameters)?) {
    helper:async-script($script-name, $script-name, $parameters)
};

declare function helper:async-script($script-name as xs:string, $job-name as xs:string, $parameters as element(parameters)?) {
    
    (: Clear job if completed :)
    let $clear-complete-job :=
        if(scheduler:get-scheduled-jobs()//scheduler:job[@name eq $job-name][scheduler:trigger/state/text() eq 'COMPLETE']) then
            scheduler:delete-scheduled-job($job-name)
        else ()
    
    (: Only schedule if not already there :)
    where not(scheduler:get-scheduled-jobs()//scheduler:job[@name eq $job-name])
    return (
        (: Log so we can monitor :)
        util:log('info', concat('async-script:', $job-name)),
        
        (: Schedule a one-off job :)
        scheduler:schedule-xquery-periodic-job(
            concat('/db/apps/84000-operations/scripts/', $script-name, '.xq'),
            10000,
            $job-name,
            $parameters,
            5000,
            0,
            true()
        )
        
    )
};

declare function helper:root-html($resource-id as xs:string, $part-id as xs:string, $commentary-key as xs:string) {
    
    let $request :=
        element { QName('http://read.84000.co/ns/1.0', 'request')} {
            attribute model { 'translation' },
            attribute resource-id { $resource-id },
            attribute resource-suffix { 'html' },
            attribute lang { 'en' },
            attribute doc-type { 'html' },
            attribute part { $part-id },
            attribute commentary { $commentary-key },
            attribute view-mode { 'passage' },
            attribute archive-path { '' },
            $translation:view-modes/m:view-mode[@id eq 'passage']
        }
    
    let $tei := tei-content:tei($resource-id, 'translation')
    let $source := tei-content:source($tei, $resource-id)
    let $passage :=  translation:passage($tei, $part-id, $translation:view-modes/m:view-mode[@id eq 'passage'])
    let $outline := translation:outline-cached($tei)
    let $parts := translation:merge-parts($outline/m:pre-processed[@type eq 'parts'], $passage)
    
    let $translation-data :=
        element { QName('http://read.84000.co/ns/1.0', 'translation') } {
            
            attribute id { tei-content:id($tei) },
            attribute status { tei-content:publication-status($tei) },
            attribute status-group { tei-content:publication-status-group($tei) },
            attribute canonical-html { translation:canonical-html($source/@key, $request/@part[. gt ''], $request/@commentary[. gt '']) },
            
            translation:titles($tei, $source/@key),
            $source,
            translation:toh($tei, $source/@key),
            tei-content:ancestors($tei, $source/@key, 1),
            $parts
            
        }
    
    let $outlines-related := translation:outlines-related($tei, $parts, $commentary-key)
    
    let $glossary-cached-locations := glossary:cached-locations($tei, (), false())
    
    let $strings := translation:replace-text($source/@key)
    
    let $xml-response :=
        common:response(
            $request/@model, 
            $common:app-id,
            (
                $request,
                $translation-data,
                $outline,
                $outlines-related,
                $glossary-cached-locations,
                $strings
            )
        )
    
    let $html := 
        transform:transform(
            $xml-response,
            doc(concat($common:app-path, "/views/html/translation.xsl")), 
            <parameters/>
        )
    
    return (
        element { QName('http://read.84000.co/ns/1.0', 'tei') } {
            attribute resource-id { $resource-id },
            attribute part-id { $part-id },
            $passage
        },
        element { QName('http://read.84000.co/ns/1.0', 'html') } {
            attribute resource-id { $resource-id },
            attribute part-id { $part-id },
            $html//xhtml:*[@id eq $part-id]
        }
    )
    
};

(: Fix mime type / necessary in eXist 5 :)
declare function helper:fix-tm-mimetypes() {
    for $file in xmldb:get-child-resources($update-tm:tm-path)
    where 
        ends-with($file, '.tmx')
        and not(xmldb:get-mime-type(xs:anyURI(concat($update-tm:tm-path, '/', $file))) eq 'application/xml')

    let $content :=
        if(util:is-binary-doc(concat($update-tm:tm-path, '/', $file))) then
            util:binary-to-string(util:binary-doc(concat($update-tm:tm-path, '/', $file)))
        else 
            doc(concat($update-tm:tm-path, '/', $file))
    return
        xmldb:store($update-tm:tm-path, $file, $content, 'application/xml')
};
