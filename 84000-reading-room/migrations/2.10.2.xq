declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../modules/common.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

declare variable $operations-collection := '/db/apps/84000-data/operations';
declare variable $filename-new := 'entities-2-10-2.xml';

declare function local:copy-element($element as element(), $exclude as xs:string*, $indent as xs:integer) {
    if(not(local-name($element) = $exclude)) then (
        element { QName(fn:namespace-uri($element), node-name($element)) } {
            $element/@*,
            let $element-has-content := if($element/*[not(local-name(.) = $exclude)] or $element/text()[normalize-space(.)]) then true() else false()
            where $element-has-content
            return
                for $node in $element/node()
                return 
                    if($node instance of element()) then
                        local:copy-element($node, $exclude, $indent + 1)
                    else 
                        $node
        }
    )
    else ()
};

declare function local:clear-flags() {
    
    let $entities-migrated := 
        element { QName('http://read.84000.co/ns/1.0', 'entities') } {
            for $entity at $index in $entities:entities//m:entity
            return (
                common:ws(1),
                local:copy-element($entity, 'flag', 1)
            ),
            common:ws(0)
        }
    
    return (
        (:$entities-migrated:)
        xmldb:store(
            $operations-collection,
            $filename-new,
            $entities-migrated
        ),
        (: Set permissions :)
        (
            sm:chown(xs:anyURI(concat($operations-collection, '/', $filename-new)), 'admin'),
            sm:chgrp(xs:anyURI(concat($operations-collection, '/', $filename-new)), 'operations'),
            sm:chmod(xs:anyURI(concat($operations-collection, '/', $filename-new)), 'rw-rw-r--')
        )
        
    )
};

local:clear-flags()
