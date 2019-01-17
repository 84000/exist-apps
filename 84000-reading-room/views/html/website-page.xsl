<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" xmlns:pkg="http://expath.org/ns/pkg" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="common.xsl"/>
    
    <xsl:import href="../../xslt/navigation.xsl"/>
    
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
    <xsl:variable name="lang" select="'en'"/>
    <xsl:variable name="active-url">
        <xsl:variable name="active-url-base">
            <xsl:choose>
                <xsl:when test="/m:response/m:section/@id eq 'ALL-TRANSLATED'">
                    <xsl:value-of select="'http://read.84000.co/section/all-translated.html'"/>
                </xsl:when>
                <xsl:when test="/m:response/m:section/@id eq 'LOBBY'">
                    <xsl:value-of select="'http://read.84000.co/section/lobby.html'"/>
                </xsl:when>
                <xsl:when test="/m:response/@model-type eq 'search'">
                    <xsl:value-of select="'http://read.84000.co/search.html'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'#reading-room'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($active-url-base, if($lang eq 'zh') then '?lang=zh' else '')"/>
    </xsl:variable>
    <xsl:variable name="local-comms-url" select="$communications-site-path"/>
    <xsl:variable name="local-reading-room-url" select="$reading-room-path"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
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
                                    <a href="http://84000.co">English</a> | <a href="http://84000.co/ch">中文</a>
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
</xsl:stylesheet>