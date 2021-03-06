xquery version "3.0";

import module namespace file-upload="http://operations.84000.co/file-upload" at "modules/file-upload.xql";

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

else if ($exist:path = ('', '/') or $exist:resource = ('index.htm')) then
    (: forward root path to index.html :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

else if ($resource-suffix = ('xml')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{ concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq') }"/>
    </dispatch>
    
else if ($resource-suffix = ('html')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{ concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq') }"/>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{ concat($exist:root, $exist:controller, '/views/', substring-before($exist:resource, '.'), '.xsl') }"/>
            </forward>
        </view>
        <cache-control cache="no"/>
        <!--
        <error-handler>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, "/84000-reading-room", "/views/html/error.xsl")}"/>
            </forward>
        </error-handler>
        -->
    </dispatch>

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
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>