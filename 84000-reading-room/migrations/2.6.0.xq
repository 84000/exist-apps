xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";

(
    
    (: 
    Migrate entity types:
    In entities.xml find / replace 
        eft-glossary-term       -> eft-term
        eft-glossary-person     -> eft-person
        eft-glossary-place      -> eft-place
        eft-glossary-text       -> eft-text
        eft-attribution-person  -> eft-person
    Shortcut: 
        eft-glossary-           -> eft-
        eft-attribution-        -> eft-
    :)
    
)