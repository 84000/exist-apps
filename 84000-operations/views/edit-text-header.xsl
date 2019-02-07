<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Title -->
                    <div class="center-vertical full-width bottom-margin">
                        <span class="h3 text-sa">
                            <a target="_blank" class="text-muted">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:translation/@id, '.html')"/>
                                <xsl:value-of select="concat(m:translation/m:toh/m:full, ': ', m:translation/m:title)"/>
                                <xsl:if test="normalize-space(m:translation/m:translation/m:edition)">
                                    <xsl:value-of select="' / '"/>
                                    <span class="small">
                                        <xsl:value-of select="m:translation/m:translation/m:edition"/>
                                    </span>
                                </xsl:if>
                            </a>
                        </span>
                        <span>
                            <div class="pull-right">
                                <xsl:copy-of select="common:translation-status(m:translation/@status)"/>
                            </div>
                        </span>
                    </div>
                    
                    <!-- 
                        <hr class="sml-margin"/>
                        Summary
                        <div class="top-vertical bottom-margin">
                            <a role="button" data-toggle="collapse" href="#panelStatus" aria-expanded="false" aria-controls="panelTitles" class="italic text-color">
                                <xsl:choose>
                                    <xsl:when test="m:translation-status/m:notes/text()">
                                        <xsl:value-of select="common:limit-str(m:translation-status/m:notes, 160)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        [No notes]
                                    </xsl:otherwise>
                                </xsl:choose>
                            </a>
                            <xsl:if test="m:translation-status/m:task[not(@checked-off)]">
                               <a role="button" data-toggle="collapse" href="#panelStatus" aria-expanded="false" aria-controls="panelTitles">
                                   <span class="badge badge-notification">
                                       <xsl:value-of select="count(m:translation-status/m:task[not(@checked-off)])"/>
                                   </span>
                               </a>
                            </xsl:if>
                        </div> -->
                    
                    <div class="panel-group" role="tablist" aria-multiselectable="true" id="forms-accordion">
                        
                        <xsl:call-template name="titles-form-panel"/>
                        
                        <xsl:call-template name="locations-form-panel"/>
                        
                        <xsl:call-template name="contributors-form-panel"/>
                        
                        <xsl:call-template name="translation-status-form-panel">
                            <xsl:with-param name="active" select="true()"/>
                        </xsl:call-template>
                        
                        <!-- 
                            Submissions form prototype -->
                        <xsl:call-template name="submissions-form-panel"/>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Institutions :: 84000 Operations'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>