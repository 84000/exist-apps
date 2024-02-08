xquery version "3.0";

<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <redirect url="https://84000.co/resources/for-translators"/>
</dispatch>

(:
declare namespace m = "http://read.84000.co/ns/1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $resource-id := lower-case(substring-before($exist:resource, "."));
declare variable $resource-suffix := lower-case(substring-after($exist:resource, "."));
declare variable $collection-path := lower-case(substring-before(substring-after($exist:path, "/"), "/"));
declare variable $controller-root := lower-case(substring-after($exist:controller, "/"));

import module namespace common="http://read.84000.co/common" at "../84000-reading-room/modules/common.xql";

(\: Log the request :\)
import module namespace log = "http://read.84000.co/log" at "../84000-reading-room/modules/log.xql";

(\:log:log-request(concat($exist:controller, $exist:path), $controller-root, $collection-path, $resource-id, $resource-suffix),:\)

(\: Accept the client error without 404. It is logged above. :\)
if (lower-case($exist:resource) eq "log-error.html") then
    <response>
        <message>logged</message>
    </response>

else if ($exist:path = ('', '/') or $exist:resource = ('index.htm')) then
    (\: forward root path to translations.html :\)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

(\: Legacy tab :\)
else if(request:get-parameter('tab','') ! lower-case(.) eq 'search') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $common:environment/m:url[@id eq 'reading-room'] }/search.html"/>
    </dispatch>

(\: Legacy tab :\)
else if(request:get-parameter('tab','') ! lower-case(.) eq 'tm-search') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $common:environment/m:url[@id eq 'reading-room'] }/search.html?search-type=tm"/>
    </dispatch>

(\: Legacy tab :\)
else if(request:get-parameter('tab','') ! lower-case(.) eq 'glossary') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $common:environment/m:url[@id eq 'reading-room'] }/glossary/search.html"/>
    </dispatch>

(\: Legacy tab :\)
else if(request:get-parameter('tab','') ! lower-case(.) eq 'translations') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $common:environment/m:url[@id eq 'reading-room'] }/section/all-translated.html"/>
    </dispatch>

else if (ends-with($exist:resource, ".xml")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq')}"/>
    </dispatch>
    
else if (ends-with($exist:resource, ".html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/models/', substring-before($exist:resource, '.'), '.xq')}"/>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, '/views/', substring-before($exist:resource, '.'), '.xsl')}"/>
            </forward>
        </view>
        <!--
        <error-handler>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, "/84000-reading-room", "/views/html/error.xsl")}"/>
            </forward>
        </error-handler>
        -->
    </dispatch>

(\: Cumulative glossary download :\)
else if (lower-case($resource-id) eq 'cumulative-glossary') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $common:environment/m:url[@id eq 'reading-room'] }/glossary/downloads.html"/>
    </dispatch>
    
else
    (\: pass to data :\)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{ $exist:path }">
            <set-header name="Content-Disposition" value="attachment"/>
        </forward>
    </dispatch>:)
    
    