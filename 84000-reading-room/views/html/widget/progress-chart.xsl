<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../website-page.xsl"/>
    <xsl:import href="../../../xslt/lang.xsl"/>
    <xsl:import href="../../../xslt/functions.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <div class="container">
                <div class="row">
                    <div class="col-sm-offset-4 col-sm-4 top-margin">
                        <div id="eft-progress-chart-panel" class="panel panel-default">
                            <div id="eft-progress-chart-panel-body" class="panel-body">
                                <div id="eft-progress-chart-panel-content">
                                    
                                    <div class="tabs-container">
              
                                        <ul class="nav nav-tabs" role="tablist">
                                            <li role="presentation" class="active">
                                                <a href="#eft-progress-chart-kangyur-tab" aria-controls="eft-progress-chart-kangyur-tab" role="tab" data-toggle="tab">
                                                    <xsl:value-of select="'Kangyur'"/>
                                                    <br/>
                                                    <small class="text-muted">
                                                        <xsl:value-of select="'~70,000 pages'"/>
                                                        <!--<br/><xsl:value-of select="'In 25 years'"/>-->
                                                    </small>
                                                </a>
                                            </li>
                                            <li role="presentation">
                                                <a href="#eft-progress-chart-combined-tab" aria-controls="eft-progress-chart-combined-tab" role="tab" data-toggle="tab">
                                                    <xsl:value-of select="'And Tengyur'"/>
                                                    <br/>
                                                    <small class="text-muted">
                                                        <xsl:value-of select="'~240,000 pages'"/>
                                                        <!--<br/><xsl:value-of select="'In 100 years'"/>-->
                                                    </small>
                                                </a>
                                            </li>
                                        </ul>
                                        <div class="tab-content">
                                            <div role="tabpanel" class="tab-pane active" id="eft-progress-chart-kangyur-tab">
                                                <xsl:call-template name="chart">
                                                    <xsl:with-param name="outline-summary" select="m:outline-summary[@work eq 'UT4CZ5369']"/>
                                                </xsl:call-template>
                                                <p class="top-margin small">
                                                    <xsl:value-of select="'Our 25 year goal is the translation of the Kangyur, the ancient Tibetan library of the Buddha''s Sūtras made up of approximately 70,000 pages.'"/>
                                                </p>
                                            </div>
                                            <div role="tabpanel" class="tab-pane" id="eft-progress-chart-combined-tab">
                                                <xsl:call-template name="chart">
                                                    <xsl:with-param name="outline-summary" select="m:outline-summary"/>
                                                </xsl:call-template>
                                                <p class="top-margin small">
                                                    <xsl:value-of select="'Our 100 year goal is the translation of the Kangyur and the Tengyur making up the full 240,000 pages of the Tibetan canon of sūtras and commentaries.'"/>
                                                </p>
                                            </div>
                                        </div>
              
                                    </div>
                                    
                                    <div class="text-center top-margin">
                                        <div>
                                            <a class="btn btn-warning btn-lg uppercase">
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
    
    <xsl:template name="chart">
        
        <xsl:param name="outline-summary" as="element(m:outline-summary)*" required="yes"/>
        
        <xsl:variable name="chart-id" select="string-join(('eft-progress-chart', $outline-summary/@work ! string(.)), '-')"/>
        <xsl:variable name="percent-published" select="xs:integer((sum($outline-summary/m:tohs/m:pages/@published ! xs:integer(.)) div sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))) * 100)" as="xs:integer"/>
        <xsl:variable name="percent-translated" select="xs:integer((sum($outline-summary/m:tohs/m:pages/@translated ! xs:integer(.)) div sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))) * 100)" as="xs:integer"/>
        <xsl:variable name="percent-in-translation" select="xs:integer((sum($outline-summary/m:tohs/m:pages/@in-translation ! xs:integer(.)) div sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))) * 100)" as="xs:integer"/>
        <xsl:variable name="percent-remaining" select="100 - ($percent-in-translation + $percent-published + $percent-translated)" as="xs:integer"/>
        
        <div style="height:300px;">
            <xsl:attribute name="id" select="$chart-id"/>
        </div>
        
        <script>
            Highcharts.chart("<xsl:value-of select="$chart-id"/>", {
                chart: {
                    plotBackgroundColor: null,
                    plotBorderWidth: null,
                    plotShadow: false,
                    type: 'pie'
                },
                title: {
                    text: undefined
                },
                tooltip: {
                    pointFormat: '{point.y}% {series.data.name}'
                },
                legend: {
                    align: 'left',
                    verticalAlign: 'top',
                    layout: 'vertical',
                    floating: true,
                    backgroundColor: 'rgba(255,255,255,.7)',
                    itemMarginBottom: 5,
                    labelFormat: '{name}'
                },
                accessibility: {
                    point: {
                        valueSuffix: '%'
                    }
                },
                plotOptions: {
                    pie: {
                        allowPointSelect: false,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: true,
                            format: '{point.y}%',
                            distance: '-30%',
                            style: {
                                color: '#fff',
                                fontSize: '12px',
                                fontWeight: 'normal',
                                textOutline: 'none'
                            }
                        },
                        showInLegend: true,
                        point: {
                            events: {
                                legendItemClick: function(){
                                    return false;
                                }
                            }
                        }
                    }
                },
                series: [{
                    name: 'Translation status',
                    data: [{
                        name: 'Published',
                        y: <xsl:value-of select="$percent-published"/>,
                        color: '#566e90'
                    }, {
                        name: 'Translated',
                        y: <xsl:value-of select="$percent-translated"/>,
                        color: '#b76c1e'
                    }, {
                        name: 'In translation',
                        y: <xsl:value-of select="$percent-in-translation"/>,
                        color: '#752d28'
                    }, {
                        name: 'Not started',
                        y: <xsl:value-of select="$percent-remaining"/>,
                        color: '#4d6253'
                    }]
                }]
            });
        </script>
    </xsl:template>
    
</xsl:stylesheet>