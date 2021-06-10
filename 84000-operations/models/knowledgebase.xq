xquery version "3.0" encoding "UTF-8";

import module namespace local="http://operations.84000.co/local" at "../modules/local.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $form-action := request:get-parameter('form-action', '')
let $new-kb-title := request:get-parameter('new-kb-title', '')

let $add-article :=
    if($form-action eq 'new-kb-article' and $new-kb-title gt '') then
    
        let $filename := concat(replace(knowledgebase:id($new-kb-title), '\-', '_'), '.xml')
        let $new-tei := knowledgebase:new-tei($new-kb-title)
        let $text-id := tei-content:id($new-tei/tei:TEI)
        
        where $filename and $new-tei and $text-id
        return 
            (:if(true())then $text-id else:)
            (: Create the file :)
            let $store := xmldb:store($common:knowledgebase-path, $filename, $new-tei, 'application/xml')
            let $set-grp := sm:chgrp(xs:anyURI(concat($common:knowledgebase-path, '/', $filename)), 'tei')
            let $set-mod := sm:chmod(xs:anyURI(concat($common:knowledgebase-path, '/', $filename)), 'rw-rw-r--')
            
            (: Touch it with a new update :)
            let $tei := tei-content:tei($text-id, 'knowledgebase')
            return (
                (:$tei//tei:publicationStmt,:)
                update-tei:minor-version-increment($tei, 'file-created')
            )
        
    else ()
    
return
    common:response(
        'operations/knowledgebase', 
        'operations', 
        (
            (: Include request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request') } {},
            
            (: Details of updates :)
            element { QName('http://read.84000.co/ns/1.0', 'updates') } {
                $add-article
            },
            
            (: Knowledge Base pages :)
            knowledgebase:pages()
            
        )
    )