xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";

(:
    From now we will assume that all additional data is operations data 
    and is set in the operations app but can be read by all (reading-room)
:)

let $move-files :=
    for $file in collection(concat($common:data-path, '/entities')) ! tokenize(document-uri(.), '/')[last()]
    return
        xmldb:move(concat($common:data-path, '/entities'), concat($common:data-path, '/operations'), $file)

let $delete-folder :=
    if(not(collection(concat($common:data-path, '/entities'))) and xmldb:collection-available(concat($common:data-path, '/entities'))) then
        xmldb:remove(concat($common:data-path, '/entities'))
    else
        ()

let $set-permissions :=
    for $file in collection(concat($common:data-path, '/operations')) ! tokenize(document-uri(.), '/')[last()]
        let $file-uri := concat($common:data-path, '/operations/', $file)
        let $group := 
            if($file = ('sections-structure.xml')) then
                'dba'
            else
                'operations'
                
        let $group-ace :=
            if($file = ('translation-status.xml')) then
                'utilities'
            else
                ''
    return
        (
            sm:chown($file-uri, 'admin'),
            sm:chgrp($file-uri, $group),
            sm:chmod($file-uri, 'rw-rw-r--'),
            if($group-ace gt '') then
                sm:add-group-ace($file-uri, $group-ace, true(), 'rw-')
            else
                ()
        )
        
return
    'Migrated to 1.21.0'