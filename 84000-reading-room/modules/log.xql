xquery version "3.1" encoding "UTF-8";

module namespace log = "http://read.84000.co/log";

declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";

declare function local:parameters() as element()* {
    for $parameter in request:get-parameter-names()
    return 
        <parameter xmlns="http://read.84000.co/ns/1.0" name="{ $parameter }">
             { request:get-parameter($parameter, "") }
        </parameter>
};

declare function log:log-request($request as xs:string, $app as xs:string, $type as xs:string, $resource-id as xs:string, $resource-suffix as xs:string) as empty-sequence() {
    
    (: 
        Note: this only logs if the log file is present (available)
        To inhibit logging remove the log file.    
    :)
    
    let $logfile-name := "requests.xml"
    let $logfile-full := concat($common:log-path, '/', $logfile-name)
    
    where doc-available($logfile-full)
    return
        update insert
            <request xmlns="http://read.84000.co/ns/1.0" timestamp="{current-dateTime()}">
                <request>{$request}</request>
                <app>{$app}</app>
                <type>{$type}</type>
                <resource-id>{$resource-id}</resource-id>
                <resource-suffix>{$resource-suffix}</resource-suffix>
                <parameters>{local:parameters()}</parameters>
            </request>
        into doc($logfile-full)/m:log
};

declare function local:dateTimes($timestamps) as item()* {
    for $i in $timestamps 
    return 
        xs:dateTime($i)
};

declare function local:dateTimeStr($timestamp) as xs:string {
    format-dateTime($timestamp, '[D01]/[M01]/[Y0001] at [H01]:[m01]:[s01]')
};

declare function local:days-from-now($timestamp){
    current-dateTime() - $timestamp
};

declare function local:days-ago-str($duration) as xs:string {
    let $days := days-from-duration($duration)
    let $hours := hours-from-duration($duration)
    let $minutes := minutes-from-duration($duration)
    return 
        if ($days eq 1) then
            'Yesterday'
        else if ($days gt 1) then
            concat($days, ' days ago')
        else if($hours gt 3) then
            concat($hours, ' hours ago')
        else
            concat($minutes, ' minutes ago')
            
};

declare function log:requests($first-record as xs:double, $max-records as xs:double) as element() {
    
    let $grouped-requests :=
        for $request in collection($common:log-path)//m:request[m:request]
            group by $request-string := string($request/m:request)
            let $ts := $request/@timestamp
            let $max-ts := if($ts) then max(local:dateTimes($ts)) else ''
            order by $max-ts descending, count($request) descending
        return
            <grouped-request request-string="{ $request-string }">
                { 
                    $request
                }
            </grouped-request>
    
    return
        <requests 
            xmlns="http://read.84000.co/ns/1.0"
            first-record="{ $first-record }"
            max-records="{ $max-records }"
            count-records="{ count($grouped-requests) }">
        {
            
            for $grouped-request in subsequence($grouped-requests, $first-record, $max-records)
                let $count-request := count($grouped-request/m:request)
                let $ts := $grouped-request/m:request/@timestamp
                let $min-ts := if($ts) then min(local:dateTimes($ts)) else ''
                let $max-ts := if($ts) then max(local:dateTimes($ts)) else ''
                let $first-from-now := local:days-from-now($min-ts)
                let $latest-from-now := local:days-from-now($max-ts)
                
                return 
                    <request 
                        count="{ $count-request }" 
                        first="{ local:days-ago-str($first-from-now) }" 
                        latest="{ local:days-ago-str($latest-from-now) }">
                        { 
                            $grouped-request/@request-string
                        }
                    </request>
        }
       </requests>
};

declare function log:client-errors($first-record as xs:double, $max-records as xs:double) as element() {
    
    let $grouped-errors :=
        for $error in collection($common:log-path)//m:request[m:resource-id/text() eq 'log-error']
            group by $url := string($error/m:parameters/m:parameter[@name = 'url'])
            let $ts := $error/@timestamp
            let $max-ts := if($ts) then max(local:dateTimes($ts)) else ''
            order by $max-ts descending, count($error) descending
        return
            <grouped-error
                xmlns="http://read.84000.co/ns/1.0"
                request-string="{ $url }">
                { 
                    $error
                }
            </grouped-error>
    
    return
        (:$grouped-errors:)
        <errors
            xmlns="http://read.84000.co/ns/1.0"
            first-record="{ $first-record }"
            max-records="{ $max-records }"
            count-records="{ count($grouped-errors) }">
        {
            
            for $grouped-error in subsequence($grouped-errors, $first-record, $max-records)
                let $count-errors := count($grouped-error/m:request)
                let $ts := $grouped-error/m:request/@timestamp
                let $min-ts := if($ts) then min(local:dateTimes($ts)) else ''
                let $max-ts := if($ts) then max(local:dateTimes($ts)) else ''
                let $first-from-now := local:days-from-now($min-ts)
                let $latest-from-now := local:days-from-now($max-ts)
                return 
                    <error 
                        count="{ $count-errors }" 
                        first="{ local:days-ago-str($first-from-now) }" 
                        latest="{ local:days-ago-str($latest-from-now) }">
                        { 
                            $grouped-error/@request-string
                        }
                    </error>
        }
       </errors>
       
};

declare function log:achive-logs() as element() {
    
    (: 
        Archive the log files so they don't get too big
        - Write a copy of the file to disk with a timestamped name e.g. requests.xml, requests-29-05-2019.xml...
        - Clear out the log file in eXist
        - Files on disk can then be copied to s3 and pruned using the scheduled task
        - This can be run just by calling this file
        - This file needs SetUID permissions flag
        - Historic logs can be cross queried simply by copying them into the logs file
    :)
    
    (: What log files are there? :)
    let $log-files := collection($common:log-path) ! tokenize(document-uri(.), '/')[last()] ! .[. = ('requests.xml', 'triggers.xml')]
    let $timestamp := format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]")
    
    return
        <achive-logs xmlns="http://read.84000.co/ns/1.0">
        {
            if(file:is-directory(concat('/', $common:environment//m:logs-conf/m:sync-path))) then
                (
                    
                    (: Rename each current log :)
                    for $file-name in $log-files
                        let $file-name-ts := concat($timestamp, '-', $file-name)
                    return
                        element rename {
                            attribute source-collection { $common:log-path },
                            attribute source-file { $file-name },
                            attribute new-file { $file-name-ts },
                            xmldb:rename($common:log-path, $file-name, $file-name-ts)
                        }
                    ,
                    
                    (: Save the logs to disk :)
                    file:sync($common:log-path, concat('/', $common:environment//m:logs-conf/m:sync-path), ()),
                    
                    (: Create new empty files and delete the timestamped ones :)
                    for $file-name in $log-files
                        let $file-uri := xs:anyURI(concat($common:log-path, "/", $file-name))
                        let $file-name-ts := concat($timestamp, '-', $file-name)
                    return
                    (
                        (: Create a new, empty file with correct permissions :)
                        element store {
                            attribute collection { $common:log-path },
                            attribute file { $file-name },
                            xmldb:store($common:log-path, $file-name, <log xmlns="http://read.84000.co/ns/1.0"/>),
                            sm:chown($file-uri, 'admin'),
                            sm:chgrp($file-uri, 'dba'),
                            sm:chmod($file-uri, 'rw-rw-rw-')
                        },
                       
                        (: Delete the date stamped file :)
                        element remove {
                            attribute collection { $common:log-path },
                            attribute file { $file-name-ts },
                            xmldb:remove($common:log-path, $file-name-ts)
                        }
                    )
                 )
            else
                ()
        }
        </achive-logs>
};



