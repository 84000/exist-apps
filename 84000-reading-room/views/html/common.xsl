<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:template name="html-head">
        
        <xsl:param name="front-end-path"/>
        <xsl:param name="app-version"/>
        <xsl:param name="page-url"/>
        <xsl:param name="page-title"/>
        <xsl:param name="page-description"/>
        <xsl:param name="page-type"/>
        
        <head xmlns="http://www.w3.org/1999/xhtml">
            
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
    
    <xsl:template name="html-footer">
        
        <xsl:param name="app-version"/>
        <xsl:param name="front-end-path"/>
        <xsl:param name="ga-tracking-id"/>
        
        <footer xmlns="http://www.w3.org/1999/xhtml" class="hidden-print">
            <div class="container" itemscope="itemscope" itemtype="http://schema.org/Organization">
                Copyright © 2011-2018 <span itemprop="name">84000: Translating the Words of the Buddha</span> - All Rights Reserved
                <br/>
                Contact: <a href="mailto:info@84000.co" itemprop="email">info@84000.co</a> | 
                Website: <a href="http://84000.co" itemprop="url">http://84000.co</a> | 
                <a href="http://84000.co/about/privacy-policy" itemprop="url">Privacy Policy</a>
            </div>
        </footer>
        
        <span xmlns="http://www.w3.org/1999/xhtml" id="media_test">
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
            <script xmlns="http://www.w3.org/1999/xhtml">
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
    
</xsl:stylesheet>