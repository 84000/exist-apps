xquery version "3.0" encoding "UTF-8";


import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tests="http://utilities.84000.co/tests" at "../modules/tests.xql";

declare namespace m="http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

let $lang := request:get-parameter('lang', 'sa-ltn')
let $action := request:get-parameter('action', '')
let $test-id := request:get-parameter('test-id', '')

let $action-result := 
    if($action eq 'add-test') then 
        tests:add-lucene-test($lang, request:get-parameter('test-string', ''))
    else if($action eq 'add-data') then
        tests:add-lucene-data($lang, request:get-parameter('data-string', ''))
    else if($action = ('should-match', 'should-not-match')) then
        tests:add-test-match($action eq 'should-match', $test-id, request:get-parameter('data-id', ''))
    else if($action eq 'reindex') then
        tests:reindex()
    else
        ()

return 
    common:response(
        'utilities/text-searches',
        'utilities',
        (
            local:request(),
            $action-result,
            tests:lucene-test-languages(),
            tests:lucene-lang-data($lang),
            tests:lucene-tests($lang)
        )
    )