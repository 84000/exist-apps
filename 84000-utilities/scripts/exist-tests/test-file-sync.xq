import module namespace sync-test="http://exist-db.org/xquery/test/file/sync" 
at "/db/apps/84000-utilities/scripts/exist-tests/sync.xqm";


(:sync-test:setup():)
file:sync(
    '/db/file-module-test',
    '/home/existdb/exist-sync/test-sync',
    map{ "prune": true(), "excludes": ("zip","xar",".git") }
)