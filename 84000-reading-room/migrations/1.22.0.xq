xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../modules/sponsorship.xql";

declare variable $local:tei := collection($common:translations-path);

(: 
    Sponsorship information about texts is being moved out of the TEI into projects
:)

(: Loop through texts with sponsor status :)
let $projects-data := 
    <sponsorship xmlns="http://read.84000.co/ns/1.0">
    {
        for $tei in $local:tei//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/@sponsored]
            let $text-id := tei-content:id($tei)
            
        return
            (: Add a project node to the projects data :)
            element { QName('http://read.84000.co/ns/1.0', 'project') } {
                attribute id { $text-id },
                element { 'text' } {
                    attribute text-id { $text-id }
                },
                (: Set the sponsorship status :)
                sponsorship:cost-estimate($tei)
            }
            
    }
    </sponsorship>

(: Create the projects file :)
let $create-projects-file := xmldb:store(concat($common:data-path, '/operations'), 'sponsorship.xml', $projects-data)

(: Set permissions :)
let $file-uri := concat($common:data-path, '/operations/', 'sponsorship.xml')
let $set-permissions := 
    (
        sm:chown($file-uri, 'admin'),
        sm:chgrp($file-uri, 'operations'),
        sm:chmod($file-uri, 'rw-rw-r--')
    )

return
    'Migrated to 1.22.0'