xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";


(: 
    Sponsorship information about texts is being moved out of the TEI into projects
:)

let $init-projects-data :=
<projects xmlns="http://read.84000.co/ns/1.0">
    <project id="toh487-488">
        <text text-id="UT22084-085-007"/>
        <text text-id="UT22084-085-008"/>
        <sponsorship status="available">
            <cost currency="USD" amount="50000"/>
        </sponsorship>
    </project>
    <project id="UT22084-077-010">
        <text text-id="UT22084-077-010"/>
        <sponsorship status="available">
            <cost currency="USD" amount="30000"/>
        </sponsorship>
        <sponsorship status="available">
            <cost currency="USD" amount="30000"/>
        </sponsorship>
    </project>
</projects>

(: Create the projects file :)
let $create-projects-file := xmldb:store(concat($common:data-path, '/operations'), 'projects.xml', $init-projects-data)

(: Set permissions :)
let $file-uri := concat($common:data-path, '/operations/', 'projects.xml')
let $set-permissions := 
    (
        sm:chown($file-uri, 'admin'),
        sm:chgrp($file-uri, 'operations'),
        sm:chmod($file-uri, 'rw-rw-r--')
    )

(: Loop through texts with sponsor status :)
(: Add a project node to the projects data :)
(: Set the sponsorship status :)
(: Remove the sponsorship status attribute from the TEI file :)

return
    'Migrated to 1.22.0'