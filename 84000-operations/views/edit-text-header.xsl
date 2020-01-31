<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Title -->
                    <div class="h3 sml-margin top bottom">
                        <a target="_blank">
                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:translation/@id, '.html')"/>
                            <xsl:value-of select="concat(string-join(m:translation/m:toh/m:full, ' / '), ' : ', m:translation/m:title)"/>
                        </a>
                    </div>
                    
                    <div class="sml-margin bottom">
                        <xsl:copy-of select="common:translation-status(m:translation/@status-group)"/>
                        <xsl:if test="normalize-space(m:translation/m:translation/m:edition)">
                            <a class="label label-info">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:translation/@id, '.tei')"/>
                                <xsl:attribute name="target" select="concat(m:translation/@id, '.tei')"/>
                                <xsl:value-of select="concat('TEI ', m:translation/m:translation/m:edition)"/>
                            </a>
                        </xsl:if>
                        <xsl:if test="m:translation/@status eq '1'">
                            <xsl:for-each select="m:translation/m:downloads">
                                <xsl:variable name="resource-id" select="@resource-id"/>
                                <xsl:variable name="tei-version" select="@tei-version"/>
                                <xsl:for-each select="m:download">
                                    <a href="#" class="label label-danger">
                                        <xsl:choose>
                                            <xsl:when test="@version eq $tei-version">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/data/', $resource-id, '.', @type)"/>
                                                <xsl:attribute name="class" select="'label label-info'"/>
                                                <i class="fa fa-check"/>
                                                <xsl:value-of select="concat(' ', $resource-id, '.', @type)"/>
                                            </xsl:when>
                                            <xsl:when test="@version eq 'none'">
                                                <i class="fa fa-exclamation-circle"/>
                                                <xsl:value-of select="concat(' ', $resource-id, '.', @type, ' missing')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/data/', $resource-id, '.', @type)"/>
                                                <i class="fa fa-exclamation-circle"/>
                                                <xsl:value-of select="concat(' ', $resource-id, '.', @type, ' ', @version)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:if>
                    </div>
                    
                    <div class="small text-muted bottom-margin">
                        <xsl:value-of select="concat('TEI file: ', m:translation/@document-url)"/>
                    </div>
                    
                    <div class="panel-group" role="tablist" aria-multiselectable="true" id="forms-accordion">
                        
                        <xsl:call-template name="titles-form-panel"/>
                        
                        <xsl:call-template name="locations-form-panel"/>
                        
                        <xsl:call-template name="contributors-form-panel"/>
                        
                        <!-- Submissions form prototype -->
                        <xsl:call-template name="submissions-form-panel"/>
                        
                        <xsl:call-template name="translation-status-form-panel">
                            <xsl:with-param name="active" select="true()"/>
                        </xsl:call-template>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Text | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>