xquery version "3.0" encoding "UTF-8";

import module namespace deploy="http://read.84000.co/deploy" at "/db/apps/84000-reading-room/modules/deploy.xql";

let $commit-msg := concat('Nightly publication: ', format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01] [H01]:[m01]'))
let $scheduled-jobs := scheduler:get-scheduled-jobs()/scheduler:jobs/scheduler:group[@name = ( 'eXist.User', 'eXist.System')]/scheduler:job
(:let $reserved-dateTime := current-dateTime() + xs:dayTimeDuration('PT30M')
let $conflicting-jobs := $scheduled-jobs[not(scheduler:trigger/state/text() eq 'COMPLETE')][scheduler:trigger/next ! xs:dateTime(text()) lt $reserved-dateTime]:)
let $conflicting-jobs := $scheduled-jobs[matches(@name, '^store\-publication\-files')][not(scheduler:trigger/state/text() eq 'COMPLETE')]

where not($conflicting-jobs)
return (
    deploy:push('data-static', (), $commit-msg, ()),
    deploy:push('data-rdf', (), $commit-msg, ()),
    deploy:push('data-json', (), $commit-msg, ())
)