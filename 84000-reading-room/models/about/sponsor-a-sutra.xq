xquery version "3.0" encoding "UTF-8";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../modules/translations.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../modules/sponsorship.xql";

declare option exist:serialize "method=xml indent=no";

common:response(
    "about/sponsor-a-sutra", 
    $common:app-id,
    (
        translations:summary(),
        translations:sponsorship-texts(),
        $sponsorship:cost-groups
    )
)
