<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" xmlns:util="http://exist-db.org/xquery/util" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
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
            <xsl:with-param name="page-class" select="'reading-room auth'"/>
            <xsl:with-param name="page-title" select="'Authorisation | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="'You are not authorised to access this resource.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
    
    </xsl:template>
    
</xsl:stylesheet>