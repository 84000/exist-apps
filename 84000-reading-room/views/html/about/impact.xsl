<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            <h2>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'page-subtitle'"/>
                </xsl:call-template>
            </h2>
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'page-introduction'"/>
            </xsl:call-template>
            <hr/>
            <div class="about-stats">
                <div class="row">
                    <div class="col-sm-4">
                        <div class="stat green">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'visitors-per-week-stat'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    <div class="col-sm-8">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'visitors-description'"/>
                        </xsl:call-template>
                    </div>
                </div>
                <hr/>
                <div class="row">
                    <div class="col-sm-4">
                        <div class="stat blue">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'reach-countries-stat'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    <div class="col-sm-8">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'reach-description'"/>
                        </xsl:call-template>
                    </div>
                </div>
                <hr/>
                <div class="row">
                    <div class="col-sm-4">
                        <div class="stat orange">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'engagement-minutes-stat'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    <div class="col-sm-8">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'engagement-description'"/>
                        </xsl:call-template>
                    </div>
                </div>
                <hr/>
                <div class="row">
                    <div class="col-sm-4">
                        <div class="stat red">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'popular-views-stat'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    <div class="col-sm-8">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'popular-description'"/>
                        </xsl:call-template>
                    </div>
                </div>
                <hr/>
            </div>
            
            <h2>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'countries-title'"/>
                </xsl:call-template>
            </h2>
            
            <xsl:variable name="map-img-src">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'map-img-src'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:if test="$map-img-src gt ''">
                <div>
                    <img class="aligncenter img-responsive">
                        <xsl:attribute name="src" select="concat($front-end-path, $map-img-src)"/>
                        <xsl:attribute name="alt">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'map-img-alt'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </div>
            </xsl:if>
            
            <div class="top-margin">
                <p>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'countries-legend'"/>
                    </xsl:call-template>
                </p>
                <p class="small text-muted">
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'countries-timestamp'"/>
                    </xsl:call-template>
                </p>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
            <xsl:with-param name="page-class" select="'about'"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>