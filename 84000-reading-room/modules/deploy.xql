xquery version "3.0";

module namespace deploy="http://read.84000.co/deploy";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace expath="http://expath.org/ns/pkg";

import module namespace common="http://read.84000.co/common" at "common.xql";
(:import module namespace repair="http://exist-db.org/xquery/repo/repair" at "resource:org/exist/xquery/modules/expathrepo/repair.xql";:)
import module namespace functx="http://www.functx.com";

declare variable $deploy:snapshot-conf := $common:environment//m:snapshot-conf;
declare variable $deploy:deployment-conf := $common:environment//m:deployment-conf;

declare variable $deploy:git-config := $common:environment/m:git-config;

declare function deploy:exist-options() as element() {
    <options type="exist-options">
        <workingDir>{ $deploy:git-config/@exist-path/string() }</workingDir>
        { deploy:environment-vars() }
    </options>
};

declare function deploy:git-options($repo as element(m:repo)) as element() {
    <options type="git-options">
        <workingDir>{ $repo/@path/string() }</workingDir>
        { deploy:environment-vars() }
    </options>
};

declare function deploy:environment-vars() as element() {
    <environment>
    {
        for $env-var in $common:environment//m:env-vars/m:var
        return 
            <env name="{ upper-case($env-var/@id) }" value="/{ $env-var/text() }"/>
    }
    </environment>
};

