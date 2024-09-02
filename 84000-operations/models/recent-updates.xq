xquery version "3.0" encoding "UTF-8";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";

declare option exist:serialize "method=xml indent=no";

let $resource-suffix := request:get-parameter('resource-suffix', '')

let $xml-response :=
    common:response(
        'operations/index', 
        'operations', 
        (
            translations:recent-updates-spreadsheet(translations:recent-updates())
        )
    )

return

    (: return spreadsheet :)
    if($resource-suffix eq 'xlsx') then (
    
        let $spreadsheet-zip := common:spreadsheet-zip($xml-response/m:spreadsheet-data)
        let $spreadsheet-name := ($xml-response/m:spreadsheet-data/@key/string(), concat('84000-spreadsheet-', format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')))[1]
        
        return (
            response:set-header("Content-Disposition", concat("attachment; filename=", $spreadsheet-name, ".xlsx")),
            response:stream-binary($spreadsheet-zip, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        )
    )
    
    (: return xml data :)
    else (
        util:declare-option("exist:serialize", "method=xml indent=no"),
        $xml-response
    )