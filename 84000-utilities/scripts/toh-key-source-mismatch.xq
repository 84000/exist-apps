xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace translations="http://read.84000.co/translations" at "../../84000-reading-room/modules/translations.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

let $source-texts := collection(concat($source:source-data-path, '/', 'UT23703-230324'))//tei:milestone[@unit eq 'text']
let $source-text-ids := $source-texts/@toh/string() ! concat('toh', .)
let $translation-source := $tei-content:translations-collection//tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work = $source:tengyur-work]
let $translation-source-keys := $translation-source/@key/string() ! replace(., '^toh', '')

return (

    fn:sort($translation-source[not(@key/string() (:! replace(., '^(toh\d+).*', '$1','i'):) = $source-text-ids)], (), function($item) {$item/@key[1] ! replace(., '^toh(\d+).*', '$1','i') ! xs:integer(.)} ) ! element tei:bibl { @key }
    
    (:,fn:sort($source-texts[not(@toh/string() = $translation-source-keys)], (), function($item) {$item/@toh ! replace(., '^(\d+).*', '$1','i') ! xs:integer(.)} ):)

)
