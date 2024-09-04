xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace sm = "http://exist-db.org/xquery/securitymanager";

import module namespace common="http://read.84000.co/common" at "modules/common.xql";
import module namespace log = "http://read.84000.co/log" at "modules/log.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "modules/translation.xql";
(:import module namespace store="http://read.84000.co/store" at "modules/store.xql";:)
(:import module namespace functx="http://www.functx.com";:)

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $resource-id := $exist:resource[matches(., '\.')][. gt ''] ! tokenize(., '\.')[1] ! lower-case(.);
declare variable $resource-suffix := string-join(subsequence(tokenize($exist:resource, '\.'), 2), '.') ! lower-case(.);
(: ISSUE - path parameters are case sensitive :)
declare variable $path := ($resource-id ! substring-before($exist:path, $exist:resource), $exist:path)[1];
declare variable $path-tokens := tokenize(replace($path, '^/', ''), '/');
declare variable $collection-path := tokenize($exist:path, '/')[2] ! lower-case(.);
declare variable $redirects := doc('/db/system/config/db/system/redirects.xml')/m:redirects;
declare variable $user-name := common:user-name();
declare variable $api-version := (request:get-parameter('api-version', '')[. = ('0.1.0','0.2.0','0.3.0','0.4.0')], '0.4.0')[1];
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
        <var name="api-version" value="{ $api-version }"/>
    </debug>;

declare function local:dispatch($model as xs:string?, $view as xs:string?, $parameters as node()?) as element() {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    {
        
        (: Model optional :)
        if($model)then
            <forward url="{concat($exist:controller, $model)}">
            { 
                $parameters//add-parameter,
                $parameters//set-attribute
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
                        $parameters//add-parameter,
                        $parameters//set-attribute,
                        $parameters//set-header
                    }
                    </forward>
            }
            </view>
        else ()
        ,
        
        (: Error page :)
        if($resource-suffix = ('html','pdf','epub')) then
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
                    local:redirect(concat($common:environment/m:url[@id eq 'reading-room'], translation:href($toh-key, (), (), (), ())))
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
        substring-after($exist:controller, "/") ! lower-case(.), 
        $collection-path, 
        $resource-id, 
        $resource-suffix
    ):)

