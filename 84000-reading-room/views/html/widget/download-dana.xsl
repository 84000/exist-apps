<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/webpage.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="communications-site-path" select="$environment/m:url[@id eq 'communications-site']/text()"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="title-en" select="m:title"/>
        
        <xsl:variable name="widget-title">
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'widget-title'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container text-center">
                    <h1 class="title">
                        <xsl:value-of select="$widget-title"/>
                    </h1>
                </div>
            </div>
            
            <div class="content-band">
                <div class="container text-center" id="dana-description">
                    <div class="row">
                        <div class="col-sm-10 col-sm-offset-1">
                            
                            <div class="center-vertical center-aligned">
                                <span>
                                    <i class="fa fa-cloud-download"/>
                                </span>
                                <span>
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'icon-label'"/>
                                    </xsl:call-template>
                                </span>
                            </div>
                            
                            <h2>
                                <xsl:value-of select="$title-en"/>
                            </h2>
                            
                            <p>
                                <a target="_blank" class="underline">
                                    
                                    <xsl:variable name="donate-form-link">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'donate-form-link'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    
                                    <xsl:attribute name="href" select="concat($communications-site-path, $donate-form-link)"/>
                                    
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'donate-form-link-label'"/>
                                    </xsl:call-template>
                                </a>
                            </p>
                            
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'dana-description'"/>
                            </xsl:call-template>
                            
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="widget-page">
            <xsl:with-param name="page-url" select="'http://read.84000.co/widget/progress.html'"/>
            <xsl:with-param name="page-class" select="'reading-room'"/>
            <xsl:with-param name="page-title" select="concat($widget-title, ' | ', $title-en, ' | 84000 Translating the Words of the Buddha')"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>