xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace functx="http://www.functx.com";

declare variable $sponsors := doc('/db/apps/84000-data/entities/sponsors.xml');
declare variable $translation-status := doc('/db/apps/84000-data/operations/translation-status.xml');

let $migrate-sponsors := 
    for $sponsor in $sponsors//m:sponsor[@type]
    return
        update replace $sponsor with
            element { QName("http://read.84000.co/ns/1.0", 'sponsor')} {
                $sponsor/@xml:id,
                $sponsor/node(),
                element type {
                    attribute id { $sponsor/@type }
                }
            }

let $migrate-text-notes := 
    xmldb:store(
        '/db/apps/84000-data/operations/', 
        'translation-status.xml', 
        functx:change-element-names-deep($translation-status, QName('http://read.84000.co/ns/1.0', 'notes'), QName('http://read.84000.co/ns/1.0', 'progress-note'))
    )
    
return
    'Migrated to 1.13.0'