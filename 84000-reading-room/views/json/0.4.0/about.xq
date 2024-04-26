xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $resource-id := request:get-parameter('resource-id', '');
declare variable $local:xml := request:get-data()/eft:response;

if($resource-id eq 'sponsor-a-sutra') then
    transform:transform($local:xml, doc("sponsor-a-sutra.xsl"), <parameters/>)
else 
    $local:xml
