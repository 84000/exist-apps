xquery version "3.0";

module namespace deployment="http://read.84000.co/deployment";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace file="http://exist-db.org/xquery/file";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace repair="http://exist-db.org/xquery/repo/repair" at "resource:org/exist/xquery/modules/expathrepo/repair.xql";

declare variable $deployment:snapshot-conf := $common:environment//m:snapshot-conf;
declare variable $deployment:deployment-conf := $common:environment//m:deployment-conf;

declare function deployment:execute-options($working-dir as xs:string) as element() {
    <options>
        <workingDir>/{ $working-dir }</workingDir>
        <environment>
        {
            for $env-var in $common:environment//m:env-vars/m:var
            return 
                <env name="{ upper-case($env-var/@id) }" value="/{ $env-var/text() }"/>
        }
        </environment>
    </options>
};

declare function deployment:commit-data($action as xs:string, $sync-resource as xs:string, $commit-msg as xs:string) {

    let $repo-path := $deployment:snapshot-conf/m:repo-path/text()
    
    (: Sync data :)
    let $sync :=
        if($action eq 'sync' and $repo-path) then
            (
                for $collection in ('tei', 'translation-memory', 'config')
                return
                    file:sync(
                        concat($common:data-path, '/', $collection), 
                        concat('/', $repo-path, '/', $collection), 
                        ()
                    )
            )
        else
            ()
    
    (: Only add specified file to commit :)
    let $git-add := 
        if ($sync-resource eq 'all') then
            "--all"
        else if($sync-resource eq 'translation-memory') then
            "translation-memory/."
        else
            substring-after($sync-resource, concat($common:data-path, '/'))
            
    let $commit-msg := 
        if(not($commit-msg))then
            concat('Sync ', $sync-resource)
        else
            $commit-msg
    
    return 
        <result xmlns="http://read.84000.co/ns/1.0">
            <sync>
            {
                $sync
            }
            </sync>
            {
                if($sync) then
                    deployment:git-push($git-add, $commit-msg, deployment:execute-options($repo-path))
                else
                    ()
            }
        </result>
    
};

declare function deployment:deploy-apps($admin-password as xs:string, $commit-msg as xs:string, $get-app as xs:string) as element() {

    let $repo-path := $deployment:deployment-conf/m:repo-path/text()
    let $exist-path := $deployment:deployment-conf/m:exist-path/text()
    let $action := $deployment:deployment-conf/m:apps/@role
    let $pull-collection := $deployment:deployment-conf/m:apps/m:app[@collection eq $get-app]/@collection
    
    let $admin-password-correct := xmldb:authenticate('/db', 'admin', $admin-password)
    
    let $git-options := deployment:execute-options($repo-path)
    let $exist-options := deployment:execute-options($exist-path)
    
    (: Sync app :)
    let $sync :=
        if($repo-path and $exist-path and $admin-password-correct) then
            if($action eq 'push') then
                (
                    for $push-collection in $deployment:deployment-conf/m:apps/m:app/@collection
                        (: Sync files with the file system :)
                        let $file-sync := 
                            file:sync(
                               concat('/db/apps/', $push-collection), 
                               concat('/', $repo-path, '/', $push-collection), 
                               ()
                            )
                    return
                    (
                        $file-sync,
                        (: If files were updated then create a new zip of the app :)
                        if(count($file-sync//file:update) gt 0) then
                            process:execute(
                                ('bin/backup.sh', '-u', 'admin', '-p', $admin-password, '-b', concat('/db/apps/', $push-collection), '-d', concat('/', $repo-path, '/', $push-collection, '/zip/', $push-collection, '.zip')), 
                                $exist-options
                            )
                        else
                            ()
                    )
                )
            else if($action eq 'pull' and $pull-collection) then
                let $git-pull := deployment:git-pull($git-options)
                let $restore :=
                    process:execute(
                        ('bin/backup.sh', '-u', 'admin', '-p', $admin-password, '-P', $admin-password, '-r', concat('/', $repo-path, '/', $pull-collection, '/zip/', $pull-collection, '.zip')),
                        $exist-options
                    )
                let $clean-up := 
                    (
                        repair:clean-all(),
                        repair:repair()
                    )
                return
                    (
                        $git-pull,
                        $restore,
                        $clean-up
                    )
            else
                ()
        else
            ()
    
    return 
        <result xmlns="http://read.84000.co/ns/1.0">
            <sync admin-password-correct="{ $admin-password-correct }">
            {
                $sync
            }
            </sync>
            {
                if($action eq 'push' and  $sync and $git-options) then
                    deployment:git-push('--all', $commit-msg, $git-options)
                else
                    ()
            }
        </result>
    
};

declare function deployment:git-push($git-add as xs:string, $commit-msg as xs:string, $options as element()) as node()*{
    
    (: Push to GitHub :)
    <execute xmlns="http://read.84000.co/ns/1.0">
    {
        process:execute(('git', 'status'), $options)
    }
    </execute>,
    <execute xmlns="http://read.84000.co/ns/1.0">
    {
        process:execute(('git', 'add', $git-add), $options)
    }
    </execute>,
    <execute xmlns="http://read.84000.co/ns/1.0">
    {
        process:execute(('git', 'commit', "-m", $commit-msg), $options)
    }
    </execute>,
    <execute xmlns="http://read.84000.co/ns/1.0">
    {
        process:execute(('git', 'push', 'origin', 'master'), $options)
    }
    </execute>
    
};

declare function deployment:git-pull($options as element()) as node()*{
    
    (: Pull from GitHub :)
    <execute xmlns="http://read.84000.co/ns/1.0">
    {
        process:execute(('git', 'pull', 'origin', 'master'), $options)
    }
    </execute>
    
};

