xquery version "3.1";

let $params :=
     <parameters>
        <param name="output" value="/home/existdb/exist-backup"/>
    	<param name="backup" value="yes"/>
    	<param name="incremental" value="no"/>
    	<parameter name="zip" value="yes"/>
     </parameters>

return
	system:trigger-system-task("org.exist.storage.ConsistencyCheckTask", $params)
