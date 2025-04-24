xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace store = "http://read.84000.co/store" at "/db/apps/84000-reading-room/modules/store.xql";
import module namespace json-helpers = "http://read.84000.co/json-helpers/0.5.0" at '/db/apps/84000-reading-room/views/json/0.5.0/common/helpers.xql';
(: 
    
    1. Confirm output directory '/db/apps/84000-data/migration'
    2. Run this script
    3. Search output for any content flagged as 'unknown:' or 'error:'
    4. Fix issues, delete any files that should be replaced, re-run script
    5. Sync to file server and commit to Github

:)

declare variable $local:static-paths := map {
    '/rest/authorities.json':                                               'authorities.json',
    '/rest/authorities-annotations.json':                                   'authorities-annotations.json',
    '/rest/authorities-classifications.json':                               'authorities-classifications.json',
    '/rest/authorities-relations.json':                                     'authorities-relations.json',
    '/rest/creators.json':                                                  'creators.json',
    '/rest/names.json':                                                     'names.json',
    '/rest/catalogue.json?section-id=O1JC11494&amp;content=sections':       'kangyur-catalog.json',
    '/rest/catalogue.json?section-id=O1JC11494&amp;content=control-data':   'kangyur-control-data.json',
    '/rest/catalogue.json?section-id=O1JC11494&amp;content=works':          'kangyur-works.json',
    '/rest/catalogue.json?section-id=O1JC7630&amp;content=sections':        'tengyur-catalog.json',
    '/rest/catalogue.json?section-id=O1JC7630&amp;content=control-data':    'tengyur-control-data.json',
    '/rest/catalogue.json?section-id=O1JC7630&amp;content=works':           'tengyur-works.json',
    '/rest/works-annotations.json':                                         'works-annotations.json',
    '/rest/works-relations.json':                                           'works-relations.json',
    '/rest/classifications.json':                                           'classifications.json',
    '/rest/types.json':                                                     'types.json',
    '/rest/translation-projects.json':                                      'translation-projects.json'
};

declare variable $local:exec-options := 
    <option>
        <workingDir>/{ $common:environment//eft:env-vars/eft:var[@id eq 'home']/text() }/</workingDir>
    </option>;
    
declare function local:store($source-path as xs:string, $target-file as xs:string) {
    
    let $target-file-path := string-join(('/db/apps/84000-data/migration', $target-file), '/')
    let $source-path := concat($source-path, if(contains($source-path, '?')) then '&amp;' else '?', 'store=store')
    where not(util:binary-doc-available($target-file-path))
    let $get-file := json-helpers:get($source-path)
    return (
        $source-path  || ' -> ' || $target-file,
        process:execute(('sleep', '0.5'), $local:exec-options) ! ()
    )
    
};

(:local:store('/rest/translation.json?id=UT23703-001-001', 'UT23703-001-001.json')
,:)

for $source-path in map:keys($local:static-paths)
return
    local:store($source-path, $local:static-paths($source-path))
,

for $tei in subsequence($tei-content:translations-collection//tei:TEI, 1, 3)
let $text-id := tei-content:id($tei)
let $target-file := concat($text-id, '.json')
return
    local:store(concat('/rest/translation.json?id=', $text-id), concat($text-id, '.json'))

