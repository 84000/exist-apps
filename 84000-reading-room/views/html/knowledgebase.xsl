<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render-translation/m:status/@status-id"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="title-band hidden-print">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        
                        <div>
                            <nav role="navigation" aria-label="Breadcrumbs">
                                <ul class="breadcrumb">
                                    
                                    <li>
                                        <xsl:value-of select="'84000 Knowledge Base'"/>
                                    </li>
                                    
                                    <li>
                                        <xsl:value-of select="m:knowledgebase/m:page/m:titles/m:title[@xml:lang = 'en']"/>
                                    </li>
                                    
                                </ul>
                            </nav>
                        </div>
                        
                        <div>
                            <div class="center-vertical pull-right">
                                
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
            
            <xsl:if test="not(m:knowledgebase/m:page/@status-group eq 'published')">
                <div class="title-band warning">
                    <div class="container">
                        <xsl:value-of select="'This text is not yet ready for publication!'"/>                      
                    </div>
                </div>
            </xsl:if>
            
            <div class="content-band">
                <div class="container">
                    <div class="row">
                        
                        <main class="col-md-8 col-lg-9">
                            
                            <!-- Link to tei-editor -->
                            <!-- Knowledge base only, editor mode, operations app, no child divs and an id -->
                            <xsl:if test="$view-mode[@id = ('editor')] and $environment/m:url[@id eq 'operations']">
                                <a class="text-muted underline top-right" target="84000-operations">
                                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/text(), '/edit-kb-header.html', '?id=', m:knowledgebase/m:page/@xml:id)"/>
                                    <xsl:value-of select="'[Edit headers]'"/>
                                </a>
                            </xsl:if>
                            
                            <h1>
                                <xsl:apply-templates select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en']"/>
                            </h1>
                            
                            <xsl:for-each select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][not(@xml:lang eq 'en')]">
                                <div class="h4">
                                    <xsl:value-of select="common:lang-label(@xml:lang)"/>
                                    <span>
                                        <xsl:call-template name="class-attribute">
                                            <xsl:with-param name="lang" select="@xml:lang"/>
                                        </xsl:call-template>
                                        <xsl:value-of select="text()"/>
                                    </span>
                                </div>
                            </xsl:for-each>
                            
                            <xsl:for-each select="m:knowledgebase/m:page/m:titles/m:title[not(@type eq 'mainTitle')]">
                                <div>
                                    <xsl:call-template name="class-attribute">
                                        <xsl:with-param name="lang" select="@xml:lang"/>
                                        <xsl:with-param name="base-classes" select="'h4 text-muted'"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="text()"/>
                                </div>
                            </xsl:for-each>
                            
                            <p class="text-muted small">
                                <xsl:choose>
                                    <xsl:when test="m:knowledgebase/m:page/m:publication/m:publication-date castable as xs:date">
                                        <xsl:value-of select="concat('First published ', format-date(m:knowledgebase/m:page/m:publication/m:publication-date, '[Y]'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Not yet published'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                            
                            <section class="tei-parser">
                                <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'article']"/>
                            </section>
                            
                            <xsl:if test="m:knowledgebase/m:part[@type eq 'bibliography'][tei:div[tei:bibl] or $view-mode[@id = ('editor')]]">
                                <section class="tei-parser">
                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'bibliography']"/>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:knowledgebase/m:part[@type eq 'end-notes'][tei:note]">
                                <section class="tei-parser">
                                    <xsl:call-template name="end-notes"/>
                                </section>
                            </xsl:if>
                            
                        </main>
                        
                        <aside class="col-md-4 col-lg-3">
                            
                            <xsl:call-template name="taxonomy"/>
                            
                            <!-- Project Progress, get from ajax -->
                            <div id="project-progress">
                                <xsl:attribute name="data-onload-replace">
                                    <xsl:choose>
                                        <xsl:when test="$lang eq 'zh'">
                                            <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-chart.html#eft-progress-chart-panel&#34;}')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-chart.html?lang=', $lang ,'#eft-progress-chart-panel&#34;}')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>                            
                                <div class="panel panel-default">
                                    <div class="panel-body loading"/>
                                </div>
                            </div>
                        
                        </aside>
                        
                    </div>
                </div>
                
            </div>
            
            <!-- General pop-up for notes -->
            <div id="popup-footer" class="fixed-footer collapse hidden-print">
                <div class="fix-height">
                    <div class="container translation">
                        <div class="row">
                            <div class="col-md-8 col-lg-9">
                                <div class="data-container">
                                    <!-- Ajax data here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="fixed-btn-container close-btn-container">
                    <button type="button" class="btn-round close close-collapse" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="(m:knowledgebase/m:page/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room knowledgebase'"/>
            <xsl:with-param name="page-title" select="concat(m:knowledgebase/m:page/m:titles/m:title[@xml:lang eq 'en'][@type eq 'mainTitle']/text(), ' | 84000 Reading Room')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:knowledgebase/m:page/m:summary/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="taxonomy">
        
        <ul class="list-unstyled taxonomy">
            <xsl:for-each select="m:knowledgebase/m:taxonomy/tei:category">
                <li class="label label-filter">
                    <xsl:value-of select="tei:catDesc"/>
                </li>
            </xsl:for-each>
        </ul>
        
    </xsl:template>
    
</xsl:stylesheet>