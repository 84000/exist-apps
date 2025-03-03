xquery version "3.0" encoding "UTF-8";

import module namespace deploy="http://read.84000.co/deploy" at "/db/apps/84000-reading-room/modules/deploy.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "/db/apps/84000-reading-room/modules/translations.xql";
import module namespace webflow-api="http://read.84000.co/webflow-api" at "/db/apps/84000-operations/modules/webflow-api.xql";
(:import module namespace store="http://read.84000.co/store" at "/db/apps/84000-reading-room/modules/store.xql";:)
(:import module namespace functx="http://www.functx.com";:)

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace webflow="http://read.84000.co/webflow-api";

let $commit-msg := concat('Nightly publication: ', format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01] [H01]:[m01]'))
let $scheduled-jobs := scheduler:get-scheduled-jobs()/scheduler:jobs/scheduler:group[@name = ( 'eXist.User', 'eXist.System')]/scheduler:job
(:let $reserved-dateTime := current-dateTime() + xs:dayTimeDuration('PT30M')
let $conflicting-jobs := $scheduled-jobs[not(scheduler:trigger/state/text() eq 'COMPLETE')][scheduler:trigger/next ! xs:dateTime(text()) lt $reserved-dateTime]:)
let $conflicting-jobs := $scheduled-jobs[matches(@name, '^store\-publication\-files')][not(scheduler:trigger/state/text() eq 'COMPLETE')]

where not($conflicting-jobs)
return (
    
    (: Push updates :)
    deploy:push('data-static', (), $commit-msg, ()),
    deploy:push('data-rdf', (), $commit-msg, ()),
    deploy:push('data-json', (), $commit-msg, ()),
    
    (: Update webflow api :)
    (: Get texts with a new version :)
    let $filtered-texts := translations:filtered-texts('all', (), '', '', '', 'published-files-version', '', '', 'text', '', '')
    
    (: Check the api-call is out of date :)
    for $filtered-text in $filtered-texts/eft:text[eft:api-status/eft:api-call[@group eq 'translation'][@publish eq 'true']]
    let $tei := tei-content:tei($filtered-text/@id, 'translation')
    
    (: Check the files are not out of date :)
    let $translation-files := translation:files($tei, ('translation-html', 'translation-files', 'publications-list'), ())
    where count($translation-files/eft:file) eq count($translation-files/eft:file[@up-to-date])
    
    (: Update Webflow :)
    return (
        
        (:$translation-files:)
        (:$filtered-text/@id, :)
        webflow:translation-updates($tei)
    
    )
    
    (:
    (\: Triage texts where file-versions are up-to-date but the webflow version isn't :\)
    let $webflow-item-candidates := $webflow:conf//webflow:collection[@id eq "texts"]/webflow:item[@webflow-id gt '']
    let $webflow-item-candidates := for $webflow-item in $webflow-item-candidates
        let $webflow-version := $webflow-item/@version
        let $file-name-regex := concat('^', functx:escape-for-regex($webflow-item/@id), '\.')
        let $file-versions := $store:file-versions//eft:file-version[matches(@file-name, $file-name-regex, 'i')]
        let $file-versions-distinct := distinct-values($file-versions/@version)[. gt '']
        where count($file-versions-distinct) eq 1 and not($file-versions-distinct eq $webflow-version)
        return
            $webflow-item
        
    for $webflow-item in $webflow-item-candidates
    let $tei := tei-content:tei($webflow-item/@id, 'translation')
    let $text-id := tei-content:id($tei)
    group by $text-id
    return (
        concat('Checking: ', $text-id),
        (\: Check the api needs updating :\)
        let $api-status := translation:api-status($tei)
        where $api-status/eft:api-call[@group eq 'translation'][not(@up-to-date)]
        return
            (\: Check the files are up-to-date :\)
            let $translation-files := translation:files($tei[1], ('translation-html','translation-files'), ())
            where count($translation-files) eq count($translation-files[@up-to-date])
            return
                $webflow-item
                (\:webflow:translation-updates($tei[1]):\)
            
    ):)

)