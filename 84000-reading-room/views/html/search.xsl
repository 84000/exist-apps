<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-search.xsl"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        
                        <nav role="navigation" aria-label="Breadcrumbs">
                            <ul class="breadcrumb">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', /m:response/@lang)"/>
                                        <xsl:value-of select="'The Collection'"/>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('search.html', (), '', /m:response/@lang)"/>
                                        <xsl:value-of select="'Search Our Translations'"/>
                                    </a>
                                </li>
                                <xsl:if test="m:search/m:request[text()]">
                                    <li>
                                        <xsl:value-of select="m:search/m:request/text()"/>
                                    </li>
                                </xsl:if>
                            </ul>
                        </nav>
                        
                        <div>
                            <div class="center-vertical pull-right">
                                
                                <div>
                                    <a class="center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Published Translations'"/>
                                        </span>
                                    </a>
                                </div>
                                
                                <div>
                                    <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical" role="button" aria-haspopup="true" aria-expanded="false">
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-bookmark"/>
                                                <span class="badge badge-notification">0</span>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Bookmarks'"/>
                                        </span>
                                    </a>
                                </div>
                                
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
            
            <!-- Include the bookmarks sidebar -->
            <xsl:variable name="bookmarks-sidebar">
                <m:bookmarks-sidebar>
                    <xsl:copy-of select="$eft-header/m:translation"/>
                </m:bookmarks-sidebar>
            </xsl:variable>
            <xsl:apply-templates select="$bookmarks-sidebar"/>
            
            <main class="content-band">
                <div class="container">
                    
                    <div class="section-title row">
                        <div class="col-sm-offset-2 col-sm-8">
                            <h1 class="title main-title">
                                <xsl:value-of select="'Search Our Translations'"/>
                            </h1>
                        </div>
                    </div>
                    
                    <div class="tabs-container-center">
                        <ul class="nav nav-tabs" role="tablist">
                            
                            <!-- TEI search tab -->
                            <li role="presentation">
                                <xsl:if test="not(m:request/@search-type eq 'tm')">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Search the 84000 published translations'"/>
                                    <xsl:attribute name="data-loading" select="'Searching...'"/>
                                    <xsl:value-of select="'The Publications'"/>
                                </a>
                            </li>
                            
                            <!-- TM search tab -->
                            <li role="presentation" class="icon">
                                <xsl:if test="m:request/@search-type eq 'tm'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/search.html?search-type=tm', (), '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Search the 84000 Translation Memory'"/>
                                    <xsl:attribute name="data-loading" select="'Searching...'"/>
                                    <xsl:value-of select="'Translation Memory'"/>
                                </a>
                            </li>
                            
                        </ul>
                    </div>
                    
                    <xsl:choose>
                        
                        <!-- TM search -->
                        <xsl:when test="m:request/@search-type eq 'tm'">
                            
                            <p class="text-center text-muted small bottom-margin">
                                <xsl:value-of select="'Search our Translation Memory files to find translations aligned with the Tibetan source.'"/>
                            </p>
                            
                        </xsl:when>
                        
                        <!-- TEI search -->
                        <xsl:otherwise>
                            
                            <p class="text-center text-muted small bottom-margin">
                                <xsl:value-of select="'The 84000 database contains both the translated texts and titles and summaries for other works within the Kangyur and Tengyur where available.'"/>
                            </p>
                            
                            <xsl:call-template name="search">
                                <xsl:with-param name="action" select="'search.html'"/>
                                <xsl:with-param name="lang" select="/m:response/@lang"/>
                            </xsl:call-template>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    
                </div>
            </main>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/search.html?s=', m:search/m:request/text())"/>
            <xsl:with-param name="page-class" select="'reading-room section'"/>
            <xsl:with-param name="page-title" select="string-join((if(m:search/m:request/text() gt '') then m:search/m:request/text() else (), 'Search' , '84000 Reading Room'), ' | ')"/>
            <xsl:with-param name="page-description" select="if(m:search/m:request/text() gt '') then concat('Search results for ', m:search/m:request/text()) else 'Search the 84000 Reading Room'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>