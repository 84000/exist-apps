<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <!-- include navigation stylesheet -->
    <xsl:import href="../../xslt/84000-html.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'" as="xs:string"/>
    <xsl:variable name="environment" select="doc($environment-path)/m:environment" as="element(m:environment)"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()" as="xs:string"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="communications-site-path" select="$environment/m:url[@id eq 'communications-site']/text()" as="xs:string"/>
    <xsl:variable name="app-version" select="if(/m:response/@app-version) then /m:response/@app-version else 'unknown'" as="xs:string"/>
    <xsl:variable name="ga-tracking-id" select="$environment/m:google-analytics/@tracking-id" as="xs:string"/>
    
    <!-- get shared html -->
    <xsl:variable name="eft-header" select="doc('../../xslt/84000-header.xml')/m:eft-header" as="element(m:eft-header)"/>
    <xsl:variable name="eft-footer" select="doc('../../xslt/84000-footer.xml')/m:eft-footer" as="element(m:eft-footer)"/>
    
    <!-- language -->
    <xsl:variable name="lang" select="if(/m:response/@lang) then /m:response/@lang else 'en'" as="xs:string"/>
    
    <!-- view-mode -->
    <xsl:variable name="view-mode" select="/m:response/m:request/@view-mode" as="xs:string?"/>
    
    <!-- override navigation params -->
    <xsl:variable name="active-url" as="xs:string">
        <!-- <xsl:value-of select="common:internal-link('http://read.84000.co/', (), '', $lang)"/> -->
        <xsl:choose>
            <xsl:when test="/m:response/m:section/@id eq 'ALL-TRANSLATED'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/section/all-translated.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/m:section/@id eq 'LOBBY'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/section/lobby.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'search'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/search.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/sponsors'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/about/sponsors.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/impact'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/about/impact.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/progress'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/about/progress.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/translators'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/about/translators.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/sponsor-a-sutra'">
                <xsl:value-of select="common:internal-link('http://read.84000.co/about/sponsor-a-sutra.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="common:internal-link('#reading-room', (), '', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="local-comms-url" select="$communications-site-path" as="xs:string"/>
    <xsl:variable name="local-reading-room-url" select="$reading-room-path" as="xs:string"/>
    <xsl:variable name="local-front-end-url" select="$front-end-path" as="xs:string"/>
    <xsl:variable name="default-search-form-target" select="'reading-room'" as="xs:string"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat" omit-xml-declaration="yes"/>
    
    <!-- html head tag -->
    <xsl:template name="html-head">
        
        <xsl:param name="front-end-path" required="yes" as="xs:string"/>
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="page-type" required="yes" as="xs:string"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        
        <head>
            
            <meta charset="utf-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0"/>
            <meta name="description" content="84000 is a non-profit global initiative to translate the words of the Buddha and make them available to everyone."/>
            
            <title>
                <xsl:value-of select="$page-title"/>
            </title>
            
            <link rel="stylesheet" type="text/css">
                <xsl:choose>
                    <xsl:when test="$page-type = ('communications')">
                        <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-comms.css', '?v=', $app-version)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-reading-room.css', '?v=', $app-version)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </link>
            <link rel="stylesheet" type="text/css">
                <xsl:attribute name="href" select="concat($front-end-path, '/css/ie10-viewport-bug-workaround.css')"/>
            </link>
            <!--[if lt IE 9]>
                <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
            <![endif]-->
            <link rel="apple-touch-icon" sizes="180x180">
                <xsl:attribute name="href" select="concat($front-end-path, '/favicon/apple-touch-icon.png')"/>
            </link>
            <link rel="icon" type="image/png" sizes="32x32">
                <xsl:attribute name="href" select="concat($front-end-path, '/favicon/favicon-32x32.png')"/>
            </link>
            <link rel="icon" type="image/png" sizes="16x16">
                <xsl:attribute name="href" select="concat($front-end-path, '/favicon/favicon-16x16.png')"/>
            </link>
            <link rel="manifest">
                <xsl:attribute name="href" select="concat($front-end-path, '/favicon/manifest.json')"/>
            </link>
            <link rel="mask-icon" color="#ffffff">
                <xsl:attribute name="href" select="concat($front-end-path, '/favicon/safari-pinned-tab.svg')"/>
            </link>
            <link rel="shortcut icon">
                <xsl:attribute name="href" select="concat($front-end-path, '/favicon/favicon.ico')"/>
            </link>
            <link rel="canonical">
                <xsl:attribute name="href" select="$page-url"/>
            </link>
            <xsl:copy-of select="$additional-links"/>
            <meta name="msapplication-config">
                <xsl:attribute name="content" select="concat($front-end-path, '/favicon/browserconfig.xml')"/>
            </meta>
            <meta name="theme-color" content="#ffffff"/>
            <meta property="og:url">
                <xsl:attribute name="content" select="$page-url"/>
            </meta>
            <meta property="og:title">
                <xsl:attribute name="content" select="$page-title"/>
            </meta>
            <meta property="og:description">
                <xsl:attribute name="content" select="$page-description"/>
            </meta>
            <meta property="og:image">
                <xsl:attribute name="content" select="concat($front-end-path, '/imgs/logo-stacked-sq.jpg')"/>
            </meta>
            <meta property="og:image:width" content="300"/>
            <meta property="og:image:height" content="300"/>
            <meta property="og:site_name" content="84000 Translating The Words of The Budda"/>
            <meta name="twitter:card" content="summary"/>
            <meta name="twitter:image:alt" content="84000 Translating The Words of The Budda Logo"/>
            <meta name="twitter:site" content="@Translate84000"/>
        </head>
        
    </xsl:template>
    
    <!-- html footer -->
    <xsl:template name="html-footer">
        
        <xsl:param name="front-end-path" required="yes" as="xs:string"/>
        <xsl:param name="ga-tracking-id" required="no" as="xs:string?"/>
        
        <!-- Shared footer -->
        <xsl:apply-templates select="$eft-footer"/>
        
        <!-- Don't add js in static mode -->
        <xsl:if test="not($view-mode eq 'app')">
            <script>
                function downloadJSAtOnload() {
                var element = document.createElement("script");
                element.src = "<xsl:value-of select="concat($front-end-path, '/js/84000-fe.min.js', '?v=', $app-version)"/>";
                document.body.appendChild(element);
                }
                if (window.addEventListener)
                window.addEventListener("load", downloadJSAtOnload, false);
                else if (window.attachEvent)
                window.attachEvent("onload", downloadJSAtOnload);
                else window.onload = downloadJSAtOnload;
            </script>
            
            <xsl:if test="$ga-tracking-id and not($ga-tracking-id eq '')">
                <script>
                    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
                    ga('create', '<xsl:value-of select="$ga-tracking-id"/>', 'auto');
                    ga('set', 'anonymizeIp', true);
                    ga('send', 'pageview');
                </script>
            </xsl:if>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Website page -->
    <xsl:template name="website-page">
        
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-class" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="content" required="no" as="node()*"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        
        <html>
            
            <xsl:attribute name="lang" select="$lang"/>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'communications'"/>
                <xsl:with-param name="additional-links" select="$additional-links"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="$page-class"/>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:warning/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:warning/text()"/> / <xsl:value-of select="@user-name"/> / <xsl:value-of select="$app-version"/> / <xsl:value-of select="@exist-version"/>
                    </div>
                </xsl:if>
                
                <!-- Alert -->
                <div id="page-alert" class="collapse">
                    <div class="container"/>
                </div>
                
                <!-- Shared header -->
                <xsl:apply-templates select="$eft-header"/>
                
                <!-- Content -->
                <xsl:copy-of select="$content"/>
                
                <!-- Get the common <footer> -->
                <xsl:call-template name="html-footer">
                    <xsl:with-param name="front-end-path" select="$front-end-path"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Reading Room page -->
    <xsl:template name="reading-room-page">
        
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-class" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="content" required="no" as="node()*"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        
        <html>
            
            <xsl:attribute name="lang" select="$lang"/>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'reading-room'"/>
                <xsl:with-param name="additional-links" select="$additional-links"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="$page-class"/>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:warning/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:warning/text()"/> / <xsl:value-of select="@user-name"/> / <xsl:value-of select="$app-version"/> / <xsl:value-of select="@exist-version"/>
                    </div>
                </xsl:if>
                
                <!-- Alert -->
                <div id="page-alert" class="collapse">
                    <div class="container"/>
                </div>
                
                <!-- Place content -->
                <xsl:copy-of select="$content"/>
                
                <!-- Get the common <footer> -->
                <xsl:call-template name="html-footer">
                    <xsl:with-param name="front-end-path" select="$front-end-path"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Modal page -->
    <xsl:template name="modal-page">
        
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="content" required="no" as="node()*"/>
        
        <html>
            
            <xsl:attribute name="lang" select="$lang"/>
            
            <head>
                
                <meta charset="utf-8"/>
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0"/>
                
                <title>
                    <xsl:value-of select="concat('84000 Reading Room | ', $page-title)"/>
                </title>
                
                <!-- Styles -->
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-reading-room.css', '?v=', $app-version)"/>
                </link>
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="href" select="concat($front-end-path, '/css/ie10-viewport-bug-workaround.css')"/>
                </link>
                <!--[if lt IE 9]>
                   <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                   <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
               <![endif]-->
            </head>
            
            <body id="top" class="reading-room modal-page">
                
                <!-- Place content -->
                <xsl:copy-of select="$content"/>
                
                <xsl:if test="not($view-mode eq 'app')">
                    
                    <!-- Foooter components -->
                    <span id="media_test">
                        <span class="visible-xs"/>
                        <span class="visible-sm"/>
                        <span class="visible-md"/>
                        <span class="visible-lg"/>
                        <span class="visible-print"/>
                        <span class="visible-mobile"/>
                        <span class="visible-desktop"/>
                        <span class="event-hover"/>
                    </span>
                    
                    <script type="text/javascript">
                        function downloadJSAtOnload() {
                        var element = document.createElement("script");
                        element.src = "<xsl:value-of select="concat($front-end-path, '/js/84000-fe.min.js', '?v=', $app-version)"/>";
                        document.body.appendChild(element);
                        }
                        if (window.addEventListener)
                        window.addEventListener("load", downloadJSAtOnload, false);
                        else if (window.attachEvent)
                        window.attachEvent("onload", downloadJSAtOnload);
                        else window.onload = downloadJSAtOnload;
                    </script>
                    
                </xsl:if>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Localization helpers -->
    <!-- Copied from functions.xsl to avoid duplicate include warning -->
    <xsl:function name="common:internal-link">
        <xsl:param name="url" required="yes"/>
        <xsl:param name="attributes" required="yes"/>
        <xsl:param name="fragment-id" required="yes" as="xs:string"/>
        <xsl:param name="lang" required="yes"/>
        <xsl:variable name="lang-attribute" select="if($lang = ('zh')) then concat('lang=', $lang) else ()"/>
        <xsl:variable name="attributes-with-lang" select="($attributes, $lang-attribute)"/>
        <xsl:value-of select="concat($url, if(count($attributes-with-lang) gt 0) then concat('?', string-join($attributes-with-lang, '&amp;')) else '', $fragment-id)"/>
    </xsl:function>
    
</xsl:stylesheet>