xquery version "3.0";
(: 
    If we have to resort to copying a backup of the app because the restore / install doesn't work
    This script fixes permissions and copies files
:)
import module namespace install="http://read.84000.co/install" at "modules/install.xql";
import module namespace repair="http://exist-db.org/xquery/repo/repair" at "resource:org/exist/xquery/modules/expathrepo/repair.xql";

(: the target collection into which the app is deployed :)
declare variable $target := '/db/apps/84000-reading-room';

repair:clean-all(),
repair:repair(),
install:base-permissions($target),
install:special-permissions($target),
install:copy-xconf($target),
install:reindex()