xquery version "3.0" encoding "UTF-8";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../modules/update-entity.xql";

declare variable $local:resource-id external;

update-entity:merge-glossary($local:resource-id, true())