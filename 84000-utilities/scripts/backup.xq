xquery version "3.1";
declare namespace eft = "http://read.84000.co/ns/1.0";

(: Notes:
	Script must be “setGID DBA” to run with sufficient permissions in cron.

Format of cron job in conf.xml:
<job type="user" name="spreadoutBackup" xquery="/db/system/sysadmin/spreadoutBackup.xq" cron-trigger="0 0 0 * * ?" unschedule-on-exception="false"/>

Format of config in environment.xml
<backup-conf data-collection="/db/apps/84000-data/audio" target-path="/home/existdb/exist-backup" exist-path="/home/existdb" prefix="dev" zip-target="> /dev/null 2>&amp;1 &amp;">
    <backup collection="/db/apps/84000-reading-room"/>
    <backup collection="/db/apps/84000-utilities"/>
    <backup collection="/db/apps/84000-operations"/>
</backup-conf>
:)

declare variable $local:conf:= doc('/db/system/config/db/system/environment.xml')//eft:backup-conf;
declare variable $local:data-collection := $local:conf/@data-collection/string();
declare variable $local:target-path := $local:conf/@target-path/string();
declare variable $local:buDate := current-date();

declare function local:getDataCollections ()
{   (:  Create a list of the collections in 84000-data, prepending the full path to each :)
    let $collection-list := $local:data-collection ! xmldb:get-child-collections(.)
    for $col in $collection-list
        (: where $col != "html" :) 
        let $fullPathList := string-join(($local:data-collection, $col),'/')
    return $fullPathList
};

declare function local:doBackupCollections ($coList)
{   (:  
    Backup each collection from the list $coList into a directory named as the current date.  
    Pause 20 seconds between collections to allow other requests to run.  :)
    let $exOptions := 
        <option>
            <workingDir>{$local:conf/@exist-path/string()}/</workingDir>
        </option>
    for $col in $coList
       let $pfix := fn:replace($col,"/", "-") (: Reformat path to serve in filename :)
       let $dir := string-join(($local:target-path, $local:buDate), '/')
       let $params :=
            <parameters>
                <param name="dir" value="{ $dir }"/>
                <param name="zip" value="no"/>
                <param name="prefix" value="{$local:conf/@prefix}{$pfix}-"/>
                <param name="collection" value="{$col}"/>
            </parameters>
        (: Pause for 5 seconds to give the database a chance to run queued queries. :)
        let $delay := process:execute(("sleep","20"),$exOptions) 
    return (
        util:log('info', 'backup-script:'||$dir),
        system:trigger-system-task("org.exist.storage.BackupSystemTask", $params)
    )
};

let $log-start := util:log('info', 'backup-script:'||$local:buDate)

(: create a list of each collection we wish to backup :)
let $data-list := local:getDataCollections()
let $backup-list := ($data-list, $local:conf/eft:backup/@collection/string())

(: Send the list to the backup function :)
let $do-backup := local:doBackupCollections($backup-list)

(: Spawn a job that will zip the database backup directory into a single zip file named as today's date.  Don’t wait for response. :)
(: Only do the zip if @zip-target is configured:)
let $cmd := $local:conf/@zip-target/string() ! "nohup nice zip -rm "||$local:buDate||".zip "||$local:buDate || .
let $exOptions := 
    <option>
        <workingDir>{ $local:target-path }/</workingDir>
    </option>
where $cmd
return (
    util:log('info', 'backup-script:create-archive'),
    process:execute(("sh", "-c", $cmd),$exOptions)
)
