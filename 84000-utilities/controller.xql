xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../84000-reading-room/modules/common.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $resource-id := lower-case(substring-before($exist:resource, "."));
declare variable $resource-suffix := lower-case(substring-after($exist:resource, "."));
declare variable $collection-path := lower-case(substring-before(substring-after($exist:path, "/"), "/"));
declare variable $controller-root := lower-case(substring-after($exist:controller, "/"));

(: Log the request :)
import module namespace log = "http://read.84000.co/log" at "../84000-reading-room/modules/log.xql";
log:log-request(concat($exist:controller, $exist:path), $controller-root, $collection-path, $resource-id, $resource-suffix),

(: Accept the client error without 404. It is logged above. :)
if (lower-case($exist:resource) eq "log-error.html") then
    <response>
        <message>logged</message>
    </response>

else if ($exist:path = ('', '/') or $exist:resource = ('index.html', 'index.htm')) then
    (: forward root path to translations.html :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="translations.html"/>
    </dispatch>

(: Stylesheets, javascript and other front-end :)
else if($collection-path eq 'frontend' and $resource-suffix = ('css','js','json','min.js','svg','png','ttf', 'ico','otf','eot','svg','woff','woff2')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{ string-join(('/84000-static', $exist:path)) }">
            <set-header name="Content-Type" value="{ 
                if($resource-suffix eq 'css') then 'text/css'
                else if($resource-suffix eq 'svg') then 'image/svg+xml'
                else if($resource-suffix eq 'png') then 'image/png'
                else if($resource-suffix eq 'ico') then 'image/x-icon'
                else if($resource-suffix eq 'ttf') then 'font/ttf'
                else if($resource-suffix eq 'otf') then 'font/otf'
                else if($resource-suffix eq 'eot') then 'application/vnd.ms-fontobject'
                else if($resource-suffix eq 'svg') then 'image/svg+xml'
                else if($resource-suffix eq 'woff') then 'font/woff'
                else if($resource-suffix eq 'woff2') then 'font/woff2'
                else 'text/javascript'
            }"/>
        </forward>
    </dispatch>

(: Editor :)
(: Module located in operations app :)
else if ($resource-id = ("create-article") and $common:environment/m:url[@id eq 'operations'](: and common:user-in-group('operations'):)) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/84000-operations/models/{ $resource-id }.xq">
            <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
        </forward>
    </dispatch>

else if (ends-with($exist:resource, ".xml")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq')}"/>
    </dispatch>

else if (ends-with($exist:resource, ".xlsx")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq')}">
            <add-parameter name="resource-suffix" value="xlsx"/>
        </forward>
        <view>
            <forward url="/84000-reading-room/views/spreadsheet/excel.xq"/>
        </view>
    </dispatch>

else if (ends-with($exist:resource, ".html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq')}"/>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, '/views/', substring-before($exist:resource, '.'), '.xsl')}"/>
            </forward>
        </view>
    </dispatch>
    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>