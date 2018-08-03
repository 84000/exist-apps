xquery version "3.0";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";

let $data := doc(concat($common:data-path, '/uploads/spreadsheet-data.xml'))
let $xls-data := transform:transform($data, doc(concat($common:app-path, "/views/spreadsheet/xslt/spreadsheet.xsl")), <parameters/>)
return $xls-data
(:let $zip := compression:zip($xls-data, true())
return
    response:stream-binary($zip, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
:)