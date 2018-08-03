<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" xmlns:pkg="http://expath.org/ns/pkg" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="common.xsl"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <xsl:template name="reading-room-page">
        
        <xsl:param name="page-url"/>
        <xsl:param name="page-class"/>
        <xsl:param name="page-title"/>
        <xsl:param name="page-description"/>
        <xsl:param name="content"/>
        
        <!-- Look up environment variables -->
        <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'"/>
        <xsl:variable name="environment" select="doc($environment-path)/m:environment"/>
        <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
        <xsl:variable name="app-version" select="doc('../../expath-pkg.xml')/pkg:package/@version"/>
        <xsl:variable name="ga-tracking-id" select="$environment/m:google-analytics/@tracking-id"/>
        
        <html>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="app-version" select="$app-version"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'reading-room'"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="$page-class"/>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:warning/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:warning/text()"/> / <xsl:value-of select="@user-name"/>
                    </div>
                </xsl:if>
                
                <!-- Alert -->
                <div id="page-alert" class="collapse">
                    <div class="container"/>
                </div>
                
                <!-- Place content -->
                <xsl:copy-of select="$content"/>
                
                <!-- Get the common <footer> -->
                <xsl:call-template name="html-footer">
                    <xsl:with-param name="front-end-path" select="$front-end-path"/>
                    <xsl:with-param name="app-version" select="$app-version"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
</xsl:stylesheet>