<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="glossary.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-search.xsl"/>
    <xsl:import href="tibetan-search.xsl"/>
    <xsl:import href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Translator Tools
                        </span>
                        
                        <span class="text-right">
                            <a target="_self">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                Reading Room
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <!-- Tabs -->
                        <ul class="nav nav-tabs nav-justified" role="tablist">
                            
                            <!-- Additional tabs -->
                            <xsl:for-each select="m:tabs/m:tab">
                                <li role="presentation">
                                    <xsl:if test="/m:response/m:request/@tab eq @id">
                                        <xsl:attribute name="class" select="'active'"/>
                                    </xsl:if>
                                    <a>
                                        <xsl:attribute name="href" select="concat('?tab=', @id)"/>
                                        <xsl:value-of select="m:label"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                            
                        </ul>
                        <!-- Content -->
                        <div class="tab-content">
                            
                            <xsl:choose>
                                
                                <!-- Search results -->
                                <xsl:when test="/m:response/m:request/@tab eq 'search'">
                                    
                                    <div class="alert alert-warning small text-center">
                                        <p>
                                            Use the form below to search for terms, phrases, titles, and so forth in published and nearly-published 84000 translations. Search results link directly to passages in the Reading Room.
                                        </p>
                                    </div>
                                    
                                    <xsl:call-template name="search">
                                        <xsl:with-param name="action" select="'index.html?tab=search'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                
                                <!-- Cumulative Glossary -->
                                <xsl:when test="/m:response/m:request/@tab eq 'glossary'">
                                    <xsl:call-template name="glossary"/>
                                </xsl:when>
                                
                                <!-- Tibetan Search -->
                                <xsl:when test="/m:response/m:request/@tab eq 'tibetan-search'">
                                    
                                    <div class="alert alert-warning small text-center">
                                        <p>
                                            The Tibetan Search below is a convenient way to browse translation memories created from published 84000 translations. Search for a term or phrase by entering Tibetan script or Wylie into the search fields, or simply highlight a segment in the e-Kangyur display on the left. You can learn more about Translation Memories under the <a href="?tab=smartcat">CAT Tools</a> tab.
                                        </p>
                                        <p>**Please be aware that this is a beta version.**</p>
                                    </div>
                                    
                                    <xsl:call-template name="tibetan-search"/>
                                </xsl:when>
                                
                                <xsl:otherwise>
                                    <xsl:copy-of select="article/*"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </div>
                        
                    </div>
                    
                </div>
            </div>
            
            <!-- Link to top of page -->
            <div class="hidden-print">
                <div id="link-to-top-container" class="fixed-btn-container">
                    <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                        <i class="fa fa-arrow-up" aria-hidden="true"/>
                    </a>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities wait'"/>
            <xsl:with-param name="page-title" select="concat('84000 Translator Tools : ', /m:response/m:request/@tab)"/>
            <xsl:with-param name="page-description" select="'Tools for 84000 translators'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>