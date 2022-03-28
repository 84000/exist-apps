declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";

for $element in $entities:entities//m:entity/m:content/*[not(namespace-uri() eq 'http://www.tei-c.org/ns/1.0')]
return (
    $element(:,
    update replace  $element with element { QName('http://www.tei-c.org/ns/1.0', local-name($element)) } { $element/*, $element/node()}:)
)