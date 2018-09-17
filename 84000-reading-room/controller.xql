xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "modules/common.xql";
import module namespace download="http://read.84000.co/download" at "modules/download.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $resource-id := lower-case(substring-before($exist:resource, "."));
declare variable $resource-suffix := lower-case(substring-after($exist:resource, "."));
declare variable $collection-path := lower-case(substring-before(substring-after($exist:path, "/"), "/"));
declare variable $controller-root := lower-case(substring-after($exist:controller, "/"));

declare function local:dispatch($model as xs:string, $view as xs:string, $parameters as node()) as node(){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, $model)}">
        { 
            $parameters//add-parameter 
        }
        </forward>
        {
            if($view)then
                <view>
                    <forward url="{concat($exist:controller, $view)}"/>
                </view>
            else
                ()
        }
    </dispatch>
};

declare function local:dispatch-html($model as xs:string, $view as xs:string, $parameters as node()) as node(){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, $model)}">
        {
            $parameters//add-parameter 
        }
        </forward>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, $view)}"/>
            </forward>
        </view>
        <error-handler>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, "/views/html/error.xsl")}"/>
            </forward>
        </error-handler>
    </dispatch>
};

declare function local:redirect($url){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $url }"/>
    </dispatch>
};

declare function local:has-access($model) as xs:boolean {
    sm:has-access(xs:anyURI(concat($common:app-path, $model)), 'r-x')
};

declare function local:auth($redirect){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- 
            This file has permissions. 
            If the user is not authorised then it will return 401 which should generate a login box.
        -->
        <forward url="{concat($exist:controller, "/models/auth.xq")}">
            <add-parameter name="redirect" value="{ $redirect }"/>
        </forward>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, "/views/html/auth.xsl")}"/>
            </forward>
        </view>
    </dispatch>
};

(: Log the request :)
import module namespace log = "http://read.84000.co/log" at "modules/log.xql";
log:log-request(concat($exist:controller, $exist:path), $controller-root, $collection-path, $resource-id, $resource-suffix),

