xquery version "3.0";

import module namespace file-upload="http://operations.84000.co/file-upload" at "modules/file-upload.xql";

import module namespace common="http://read.84000.co/common" at "modules/common.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $resource-id := lower-case(substring-before($exist:resource, "."));
declare variable $resource-suffix := lower-case(substring-after($exist:resource, "."));
declare variable $collection-path := lower-case(substring-before(substring-after($exist:path, "/"), "/"));
declare variable $controller-root := lower-case(substring-after($exist:controller, "/"));
declare variable $models-collection := concat('/db/apps', $exist:controller, '/models/');
declare variable $model-file := concat($resource-id, '.xq');
declare variable $var-debug := 
    <debug>
        <var name="exist:path" value="{ $exist:path }"/>
        <var name="exist:resource" value="{ $exist:resource }"/>
        <var name="exist:controller" value="{ $exist:controller }"/>
        <var name="exist:prefix" value="{ $exist:prefix }"/>
        <var name="exist:root" value="{ $exist:root }"/>
        <var name="resource-id" value="{ $resource-id }"/>
        <var name="resource-suffix" value="{ $resource-suffix }"/>
        <var name="collection-path" value="{ $collection-path }"/>
        <var name="controller-root" value="{ $controller-root }"/>
        <var name="models-collection" value="{ $models-collection }">
            { 
                for $model-file in xmldb:get-child-resources($models-collection) 
                return 
                    element model {
                        $model-file
                    } 
            }
        </var>
        <var name="model-file" value="{ $model-file }"/>
    </debug>;

(: Log the request :)
import module namespace log = "http://read.84000.co/log" at "../84000-reading-room/modules/log.xql";
log:log-request(concat($exist:controller, $exist:path), $controller-root, $collection-path, $resource-id, $resource-suffix),

(: Debug controller variables :)
(:if(true()) then $var-debug else:)

(: Accept the client error without 404. It is logged above. :)
if (lower-case($exist:resource) eq "log-error.html") then
    <response>
        <message>logged</message>
    </response>

(: Forward root path to index.html :)
else if ($exist:path = ('', '/') or $exist:resource = ('index.htm')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

(: Forward to model file if valid :)
else if($model-file eq 'index.xq' or xmldb:get-child-resources($models-collection)[. eq $model-file]) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{ concat($exist:controller, '/models/', $model-file) }">
            <add-parameter name="resource-suffix" value="{$resource-suffix}"/>
        </forward>
    </dispatch>

(: File import :)
else if ($collection-path eq "imported-file") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{ file-upload:download-file-path() }">
            {
                if($resource-suffix = ('docx')) then
                    <set-header name="Content-Type" value="application/vnd.openxmlformats-officedocument.wordprocessingml.document"/>
                else if($resource-suffix = ('xlsx')) then
                    <set-header name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>
                else
                    ()
            }
            <set-header name="Content-Disposition" value="attachment"/>
        </forward>
    </dispatch>

(: Everything else is passed through :)
else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>