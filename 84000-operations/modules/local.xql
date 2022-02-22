xquery version "3.0";

module namespace local="http://operations.84000.co/local";
declare namespace pkg="http://expath.org/ns/pkg";

declare function local:app-path() as xs:string {

    let $servlet-path := system:get-module-load-path()
    let $tokens := tokenize($servlet-path, '/')
    return 
        string-join(subsequence($tokens, 1, count($tokens) - 1), '/')
    
};

declare function local:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

declare function local:get-status-parameter() as xs:string* {
    let $post-status := request:get-parameter('status[]', '')
    let $get-status := tokenize(request:get-parameter('status', ''), ',')
    return
        if (count($get-status) gt 0) then
            $get-status
        else
            $post-status
};

declare function local:async-script($script-name as xs:string, $parameters as element(parameters)?){
    
    (: Clear job if completed :)
    let $clear-complete-job :=
        if(scheduler:get-scheduled-jobs()//scheduler:job[@name eq $script-name][scheduler:trigger/state/text() eq 'COMPLETE']) then
            scheduler:delete-scheduled-job($script-name)
        else ()
    
    (: Only schedule if not already there :)
    where not(scheduler:get-scheduled-jobs()//scheduler:job[@name eq $script-name])
    return (
        (: Log so we can monitor :)
        util:log('info', concat('async-script:', $script-name)),
        (: Schedule a one-off job :)
        scheduler:schedule-xquery-periodic-job(
            concat('/db/apps/84000-operations/scripts/', $script-name, '.xq'),
            10000,
            $script-name,
            $parameters,
            5000,
            0
        )
    )
};