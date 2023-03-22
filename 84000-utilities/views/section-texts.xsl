<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/section-texts.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Section Texts | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Texts belong to a section of the canon'"/>
            <xsl:with-param name="content">
                
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content">
                        
                        <xsl:apply-templates select="m:section"/>
                        
                    </xsl:with-param>
                </xsl:call-template>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>