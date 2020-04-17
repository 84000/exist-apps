<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0" exclude-result-prefixes="xs eft">
    
    <!-- 
        NOTE:
        For use in eXist: leave xmlns to root e.g. <xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"  xmlns:xsl.../>
        For use in php XSLTProcessor: remove xmlns from root e.g. <xsl:stylesheet xmlns:xsl.../>
    -->
    
    <xsl:param name="lang" select="'en'"/>
    <xsl:param name="active-url" select="'/'"/>
    <xsl:param name="local-comms-url" select="''"/>
    <xsl:param name="local-reading-room-url" select="'https://read.84000.co'"/>
    <xsl:param name="local-front-end-url" select="'https://fe.84000.co'"/>
    <xsl:param name="default-search-form-target" select="'comms'"/>
    
    <xsl:output method="html" indent="no" omit-xml-declaration="yes"/>
    
    <xsl:template match="eft:eft-header">
        <nav class="navbar navbar-default">
            
            <div class="brand-header">
                <div class="container">
                    <div class="navbar-header">
                        <div class="navbar-brand center-vertical full-width">
                            
                            <!-- Logo -->
                            <a class="logo">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$local-comms-url"/>
                                </xsl:attribute>
                                <img>
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="concat($local-front-end-url, '/imgs/logo.png')"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="alt">
                                        <xsl:value-of select="'84000 logo'"/>
                                    </xsl:attribute>
                                </img>
                            </a>
                            
                            <!-- Tag line -->
                            <span class="tag-line">
                                <xsl:call-template name="translation">
                                    <xsl:with-param name="translation-id" select="'tag-line'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="text-node" select="false()"/>
                                </xsl:call-template>
                            </span>
                            
                            <!-- Nav button for mobile nav -->
                            <span class="nav-button">
                                <button id="navigation-button" class="btn-round navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                                    <i class="fa fa-bars" aria-hidden="true"/>
                                </button>
                            </span>
                            
                            <div class="visible-desktop">
                                <div class="center-vertical align-right">
                                    <span>
                                        <xsl:call-template name="language-links"/>
                                    </span>
                                    <xsl:call-template name="search-form"/>
                                </div>
                            </div>
                            
                        </div>
                    </div>
                </div>
                
            </div>
            
            <div class="container">
                <div id="navbar" class="navbar-collapse collapse" role="navigation" aria-label="Main navigation" aria-expanded="false">
                    
                    <!-- Main navigation -->
                    <ul class="nav navbar-nav">
                        <xsl:for-each select="eft:navigation[@xml:lang = $lang]/eft:item">
                            <li>
                                <xsl:choose>
                                    
                                    <!-- Has child items -->
                                    <xsl:when test="eft:item">
                                        
                                        <xsl:attribute name="class">
                                            <xsl:choose>
                                                <xsl:when test="@url = $active-url">
                                                    <xsl:value-of select="concat(@class,' dropdown-toggle-container', ' active')"/>
                                                </xsl:when>
                                                <xsl:when test="eft:item[@url = $active-url]">
                                                    <xsl:value-of select="concat(@class,' dropdown-toggle-container', ' active')"/>
                                                </xsl:when>
                                                <xsl:when test="eft:item[eft:item/@url = $active-url]">
                                                    <xsl:value-of select="concat(@class,' dropdown-toggle-container', ' active')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(@class,' dropdown-toggle-container')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        
                                        <!-- Main nav -->
                                        <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="local-url">
                                                    <xsl:with-param name="url" select="@url"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:value-of select="eft:label"/>
                                            <span>
                                                <i class="fa fa-plus"/>
                                                <i class="fa fa-minus"/>
                                            </span>
                                        </a>
                                        
                                        <!-- Dropdown sub-nav -->
                                        <ul class="dropdown-menu">
                                            <xsl:for-each select="eft:item">
                                                <li>
                                                    <xsl:choose>
                                                        <xsl:when test="eft:item">
                                                            <div>
                                                                <xsl:attribute name="class">
                                                                    <xsl:choose>
                                                                        <xsl:when test="eft:item[@url = $active-url]">
                                                                            <xsl:value-of select="'top-vertical together subnav active'"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="'top-vertical together subnav'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:attribute>
                                                                <div class="title">
                                                                    <xsl:value-of select="eft:label"/>
                                                                </div>
                                                                <div class="links">
                                                                    <ul>
                                                                        <xsl:for-each select="eft:item">
                                                                            <li>
                                                                                <xsl:attribute name="class">
                                                                                    <xsl:if test="@url = $active-url">
                                                                                        <xsl:value-of select="'active'"/>
                                                                                    </xsl:if>
                                                                                </xsl:attribute>
                                                                                <a>
                                                                                    <xsl:attribute name="href">
                                                                                        <xsl:call-template name="local-url">
                                                                                            <xsl:with-param name="url" select="@url"/>
                                                                                        </xsl:call-template>
                                                                                    </xsl:attribute>
                                                                                    <xsl:value-of select="eft:label"/>
                                                                                </a>
                                                                            </li>
                                                                        </xsl:for-each>
                                                                    </ul>
                                                                </div>
                                                            </div>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:if test="@url = $active-url">
                                                                <xsl:attribute name="class">
                                                                    <xsl:value-of select="'active'"/>
                                                                </xsl:attribute>
                                                            </xsl:if>
                                                            <a>
                                                                <xsl:attribute name="href">
                                                                    <xsl:call-template name="local-url">
                                                                        <xsl:with-param name="url" select="@url"/>
                                                                    </xsl:call-template>
                                                                </xsl:attribute>
                                                                <xsl:value-of select="eft:label"/>
                                                            </a>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                        
                                    </xsl:when>
                                    
                                    <!-- Has no child items -->
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">
                                            <xsl:choose>
                                                <xsl:when test="@url = $active-url">
                                                    <xsl:value-of select="concat(@class, ' active')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="@class"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="local-url">
                                                    <xsl:with-param name="url" select="@url"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:value-of select="eft:label"/>
                                        </a>
                                    </xsl:otherwise>
                                    
                                </xsl:choose>
                                
                            </li>
                        </xsl:for-each>
                        
                        <!-- Search form -->
                        <li class="search visible-mobile">
                            <xsl:call-template name="search-form"/>
                        </li>
                        
                        <!-- language links -->
                        <li class="languages visible-mobile">
                            <div class="center-vertical">
                                <xsl:call-template name="language-links"/>
                            </div>
                        </li>
                        
                        <!-- social media links -->
                        <li class="social">
                            <div id="social" class="center-vertical">
                                <span>
                                    <xsl:call-template name="translation">
                                        <xsl:with-param name="translation-id" select="'label-social-icons'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                        <xsl:with-param name="text-node" select="false()"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:for-each select="eft:social[@xml:lang = $lang]/eft:item">
                                    <a target="_blank">
                                        <xsl:choose>
                                            <xsl:when test="starts-with(@url, '#')">
                                                <xsl:attribute name="data-toggle">
                                                    <xsl:value-of select="'modal'"/>
                                                </xsl:attribute>
                                                <xsl:attribute name="data-target">
                                                    <xsl:value-of select="@url"/>
                                                </xsl:attribute>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:attribute name="href">
                                            <xsl:call-template name="local-url">
                                                <xsl:with-param name="url" select="@url"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:attribute name="title">
                                            <xsl:value-of select="eft:label/text()"/>
                                        </xsl:attribute>
                                        <i aria-hidden="true">
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="@icon-class"/>
                                            </xsl:attribute>
                                        </i>
                                    </a>
                                </xsl:for-each>
                            </div>
                        </li>
                        
                    </ul>
                    
                </div>
            </div>
            
            <xsl:if test="eft:social[@xml:lang = $lang]/eft:item[@url = '#wechat-qcode']">
                <div class="modal fade" tabindex="-1" role="dialog" id="wechat-qcode">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-body">
                                <div class="text-center">
                                    <img>
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="concat($local-front-end-url, '/imgs/84000_WeChat_QRCode.jpg')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="alt">
                                            <xsl:value-of select="'WeChat QR code'"/>
                                        </xsl:attribute>
                                    </img>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>
            
        </nav>
    </xsl:template>
    
    <xsl:template match="eft:eft-footer">
        
        <!-- Page footer -->
        <footer class="hidden-print">
            <div class="container" itemscope="itemscope" itemtype="http://schema.org/Organization">
                
                <div>
                    <xsl:call-template name="translation">
                        <xsl:with-param name="translation-id" select="'copyright'"/>
                        <xsl:with-param name="lang" select="$lang"/>
                        <xsl:with-param name="text-node" select="false()"/>
                    </xsl:call-template>
                    <span itemprop="name">
                        <xsl:call-template name="translation">
                            <xsl:with-param name="translation-id" select="'org-name'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="text-node" select="false()"/>
                        </xsl:call-template>
                    </span>
                    <xsl:call-template name="translation">
                        <xsl:with-param name="translation-id" select="'rights-reserved'"/>
                        <xsl:with-param name="lang" select="$lang"/>
                        <xsl:with-param name="text-node" select="false()"/>
                    </xsl:call-template>
                </div>
                
                <ul class="list-inline inline-dots">
                    <li>
                        <xsl:call-template name="translation">
                            <xsl:with-param name="translation-id" select="'contact-label'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="text-node" select="false()"/>
                        </xsl:call-template>
                        <a itemprop="email">
                            <xsl:attribute name="href">
                                <xsl:call-template name="translation">
                                    <xsl:with-param name="translation-id" select="'contact-link'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="text-node" select="true()"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:call-template name="translation">
                                <xsl:with-param name="translation-id" select="'contact-link-text'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="text-node" select="false()"/>
                            </xsl:call-template>
                        </a>
                    </li>
                    <li>
                        <xsl:call-template name="translation">
                            <xsl:with-param name="translation-id" select="'website-label'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="text-node" select="false()"/>
                        </xsl:call-template>
                        <a itemprop="email">
                            <xsl:attribute name="href">
                                <xsl:call-template name="translation">
                                    <xsl:with-param name="translation-id" select="'website-link'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="text-node" select="true()"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:call-template name="translation">
                                <xsl:with-param name="translation-id" select="'website-link-text'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="text-node" select="false()"/>
                            </xsl:call-template>
                        </a>
                    </li>
                    <li>
                        <a itemprop="url">
                            <xsl:attribute name="href">
                                <xsl:call-template name="translation">
                                    <xsl:with-param name="translation-id" select="'privacy-link'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="text-node" select="true()"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:call-template name="translation">
                                <xsl:with-param name="translation-id" select="'privacy-label'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="text-node" select="false()"/>
                            </xsl:call-template>
                        </a>
                    </li>
                </ul>
            </div>
        </footer>
        
        <!-- Link to top of page -->
        <div class="hidden-print">
            <div id="link-to-top-container" class="fixed-btn-container">
                <a href="#top" class="btn-round scroll-to-anchor link-to-top">
                    <xsl:attribute name="title">
                        <xsl:call-template name="translation">
                            <xsl:with-param name="translation-id" select="'top-link-title'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="text-node" select="true()"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <i class="fa fa-arrow-up" aria-hidden="true"/>
                </a>
            </div>
        </div>
        
        <!-- For JS media queries -->
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
        
    </xsl:template>
    
    <xsl:template match="eft:nav-category[eft:item/eft:item]">
        <div>
            <h2>
                <xsl:value-of select="eft:item/eft:label"/>
            </h2>
            <p data-match-height="homepage-categories">
                <xsl:value-of select="eft:item/eft:description"/>
            </p>
            <div class="list-group">
                <xsl:for-each select="eft:item/eft:item">
                    <a class="list-group-item">
                        <xsl:attribute name="href">
                            <xsl:call-template name="local-url">
                                <xsl:with-param name="url" select="@url"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:if test="@url = $active-url">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'list-group-item active'"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="eft:label"/>
                    </a>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="eft:nav-sidebar[eft:item/eft:item]">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <xsl:value-of select="concat('More About ', eft:item/eft:label)"/>
                </h3>
            </div>
            <div class="panel-body">
                <p data-match-height="homepage-categories">
                    <xsl:value-of select="eft:item/eft:description"/>
                </p>
            </div>
            <div class="list-group">
                <xsl:for-each select="eft:item/eft:item">
                    <a class="list-group-item">
                        <xsl:attribute name="href">
                            <xsl:call-template name="local-url">
                                <xsl:with-param name="url" select="@url"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:if test="@url = $active-url">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'list-group-item active'"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="eft:label"/>
                    </a>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="eft:title-band[eft:item]">
        <div class="title-band">
            <div class="container">
                <xsl:choose>
                    <xsl:when test="eft:item/eft:item[@url = $active-url]">
                        <ul class="breadcrumb">
                            <li>
                                <xsl:value-of select="eft:item/eft:label"/>
                            </li>
                            <li>
                                <h1>
                                    <xsl:value-of select="eft:item/eft:item[@url = $active-url]/eft:label"/>
                                </h1>
                            </li>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <h1>
                            <xsl:value-of select="eft:item[@url = $active-url]/eft:label"/>
                        </h1>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="local-url">
        <xsl:param name="url"/>
        <xsl:variable name="standard-comms-url" select="'https://84000.co'"/>
        <xsl:variable name="standard-reading-room-url" select="'https://read.84000.co'"/>
        <xsl:choose>
            <xsl:when test="starts-with($url, $standard-reading-room-url)">
                <xsl:value-of select="concat($local-reading-room-url, substring-after($url, $standard-reading-room-url))"/>
            </xsl:when>
            <xsl:when test="starts-with($url, $standard-comms-url)">
                <xsl:value-of select="concat($local-comms-url, substring-after($url, $standard-comms-url))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="translation">
        <xsl:param name="translation-id"/>
        <xsl:param name="lang" select="'en'"/>
        <xsl:param name="text-node" select="true()"/>
        <xsl:variable name="translation" select="eft:translation[@id = $translation-id]"/>
        <xsl:variable name="text">
            <xsl:choose>
                <xsl:when test="$translation/eft:text[@xml:lang = $lang]">
                    <xsl:value-of select="$translation/eft:text[@xml:lang = $lang]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$translation/eft:text[@xml:lang = 'en']/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$text">
            <xsl:choose>
                <xsl:when test="$text-node">
                    <xsl:value-of select="$text"/>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:attribute name="class">
                            <xsl:choose>
                                <xsl:when test="$lang = 'zh'">
                                    <xsl:value-of select="'text-zh'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'text-en'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$text"/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="language-links">
        <a>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$active-url = '#reading-room' or starts-with($active-url, 'https://read.84000.co')">
                        <xsl:value-of select="'?lang=en'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$local-comms-url"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="'English'"/>
        </a>
        <span>
            <xsl:value-of select="' | '"/>
        </span>
        <a>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$active-url = '#reading-room' or starts-with($active-url, 'https://read.84000.co')">
                        <xsl:value-of select="'?lang=zh'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($local-comms-url, '/ch')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="'中文'"/>
        </a>
    </xsl:template>
    
    <xsl:template name="search-form">
        <form method="get" role="search" name="searchformTop" class="navbar-form">
            <xsl:attribute name="action">
                <xsl:choose>
                    <xsl:when test="$default-search-form-target = 'reading-room'">
                        <xsl:value-of select="concat($local-reading-room-url, '/search.html')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($local-comms-url, '/')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="$lang = 'zh'">
                <input type="hidden" name="lang">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$lang"/>
                    </xsl:attribute>
                </input>
            </xsl:if>
            <div id="search-controls" class="input-group">
                <input type="text" name="s" class="form-control">
                    <xsl:attribute name="placeholder">
                        <xsl:call-template name="translation">
                            <xsl:with-param name="translation-id" select="'placeholder-search'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="text-node" select="true()"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </input>
                <input type="submit" value="Submit" class="hidden"/>
                <div class="input-group-btn">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-search"/> <span class="caret"/>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-right">
                        <li>
                            <a class="on-click-submit">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat($local-reading-room-url, '/search.html')"/>
                                </xsl:attribute>
                                <xsl:call-template name="translation">
                                    <xsl:with-param name="translation-id" select="'button-search-reading-room'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="text-node" select="false()"/>
                                </xsl:call-template>
                                
                            </a>
                        </li>
                        <li>
                            <a class="on-click-submit">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat($local-comms-url, '/')"/>
                                </xsl:attribute>
                                <xsl:call-template name="translation">
                                    <xsl:with-param name="translation-id" select="'button-search-comms'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="text-node" select="false()"/>
                                </xsl:call-template>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </form>
    </xsl:template>

    
</xsl:stylesheet>