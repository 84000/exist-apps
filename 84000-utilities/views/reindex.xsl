<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <span class="title">
                            <xsl:value-of select="'84000 Utilities'"/>
                        </span>
                        
                        <span class="text-right">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                <xsl:value-of select="'Reading Room'"/>
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <div class="row">
                                <div class="col-sm-6 col-sm-offset-3">
                            
                                    <xsl:if test="m:request/@collection gt ''">
                                        <div class="alert alert-success" role="alert">
                                            <xsl:choose>
                                                <xsl:when test="m:result/@reindexed eq 'true'">
                                                    <xsl:attribute name="class" select="'alert alert-success'"/>
                                                    <xsl:value-of select="concat('Re-indexed: ', m:result/@collection)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="class" select="'alert alert-danger'"/>
                                                    <xsl:value-of select="concat('Re-index failed: ', m:result/@collection)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </div>
                                    </xsl:if>
                                    
                                    <div class="alert alert-info small text-center">
                                        <p>Re-index database collections if the index is missing items or the config is updated.</p>
                                    </div>
                                    
                                    <ul>
                                        <li>
                                            <a href="?collection=tei">TEI collection</a>
                                        </li>
                                        <li>
                                            <a href="?collection=operations">Operations collection</a>
                                        </li>
                                        <li>
                                            <a href="?collection=translation-memory">Translation memory collection</a>
                                        </li>
                                    </ul>
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Tests | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Test utilities'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>