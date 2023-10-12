<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/text-overlay.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="glossary" select="/m:response/m:glossary"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="tab-label" select="m:tabs/m:tab[@id eq $request/@tab]/m:label"/>
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical full-width">
                        <span class="logo">
                            <img alt="84000 logo">
                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                            </img>
                        </span>
                        <span>
                            <h1 class="title">
                                <xsl:value-of select="concat('84000 Community / ', $tab-label)"/>
                            </h1>
                        </span>
                        <span>
                            <a href="#navigation-sidebar" class="center-vertical align-right show-sidebar">
                                <span class="btn-round-text">
                                    <xsl:value-of select="'Navigation'"/>
                                </span>
                                <span>
                                    <span class="btn-round sml">
                                        <i class="fa fa-bars"/>
                                    </span>
                                </span>
                            </a>
                        </span>
                    </div>
                </div>
            </div>
            
            <!-- Content -->
            <div class="content-band">
                <div class="container">
                    <div class="tab-content">
                        
                        <xsl:copy-of select="xhtml:article/*"/>
                        
                    </div>
                </div>
            </div>
            
            <!-- Sidebar -->
            <div id="navigation-sidebar" class="fixed-sidebar collapse width hidden-print">
                <div class="fix-width">
                    <div class="sidebar-content">
                        
                        <h4 class="uppercase">
                            <xsl:value-of select="'84000 Community'"/>
                        </h4>
                        
                        <table class="table table-hover no-border">
                            <tbody>
                                <xsl:for-each select="m:tabs/m:tab">
                                    <tr>
                                        <xsl:if test="$request/@tab eq @id">
                                            <xsl:attribute name="class" select="'active'"/>
                                        </xsl:if>
                                        <td>
                                            <a>
                                                <xsl:choose>
                                                    <xsl:when test="@url">
                                                        <xsl:attribute name="href" select="@url"/>
                                                        <xsl:attribute name="target" select="concat('84000-', @id)"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="href" select="concat('?tab=', @id)"/>
                                                        <xsl:attribute name="data-loading" select="'Loading ' || m:label || '...'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:value-of select="m:label"/>
                                            </a>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                        
                    </div>
                </div>
                
                <div class="fixed-btn-container close-btn-container right">
                    <button type="button" class="btn-round close close-collapse" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat($tab-label, ' | 84000 Community')"/>
            <xsl:with-param name="page-description" select="'Tools for the 84000 translator community'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>