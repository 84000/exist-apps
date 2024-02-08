xquery version "3.1";
declare namespace eft = "http://read.84000.co/ns/1.0";

(:  Notes:
    
    Script must be "setGID DBA" or "setUID admin" to run with sufficient permissions in as scheduled job
    
    Format of config in environment.xml
    <backup-conf data-collection="/db/apps/84000-data" target-path="/home/existdb/exist-backup" exist-path="/home/existdb" prefix="collab">
        <backup collection="/db/apps/84000-reading-room"/>
        <backup collection="/db/apps/84000-utilities"/>
        <backup collection="/db/apps/84000-operations"/>
    </backup-conf>
    
    Format of cron job in conf.xml
    <job type="user" name="backupDaily" xquery="/db/apps/84000-utilities/models/backup-daily.xq" cron-trigger="0 0 0 * * ?" unschedule-on-exception="false"/>
    
    Note to test run this script use the scheduler (running the .xq file directly won't work)
    scheduler:schedule-xquery-periodic-job('/db/apps/84000-utilities/models/backup-daily.xq', 10000, 'backup-daily', (), 1000, 0)

:)

declare variable $local:conf:= doc('/db/system/config/db/system/environment.xml')//eft:backup-conf;
declare variable $local:data-collection := $local:conf/@data-collection/string();
declare variable $local:target-path := $local:conf/@target-path/string();
declare variable $local:buDate := tokenize(current-date(), '\+')[1];
declare variable $local:delay := 20;
declare variable $local:username := 'admin';
declare variable $local:password := environment-variable("EXIST_PW");

declare function local:getDataCollections(){   
    (: Create a list of the collections in 84000-data, prepending the full path to each :)
    let $collection-list := $local:data-collection[xmldb:collection-available(.)] ! xmldb:get-child-collections(.)
    for $col in $collection-list
    (: where $col != "html" :) 
    let $fullPathList := string-join(($local:data-collection, $col),'/')
    return $fullPathList
};

declare function local:doBackupCollections($coList){
    (: Backup each collection from the list $coList into a directory named as the current date.  
       Pause 20 seconds between collections to allow other requests to run. :)
    
    let $exOptions := 
        <option>
            <workingDir>{ $local:conf/@exist-path/string() }/</workingDir>
        </option>
    
    for $col in $coList
    let $pfix := fn:replace($col,"/", "-") (: Reformat path to serve in filename :)
    let $dir := string-join(($local:target-path, $local:buDate), '/')
    let $params :=
        <parameters>
            <param name="dir" value="{ $dir }"/>
            <param name="zip" value="no"/>
            <param name="prefix" value="{ $local:conf/@prefix }{ $pfix }-"/>
            <param name="collection" value="{ $col }"/>
            <param name="user" value="{ $local:username }"/>
            <param name="password" value="{ $local:password }"/>
        </parameters>
    
    return (
        (: Do backup :)
        util:log('info', 'backup-script:'|| $dir ||'/'|| $local:conf/@prefix || $pfix),
        system:trigger-system-task("org.exist.storage.BackupSystemTask", $params),
        
        (: Pause for 20 seconds to give the database a chance to run queued queries. :)
        process:execute(("sleep",$local:delay), $exOptions)
    )
};

let $log-start := util:log('info', 'backup-script:' || $local:buDate)

return 
    if($local:username gt '' and $local:password gt '' and xmldb:authenticate('/db', $local:username, $local:password)) then
        
        (: create a list of each collection we wish to backup :)
        let $data-list := local:getDataCollections()
        let $backup-list := ($data-list, $local:conf/eft:backup/@collection/string())
        
        (: Send the list to the backup function :)
        let $do-backup := local:doBackupCollections($backup-list)
        
        (: Spawn a job that will zip the database backup directory into a single zip file named as today's date.  Don’t wait for response. :)
        let $cmd := concat(string-join(("nohup", "nice", "zip","-rm", concat('backup-daily-', $local:conf/@prefix, '-', $local:buDate, ".zip"), $local:buDate), ' '), "> /dev/null 2>&amp;1 &amp;")
        let $exOptions := 
            <option>
                <workingDir>{ $local:target-path }/</workingDir>
            </option>
        
        return (
            util:log('info', 'backup-script:create-archive'),
            process:execute(("sh", "-c", $cmd), $exOptions)
        )
        
    else 
        util:log('warn', 'backup-script:BACKUP ABORTED! username/password not valid')
        
