xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare namespace m = "http://read.84000.co/ns/1.0";

declare option exist:serialize "method=xml indent=no";

common:response(
    'utilities/folios',
    'utilities',
    translations:translations($tei-content:marked-up-status-ids, '', true())
)