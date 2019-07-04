xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";

declare variable $local:tei := collection($common:translations-path);

count($local:tei//tei:list[@type eq "glossary"]/tei:item/tei:gloss)