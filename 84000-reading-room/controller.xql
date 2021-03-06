xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "modules/common.xql";
import module namespace download="http://read.84000.co/download" at "modules/download.xql";
import module namespace log = "http://read.84000.co/log" at "modules/log.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $path := lower-case(substring-before($exist:path, $exist:resource));
declare variable $resource-id := lower-case(replace($exist:resource, '\..*', ''));
declare variable $resource-suffix := lower-case(replace($exist:resource, '.*\.', ''));
declare variable $collection-path := lower-case(tokenize($exist:path, '/')[2]);
declare variable $redirects := doc('/db/system/config/db/system/redirects.xml')/m:redirects;
declare variable $user-name := common:user-name();
(:declare variable $var-debug := 
    <debug>
        <var name="exist:path" value="{ $exist:path }"/>
        <var name="exist:resource" value="{ $exist:resource }"/>
        <var name="exist:controller" value="{ $exist:controller }"/>
        <var name="exist:prefix" value="{ $exist:prefix }"/>
        <var name="exist:root" value="{ $exist:root }"/>
        <var name="path" value="{ $path }"/>
        <var name="resource-id" value="{ $resource-id }"/>
        <var name="resource-suffix" value="{ $resource-suffix }"/>
        <var name="collection-path" value="{ $collection-path }"/>
        <var name="user-name" value="{ $user-name }"/>
    </debug>;:)

declare function local:dispatch($model as xs:string?, $view as xs:string?, $parameters as node()?) as node(){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    {
        (: Model optional :)
        if($model)then
            <forward url="{concat($exist:controller, $model)}">
            { 
                $parameters//add-parameter
            }
            </forward>
        else ()
        ,
        (: View optional :)
        if($view)then
            <view>
            {
                if(ends-with($view, '.xsl')) then
                    <forward servlet="XSLTServlet">
                        <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, $view)}"/>
                        { 
                            $parameters//set-header
                        }
                    </forward>
                else
                    <forward url="{concat($exist:controller, $view)}">
                    { 
                        $parameters//set-header
                    }
                    </forward>
            }
            </view>
        else ()
    }
    </dispatch>
};

declare function local:dispatch-html($model as xs:string, $view as xs:string, $parameters as node()) as node(){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    
        <!-- Model -->
        <forward url="{concat($exist:controller, $model)}">
        {
            $parameters//add-parameter 
        }
        </forward>
        
        <!-- View -->
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, $view)}"/>
                <set-header name="Expires" value="{xs:dateTime(current-dateTime()) + xs:dayTimeDuration('P7D')}"/>
                <set-header name="X-UA-Compatible" value="IE=edge,chrome=1"/>
                { 
                    $parameters//set-header
                }
            </forward>
        </view>
        
        <!-- Error -->
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
(: Suspend this, we don't really use it and it's become an overhead (since deferred parsing was added?) :)
(: Perhaps re-instate when we understand the slowness :)
let $log-request := log:log-request(concat($exist:controller, $exist:path), lower-case(substring-after($exist:controller, "/")), $collection-path, $resource-id, $resource-suffix)

