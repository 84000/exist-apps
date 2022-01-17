xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace sm = "http://exist-db.org/xquery/securitymanager";

import module namespace common="http://read.84000.co/common" at "modules/common.xql";
import module namespace download="http://read.84000.co/download" at "modules/download.xql";
import module namespace log = "http://read.84000.co/log" at "modules/log.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

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
declare variable $var-debug := 
    <debug>
        <var name="request:get-hostname()" value="{ request:get-hostname() }"/>
        <var name="request:get-remote-host()" value="{ request:get-remote-host() }"/>
        <var name="request:get-server-name()" value="{ request:get-server-name() }"/>
        {
            for $header-name in request:get-header-names()
            return
            <var name="request:get-header('{ $header-name }')" value="{ request:get-header( $header-name ) }"/>
        }
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
        <var name="common:data-path" value="{ $common:data-path }"/>
    </debug>;

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

declare function local:dispatch-html($model as xs:string, $view as xs:string, $parameters as node()) as element() {
    
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

declare function local:redirect($url as xs:string){
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
let $log-request := ()
    (:log:log-request(
        concat($exist:controller, $exist:path), 
        lower-case(substring-after($exist:controller, "/")), 
        $collection-path, 
        $resource-id, 
        $resource-suffix
    ):)

(: Process the request :)
return

    (: Robots :)
    if (lower-case($exist:resource) = ('robots.txt')) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="../../../system/config/db/system/robots.txt"/>
        </dispatch>
        
    (: Accept the client error without 404. It is logged above. :)
    else if (lower-case($exist:resource) eq "log-error.html") then (
        log:log-request(
            concat($exist:controller, $exist:path), 
            lower-case(substring-after($exist:controller, "/")), 
            $collection-path, 
            $resource-id, 
            $resource-suffix
        ),
        <response>
            <message>logged</message>
        </response>
    )
    
    (: If environment wants login then check there is some authentication :)
    else if(not(common:auth-path($collection-path)) or sm:is-authenticated()) then
        
        (: Resource redirects :)
        if ($redirects//m:resource/id(lower-case($exist:resource))) then
            local:redirect($redirects//m:resource/id(lower-case($exist:resource))[1]/parent::m:redirect/@target)
        
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
            
        (: Exist environment debug :)
        else if (lower-case($exist:resource) eq "exist-debug.xml" and $common:environment/m:enable[@type eq 'debug']) then
            $var-debug
        
        (: Spreadsheet test :)
        (:else if (lower-case($exist:resource) eq 'spreadsheet.xlsx') then
            local:dispatch("/views/spreadsheet/spreadsheet.xq", "", <parameters/>):)
        
        (: Test :)
        (:else if ($collection-path eq "test") then
            local:dispatch($exist:path, "", <parameters/>):)
        
        (: iOS universal links :)
        else if ($collection-path eq ".well-known" and $resource-id = ('apple-app-site-association')) then
            local:dispatch("/models/apple-app-site-association.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        
        (: Check for app subdomain and forward to the download page - do this after iOS universal links so these are still active on the app subdomain :)
        else if (
            $common:environment/m:url[@id eq 'communications-site'][text()]
            and $common:environment/m:url[@id eq 'app'][text()]
            and request:get-header('X-Forwarded-Host') gt ''
            and matches(
                    $common:environment/m:url[@id eq 'app']/text(), 
                    concat('^https?://', functx:escape-for-regex(request:get-header('X-Forwarded-Host'))),
                    'i'
                )
        ) then
            local:redirect($common:environment/m:url[@id eq 'communications-site'] || '/mobile')
        
        (: These are URIs redirected from purl.84000.co :)
        else if ($path eq "/resource/core/") then 
            let $toh-key := replace(lower-case($exist:resource), '.+(toh[a-z0-9\-]+).*', '$1')
            where $toh-key and $common:environment/m:url[@id eq 'reading-room']
            return 
                if(matches(lower-case($exist:resource), '^wae')) then
                    local:redirect($common:environment/m:url[@id eq 'reading-room'] || '/translation/' || $toh-key || '.html')
                else
                    let $tei := tei-content:tei($toh-key, 'translation')
                    let $bibl := tei-content:source-bibl($tei, $toh-key)
                    let $parent-id := $bibl/tei:idno[@parent-id][1]/@parent-id/string()
                    where $parent-id gt ''
                    return
                        local:redirect($common:environment/m:url[@id eq 'reading-room'] || '/section/' || $parent-id || '.html#' || $toh-key)
        
        (: Translation :)
        else if ($collection-path eq "translation") then
            if ($resource-suffix eq 'json') then (: placeholder - this is incomplete :)
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
            else
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
        
        (: Section :)
        else if ($collection-path eq "section") then
            if ($resource-suffix eq 'json') then
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
                        <add-parameter name="resource-suffix" value="{$resource-suffix}"/>
                    </parameters>
                )
        
        (: Source texts :)
        else if ($collection-path eq "source") then
            if ($resource-suffix eq 'json') then
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
                local:dispatch("/models/source.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{$resource-id}"/>
                        <add-parameter name="resource-suffix" value="{$resource-suffix}"/>
                    </parameters>
                )(::)
        
        (: Search :)
        else if ($resource-id eq "search") then
             if ($resource-suffix eq 'json') then
                local:dispatch("/models/search.xq", "/views/json/search.xq", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="json"/>
                    </parameters>
                )
            else
                local:dispatch("/models/search.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="{$resource-suffix}"/>
                    </parameters>
                )
        
        (: About :)
        else if ($collection-path eq "about") then
            local:dispatch(concat("/models/about/",  $resource-id, ".xq"), "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                </parameters>
            )
        
        (: Widget :)
        else if ($collection-path eq "widget") then
            local:dispatch(concat("/models/widget/",  $resource-id, ".xq"), "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                </parameters>
            )
        
        (: Knowledgebase :)
        else if ($collection-path eq "knowledgebase") then
            local:dispatch("/models/knowledgebase.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{$resource-id}"/>
                    <add-parameter name="resource-suffix" value="{$resource-suffix}"/>
                </parameters>
            )
        
        (: Glossary :)
        else if ($resource-id eq "glossary") then
            local:dispatch("/models/glossary.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                </parameters>
            )
        
        (: Downloads - used on Dist to get Collab files :)
        else if ($resource-id eq "downloads") then
            (: return the xml :)
            local:dispatch("/models/downloads.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        
        (: Schema :)
        else if ($collection-path eq "schema") then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ concat($common:data-collection, $exist:path) }"/>
            </dispatch>
        
        (: Audio :)
        else if ($collection-path eq "audio") then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ concat($common:data-collection, $exist:path) }"/>
            </dispatch>
        
        (: Editor :)
        (: Module located in operations app :)
        else if ($resource-id = ("tei-editor", "edit-entity") and $common:environment/m:url[@id eq 'operations'](: and common:user-in-group('operations'):)) then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="/84000-operations/models/{ $resource-id }.xq">
                    <add-parameter name="resource-suffix" value="{$resource-suffix}"/>
                </forward>
            </dispatch>
        
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
                        <set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>
                    </forward>
                </dispatch>
            else if ($resource-suffix eq 'epub') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/epub+zip"/>
                        <set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>
                    </forward>
                </dispatch>
            else if ($resource-suffix eq 'azw3') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name='Content-Type' value='application/x-mobi8-ebook'/>
                        <set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>
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

    