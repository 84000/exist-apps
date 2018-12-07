xquery version "3.0" encoding "UTF-8";

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
    let $logfile-collection := $common:log-path
    let $logfile-name := "requests.xml"
    let $logfile-full := concat($logfile-collection, '/', $logfile-name)
    let $logfile-created := 
        if(doc-available($logfile-full)) then 
            $logfile-full
        else
            xmldb:store($logfile-collection, $logfile-name, <log xmlns="http://read.84000.co/ns/1.0"/>)
    let $parameters :=  local:parameters()
    return
        update insert
            <request xmlns="http://read.84000.co/ns/1.0" timestamp="{current-dateTime()}">
                <request>{$request}</request>
                <app>{$app}</app>
                <type>{$type}</type>
                <resource-id>{$resource-id}</resource-id>
                <resource-suffix>{$resource-suffix}</resource-suffix>
                <parameters>{$parameters}</parameters>
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
    let $log := doc(concat($common:log-path, '/requests.xml'))
    let $grouped-requests :=
        for $request in $log/m:log/m:request
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
    let $log := doc(concat($common:log-path, '/requests.xml'))
    
    let $grouped-errors :=
        for $error in $log/m:log/m:request[m:resource-id/text() eq 'log-error']
            group by $url := string($error/m:parameters/m:parameter[@name = 'url'])
            let $ts := $error/@timestamp
            let $max-ts := if($ts) then max(local:dateTimes($ts)) else ''
            order by $max-ts descending, count($error) descending
        return
            <grouped-error request-string="{ $url }">
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