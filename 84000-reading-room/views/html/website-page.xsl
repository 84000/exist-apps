<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:m="http://read.84000.co/ns/1.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <!-- include navigation stylesheet -->
    <xsl:import href="../../xslt/navigation.xsl"/>
    <xsl:import href="../../xslt/functions.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'"/>
    <xsl:variable name="environment" select="doc($environment-path)/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="communications-site-path" select="$environment/m:url[@id eq 'communications-site']/text()"/>
    <xsl:variable name="app-version" select="doc('../../expath-pkg.xml')/pkg:package/@version"/>
    <xsl:variable name="ga-tracking-id" select="$environment/m:google-analytics/@tracking-id"/>
    
    <!-- get navigation config -->
    <xsl:variable name="navigation" select="doc('../../xslt/navigation.xml')/m:navigation"/>
    
    <!-- override navigation params -->
    <xsl:variable name="lang" select="if(/m:response/@lang) then /m:response/@lang else 'en'"/>
    <xsl:variable name="active-url">
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
                <xsl:value-of select="common:internal-link('http://84000.co/about/sponsors', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/sponsors'">
                <xsl:value-of select="common:internal-link('http://84000.co/about/sponsors', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/impact'">
                <xsl:value-of select="common:internal-link('http://84000.co/about/impact', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/progress'">
                <xsl:value-of select="common:internal-link('http://84000.co/about/progress', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model-type eq 'about/translators'">
                <xsl:value-of select="common:internal-link('http://84000.co/about/translators', (), '', $lang)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="common:internal-link('#reading-room', (), '', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="local-comms-url" select="$communications-site-path"/>
    <xsl:variable name="local-reading-room-url" select="$reading-room-path"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <!-- html head tag -->
    <xsl:template name="html-head">
        
        <xsl:param name="front-end-path" required="yes"/>
        <xsl:param name="app-version" required="yes"/>
        <xsl:param name="page-url" required="yes"/>
        <xsl:param name="page-title" required="yes"/>
        <xsl:param name="page-description" required="yes"/>
        <xsl:param name="page-type" required="yes"/>
        
        <head>
            
            <meta charset="utf-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0"/>
            <meta name="description" content="84000 is a non-profit global initiative to translate the words of the Buddha and make them available to everyone."/>
            
            <title>
                84000 Reading Room | <xsl:value-of select="$page-title"/>
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
        
        <xsl:param name="app-version" required="yes"/>
        <xsl:param name="front-end-path" required="yes"/>
        <xsl:param name="ga-tracking-id"/>
        
        <footer class="hidden-print">
            <div class="container" itemscope="itemscope" itemtype="http://schema.org/Organization">
                Copyright © 2011-2018 <span itemprop="name">84000: Translating the Words of the Buddha</span> - All Rights Reserved
                <br/>
                Contact: <a href="mailto:info@84000.co" itemprop="email">info@84000.co</a> | 
                Website: <a href="http://84000.co" itemprop="url">http://84000.co</a> | 
                <a href="http://84000.co/about/privacy-policy" itemprop="url">Privacy Policy</a>
            </div>
        </footer>
        
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
        
        <xsl:if test="$ga-tracking-id != ''">
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
        
    </xsl:template>
    
    <!-- Website page -->
    <xsl:template name="website-page">
        
        <xsl:param name="page-url"/>
        <xsl:param name="page-class"/>
        <xsl:param name="page-title"/>
        <xsl:param name="page-description"/>
        <xsl:param name="content"/>
        <xsl:param name="nav-tab"/>
        
        <html>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="app-version" select="$app-version"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'communications'"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="$page-class"/>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:warning/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:warning/text()"/> / <xsl:value-of select="@user-name"/>
                    </div>
                </xsl:if>
                
                <!-- Alert -->
                <div id="page-alert" class="collapse">
                    <div class="container"/>
                </div>
                
                <!-- Navigation -->
                <nav class="navbar navbar-default">
                    
                    <div class="brand-header">
                        <div class="container">
                            <div class="navbar-header">
                                <div class="navbar-brand center-vertical">
                                    
                                    <a href="http://84000.co" class="logo">
                                        <img>
                                            <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                                        </img>
                                    </a>
                                    
                                    <span class="tag-line">
                                        Translating the words of the Buddha
                                    </span>
                                    
                                    <span class="nav-button">
                                        <button id="navigation-button" class="btn-round navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                                            <i class="fa fa-bars" aria-hidden="true"/>
                                        </button>
                                    </span>
                                    
                                </div>
                            </div>
                        </div>
                        
                    </div>
                    
                    <div class="container">
                        <div id="navbar" class="navbar-collapse collapse" aria-expanded="false">
                            
                            <xsl:apply-templates select="$navigation"/>
                            
                            <form method="get" role="search" name="searchformTop" class="navbar-form navbar-right">
                                <xsl:attribute name="action" select="concat($reading-room-path, '/search.html')"/>
                                <xsl:copy-of select="common:localise-form($lang)"/>
                                <div id="search-controls" class="input-group">
                                    <input type="text" name="s" class="form-control" placeholder="Search..."/>
                                    <input type="submit" value="Submit" class="hidden"/>
                                    <span class="input-group-btn">
                                        <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                            <i class="fa fa-search"/> <span class="caret"/>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <a class="on-click-submit">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/search.html')"/>
                                                    <i class="fa fa-caret-right"/>
                                                    Search the Reading Room
                                                </a>
                                            </li>
                                            <li>
                                                <a class="on-click-submit">
                                                    <xsl:attribute name="href" select="concat($communications-site-path, '/')"/>
                                                    <i class="fa fa-caret-right"/>
                                                    Search the Website
                                                </a>
                                            </li>
                                        </ul>
                                    </span>
                                </div>
                                
                                <div id="language-links">
                                    <a href="?lang=en">English</a> | <a href="?lang=zh">中文</a>
                                </div>
                                
                            </form>
                            
                            <div id="social" class="center-vertical">
                                <span>Follow our work:</span>
                                <a href="mailto:info@84000.co" target="_blank">
                                    <i class="fa fa-envelope-square" aria-hidden="true"/>
                                </a>
                                <a href="http://www.facebook.com/Translate84000" target="_blank">
                                    <i class="fa fa-facebook-square" aria-hidden="true"/>
                                </a>
                                <a href="https://twitter.com/Translate84000" target="_blank">
                                    <i class="fa fa-twitter-square" aria-hidden="true"/>
                                </a>
                                <a href="http://www.youtube.com/Translate84000" target="_blank">
                                    <i class="fa fa-youtube-square" aria-hidden="true"/>
                                </a>
                            </div>
                            
                        </div>
                    </div>
                    
                </nav>
                
                <!-- Content -->
                <xsl:copy-of select="$content"/>
                <!-- 
                    Potentially apply templates to parse / internationalise all links and forms
                    <xsl:apply-templates select="$content"/>
                -->
                
                <!-- Link to top of page -->
                <div class="hidden-print">
                    <div id="link-to-top-container" class="fixed-btn-container">
                        <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                            <i class="fa fa-arrow-up" aria-hidden="true"/>
                        </a>
                    </div>
                </div>
                
                <!-- Get the common <footer> -->
                <xsl:call-template name="html-footer">
                    <xsl:with-param name="front-end-path" select="$front-end-path"/>
                    <xsl:with-param name="app-version" select="$app-version"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Reading Room page -->
    <xsl:template name="reading-room-page">
        
        <xsl:param name="page-url"/>
        <xsl:param name="page-class"/>
        <xsl:param name="page-title"/>
        <xsl:param name="page-description"/>
        <xsl:param name="content"/>
        
        <html>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="app-version" select="$app-version"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'reading-room'"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="$page-class"/>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:warning/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:warning/text()"/> / <xsl:value-of select="@user-name"/>
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
                    <xsl:with-param name="app-version" select="$app-version"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Modal page -->
    <xsl:template name="modal-page">
        
        <xsl:param name="page-title"/>
        <xsl:param name="content"/>
        
        <!-- Look up environment variables -->
        <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'"/>
        <xsl:variable name="environment" select="doc($environment-path)/m:environment"/>
        <xsl:variable name="app-version" select="doc('../../expath-pkg.xml')/pkg:package/@version"/>
        <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
        
        <html>
            
            <head>
                
                <meta charset="utf-8"/>
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0"/>
                
                <title>
                    84000 Reading Room | <xsl:value-of select="$page-title"/>
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
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Internationalise the html
    <xsl:template match="xhtml:form">
        <form>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="common:localise-form($lang)"/>
            <xsl:copy-of select="node()"/>
        </form>
    </xsl:template>
    
    <xsl:template match="xhtml:a[starts-with(@href, $reading-room-path)]">
        <a>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="href">
                <xsl:call-template name="internal-link">
                    <xsl:with-param name="url" select="@href"/>
                    <xsl:with-param name="lang" select="$lang"></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:copy-of select="node()"/>
        </a>
    </xsl:template>
    
    <xsl:template match="xhtml:*">
        <xsl:copy>
            <xsl:copy-of select="@*|text()" />
            <xsl:apply-templates select="*" />
        </xsl:copy>
    </xsl:template> -->
    
</xsl:stylesheet>