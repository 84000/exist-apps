xquery version "3.0" encoding "UTF-8";
(:
    Returns the entire cumulative glossary
    ---------------------------------------------------------------
:)
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

let $resource-suffix := request:get-parameter('resource-suffix', '')
let $chunk := request:get-parameter('chunk', '1')
let $cumulative-glossary := glossary:cumulative-glossary($chunk)

let $zip-entry :=
    <entry name="cumulative-glossary-{ $chunk }.xml" type="xml">
    { 
        $cumulative-glossary
    }
    </entry>

let $zip-data := 
    if($resource-suffix eq 'zip') then
        compression:zip($zip-entry, true())
    else
        ()

let $zip-filename := concat('84000-cumulative-glossary-', format-date(current-date(), "[D01]-[M01]-[Y0001]"), '-', $chunk, '.zip')

return
    if($resource-suffix eq 'zip') then
        response:stream-binary(
            $zip-data, 
            'application/xml+zip', 
            $zip-filename
        )
    else
        common:response(
            "translator-tools/cumulative-glossary", 
            'translator-tools',
            $cumulative-glossary
        )
        

