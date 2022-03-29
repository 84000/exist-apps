
xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translations = "http://read.84000.co/translations" at "../../modules/translations.xql";

let $data := request:get-data()

(:return if(true()) then element debug {$data} else:)

let $spreadsheet-zip := common:spreadsheet-zip($data//m:spreadsheet-data)

let $spreadsheet-name := ($data//m:spreadsheet-data/@key/string(), concat('84000-spreadsheet-', format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')))[1]

return (
    response:set-header("Content-Disposition", concat("attachment; filename=", $spreadsheet-name, ".xlsx")),
    response:stream-binary($spreadsheet-zip, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
)