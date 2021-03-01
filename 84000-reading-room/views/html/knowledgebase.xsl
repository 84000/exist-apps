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
                                
                                <li>
                                    <xsl:value-of select="'The 84000 Knowledge Base'"/>
                                </li>
                                
                                <!--<li class="title">
                                    <xsl:value-of select="m:knowledgebase/m:page/m:titles/m:title[@xml:lang = 'en']"/>
                                </li>-->
                                
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
                            
                            <section id="front-matter">
                                <xsl:call-template name="front-matter"/>
                            </section>
                            
                            <section id="article">
                                <xsl:call-template name="article"/>
                            </section>
                            
                            <section id="bibliography">
                                <xsl:call-template name="bibliography"/>
                            </section>
                            
                        </main>
                        
                        <aside class="col-md-4 col-lg-3">
                            
                            <xsl:variable name="sharing-panel">
                                <m:sharing-panel>
                                    <xsl:copy-of select="$eft-header/m:sharing[@xml:lang eq $lang]/node()"/>
                                </m:sharing-panel>
                            </xsl:variable>
                            
                            <xsl:apply-templates select="$sharing-panel"/>
                            
                            <xsl:call-template name="taxonomy"/>
                            
                        </aside>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="(m:knowledgebase/m:page/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room translation'"/>
            <xsl:with-param name="page-title" select="concat(m:knowledgebase/m:page/m:titles/m:title[@xml:lang eq 'en'][@type eq 'mainTitle']/text(), ' | 84000 Reading Room')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:knowledgebase/m:page/m:summary/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="front-matter">
        <div class="page page-first">
            
            <h1 class="no-top-margin">
                <xsl:apply-templates select="m:knowledgebase/m:page/m:titles/m:title[@xml:lang eq 'en']"/>
            </h1>
            
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
            
        </div>
    </xsl:template>
    
    <xsl:template name="article">
        <div class="page">
            
            <xsl:apply-templates select="m:knowledgebase/m:article/*"/>
            
        </div>
    </xsl:template>
    
    <xsl:template name="bibliography">
        <xsl:if test="m:knowledgebase/m:bibliography[node()]">
            <div class="page">
                
                <h3>
                    <xsl:value-of select="'Bibliography'"/>
                </h3>
                
                <xsl:apply-templates select="m:knowledgebase/m:bibliography/*"/>
                
            </div>
        </xsl:if>
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