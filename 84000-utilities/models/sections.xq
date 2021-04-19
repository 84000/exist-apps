xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace section="http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $sections-structure := doc(concat($common:data-path, '/config/tests/sections-structure.xml'))
let $structure-source-ids := $sections-structure//m:text/@source-id/string()
let $store-conf := $common:environment/m:store-conf

let $resolve-issues :=
    if($store-conf[@type eq 'client'][m:translations-master-host] and common:user-name() eq 'admin') then
        if(request:get-parameter('resolve', '') eq 'unmatched-ids') then
        
            (: Get source-ids that don't have a matching TEI file :)
            let $tei-source-ids := collection($common:tei-path)//tei:TEI//tei:idno/@source-id/string()
            let $structure-source-ids-unmatched := $structure-source-ids[not(. = $tei-source-ids)]
            let $master-downloads-data := store:master-downloads-data(xs:anyURI(concat($store-conf/m:translations-master-host, '/downloads.xml?source-ids=', string-join($structure-source-ids-unmatched, ','))))
            for $master-download-text in $master-downloads-data/m:text
            (: Get text-ids from master :)
            let $text-id := $master-download-text/@id
            let $store-url := concat($store-conf/m:translations-master-host, '/translation/', $text-id, '.tei')
            let $target-collection := concat($common:translations-path, '/unsorted')
            (: Download tei from the master :)
            return (
                (:<http-download text-id="{ $text-id }" source="{ $store-url }" target="{ $target-collection }" file-name="{ $master-download-text/@file-name }"/>,:)
                store:http-download($store-url, $target-collection, $master-download-text/@file-name, 'tei')
            )
            
        else if(request:get-parameter('resolve', '') eq 'unmatched-tei') then
        
            (: Get text-ids with a source-id not in the validation :)
            for $tei in collection($common:tei-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:idno/@source-id[not(string() = $structure-source-ids)]]]
            let $source-id := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno/@source-id/string()
            let $text-id := tei-content:id($tei)
            let $store-file-name := concat($text-id, '.tei')
            (: Download them from the master :)
            return (
                (:<download-master source-id="{ $source-id }" text-id="{ $text-id }">{ $store-file-name }</download-master>,:)
                store:download-master($store-file-name, $store-conf/m:translations-master-host, false())
            )
            
        else ()
    else()

return
  common:response(
      'utilities/sections',
      'utilities',
      (
          utilities:request(),
          section:child-sections(tei-content:tei('lobby', 'section'), true(), 'none'),
          tests:structure(),
          <resolve-issues count-structure-source-ids="{ count($structure-source-ids) }">
          {
            $resolve-issues
          }
          </resolve-issues>
      )
  )
