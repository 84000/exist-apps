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
declare variable $resource-suffix := string-join(subsequence(tokenize($exist:resource, '\.') ! lower-case(.), 2), '.');
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

declare function local:dispatch($model as xs:string?, $view as xs:string?, $parameters as node()?) as element() {
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
                        <set-header name="Expires" value="{xs:dateTime(current-dateTime()) + xs:dayTimeDuration('P7D')}"/>
                        <set-header name="X-UA-Compatible" value="IE=edge,chrome=1"/>
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
        ,
        if($resource-suffix eq 'html') then
            <error-handler>
                <forward servlet="XSLTServlet">
                    <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, "/views/html/error.xsl")}"/>
                </forward>
            </error-handler>
        else ()
        
    }
    </dispatch>
};

declare function local:dispatch-html($model as xs:string, $view as xs:string, $parameters as node()) as element() {
    local:dispatch($model, $view, $parameters)
};

declare function local:redirect($url as xs:string){
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{ $url }"/>
    </dispatch>
};

declare function local:redirect-purl(){
    
    if($common:environment/m:url[@id eq 'reading-room']) then
        
        (: Check for toh key :)
        if(matches($exist:resource,  'toh[0-9]+(\-[0-9]+)?[a-zA-Z]?$', 'i')) then
        
            (: Check it's published :)
            let $toh-key := replace($exist:resource, '.*(toh[0-9]+(\-[0-9]+)?[a-zA-Z]?)$', '$1', 'i') ! lower-case(.)
            let $tei := tei-content:tei($toh-key, 'translation')
            let $tei-publication-status := tei-content:publication-status-group($tei)
            
            where $tei
            return 
                if(matches($exist:resource,  '^wae', 'i') and $tei-publication-status eq 'published') then
                    local:redirect($common:environment/m:url[@id eq 'reading-room'] || '/translation/' || $toh-key || '.html')
                else
                    let $tei := tei-content:tei($toh-key, 'translation')
                    let $bibl := tei-content:source-bibl($tei, $toh-key)
                    let $parent-id := $bibl/tei:idno[@parent-id][1]/@parent-id/string()
                    where $parent-id gt ''
                    return
                        local:redirect($common:environment/m:url[@id eq 'reading-room'] || '/section/' || $parent-id || '.html#' || $toh-key)
        
        (: Check for UT number :)
        else if (matches($exist:resource,  '^UT.+', 'i')) then
            local:redirect($common:environment/m:url[@id eq 'reading-room'] || '/passage/' || $exist:resource || '.json')
            
        (: Exit :)
        else ()
        
    else ()
    
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
            local:dispatch("/models/section.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="lobby"/>
                    <add-parameter name="resource-suffix" value="html"/>
                </parameters>
            )
            
        (: Exist environment debug :)
        else if (lower-case($exist:resource) eq "exist-debug.xml" and $common:environment/m:enable[@type eq 'debug']) then
            $var-debug
        
        (: iOS universal links :)
        else if ($collection-path eq ".well-known" and $resource-id = ('apple-app-site-association', 'assetlinks')) then
            if($resource-id eq 'apple-app-site-association') then
                local:dispatch("/models/apple-app-site-association.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
                )
            else
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="../../../system/config/db/system/assetlinks.json">
                        <set-header name="Content-Type" value="text/javascript"/>
                    </forward>
                </dispatch>
        
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
        else if ($path = ('/resource/core/', '/resource/id/')) then
            local:redirect-purl()
        
        (: Translation :)
        else if ($collection-path eq "translation") then
            (: xml model -> json view :)
            if ($resource-suffix eq 'json') then 
                
                if(request:get-parameter('api-version', '') eq '0.2.0') then
                    local:dispatch("/models/translation.xq", "/views/json/0.2.0/translation.xq",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ $resource-id }"/>
                            <add-parameter name="resource-suffix" value="json"/>
                            <set-header name="Content-Type" value="application/json"/>
                        </parameters>
                    )
                else if(request:get-parameter('api-version', '') eq '0.3.0') then
                    local:dispatch("/views/json/0.3.0/translation.xq", "",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ $resource-id }"/>
                            <set-header name="Content-Type" value="application/json"/>
                        </parameters>
                    )
                else
                    local:dispatch("/models/translation.xq", "/views/json/translation.xq",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ $resource-id }"/>
                            <add-parameter name="resource-suffix" value="json"/>
                            <set-header name="Content-Type" value="application/json"/>
                            <set-header name="Content-Disposition" value="attachment"/>
                        </parameters>
                    )
                    
            (: xml model -> pdf view :)
            else if ($resource-suffix eq 'pdf') then (: placeholder - this is incomplete :)
                local:dispatch("/models/translation.xq", "/views/pdf/translation-fo.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="pdf"/>
                    </parameters>
                )
            (: xml model -> epub view :)
            else if ($resource-suffix eq 'epub') then
                local:dispatch("/models/translation.xq", "/views/epub/translation.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="epub"/>
                    </parameters>
                )
            (: xml model -> txt view :)
            else if ($resource-suffix eq 'txt') then
                local:dispatch("/models/translation.xq", "/views/txt/translation.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ replace($resource-id, '\-en(\-plain)?$', '') }"/>
                        <add-parameter name="resource-suffix" value="{ if(matches($resource-id, '\-en\-plain$')) then 'plain.txt' else 'txt' }"/>
                        <set-header name="Content-Type" value="text/plain"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </parameters>
                )
            (: xml model -> rdf view :)
            else if ($resource-suffix eq 'rdf') then
                local:dispatch("/models/translation.xq", "/views/rdf/translation.xsl",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="rdf"/>
                    </parameters>
                )
            (: xml model -> model sets view :)
            else if ($resource-suffix = ('tei', 'xml', 'cache', 'html')) then
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            (: default to html view :)
            else
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
        
        (: Passage :)
        else if ($collection-path eq "passage") then
            (: xml model -> model sets view :)
            if ($resource-suffix = ('xml', 'html')) then
                local:dispatch("/models/passage.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            else if ($resource-suffix eq 'json') then
                local:dispatch("/models/passage.xq", "/views/json/passage.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="json"/>
                    </parameters>
                )
            (: default to html view :)
            else
                local:dispatch("/models/passage.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
        
        (: Translations :)
        else if ($resource-id eq "translations" and $resource-suffix eq 'json') then
            local:dispatch("/views/json/0.3.0/translations.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <set-header name="Content-Type" value="application/json"/>
                </parameters>
            )
        
        (: Sections :)
        else if ($resource-id eq "sections" and $resource-suffix eq 'json' and request:get-parameter('api-version', '') eq '0.3.0') then
            local:dispatch("/views/json/0.3.0/sections.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <set-header name="Content-Type" value="application/json"/>
                </parameters>
            )
            
        (: Section :)
        else if ($collection-path eq "section") then
            (: xml model -> json view :)
            if ($resource-suffix eq 'json') then
                let $view-path := 
                    if(request:get-parameter('api-version', '') eq '0.2.0') then
                        "/views/json/0.2.0/section.xq"
                    else
                        "/views/json/section.xq"
                return
                    local:dispatch("/models/section.xq", $view-path, 
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ $resource-id }"/>
                            <add-parameter name="resource-suffix" value="json"/>
                        </parameters>
                    )
            (: xml model -> atom view :)
            else if ($resource-suffix = ('navigation.atom', 'acquisition.atom')) then
                local:dispatch("/models/section.xq", "/views/atom/section.xsl", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            (: xml model -> model sets view :)
            else if ($resource-suffix = ('tei', 'xml', 'html')) then
                local:dispatch("/models/section.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            (: default to html :)
            else
                local:dispatch("/models/section.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
        
        (: Source texts :)
        else if ($collection-path eq "source") then
            (: xml model -> json view :)
            if ($resource-suffix eq 'json') then
                local:dispatch("/models/source.xq", "/views/json/source.xq", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="json"/>
                        <set-header name="Content-Type" value="application/pdf"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </parameters>
                )
            (: xml model -> txt view :)
            else if ($resource-suffix eq'txt') then
                local:dispatch("/models/source.xq", "/views/txt/source.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ replace($resource-id, '\-bo(\-plain)?$', '') }"/>
                        <add-parameter name="resource-suffix" value="{ if(matches($resource-id, '\-bo\-plain$')) then 'plain.txt' else 'txt' }"/>
                        <set-header name="Content-Type" value="text/plain"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </parameters>
                )
            (: xml model -> model sets view :)
            else if ($resource-suffix = ('xml', 'html', 'resources')) then
                local:dispatch("/models/source.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )(::)
            (: default to html :)
            else
                local:dispatch("/models/source.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
            
        (: About :)
        else if ($collection-path eq "about") then
            local:dispatch(concat("/models/about/",  $resource-id, ".xq"), "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                </parameters>
            )
        
        (: Widget :)
        else if ($collection-path eq "widget") then
            local:dispatch(concat("/models/widget/",  $resource-id, ".xq"), "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                </parameters>
            )
        
        (: Knowledgebase :)
        else if ($resource-id eq "knowledgebase") then
            local:dispatch("/models/knowledgebase.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                </parameters>
            )
        else if ($collection-path eq "knowledgebase") then
            local:dispatch("/models/knowledgebase-article.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{ $resource-id }"/>
                    <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('tei', 'xml', 'html')], 'html')[1] }"/>
                </parameters>
            )
        
        (: Glossary :)
        else if ($collection-path eq "glossary") then
            if($resource-id = ("search", "downloads")) then
                local:dispatch("/models/glossary.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                    </parameters>
                )
            else
                local:dispatch("/models/glossary-entry.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                    </parameters>
                )
                
        (: Glossary downloads :)
        else if ($resource-id eq "glossary-download") then
            local:dispatch("/models/glossary-download.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'xlsx', 'txt', 'dict')], 'xml')[1] }"/>
                </parameters>
            )
        
        (: Schema :)
        else if ($collection-path eq "schema") then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ concat($common:data-collection, $exist:path) }"/>
            </dispatch>
        
        (: Audio / images :)
        else if ($collection-path = ("audio", "images")) then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ concat($common:data-collection, $exist:path) }"/>
            </dispatch>
        
        (: Search :)
        else if ($resource-id eq "search") then
            (: xml model -> json view :)
            if ($resource-suffix eq 'json') then
                local:dispatch("/models/search.xq", "/views/json/search.xq", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="json"/>
                    </parameters>
                )
            (: xml model -> model sets view :)
            else if ($resource-suffix = ('xml', 'html')) then
                local:dispatch("/models/search.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            (: default to html :)
            else
                local:dispatch("/models/search.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
                
        (: Downloads - used on Dist to get Collab files :)
        else if ($resource-id eq "downloads") then
            (: return the xml :)
            local:dispatch("/models/downloads.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        
        (: Redirect legacy glossary :)
        else if ($resource-id eq "glossary") then
            if(request:get-parameter('entity-id', '') gt '') then
                local:redirect(concat($common:environment/m:url[@id eq 'reading-room'], '/glossary/', request:get-parameter('entity-id', ''),'.html'))
            else
                local:redirect(concat($common:environment/m:url[@id eq 'reading-room'], '/glossary/search.html'))
        
        (: Editor :)
        (: Module located in operations app :)
        else if ($resource-id = ("tei-editor", "edit-entity", "edit-glossary", "create-article") and $common:environment/m:url[@id eq 'operations'](: and common:user-in-group('operations'):)) then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="/84000-operations/models/{ $resource-id }.xq">
                    <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                </forward>
            </dispatch>
        
        else
            (: It's data :)
            (:if($resource-suffix eq 'html') then
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="text/html"/>
                    </forward>
                </dispatch>
            else:) 
            if($resource-suffix eq 'pdf') then
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
            else if ($resource-suffix eq 'rdf') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/rdf+xml"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </forward>
                </dispatch>
            else if ($resource-suffix eq 'json') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/rdf+xml"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </forward>
                </dispatch>
            else
                (: Return an error :)
                local:dispatch((),(),())
                
    else
        (: Auth required and not given. Show login. :)
        local:auth(concat('/', $exist:path))

    