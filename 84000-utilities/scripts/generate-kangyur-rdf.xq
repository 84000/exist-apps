xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translation-status="http://read.84000.co/translation-status" at "../../84000-operations/modules/translation-status.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

(:  NOTE: 
    - To run switch environment store-conf/@type to master
    - Remove nodes in 84000-data/rdf/file-versions for each file to be created
      OR comment out where clause to do all
:)

let $work := $source:ekangyur-work
let $teis := translations:work-tei($work)
let $kangyur-toh-keys := $teis//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work eq 'UT4CZ5369']/@key
let $text-refs := doc(concat($common:data-path, '/operations/text-refs.xml'))
let $rdf-file-versions := doc(concat($common:data-path, '/rdf/file-versions.xml'))
let $rdf-collection := collection(concat($common:data-path, '/rdf'))

return (
    concat('Count tohs: ', count($kangyur-toh-keys)),
    concat('Count rdf files: ', count($rdf-collection//rdf:RDF)),
    concat('Count rdf version elements: ', count($rdf-file-versions//m:file-version)),
    (:concat('Missing rdf files: ', string-join($kangyur-toh-keys[not(concat(., '.rdf') = $rdf-file-versions//m:file-version/@file-name)], ', ')),:)
    '------------------------------------------------',
    (# exist:batch-transaction #) {
        for $toh-key at $position in $kangyur-toh-keys(:[. eq 'toh1-1']:)
            (:let $text-ref := $text-refs//m:text[@key eq $tei-toh-key]:)
            let $file-name := concat($toh-key, '.rdf')
            let $file-path := concat($common:data-path, '/rdf/', $file-name)
            let $tei := $teis[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq $toh-key]]
            let $tei-version-str := translation:version-str($tei)
            let $rdf-version-str := $rdf-file-versions//m:file-version[@file-name eq $file-name]/@version
            where not($rdf-version-str) or not(translation-status:is-current-version($tei-version-str, $rdf-version-str))
            order by $toh-key
        return 
            string-join((
                xs:string($toh-key),
                xs:string($file-name),
                xs:string($tei-version-str),
                xs:string($rdf-version-str),
                store:store-new-rdf($file-path, $tei-version-str)
            ), ' : ')
    }(::)
)