(: Process the request :)
return

    (: robots.txt :)
    if ($exist:resource ! lower-case(.) = ('robots.txt')) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="../../../system/config/db/system/robots.txt"/>
        </dispatch>
    
    (: Dynamic robots.txt disallowing restricted texts :)
    else if ($exist:resource ! lower-case(.) = ('robots-public.txt')) then
        local:dispatch("/models/robots-public.xq", "", 
            <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
        )
    
    (: Accept the client error without 404. It is logged above. :)
    else if ($exist:resource ! lower-case(.) eq "log-error.html") then (
        log:log-request(
            concat($exist:controller, $exist:path), 
            substring-after($exist:controller, "/") ! lower-case(.), 
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
        
        (: Sitemap :)
        if ($exist:resource ! lower-case(.) = ('sitemap.xml')) then
            local:dispatch("/models/sitemap.xq", "", ())
        
        (: Resource redirects :)
        else if ($redirects//m:resource/id($exist:resource ! lower-case(.))) then
            local:redirect($redirects//m:resource/id($exist:resource ! lower-case(.))[1]/parent::m:redirect/@target)
        
        (: Restrict view to single resource :)
        else if($redirects/m:redirect[@user-name eq $user-name][not(@resource-id eq $resource-id)]) then
            local:redirect($redirects/m:redirect[@user-name eq $user-name][1]/@target)
            
        (: Trap no path :) (: Trap index/home :)
        else if ($exist:path = ('', '/') or $collection-path ! lower-case(.) = ('old-app')) then
            local:dispatch("/models/section.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="lobby"/>
                    <add-parameter name="resource-suffix" value="html"/>
                </parameters>
            )
        
        (: Exist environment debug :)
        else if ($exist:resource ! lower-case(.) eq "exist-debug.xml" and $common:environment/m:enable[@type eq 'debug']) then
            $var-debug
        
        (: iOS universal links :)
        else if ($collection-path eq ".well-known" and $path-tokens[2] = ('apple-app-site-association', 'assetlinks')) then
            if($path-tokens[2] eq 'apple-app-site-association') then
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
            (:and $common:environment/m:url[@id eq 'app'][text()]:)
            and request:get-header('X-Forwarded-Host') gt ''
            and matches(
                    request:get-header('X-Forwarded-Host'), 
                    '^https?://app\.84000(\.co|\-translate\.org|\.local)',
                    'i'
                )
        
        ) then
            local:redirect($common:environment/m:url[@id eq 'communications-site'] || '/mobile')
        
        (: These are URIs redirected from purl.84000.co :)
        else if ($path ! lower-case(.) = ('/resource/core/', '/resource/id/')) then
            local:redirect-purl()
        
        (: Translation :)
        else if ($collection-path eq "translation") then
        
            (: xml model -> json view :)
            if ($resource-suffix eq 'json') then 
                
                (: 0.1.0 get xml, pass to json view, and download :)
                if($api-version eq '0.1.0') then
                    local:dispatch("/models/translation.xq", "/views/json/translation.xq",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                            <add-parameter name="resource-suffix" value="json"/>
                            <set-header name="Content-Type" value="application/json"/>
                            <set-header name="Content-Disposition" value="attachment"/>
                        </parameters>
                    )
                
                (: 0.2.0 get xml, pass to json view :)
                else if($api-version eq '0.2.0') then
                    local:dispatch("/models/translation.xq", "/views/json/0.2.0/translation.xq",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                            <add-parameter name="resource-suffix" value="json"/>
                            <set-header name="Content-Type" value="application/json"/>
                        </parameters>
                    )
                
                (: 0.3.0 pass to json view :)
                else if($api-version eq '0.3.0') then
                    local:dispatch("/views/json/0.3.0/translation.xq", "",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                            <set-header name="Content-Type" value="application/json"/>
                        </parameters>
                    )
                
                (: 0.4.0 get html, pass to json view :)
                else 
                    local:dispatch("/models/translation.xq", "/views/json/0.4.0/translation.xq",
                        <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                            <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                            <add-parameter name="resource-suffix" value="xhtml"/><!-- pass xhtml to json/0.4.0/translation.xq -->
                            <add-parameter name="view-mode" value="app"/>
                            <set-header name="Content-Type" value="application/json"/>
                        </parameters>
                    )
            
            (: xml model -> pdf view :)
            else if ($resource-suffix eq 'pdf') then 
                local:dispatch("/views/pdf/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                        <add-parameter name="resource-suffix" value="pdf"/>
                        <add-parameter name="resource-requested" value="{ $exist:resource }"/>
                        <!--<set-header name="Content-Type" value="application/pdf"/>-->
                        <!--<set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>-->
                    </parameters>
                )
            
            (: xml model -> epub view :)
            else if ($resource-suffix eq 'epub') then
                local:dispatch("/models/translation.xq", "/views/epub/translation.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                        <add-parameter name="resource-suffix" value="epub"/>
                        <add-parameter name="resource-requested" value="{ $exist:resource }"/>
                        <!--<set-header name="Content-Type" value="application/epub+zip"/>-->
                        <!--<set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>-->
                    </parameters>
                )
            
            (: xml model -> txt view :)
            else if ($resource-suffix eq 'txt') then
                local:dispatch("/models/translation.xq", "/views/txt/translation.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ replace(., '\-en(\-plain)?$', '') }"/>
                        <add-parameter name="resource-suffix" value="{ if(matches($resource-id, '\-en\-plain$')) then 'plain.txt' else 'txt' }"/>
                        <set-header name="Content-Type" value="text/plain"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </parameters>
                )
            
            (: xml model -> rdf view :)
            else if ($resource-suffix eq 'rdf') then
                local:dispatch("/models/translation.xq", "/views/rdf/translation.xsl",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                        <add-parameter name="resource-suffix" value="rdf"/>
                    </parameters>
                )
            
            (: xml model -> model sets view :)
            else if ($resource-suffix = ('tei', 'xml', 'cache', 'glossary-locations.xml')) then
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ ($path-tokens[2][. gt ''], tokenize($resource-id, '_'))[1] }"/>
                        <add-parameter name="part" value="{ $path-tokens[3] }"/>
                        <add-parameter name="commentary" value="{ $path-tokens[4] }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            
            (: default to html view :)
            else
                local:dispatch("/models/translation.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ ($path-tokens[2][. gt ''], tokenize($resource-id, '_'))[1] }"/>
                        <add-parameter name="part" value="{ $path-tokens[3] }"/>
                        <add-parameter name="commentary" value="{ $path-tokens[4] }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
        
        (: Passage :)
        else if ($collection-path eq "passage") then
            (: xml model -> model sets view :)
            if ($resource-suffix = ('xml', 'html')) then
                local:dispatch("/models/passage.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )
            
            else if ($resource-suffix eq 'json') then
                local:dispatch("/models/passage.xq", "/views/json/passage.xq",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                        <add-parameter name="resource-suffix" value="json"/>
                    </parameters>
                )
             
            (: default to html view :)
            else
                local:dispatch("/models/passage.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ tokenize($resource-id, '_')[1] }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
        
        (: Translations :)
        else if ($resource-id eq "translations" and $resource-suffix eq 'json') then
            local:dispatch(string-join(("/views/json", ($api-version[. = ('0.3.0')], '0.3.0')[1],"translations.xq"),'/'), "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <set-attribute name="api-version" value="{ $api-version }"/>
                    <set-header name="Content-Type" value="application/json"/>
                </parameters>
            )
        
        (: Sections :)
        else if ($resource-id eq "sections" and $resource-suffix eq 'json') then
            local:dispatch(string-join(("/views/json", ($api-version[. = ('0.3.0')], '0.3.0')[1],"sections.xq"),'/'), "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <set-attribute name="api-version" value="{ $api-version }"/>
                    <set-header name="Content-Type" value="application/json"/>
                </parameters>
            )
        
        (: Section :)
        else if ($collection-path eq "section") then
            (: xml model -> json view :)
            (: default to "/views/json/0.0.3/section.xq" :)
            if ($resource-suffix eq 'json') then
                local:dispatch("/models/section.xq", string-join(("/views/json", ($api-version[. = ('0.2.0','0.3.0')], '0.3.0')[1], "section.xq"), '/'), 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="json"/>
                        <set-attribute name="api-version" value="{ $api-version }"/>
                    </parameters>
                )
            
            (: xml model -> atom view :)
            (:else if ($resource-suffix = ('navigation.atom', 'acquisition.atom')) then
                local:dispatch("/models/section.xq", "/views/atom/section.xsl", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                ):)
            
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
                        <add-parameter name="resource-id" value="{ ($path-tokens[2][. gt ''], $resource-id)[1] }"/>
                        <add-parameter name="ref-index" value="{ $path-tokens[4] }"/>
                        <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    </parameters>
                )(::)
            
            (: default to html :)
            else
                local:dispatch("/models/source.xq", "", 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ ($path-tokens[2][. gt ''], $resource-id)[1] }"/>
                        <add-parameter name="ref-index" value="{ $path-tokens[4] }"/>
                        <add-parameter name="resource-suffix" value="html"/>
                    </parameters>
                )
                
        (: About :)
        else if ($collection-path eq "about") then 
            if ($resource-suffix eq 'json') then
                local:dispatch(concat("/models/about/",  $resource-id, ".xq"), string-join(("/views/json", ($api-version[. = ('0.4.0')], '0.4.0')[1], "about.xq"), '/'), 
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <set-attribute name="api-version" value="{ $api-version }"/>
                        <set-header name="Content-Type" value="application/json"/>
                    </parameters>
                )
            
            else 
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
        
        (: TM search :)
        else if ($collection-path eq "tm" and $resource-id eq 'search' and $resource-suffix eq 'json') then
            local:dispatch("/views/json/0.4.0/tm-search.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <set-header name="Content-Type" value="application/json"/>
                </parameters>
            )
        
        (: Glossary :)
        else if ($collection-path = ("glossary", "glossary-embedded")) then
            if($resource-id eq 'search' and $resource-suffix eq 'json') then
                local:dispatch("/views/json/0.4.0/glossary-search.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <set-header name="Content-Type" value="application/json"/>
                    </parameters>
                )
            
            else if($resource-id = ("search", "downloads")) then
                local:dispatch("/models/glossary.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ $resource-id }"/>
                        <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                        {
                            if($collection-path eq "glossary-embedded") then
                                <add-parameter name="template" value="embedded"/>
                            else ()
                        }
                    </parameters>
                )
            
            else
                local:dispatch("/models/glossary-entry.xq", "",
                    <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                        <add-parameter name="resource-id" value="{ ($path-tokens[2][. gt ''], $resource-id)[1] }"/>
                        <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'html')], 'html')[1] }"/>
                        {
                            if($collection-path eq "glossary-embedded") then
                                <add-parameter name="template" value="embedded"/>
                            else ()
                        }
                    </parameters>
                )
        
        (: Glossary downloads :)
        else if ($resource-id = ("glossary-download", "glossary-download-bo", "glossary-download-wy")) then
            local:dispatch("/models/glossary-download.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-id" value="{ $resource-id }"/>
                    <add-parameter name="resource-suffix" value="{ ($resource-suffix[. = ('xml', 'xlsx', 'txt', 'dict')], 'xml')[1] }"/>
                </parameters>
            )
        
        (: Other Rest endpoints :)
        else if ($collection-path eq "rest" and $resource-id = ('texts-status') and $resource-suffix eq 'json') then
            local:dispatch(concat("/views/json/0.4.0/", $resource-id, ".xq"), "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <set-header name="Content-Type" value="application/json"/>
                </parameters>
            )
        
        (: Schema :)
        else if ($collection-path eq "schema") then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ concat($common:data-collection, $exist:path) }"/>
            </dispatch>
        
        (: Stylesheets, javascript and other front-end :)
        else if($collection-path eq 'frontend' and $resource-suffix = ('css','js','min.js','svg','png','ttf','otf','eot','svg','woff','woff2')) then 
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ string-join(($common:static-content-collection, $exist:path)) }">
                    <set-header name="Content-Type" value="{ 
                        if($resource-suffix eq 'css') then 'text/css'
                        else if($resource-suffix eq 'svg') then 'image/svg+xml'
                        else if($resource-suffix eq 'png') then 'image/png'
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
        
        (: Audio / images :)
        else if ($collection-path = ("audio", "images")) then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{ string-join(($common:static-content-collection, $exist:path)) }"/>
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
        
        else if ($resource-id eq "search-tm-embedded") then
            local:dispatch("/models/search.xq", "",
                <parameters xmlns="http://exist.sourceforge.net/NS/exist">
                    <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                    <add-parameter name="template" value="embedded"/>
                    <add-parameter name="search-type" value="tm"/>
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
        
        (: work-ids :)
        else if ($resource-id eq "work-ids") then
            (: return the xml :)
            local:dispatch("/models/work-ids.xq", "", 
                <parameters xmlns="http://exist.sourceforge.net/NS/exist"/>
            )
        
        (: Editor :)
        (: Module located in operations app :)
        else if ($resource-id = ("tei-editor", "edit-entity", "edit-glossary", "create-article") and $common:environment/m:url[@id eq 'operations'](: and common:user-in-group('operations'):)) then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="/84000-operations/models/{ $resource-id }.xq">
                    <add-parameter name="resource-suffix" value="{ $resource-suffix }"/>
                </forward>
            </dispatch>
        
        (:else
            (\: It's data :\)
            (\:if($resource-suffix eq 'html') then
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ download:file-path($exist:resource) }">
                        <set-header name="Content-Type" value="text/html"/>
                    </forward>
                </dispatch>
            else:\) 
            if($resource-suffix eq 'pdf') then
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ store:download-file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/pdf"/>
                        <set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>
                    </forward>
                </dispatch>
            
            else if ($resource-suffix eq 'epub') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ store:download-file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/epub+zip"/>
                        <set-header name='Content-Disposition' value='attachment; filename="{ $exist:resource }"'/>
                    </forward>
                </dispatch>
            
            else if ($resource-suffix eq 'rdf') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ store:download-file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/rdf+xml"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </forward>
                </dispatch>
            
            else if ($resource-suffix eq 'json') then
                 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{ store:download-file-path($exist:resource) }">
                        <set-header name="Content-Type" value="application/json"/>
                        <set-header name="Content-Disposition" value="attachment"/>
                    </forward>
                </dispatch>:)
        
        else
            (: Return an error :)
            local:dispatch((),(),())
                
    else
        (: Auth required and not given. Show login. :)
        local:auth(concat('/', $exist:path))

    