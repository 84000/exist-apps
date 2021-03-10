<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="row">
                    <div class="col-sm-6 col-sm-offset-3">
                        
                        <xsl:for-each select="m:result/m:collection">
                            <div role="alert">
                                <xsl:choose>
                                    <xsl:when test="@reindexed eq 'true'">
                                        <xsl:attribute name="class" select="'alert alert-success small text-center'"/>
                                        <xsl:value-of select="concat('Re-indexed: ', @path)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class" select="'alert alert-danger small text-center'"/>
                                        <xsl:value-of select="concat('Re-index failed: ', @path)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </xsl:for-each>
                        
                        <div class="alert alert-info small text-center">
                            <p>Re-index database collections if the index is missing items or the config is updated.</p>
                        </div>
                        
                        <ul>
                            <li>
                                <a href="?collection=tests">Test data</a>
                            </li>
                            <li>
                                <a href="?collection=linked-data">Linked Data references</a>
                            </li>
                            <li>
                                <a href="?collection=operations">Operations data</a>
                            </li>
                            <li>
                                <a href="?collection=local">Local data</a>
                            </li>
                            <li>
                                <a href="?collection=tei">TEI data</a>
                            </li>
                            <li>
                                <a href="?collection=translation-memory">Translation memory data</a>
                            </li>
                            <li>
                                <a href="?collection=translation-memory-generator">Translation memory generator data</a>
                            </li>
                            <li>
                                <a href="?collection=source">Tibetan source data</a>
                            </li>
                            <li>
                                <a href="?collection=reading-room-config">Reading Room config</a>
                            </li>
                            <li>
                                <a href="?collection=related-files">Related files</a>
                            </li>
                        </ul>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Re-index | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Test utilities'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>