declare function deploy:admin-password-validated($admin-password as xs:string?, $user-in-group as xs:string?) as xs:string? {
    
    (:Return the validated password for use in scripts:)
    if($admin-password) then
        
        (: The password is specific to the logged in user, i.e. you must know both the admin password and the user's password :)
        let $user-name := common:user-name()
        let $decoded-password := 
            if(not($user-name eq 'admin')) then
                replace(util:base64-decode($admin-password), $user-name, '')
            else
                $admin-password
        
        return
            (: Attempt as decoded password :)
            if(xmldb:authenticate('/db', 'admin', $decoded-password) and common:user-in-group($user-in-group)) then
                $decoded-password
            
            else ()
        
    else ()
    
};

declare function deploy:push($repo-id as xs:string, $admin-password as xs:string?, $commit-msg as xs:string?, $resource as xs:string?) as element(m:result)? {
    
    (: get the repo from the config :)
    let $repo := $deploy:git-config/m:push/m:repo[@id eq $repo-id]
    
    let $repo-group-user := 
        if($repo[@group]) then
            common:user-in-group($repo/@group)
        else
            true()
    
    (: validate the admin password :)
    (: If none provided we can still push, but no zip file can be created :)
    let $admin-password-validated := deploy:admin-password-validated($admin-password, 'git-push')
    
    where $repo and $repo-group-user
    return
    
        let $log := util:log('info', concat('deploy-push: ', $repo-id))
        
        let $exist-options := deploy:exist-options()
        
        (: Set working dir for repo :)
        let $git-options := deploy:git-options($repo)
        
        let $commit-msg := 
            if(not($commit-msg))then
                concat('Sync ', $repo/m:label)
            else
                $commit-msg
        
        (: 
            Default to git add --all 
            Unless a specific resource is specified them $repo/m:sync/@sub-dir + file name
        :)
        let $git-add := 
        
            (: There's a file defined so only commit that :)
            if($resource) then
                let $sync := $repo/m:sync[starts-with($resource, @collection)][1]
                let $sub-dir := $sync/@sub-dir ! concat(., '/')
                let $resource-relative := substring-after($resource, concat($sync/@collection, '/'))
                return
                    concat($sub-dir, $resource-relative)
            
            (: There's a sub-directory defined so only commit that :)
            else if(count($repo/m:sync[@sub-dir]) eq 1) then
                $repo/m:sync[1]/@sub-dir/string()
            
            (: Default to all :)
            else
                '--all'
    
    where $git-add
    return (
        element { QName('http://read.84000.co/ns/1.0','result') } {
        
            attribute id {'deploy-push'},
            attribute admin-password-correct { if($admin-password-validated gt '') then true() else false() },
            
            (: Sync the data for each $repo/m:sync :)
            for $sync in $repo/m:sync[@collection]
                
            (: Sub directory to sync :)
            let $sub-dir := $sync/@sub-dir ! concat('/',  .)
            
            (: Sync files in the collection with the filesystem :)
            let $do-sync := 
                file:sync(
                    $sync/@collection, 
                    concat($repo/@path, $sub-dir), 
                    if($sync[@prune]) then
                        map{ "prune": true(), "excludes": ("zip","xar",".git",".gitignore","README.md") }
                    else ()
                )
            
            let $log := util:log('info', concat('deploy-push: ', concat($repo/@path, $sub-dir), ' synced'))
            
            return (
                
                (: Return details of the sync :)
                $do-sync,
                
                (: Create a zip if required :)
                let $target-file := $sync/@backup ! concat($repo/@path, $sub-dir, '/',  .)
                
                where 
                    $do-sync//file:update 
                    and $target-file
                    and matches($target-file, '\.zip$')
                    and $admin-password-validated gt ''
                
                let $do-backup := 
                    process:execute(
                        ('bin/backup.sh', '-u', 'admin', '-p', $admin-password-validated, '-b', $sync/@collection, '-d', $target-file), 
                        $exist-options
                    )
                
                let $log := util:log('info', concat('deploy-push: ', $target-file, ' backed-up'))
                
                return 
                    element debug {
                        element command { concat('bin/backup.sh -b ', $sync/@collection, ' -d ', $target-file)},
                        $do-backup/stdout/line ! element output { data() }
                    }
                 
            ),
            
            (: Do Git push :)
            element push {
                process:execute(('git', 'checkout', ($repo/@branch/string(), 'master')[1]), $git-options),
                process:execute(('git', 'status'), $git-options),
                process:execute(('git', 'add', $git-add), $git-options),
                process:execute(('git', 'commit', '-m', $commit-msg), $git-options),
                process:execute(('git', 'push', 'origin', ($repo/@branch/string(), 'master')[1]), $git-options)
            }
            
        },
        
        util:log('info', 'deploy-push: completed')
        
    )
};

declare function deploy:pull($repo-id as xs:string, $admin-password as xs:string) as element(m:result)? {
    
    (: get the repo from the config :)
    let $repo := $deploy:git-config/m:pull/m:repo[@id eq $repo-id]
    
    let $repo-group-user := 
        if($repo[@group]) then
            common:user-in-group($repo/@group)
        else
            true()
    
    (: validate the admin password :)
    let $admin-password-validated := deploy:admin-password-validated($admin-password, 'git-push')
    
    let $exist-options := deploy:exist-options()
    let $git-options := deploy:git-options($repo)
    
    where $repo and $repo-group-user
    return (
        element { QName('http://read.84000.co/ns/1.0','result') } {
        
            attribute id {'deploy-pull'},
            attribute admin-password-correct { if($admin-password-validated gt '') then true() else false() },
            
            (: Do Git pull :)
            (:$exist-options, $git-options,:)
            element pull {
                (:process:execute(('git', 'status'), $git-options),:)
                process:execute(('git', 'checkout', ($repo/@branch/string(), 'master')[1]), $git-options),
                process:execute(('git', 'pull', 'origin', ($repo/@branch/string(), 'master')[1]), $git-options)
            },
            
            (: Restore the zip to eXist :)
            for $restore in $repo/m:restore
            
            let $restore-file := $restore/@backup ! concat($repo/@path, '/', .)

            where 
                $restore-file 
                and matches($restore-file, '\.zip$') 
                and $admin-password-validated gt ''
            
            let $do-restore :=
                process:execute(
                    ('bin/backup.sh', '-u', 'admin', '-p', $admin-password-validated, '-P', $admin-password-validated, '-r', $restore-file),
                    $exist-options
                )
            
            return 
                element debug {
                    element command { concat('bin/backup.sh -r ', $restore-file)},
                    $do-restore/stdout/line ! element output { data() }
                }
            
            (: Clean repos :)
            (:,repair:clean-all() ,repair:repair():)
            
        },
        
        util:log('info', concat('deploy-pull:', $repo-id))
        
    )
};

(: Create a xar package :)
(:declare function deploy:create-package($app-collection as xs:string) {

    let $entries :=
        dbutil:scan(
            xs:anyURI($app-collection), 
            function($collection as xs:anyURI?, $resource as xs:anyURI?) {
            
                let $resource-relative-path := substring-after($resource, $app-collection || "/")
                let $collection-relative-path := substring-after($collection, $app-collection || "/")
                
                return
                    if(empty($resource)) then
                        (\: no need to create a collection entry for the app's root directory :\)
                        if (not($collection-relative-path eq "")) then
                            <entry type="collection" name="{$collection-relative-path}"/>
                        else ()
                    
                    else if (util:binary-doc-available($resource)) then
                        <entry type="uri" name="{$resource-relative-path}">{$resource}</entry>
                    
                    else
                        <entry type="xml" name="{$resource-relative-path}">
                        {
                            util:declare-option("exist:serialize", "expand-xincludes=no"),
                            doc($resource)
                        }
                        </entry>
                        
            }
       )
    
    return 
        compression:zip($entries, true())
};:)

