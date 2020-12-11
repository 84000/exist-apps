<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'84000 Operations Sections'"/>
                    </h3>
                    
                    <div class="tab-content">
                        <table class="table table-responsive">
                            <thead>
                                <tr>
                                    <th>Section</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="m:descendants">
                                    <xsl:sort select="xs:integer(@sort-index)"/>
                                    <xsl:call-template name="section-row"/>
                                </xsl:for-each>
                            </tbody>
                        </table>
                        
                    </div>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sections | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 catalogue of sections'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="section-row">
        <xsl:variable name="section-texts-id" select="concat('section-texts-', fn:encode-for-uri(@id))"/>
        <tr>
            <td>
                <xsl:call-template name="indent">
                    <xsl:with-param name="counter" select="1"/>
                    <xsl:with-param name="finish" select="xs:integer(@nesting)"/>
                    <xsl:with-param name="content">
                        <span class="text-bold">
                            <xsl:value-of select="m:title"/>
                        </span>
                    </xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
        <xsl:for-each select="m:descendants">
            <xsl:sort select="xs:integer(@sort-index)"/>
            <xsl:call-template name="section-row"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>