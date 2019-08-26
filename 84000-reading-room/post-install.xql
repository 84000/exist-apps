xquery version "3.0";
(: 
    Run after an install of the app expath package 
:)
import module namespace install="http://read.84000.co/install" at "modules/install.xql";

(: The following external variables are set by the repo:deploy function :)
(: the target collection into which the app is deployed :)
declare variable $target external;

install:special-permissions($target),
install:reindex()