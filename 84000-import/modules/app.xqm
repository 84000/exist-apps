xquery version "3.1";

module namespace app="http://agilehumanities.ca/apps/84000/app";

import module namespace config="http://agilehumanities.ca/apps/84000/config" at "config.xqm";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace hc = "http://expath.org/ns/http-client";
import module namespace rest = "http://exquery.org/ns/restxq"; 
import module namespace templates="http://exist-db.org/xquery/templates" ;

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";


declare
	%templates:wrap
function app:list-items($collection as xs:string)
as element(ol)
{
    <ul>{
        for $string in xmldb:get-child-resources($collection)
        order by $string
        return
           <li>{$string}</li>
    }</ul>
};

declare 
 %templates:wrap
function app:list-tei-docs($node as node(), $model as map(*))
{
    app:list-items($config:TEIDocs)
};


declare 
 %templates:wrap
function app:list-word-docs($node as node(), $model as map(*))
{
    app:list-items($config:wordDocs)
};
