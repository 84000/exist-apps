xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common="http://read.84000.co/common" at "../../../84000-reading-room/modules/common.xql";
import module namespace source="http://read.84000.co/source" at "../../../84000-reading-room/modules/source.xql";
import module namespace store="http://read.84000.co/store" at "../../../84000-reading-room/modules/store.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:exec-options := 
    <option>
        <workingDir>/{ $common:environment//eft:env-vars/eft:var[@id eq 'home']/text() }/</workingDir>
    </option>;

for $collection in ((:'kangyur', :)'tengyur')
let $work-id := if($collection eq 'tengyur') then $source:tengyur-work else $source:kangyur-work
let $source-data-path := source:etext-path($work-id)
let $volumes-tei := collection($source-data-path)//tei:TEI
return
    for $volume-number in 1 to count($volumes-tei)
    let $resource-id := string-join(($collection, 'vol', $volume-number), '-')
    let $source-url := concat($store:conf/@source-url, '/source/', $collection, '.json?volume=', $volume-number, '&amp;api-version=0.4.0')
    (:where $volume-number eq 1:)
    return (
        $source-url,
        store:http-download($source-url, '/db/apps/tibetan-source/json', concat($resource-id, '.json'), $store:permissions-group),
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
)