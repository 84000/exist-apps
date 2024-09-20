xquery version "3.1" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare option exist:serialize "method=json indent=yes media-type=text/javascript";
declare option output:indent "yes";

element { QName('http://read.84000.co/ns/1.0', 'work-ids') }{
    for $tei in $tei-content:translations-collection//tei:TEI
    let $text-id := tei-content:id($tei)
    order by $text-id
    return
        $tei//tei:sourceDesc/tei:bibl[@key] ! element workId { attribute json:array { true() }, attribute source { $text-id }, attribute destination { @key/string() } }
}