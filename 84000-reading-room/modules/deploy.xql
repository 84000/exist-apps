xquery version "3.0";

module namespace deploy="http://read.84000.co/deploy";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace expath="http://expath.org/ns/pkg";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace repair="http://exist-db.org/xquery/repo/repair" at "resource:org/exist/xquery/modules/expathrepo/repair.xql";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";

declare variable $deploy:snapshot-conf := $common:environment//m:snapshot-conf;
declare variable $deploy:deployment-conf := $common:environment//m:deployment-conf;

declare function deploy:execute-options($working-dir as xs:string) as element() {
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

declare function deploy:commit-data($action as xs:string, $sync-resource as xs:string, $commit-msg as xs:string) {

    let $repo-path := $deploy:snapshot-conf/m:repo-path/text()
    
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
            concat('Sync ', substring-after($sync-resource, concat($common:data-path, '/')))
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
                    deploy:git-push($git-add, $commit-msg, deploy:execute-options($repo-path))
                else
                    ()
            }
        </result>
    
};

declare function deploy:deploy-apps($admin-password as xs:string, $commit-msg as xs:string, $get-app as xs:string) as element() {

    let $repo-path := $deploy:deployment-conf/m:repo-path/text()
    let $exist-path := $deploy:deployment-conf/m:exist-path/text()
    let $action := $deploy:deployment-conf/m:apps/@role
    let $pull-collection := $deploy:deployment-conf/m:apps/m:app[@collection eq $get-app]/@collection
    
    let $admin-password-correct := 
        if($admin-password gt '') then
            xmldb:authenticate('/db', 'admin', $admin-password)
        else
            ()
    
    let $git-options := deploy:execute-options($repo-path)
    let $exist-options := deploy:execute-options($exist-path)
    
    (: Sync app :)
    let $sync :=
        if($repo-path and $admin-password-correct and $action eq 'push') then
            (: Sync files with the file system :)
            for $push-collection in $deploy:deployment-conf/m:apps/m:app/@collection
                let $sync-collection := 
                    file:sync(
                        concat('/db/apps/', $push-collection), 
                        concat('/', $repo-path, '/', $push-collection), 
                        ()
                    )
                where count($sync-collection//file:update) gt 0
            return
                (
                    $sync-collection,
                    process:execute(
                        ('bin/backup.sh', '-u', 'admin', '-p', $admin-password, '-b', concat('/db/apps/', $push-collection), '-d', concat('/', $repo-path, '/', $push-collection, '/zip/', $push-collection, '.zip')), 
                        $exist-options
                    )
                )
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
                if($admin-password-correct) then
                    if($action eq 'push' and  $sync and $git-options) then
                        deploy:git-push('--all', $commit-msg, $git-options)
                    else if($action eq 'pull' and $pull-collection) then
                        deploy:git-pull($git-options)
                    else
                        ()
                else
                    ()
            }
        </result>
    
};

declare function deploy:git-push($git-add as xs:string, $commit-msg as xs:string, $options as element()) as node()*{
    
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

declare function deploy:git-pull($options as element()) as node()*{
    
    (: Pull from GitHub :)
    <execute xmlns="http://read.84000.co/ns/1.0">
    {
        process:execute(('git', 'pull', 'origin', 'master'), $options)
    }
    </execute>
    
};

declare function deploy:create-package($app-collection as xs:string) {
    let $entries :=
        dbutil:scan(xs:anyURI($app-collection), function($collection as xs:anyURI?, $resource as xs:anyURI?) {
            let $resource-relative-path := substring-after($resource, $app-collection || "/")
            let $collection-relative-path := substring-after($collection, $app-collection || "/")
            return
                if (empty($resource)) then
                    (: no need to create a collection entry for the app's root directory :)
                    if ($collection-relative-path eq "") then
                        ()
                    else
                        <entry type="collection" name="{$collection-relative-path}"/>
                else if (util:binary-doc-available($resource)) then
                    <entry type="uri" name="{$resource-relative-path}">{$resource}</entry>
                else
                    <entry type="xml" name="{$resource-relative-path}">{
                        util:declare-option("exist:serialize", "expand-xincludes=no"),
                        doc($resource)
                    }</entry>
        })
    return 
        compression:zip($entries, true())
};

