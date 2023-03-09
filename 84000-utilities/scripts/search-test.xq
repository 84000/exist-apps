xquery version "3.1" encoding "UTF-8";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

declare option exist:serialize "method=xml indent=yes";

(: 
    Script for testing various language analysers.
    - Data is here:
      db/apps/84000-data/tests/search/test-strings.xml
    - Analyser config is here:
      db/system/config/db/apps/84000-data/tests/search/collection.xconf
    - Documentation on configuring full-text search is here:
      https://exist-db.84000-translate.org/exist/apps/doc/lucene
:)

declare variable $local:search-texts-collection := '/db/apps/84000-data/tests/search';
declare variable $local:search-texts-file := concat($local:search-texts-collection, '/tests.xml');
declare variable $local:search-texts-data := doc($local:search-texts-file);
declare variable $local:lang-map := map { 'Sa-Ltn':'sa', 'bo':'bo', 'en':'en' };

declare function local:reindex-search-tests() {
    xmldb:reindex($local:search-texts-collection)
};

declare function local:search-tests() as element(eft:search-test)* {
    
    for $test in $local:search-texts-data//eft:test
    let $search := $test/eft:search[1]/data()
    let $hits := 
        $test/eft:content[ft:query(., concat('sa:(', $search, ')'), map { "fields": ("sa") })]
        | $test/eft:content[ft:query(., concat('bo:(', $search, ')'), map { "fields": ("bo") })]
        | $test/eft:content[ft:query(., concat('en:(', $search, ')'), map { "fields": ("en") })]
    
    let $misses := $test/eft:content[@expect eq 'hit'] except $hits
    
    return 
        element { QName('http://read.84000.co/ns/1.0', 'search-test') } {
            
            attribute search { $search },
            
            for $hit in $hits
            return
            element { if($hit[@expect eq 'hit']) then 'hit' else 'miss' } {
                $hit/@*,
                ft:highlight-field-matches($hit, map:get($local:lang-map, $hit/@xml:lang))/node()
            },
            
            for $miss in $misses
            return
            element miss {
                $miss/@*,
                $miss/node()
            }
            
        }
    
};

let $reindex := local:reindex-search-tests()
where $reindex
return
    local:search-tests()

