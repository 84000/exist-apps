<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">

    <xsl:template name="progress-pie-chart">
        
        <xsl:param name="outline-summary" as="element(m:outline-summary)*" required="yes"/>
        <xsl:param name="replace-text" as="element(m:replace-text)" required="yes"/>
        <xsl:param name="show-legend" as="xs:boolean" required="yes"/>
        
        <xsl:variable name="chart-id" select="string-join(('eft-progress-chart', $outline-summary/@work ! string(.)), '-')"/>
        <xsl:variable name="percent-published" select="xs:integer((sum($outline-summary/m:tohs/m:pages/@published ! xs:integer(.)) div sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))) * 100)" as="xs:integer"/>
        <xsl:variable name="percent-translated" select="xs:integer((sum($outline-summary/m:tohs/m:pages/@translated ! xs:integer(.)) div sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))) * 100)" as="xs:integer"/>
        <xsl:variable name="percent-in-translation" select="xs:integer((sum($outline-summary/m:tohs/m:pages/@in-translation ! xs:integer(.)) div sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))) * 100)" as="xs:integer"/>
        <xsl:variable name="percent-remaining" select="100 - ($percent-in-translation + $percent-published + $percent-translated)" as="xs:integer"/>
        
        <xsl:variable name="label-published" select="$replace-text/m:value[@key eq '#labelPublished']/text()"/>
        <xsl:variable name="label-translated" select="$replace-text/m:value[@key eq '#labelTranslated']/text()"/>
        <xsl:variable name="label-in-translation" select="$replace-text/m:value[@key eq '#labelInTranslation']/text()"/>
        <xsl:variable name="label-remaining" select="$replace-text/m:value[@key eq '#labelRemaining']/text()"/>
        
        <div style="height:270px;">
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
                <xsl:choose>
                    <xsl:when test="$show-legend">
                        legend: {
                            align: 'left',
                            verticalAlign: 'top',
                            layout: 'vertical',
                            floating: true,
                            backgroundColor: 'rgba(255,255,255,.7)',
                            itemMarginBottom: 5,
                            labelFormat: '{name}'
                        },
                    </xsl:when>
                    <xsl:otherwise>
                        legend: {
                            enabled: false
                        },
                    </xsl:otherwise>
                </xsl:choose>
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
                        name: '<xsl:value-of select="$label-published"/>',
                        y: <xsl:value-of select="$percent-published"/>,
                        color: '#566e90'
                    }, {
                        name: '<xsl:value-of select="$label-translated"/>',
                        y: <xsl:value-of select="$percent-translated"/>,
                        color: '#b76c1e'
                    }, {
                        name: '<xsl:value-of select="$label-in-translation"/>',
                        y: <xsl:value-of select="$percent-in-translation"/>,
                        color: '#752d28'
                    }, {
                        name: '<xsl:value-of select="$label-remaining"/>',
                        y: <xsl:value-of select="$percent-remaining"/>,
                        color: '#4d6253'
                    }]
                }]
            });
        </script>
    </xsl:template>
        
</xsl:stylesheet>