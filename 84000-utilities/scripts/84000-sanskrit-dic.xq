declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";

$glossary:tei//tei:back//tei:gloss/tei:term[@xml:lang eq 'Sa-Ltn'][@status eq 'verified'] ! tokenize(data(), '\s+') ! normalize-space(.)[string-length(.) gt 1]

