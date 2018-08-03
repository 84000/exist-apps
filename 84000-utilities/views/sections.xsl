<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Utilities
                        </span>
                        
                        <span class="text-right">
                            <a target="_self">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                Reading Room
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <table class="table table-responsive">
                                <thead>
                                    <tr>
                                        <th>Section</th>
                                        <th>Path</th>
                                        <th>ID</th>
                                        <th>TEI</th>
                                        <th>XML</th>
                                        <th>HTML</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="//m:child">
                                        <tr>
                                            <td>
                                                <span class="center-vertical">
                                                    <span class="nowrap">
                                                        <xsl:for-each select="1 to @nesting"> — </xsl:for-each>
                                                    </span>
                                                    <span>
                                                        <xsl:value-of select="m:title/text()"/>
                                                    </span>
                                                </span>
                                            </td>
                                            <td>section/</td>
                                            <td>
                                                <xsl:value-of select="@id"/>
                                            </td>
                                            <td>
                                                <a target="_blank">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/section/', @id, '.tei')"/>
                                                    .tei
                                                </a>
                                            </td>
                                            <td>
                                                <a target="_blank">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/section/', @id, '.xml')"/>
                                                    .xml
                                                </a>
                                            </td>
                                            <td>
                                                <a target="_blank">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/section/', @id, '.html')"/>
                                                    .html
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sections :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Sections'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>