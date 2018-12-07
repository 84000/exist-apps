<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <!-- This page will redirect if you have permissions. Otherwise it'll keep coming back. -->
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-body">
                        
                        <h1>
                            You are not authorised to access this resource.
                        </h1>
                        
                        <p>
                            Please choose an alternative navigation option.
                        </p>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'auth'"/>
            <xsl:with-param name="page-title" select="'Authorisation'"/>
            <xsl:with-param name="page-description" select="'You are not authorised to access this resource.'"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="nav-tab" select="''"/>
        </xsl:call-template>
    
    </xsl:template>
    
</xsl:stylesheet>