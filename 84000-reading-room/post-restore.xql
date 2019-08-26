xquery version "3.0";
(: 
    Run after a restore of the app
:)
import module namespace install="http://read.84000.co/install" at "modules/install.xql";
import module namespace repair="http://exist-db.org/xquery/repo/repair" at "resource:org/exist/xquery/modules/expathrepo/repair.xql";

(: the target collection into which the app is deployed :)
declare variable $target := '/db/apps/84000-reading-room';

repair:clean-all(),
repair:repair(),
install:copy-xconf($target),
install:reindex()
