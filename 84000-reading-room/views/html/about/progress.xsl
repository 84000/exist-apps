<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="bottom-margin">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'page-intro'"/>
                </xsl:call-template>
            </div>
            
            <div class="row about-stats">
                <div class="col-sm-6 col-lg-8">
                    
                    <xsl:variable name="total-pages" select="m:outline-summary/m:tohs/m:pages/@count"/>
                    <xsl:variable name="published-pages" select="m:outline-summary/m:tohs/m:pages/@published"/>
                    <xsl:variable name="translated-pages" select="m:outline-summary/m:tohs/m:pages/@translated"/>
                    <xsl:variable name="in-translation-pages" select="m:outline-summary/m:tohs/m:pages/@in-translation"/>
                    
                    <xsl:call-template name="headline-stat">
                        <xsl:with-param name="colour-class" select="'blue'"/>
                        <xsl:with-param name="label-text">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'translations-published-label'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="pages-value" select="$published-pages"/>
                        <xsl:with-param name="texts-value" select="m:outline-summary/m:tohs/@published"/>
                        <xsl:with-param name="percentage-value" select="$published-pages div $total-pages"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="headline-stat">
                        <xsl:with-param name="colour-class" select="'orange'"/>
                        <xsl:with-param name="label-text">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'translations-awaiting-label'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="pages-value" select="$translated-pages"/>
                        <xsl:with-param name="texts-value" select="m:outline-summary/m:tohs/@translated"/>
                        <xsl:with-param name="percentage-value" select="$translated-pages div $total-pages"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="headline-stat">
                        <xsl:with-param name="colour-class" select="'red'"/>
                        <xsl:with-param name="label-text">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'translations-remaining-label'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="pages-value" select="$in-translation-pages"/>
                        <xsl:with-param name="texts-value" select="m:outline-summary/m:tohs/@in-translation"/>
                        <xsl:with-param name="percentage-value" select="$in-translation-pages div $total-pages"/>
                    </xsl:call-template>
                    
                </div>
                <div class="col-sm-6 col-lg-4">
                    
                    <canvas id="progress-pie" style="width:100%;height:225px;"/>
                    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js"/>
                    <script>
                        var ctx = document.getElementById("progress-pie").getContext('2d');
                        var data = {
                            datasets: [{
                                data: [
                                    <xsl:value-of select="m:outline-summary/m:tohs/m:pages/@published"/>, 
                                    <xsl:value-of select="m:outline-summary/m:tohs/m:pages/@translated"/>, 
                                    <xsl:value-of select="m:outline-summary/m:tohs/m:pages/@in-translation"/>, 
                                    <xsl:value-of select="m:outline-summary/m:tohs/m:pages/@not-started"/>
                                ],
                                backgroundColor: ['#566e90','#b76c1e','#752d28','#4d6253']
                            }],
                            labels: ['published', 'translated', 'in progress','not started']
                        };
                        var options = { 
                             legend: { display: false, position: 'right' },
                             tooltips: { callbacks: {
                                label: function(tooltipItem, data) {
                                     var i = tooltipItem.index;
                                     var val = data.datasets[0].data[tooltipItem.index];
                                     return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + " pages " + data.labels[i];
                                 }}
                             }
                        };
                        var myPieChart = new Chart(ctx,{ type: 'pie', data: data, options: options });
                    </script>
                    
                </div>
            </div>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'outlook'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="accordion" class="list-group accordion" role="tablist" aria-multiselectable="false">
                
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'translations-published'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'translations-published-label'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <xsl:call-template name="text-list">
                            <xsl:with-param name="texts" select="m:translations-published/m:translation-status-texts/m:text"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'translations-translated'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'translations-awaiting-label'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <xsl:call-template name="text-list">
                            <xsl:with-param name="texts" select="m:translations-translated/m:translation-status-texts/m:text"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'translations-in-translation'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'translations-remaining-label'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <xsl:call-template name="text-list">
                            <xsl:with-param name="texts" select="m:translations-in-translation/m:translation-status-texts/m:text"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                
            </div>
            
            <div>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'related-pages'"/>
                </xsl:call-template>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
            <xsl:with-param name="page-class" select="'about'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="headline-stat">
        <xsl:param name="colour-class" required="yes" as="xs:string"/>
        <xsl:param name="label-text" required="yes" as="xs:string"/>
        <xsl:param name="pages-value" as="xs:integer" select="0"/>
        <xsl:param name="texts-value" as="xs:integer" select="0"/>
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
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'pages-label'"/>
                </xsl:call-template>
                <xsl:value-of select="', '"/>
                <span>
                    <xsl:value-of select="format-number($texts-value, '#,###')"/>
                </span>
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'texts-label'"/>
                </xsl:call-template>
                <xsl:value-of select="', '"/>
                <span>
                    <xsl:value-of select="format-number($percentage-value * 100, '###,##0')"/>
                    <xsl:value-of select="'%'"/>
                </span>
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'context-label'"/>
                </xsl:call-template>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>