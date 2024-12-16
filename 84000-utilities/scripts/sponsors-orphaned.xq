
xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";


for $sponsorship in $sponsors:texts//tei:TEI//tei:titleStmt/tei:sponsor[@xml:id]
let $sponsorship-instances := $sponsors:sponsors//m:instance[@id = $sponsorship/@xml:id]
let $text-id := tei-content:id($sponsorship/ancestor::tei:TEI)
where not($sponsorship-instances)
order by $text-id
return (
    $sponsorship,
    $sponsorship-instances/parent::m:sponsor
)