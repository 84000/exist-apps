xquery version "3.0" encoding "UTF-8";

import module namespace update-entity="http://operations.84000.co/update-entity" at "../modules/update-entity.xql";

declare variable $local:resource-id external;

update-entity:merge-glossary($local:resource-id, true())