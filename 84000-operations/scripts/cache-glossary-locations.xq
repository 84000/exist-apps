xquery version "3.0" encoding "UTF-8";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../modules/update-tei.xql";

declare variable $local:resource-id external;
declare variable $local:resource-type external;
declare variable $local:glossary-id external;

let $tei := tei-content:tei($local:resource-id, $local:resource-type)

return
    update-tei:cache-glossary-locations($tei, $local:glossary-id)