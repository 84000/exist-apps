<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">

    <xsl:import href="charts.xsl"/>
    <xsl:import href="../../../xslt/webpage.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container text-center">
                    <h1 class="title">
                        <xsl:value-of select="'84000 Progress Chart'"/>
                    </h1>
                </div>
            </div>
            
            <main class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-sm-offset-4 col-sm-4 top-margin">
                            <div id="eft-progress-chart-panel" class="panel panel-default no-border">
                                
                                <div id="eft-progress-chart-panel-body" class="panel-body no-padding">
                                    <div id="eft-progress-chart-panel-content">
                                        <div class="tabs-container">

                                            <ul class="nav nav-tabs no-bottom-margin" role="tablist">
                                                <xsl:for-each select="('kangyur', 'combined')">
                                                    <xsl:variable name="tab" select="." as="xs:string"/>
                                                    <li role="presentation">
                                                        <xsl:if test="$tab eq 'kangyur'">
                                                            <xsl:attribute name="class" select="'active'"/>
                                                        </xsl:if>
                                                        <a role="tab" data-toggle="tab">
                                                            <xsl:attribute name="href" select="concat('#eft-progress-chart-', $tab, '-tab')"/>
                                                            <xsl:attribute name="aria-controls" select="concat('eft-progress-chart-', $tab, '-tab')"/>
                                                            <xsl:call-template name="text">
                                                                <xsl:with-param name="global-key" select="concat('widget.progress-chart.tab-title-', $tab)"/>
                                                            </xsl:call-template>
                                                            <!--<br/>
                                                            <small class="text-muted">
                                                                <xsl:call-template name="text">
                                                                    <xsl:with-param name="global-key" select="concat('widget.progress-chart.tab-subtitle-', $tab)"/>
                                                                </xsl:call-template>
                                                            </small>-->
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                            
                                            <div class="tab-content panel-padding panel-border">
                                                <xsl:variable name="translation-summary" select="m:translation-summary"/>
                                                <xsl:variable name="replace-text" select="m:replace-text"/>
                                                <xsl:for-each select="('kangyur', 'combined')">
                                                    <xsl:variable name="tab" select="." as="xs:string"/>
                                                    <div role="tabpanel" class="tab-pane fade">
                                                        
                                                        <xsl:attribute name="id" select="concat('eft-progress-chart-', $tab, '-tab')"/>
                                                        
                                                        <xsl:if test="$tab eq 'kangyur'">
                                                            <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                                        </xsl:if>
                                                        
                                                        <div class="bottom-margin small">
                                                            <xsl:call-template name="text">
                                                                <xsl:with-param name="global-key" select="concat('widget.progress-chart.tab-description-', $tab)"/>
                                                            </xsl:call-template>
                                                        </div>
                                                        
                                                        <xsl:choose>
                                                            <xsl:when test="$tab eq 'kangyur'">
                                                                <xsl:call-template name="progress-pie-chart">
                                                                    <xsl:with-param name="publications-summary" select="$translation-summary/m:translation-summary[@section-id eq 'O1JC11494']/m:publications-summary[@scope eq 'descendant'][@grouping eq 'toh']"/>
                                                                    <xsl:with-param name="replace-text" select="$replace-text"/>
                                                                    <xsl:with-param name="show-legend" select="true()"/>
                                                                </xsl:call-template>
                                                            </xsl:when>
                                                            <xsl:when test="$tab eq 'combined'">
                                                                <xsl:call-template name="progress-pie-chart">
                                                                    <xsl:with-param name="publications-summary" select="$translation-summary/m:publications-summary[@scope eq 'descendant'][@grouping eq 'toh']"/>
                                                                    <xsl:with-param name="replace-text" select="$replace-text"/>
                                                                    <xsl:with-param name="show-legend" select="true()"/>
                                                                </xsl:call-template>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        
                                                    </div>
                                                </xsl:for-each>
                                            </div>
                                            
                                            <div class="text-center panel-padding panel-border">
                                                
                                                <div>
                                                    <a class="btn btn-warning uppercase">
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="local-text">
                                                                <xsl:with-param name="local-key" select="'sponsor-button-link'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:call-template name="local-text">
                                                            <xsl:with-param name="local-key" select="'sponsor-button-label'"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </div>
                                                
                                                <xsl:variable name="donate-instructions-link">
                                                    <xsl:call-template name="local-text">
                                                        <xsl:with-param name="local-key" select="'donate-instructions-link'"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                
                                                <xsl:if test="$donate-instructions-link gt ''">
                                                    <div class="sml-margin top">
                                                        <a target="_blank">
                                                            <xsl:attribute name="href" select="$donate-instructions-link"/>
                                                            <xsl:attribute name="title">
                                                                <xsl:call-template name="local-text">
                                                                    <xsl:with-param name="local-key" select="'donate-instructions-link-title'"/>
                                                                </xsl:call-template>
                                                            </xsl:attribute>
                                                            <xsl:call-template name="local-text">
                                                                <xsl:with-param name="local-key" select="'donate-instructions-label'"/>
                                                            </xsl:call-template>
                                                        </a>
                                                    </div>
                                                </xsl:if>
                                                
                                            </div>
                                            
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
            <xsl:with-param name="page-url" select="'https://read.84000.co/widget/progress-chart.html'"/>
            <xsl:with-param name="page-class" select="''"/>
            <xsl:with-param name="page-title" select="'Progress Summary | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="'Overview of the current status of the 84000 project'"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>