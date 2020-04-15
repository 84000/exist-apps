<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <p>
                <xsl:value-of select="'Testing Audio Sūtra.m4a shared via Google Drive'"/>
            </p>
            
            <!--<div class="embed-responsive embed-responsive-16by9">
                <iframe frameborder="0" src="https://drive.google.com/file/d/1KO7rLqdvdnXMuGPu5qPO5oxy-D2EEldv/preview"/>
            </div>-->
             
            <audio controls="controls">
                <source src="http://docs.google.com/uc?export=open&amp;id=1KO7rLqdvdnXMuGPu5qPO5oxy-D2EEldv" type="audio/mp3"/>    
            </audio>
             
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
            <xsl:with-param name="page-class" select="'about'"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>