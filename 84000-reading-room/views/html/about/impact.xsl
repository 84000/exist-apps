<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content">
                <!--<h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'page-subtitle'"/>
                    </xsl:call-template>
                </h2>-->
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
                </div>
            </xsl:with-param>
            
            <xsl:with-param name="side-content">
                
                <xsl:variable name="nav-sidebar">
                    <m:nav-sidebar>
                        <xsl:copy-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item/m:item[m:item[@url eq $active-url]]"/>
                    </m:nav-sidebar>
                </xsl:variable>
                <div class="nav-sidebar">
                    <xsl:apply-templates select="$nav-sidebar"/>
                </div>
                
                <div id="project-progress">
                    <!-- Project Progress, get from ajax -->
                    <xsl:attribute name="data-onload-replace">
                        <xsl:choose>
                            <xsl:when test="$lang eq 'zh'">
                                <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-chart.html#eft-progress-chart-panel&#34;}')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-chart.html?lang=', $lang ,'#eft-progress-chart-panel&#34;}')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>                            
                    <div class="panel panel-default">
                        <div class="panel-body loading"/>
                    </div>
                </div>
                
            </xsl:with-param>
            
            <xsl:with-param name="page-class" select="'about'"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>