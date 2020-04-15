xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/audio-test", 
    $common:app-id,
    ()
)
