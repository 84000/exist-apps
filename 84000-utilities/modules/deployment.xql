xquery version "3.0";

module namespace deployment="http://read.84000.co/deployment";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace file="http://exist-db.org/xquery/file";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare function deployment:commit-data($action as xs:string, $sync-resource as xs:string, $commit-msg as xs:string) {

    let $snapshot-conf := common:snapshot-conf()
    let $sync-path := $snapshot-conf/m:sync-path/text()
    
    (: Sync data :)
    let $sync :=
        if($action eq 'sync' and $sync-path) then
            (
                for $collection in ('tei', 'translation-memory', 'config')
                return
                    file:sync(
                        concat($common:data-path, '/', $collection), 
                        concat($sync-path, '/', $collection), 
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
            <view-repo-url>
            { 
                $snapshot-conf/m:view-repo-url/text() 
            }
            </view-repo-url>
            <sync>
            {
                $sync
            }
            </sync>
            {
                if($sync) then
                    deployment:git-push($sync-path, $snapshot-conf/m:path/text(), $snapshot-conf/m:home/text(), $git-add, $commit-msg)
                else
                    ()
            }
        </result>
    
};

declare function deployment:commit-apps($action as xs:string, $commit-msg as xs:string, $admin-password as xs:string) as element() {

    let $deployment-conf := common:deployment-conf()
    let $admin-password-correct := xmldb:authenticate('/db', 'admin', $admin-password)
    
    (: Sync app :)
    let $sync :=
        if($action eq 'push' and $deployment-conf/m:sync-path/text() and $admin-password-correct) then
            (
                for $collection in $deployment-conf/m:apps/m:app/@collection
                    (: Sync files with the file system :)
                    let $file-sync := 
                        file:sync(
                           concat('/db/apps/', $collection), 
                           concat('/', $deployment-conf/m:sync-path/text(), '/', $collection), 
                           ()
                        )
                return
                (
                    $file-sync,
                    (: If files were updated then create a new zip of the app :)
                    if($file-sync//file:update) then
                        process:execute(
                            ('bin/backup.sh', '-u', 'admin', '-p', $admin-password, '-b', concat('/db/apps/', $collection), '-d', concat('/', $deployment-conf/m:sync-path/text(), '/', $collection, '/zip/', $collection, '.zip')), 
                            <options>
                                <workingDir>/{ $deployment-conf/m:exist-path/text() }</workingDir>
                            </options>
                        )
                    else
                        ()
                )
            )
        else
            ()
    
    return 
        <result xmlns="http://read.84000.co/ns/1.0">
            <view-repo-url>
            { 
                $deployment-conf/m:view-repo-url/text() 
            }
            </view-repo-url>
            <sync admin-password-correct="{ $admin-password-correct }">
            {
                $sync
            }
            </sync>
            {
                if($sync) then
                    deployment:git-push($deployment-conf/m:sync-path/text(), $deployment-conf/m:path/text(), $deployment-conf/m:home/text(), '.', $commit-msg)
                else
                    ()
            }
        </result>
    
};

declare function deployment:git-push($working-dir as xs:string, $path as xs:string, $home as xs:string, $git-add as xs:string, $commit-msg as xs:string) as node()*{
    
    let $options := 
        <options>
            <workingDir>/{ $working-dir }</workingDir>
            <environment>
                <env name="PATH" value="/{ $path }"/>
                <env name="HOME" value="/{ $home }"/>
            </environment>
        </options>
        
    return 
    (
        (: Push it to GitHub :)
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
    )
};

