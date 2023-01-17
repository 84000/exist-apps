<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="charts.xsl"/>
    <xsl:import href="../../../xslt/webpage.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container text-center">
                    <h1 class="title">
                        <xsl:value-of select="'84000 Progress Chart ' || m:request/m:work-name"/>
                    </h1>
                </div>
            </div>
            
            <main class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-sm-8 col-sm-offset-2">
                            <div id="eft-progress-chart-single-content">
                                
                                <div class="row about-stats">
                                    <div class="col-sm-6 col-lg-4">
                                        
                                        <xsl:call-template name="progress-pie-chart">
                                            <xsl:with-param name="outline-summary" select="m:outline-summary"/>
                                            <xsl:with-param name="replace-text" select="m:replace-text"/>
                                            <xsl:with-param name="show-legend" select="false()"/>
                                        </xsl:call-template>
                                        
                                    </div>
                                    <div class="col-sm-6 col-lg-8">
                                        
                                        <xsl:variable name="total-pages" select="sum(m:outline-summary/m:tohs/m:pages/@count ! xs:integer(.))"/>
                                        <xsl:variable name="published-pages" select="sum(m:outline-summary/m:tohs/m:pages/@published ! xs:integer(.))"/>
                                        <xsl:variable name="translated-pages" select="sum(m:outline-summary/m:tohs/m:pages/@translated ! xs:integer(.))"/>
                                        <xsl:variable name="in-translation-pages" select="sum(m:outline-summary/m:tohs/m:pages/@in-translation ! xs:integer(.))"/>
                                        
                                        <div class="top-margin">
                                            
                                            <xsl:call-template name="headline-stat">
                                                <xsl:with-param name="colour-class" select="'blue'"/>
                                                <xsl:with-param name="label-text">
                                                    <xsl:call-template name="text">
                                                        <xsl:with-param name="global-key" select="'about.progress.translations-published-label'"/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                                <xsl:with-param name="pages-value" select="$published-pages"/>
                                                <xsl:with-param name="percentage-value" select="xs:integer(($published-pages div $total-pages) * 100)"/>
                                            </xsl:call-template>
                                            
                                            <xsl:call-template name="headline-stat">
                                                <xsl:with-param name="colour-class" select="'orange'"/>
                                                <xsl:with-param name="label-text">
                                                    <xsl:call-template name="text">
                                                        <xsl:with-param name="global-key" select="'about.progress.translations-awaiting-label'"/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                                <xsl:with-param name="pages-value" select="$translated-pages"/>
                                                <xsl:with-param name="percentage-value" select="xs:integer(($translated-pages div $total-pages) * 100)"/>
                                            </xsl:call-template>
                                            
                                            <xsl:call-template name="headline-stat">
                                                <xsl:with-param name="colour-class" select="'red'"/>
                                                <xsl:with-param name="label-text">
                                                    <xsl:call-template name="text">
                                                        <xsl:with-param name="global-key" select="'about.progress.translations-remaining-label'"/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                                <xsl:with-param name="pages-value" select="$in-translation-pages"/>
                                                <xsl:with-param name="percentage-value" select="xs:integer(($in-translation-pages div $total-pages) * 100)"/>
                                            </xsl:call-template>
                                            
                                        </div>
                                        
                                    </div>
                                </div>
                                
                            </div>
                            
                        </div>
                    </div>
                </div>
            </main>
        </xsl:variable>
        
        <xsl:call-template name="widget-page">
            <xsl:with-param name="page-url" select="'https://read.84000.co/widget/progress-chart-single.html?work=' || m:request/@work"/>
            <xsl:with-param name="page-class" select="''"/>
            <xsl:with-param name="page-title" select="'Progress Chart for '  || m:request/m:work-name || ' | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="'Overview of the current status of the 84000 project for the ' || m:request/m:work-name"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="headline-stat">
        
        <xsl:param name="colour-class" required="yes" as="xs:string"/>
        <xsl:param name="label-text" required="yes" as="xs:string"/>
        <xsl:param name="pages-value" as="xs:integer" select="0"/>
        <xsl:param name="percentage-value" as="xs:double" select="0"/>
        <div>
            <xsl:attribute name="class" select="concat('stat ', $colour-class)"/>
            <div class="heading">
                <xsl:value-of select="$label-text"/>
            </div>
            <div class="data">
                <span>
                    <xsl:value-of select="format-number($pages-value, '#,###')"/>
                </span> 
                <xsl:value-of select="' '"/>
                <xsl:call-template name="text">
                    <xsl:with-param name="global-key" select="'about.common.pages-label'"/>
                </xsl:call-template>
                <xsl:value-of select="' '"/>
                <xsl:value-of select="'('"/>
                <xsl:value-of select="format-number($percentage-value, '###,##0')"/>
                <xsl:value-of select="'%)'"/>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>