(: Robots :)
if (lower-case($exist:resource) = ('robots.txt')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="../../../system/config/db/system/robots.txt"/>
    </dispatch>
    
(: Accept the client error without 404. It is logged above. :)
else if (lower-case($exist:resource) eq "log-error.html") then
    <response>
        <message>logged</message>
    </response>

(: If environment wants login then check there is some authentication :)
else if(not(common:auth-environment()) or sm:is-authenticated()) then
    
    (: Redirect to root :)
    if (lower-case($exist:resource) = ('index.html', 'index.htm')) then
        local:redirect("section/lobby.html")
    
    (: Redirects :)
    else if ($collection-path eq "resources" or $exist:resource eq "resources") then
        local:redirect($common:environment/m:url[@id eq 'resources']/text())
    else if (lower-case($exist:resource) eq 'operations.html') then
        local:redirect($common:environment/m:url[@id eq 'operations']/text())
    else if (lower-case($exist:resource) eq 'utilities.html') then
        local:redirect($common:environment/m:url[@id eq 'utilities']/text())
    else if (lower-case($exist:resource) eq 'translation-memory.html') then
        local:redirect($common:environment/m:url[@id eq 'translation-memory']/text())
    else if (lower-case($exist:resource) eq 'translator-tools.html') then
        local:redirect($common:environment/m:url[@id eq 'translator-tools']/text())
    
    (: Trap no path :) (: Trap index/home :)
    else if ($exist:path = ('', '/') or lower-case( $collection-path) = ('old-app')) then
        local:dispatch-html("/models/section.xq", "/views/html/section.xsl", 
            <parameters>
                <add-parameter name="resource-id" value="lobby"/>
            </parameters>
        )
    
    (: Spreadsheet test :)
    else if (lower-case($exist:resource) eq 'spreadsheet.xlsx') then
        local:dispatch("/views/spreadsheet/spreadsheet.xq", "", <parameters/>)

    (: Translation :)
    else if ($collection-path eq "translation") then
        if ($resource-suffix eq 'tei') then
            local:dispatch("/models/translation-tei.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                </parameters>
            )
        else if ($resource-suffix eq 'html') then
            local:dispatch-html("/models/translation.xq", "/views/html/translation.xsl", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="html"/>
                </parameters>
            )
        else if ($resource-suffix eq 'json') then (: placeholder - this is incomplete :)
            local:dispatch("/models/translation.xq", "/views/json/xmlToJson.xq",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="json"/>
                </parameters>
            )
        else if ($resource-suffix eq 'pdf') then (: placeholder - this is incomplete :)
            local:dispatch("/models/translation.xq", "/views/pdf/translation-fo.xq",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="pdf"/>
                </parameters>
            )
        else if ($resource-suffix eq 'epub') then
            local:dispatch("/models/translation.xq", "/views/epub/translation.xq",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="epub"/>
                </parameters>
            )
        else
            (: return the xml :)
            if (request:get-parameter('folio', '') gt '') then
                local:dispatch("/models/folio.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="xml"/>
                    </parameters>
                )
            else
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="xml"/>
                    </parameters>
                )
    
    (: Section :)
    else if ($collection-path eq "section") then
        if ($resource-suffix eq 'tei') then
            local:dispatch("/models/section-tei.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                </parameters>
            )
        else if ($resource-suffix eq 'html') then
            local:dispatch-html("/models/section.xq", "/views/html/section.xsl", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="html"/>
                </parameters>
            )
        else if ($resource-suffix eq 'json') then
            local:dispatch("/models/section.xq", "/views/json/xmlToJson.xq", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="json"/>
                </parameters>
            )
        else
            (: return the xml :)
            local:dispatch("/models/section.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="xml"/>
                </parameters>
            )
    
    (: Source texts :)
    else if ($collection-path eq "source") then
        if ($resource-suffix eq 'html') then
            local:dispatch-html("/models/source.xq", "/views/html/source.xsl", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="html"/>
                </parameters>
            )
        else if ($resource-suffix eq 'json') then
            local:dispatch("/models/source.xq", "/views/json/xmlToJson.xq", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="json"/>
                </parameters>
            )
        else
            (: return the xml :)
            local:dispatch("/models/source.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="xml"/>
                </parameters>
            )
    
    (: Search :)
    else if ($resource-id eq "search") then
        if ($resource-suffix eq 'html') then
            local:dispatch-html("/models/search.xq", "/views/html/search.xsl", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        else
            (: return the xml :)
            local:dispatch("/models/search.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
    
    (: About :)
    else if ($collection-path eq "about") then
        if ($resource-suffix eq 'html') then
            local:dispatch-html(concat("/models/about/",  $resource-id, ".xq"), concat("/views/html/about/",  $resource-id, ".xsl"), 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        else
            (: return the xml :)
            local:dispatch(concat("/models/about/",  $resource-id, ".xq"), "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        
    else
        (: It's data :)
        if($resource-suffix eq 'pdf') then
            (:<response>{ concat($common:data-path, '/pdf/',  $exist:resource) }</response>:)
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ download:file-path($exist:resource) }">
                    <set-header name="Content-Type" value="application/pdf"/>
                    <set-header name="Content-Disposition" value="attachment"/>
                </forward>
            </dispatch>
        else if ($resource-suffix eq 'epub') then
             <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ download:file-path($exist:resource) }">
                    <set-header name="Content-Type" value="application/epub+zip"/>
                    <set-header name="Content-Disposition" value="attachment"/>
                </forward>
            </dispatch>
        else if ($resource-suffix eq 'azw3') then
             <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ download:file-path($exist:resource) }">
                    <set-header name="Content-Type" value="application/x-mobi8-ebook"/>
                    <set-header name="Content-Disposition" value="attachment"/>
                </forward>
            </dispatch>
        else
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ $exist:path }">
                    <set-header name="Content-Type" value="text/xml"/>
                    <set-header name="Content-Disposition" value="attachment"/>
                </forward>
            </dispatch>
            
else
    (: Auth required and not given. Show login. :)
    local:auth(concat('/', $exist:path))

    