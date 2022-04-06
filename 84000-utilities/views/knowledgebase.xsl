<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="div-list no-border-top">
                <xsl:for-each select="m:knowledgebase/m:page">
                    <xsl:sort select="m:sort-name"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Knowledgebase Pages | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Knowledgebase Pages'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="m:page[parent::m:knowledgebase]">
        <xsl:variable name="page-id" select="concat('page-', fn:encode-for-uri(@xml:id))"/>
        
        <div class="item">
            
            <div>
                <span class="text-bold">
                    <xsl:value-of select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                </span>
                <small>
                    <xsl:value-of select="concat(' / ', @kb-id)"/>
                </small>
            </div>
            
            <div class="sml-margin bottom">
                <ul class="list-inline inline-dots">
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.tei')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.tei')"/>
                            <span class="small">
                                <xsl:value-of select="'tei'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.xml')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.xml')"/>
                            <span class="small">
                                <xsl:value-of select="'xml'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.html')"/>
                            <span class="small">
                                <xsl:value-of select="'html'"/>
                            </span>
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Alert if file locked -->
            <xsl:if test="@locked-by-user gt ''">
                <div class="sml-margin bottom">
                    <span class="label label-danger">
                        <xsl:value-of select="concat('WARNING: This file is currenly locked by user ', @locked-by-user)"/>
                    </span>
                </div>
            </xsl:if>
            
            <div class="small text-muted">
                <xsl:value-of select="concat('File: ', @document-url)"/>
            </div>    
            
        </div>
        
    </xsl:template>
    
    
</xsl:stylesheet>