(: Process the request :)
return
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
    else if(not(common:auth-path($collection-path)) or sm:is-authenticated()) then
        
        (: Resource redirects :)
        if (lower-case($exist:resource) = $redirects//m:resource/@xml:id) then
            local:redirect($redirects//m:resource[@xml:id = lower-case($exist:resource)][1]/parent::m:redirect/@target)
        
        (: Restrict view to single resource :)
        else if($redirects/m:redirect[@user-name eq $user-name][not(@resource-id eq $resource-id)]) then
            local:redirect($redirects/m:redirect[@user-name eq $user-name][1]/@target)
            
        (: Trap no path :) (: Trap index/home :)
        else if ($exist:path = ('', '/') or lower-case($collection-path) = ('old-app')) then
            local:dispatch-html("/models/section.xq", "/views/html/section.xsl", 
                <parameters>
                    <add-parameter name="resource-id" value="lobby.html"/>
                </parameters>
            )
        
        (: Spreadsheet test :)
        (:else if (lower-case($exist:resource) eq 'spreadsheet.xlsx') then
            local:dispatch("/views/spreadsheet/spreadsheet.xq", "", <parameters/>):)
        
        (: Test :)
        (:else if ($collection-path eq "test") then
            local:dispatch($exist:path, "", <parameters/>):)
        
        (: These are URIs redirected from purl.84000.co :)
        else if ($path eq "/resource/core/") then
            local:redirect($common:environment/m:url[@id eq 'reading-room'] || '/translation/' || substring-after(lower-case($exist:resource), 'wae') || '.html')
        
        (: Translation :)
        else if ($collection-path eq "translation") then
            if ($resource-suffix eq 'tei') then
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="tei"/>
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
                local:dispatch("/models/translation.xq", "/views/json/translation.xq",
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
            else if ($resource-suffix eq 'txt') then
                local:dispatch("/models/translation.xq", "/views/txt/translation.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ replace($resource-id, '\-en$', '') }"/>
                        <add-parameter name="resource-suffix" value="txt"/>
                        <set-header name="Content-Type" value="text/plain"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </parameters>
                )
            else if ($resource-suffix eq 'rdf') then
                local:dispatch("/models/translation.xq", "/views/rdf/translation.xsl",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="rdf"/>
                    </parameters>
                )
            else if ($resource-suffix eq 'cache') then
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="cache"/>
                    </parameters>
                )
            else
                (: return the xml :)
                if (request:get-parameter('page', request:get-parameter('folio', '')) gt '') then
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
                local:dispatch("/models/section.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="tei"/>
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
                let $view-path := 
                    if(request:get-parameter('api-version', '') eq '0.2.0') then
                        "/views/json/0.2.0/section.xq"
                    else
                        "/views/json/section.xq"
                return
                    local:dispatch("/models/section.xq", $view-path, 
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{$resource-id}"/>
                            <add-parameter name="resource-suffix" value="json"/>
                        </parameters>
                    )
            else if ($resource-suffix = ('navigation.atom', 'acquisition.atom')) then
                local:dispatch("/models/section.xq", "/views/atom/section.xsl", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
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
                local:dispatch("/models/source.xq", "/views/json/source.xq", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="json"/>
                    </parameters>
                )
            else if ($resource-suffix eq'txt') then
                local:dispatch("/models/source.xq", "/views/txt/source.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ replace($resource-id, '\-bo$', '') }"/>
                        <add-parameter name="resource-suffix" value="txt"/>
                        <set-header name="Content-Type" value="text/plain"/>
                        <set-header name="Content-Disposition" value="attachment"/>
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
            else if ($resource-suffix eq 'json') then
                local:dispatch("/models/search.xq", "/views/json/search.xq", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="json"/>
                    </parameters>
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
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
            else
                (: return the xml :)
                local:dispatch(concat("/models/about/",  $resource-id, ".xq"), "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
                )
        
        (: Widget :)
        else if ($collection-path eq "widget") then
            if ($resource-suffix eq 'html') then
                local:dispatch-html(concat("/models/widget/",  $resource-id, ".xq"), concat("/views/html/widget/",  $resource-id, ".xsl"), 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
            else
                (: return the xml :)
                local:dispatch(concat("/models/widget/",  $resource-id, ".xq"), "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
                )
        
        (: Knowledgebase :)
        else if ($collection-path eq "knowledgebase") then
            if ($resource-suffix eq 'tei') then
                local:dispatch("/models/knowledgebase.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="tei"/>
                    </parameters>
                )
            else if ($resource-suffix eq 'html') then
                local:dispatch-html("/models/knowledgebase.xq", "/views/html/knowledgebase.xsl", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
            else
                (: return the xml :)
                local:dispatch("/models/knowledgebase.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="xml"/>
                    </parameters>
                )
        
        (: Downloads - used on Dist to get Collab files :)
        else if ($resource-id eq "downloads") then
            (: return the xml :)
            local:dispatch("/models/downloads.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        
        (: Sitemap - returns a site map for a multi chapter text - used for PDF generation :)
        else if ($collection-path eq "sitemap") then
            (: return the xml :)
            local:dispatch("/models/sitemap.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                </parameters>
            )
            
        else
            (: It's data :)
            if($resource-suffix eq 'html') then
                (:<response>{ download:file-path($exist:resource) }</response>:)
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="text/html"/>
                    </forward>
                </dispatch>
            else if($resource-suffix eq 'pdf') then
                (:<response>{ download:file-path($exist:resource) }</response>:)
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
            else if ($resource-suffix eq 'rdf') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/rdf+xml"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </forward>
                </dispatch>
            else
                (: Return an error :)
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <error-handler>
                        <forward servlet="XSLTServlet">
                            <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, "/views/html/error.xsl")}"/>
                        </forward>
                    </error-handler>
                </dispatch>
                
    else
        (: Auth required and not given. Show login. :)
        local:auth(concat('/', $exist:path))

    