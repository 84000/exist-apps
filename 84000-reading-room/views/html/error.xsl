<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'"/>
    <xsl:variable name="environment" select="doc($environment-path)/m:environment"/>
    
    <xsl:template match="/">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-body text-center client-error">
                        
                        <h1>Sorry, there was an error.</h1>
                        
                        <p>
                            Please select a navigation option above.
                        </p>
                        
                        <xsl:if test="$environment/@debug eq '1'">
                            <h4>
                                <xsl:value-of select="exception/path"/>
                            </h4>
                            <p>
                                <xsl:value-of select="exception/message"/>
                            </p>
                        </xsl:if>
                        
                    </div>
                </div>
            </div>
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'error'"/>
            <xsl:with-param name="page-title" select="'84000 | Error'"/>
            <xsl:with-param name="page-description" select="'Sorry, there was an error.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- suppress namespace warning -->
    <xsl:template match="dummy">
        <!-- nothing -->
    </xsl:template>
    
</xsl:stylesheet>