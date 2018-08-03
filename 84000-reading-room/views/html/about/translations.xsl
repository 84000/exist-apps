<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="row about-stats">
                <div class="col-sm-6 col-lg-8">
                    
                    <xsl:variable name="total-pages" select="m:outline-summary/m:tohs/m:pages/@count"/>
                    <xsl:variable name="published-pages" select="m:outline-summary/m:tohs/m:pages/@published"/>
                    <xsl:variable name="translated-pages" select="m:outline-summary/m:tohs/m:pages/@translated"/>
                    <xsl:variable name="in-translation-pages" select="m:outline-summary/m:tohs/m:pages/@in-translation"/>
                    
                    <div class="stat published">
                        <div class="heading">Published translations:</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number($published-pages, '#,###')"/>
                            </span> pages, 
                            <span>
                                <xsl:value-of select="format-number(m:outline-summary/m:tohs/@published, '#,###')"/>
                            </span> texts, 
                            <span>
                                <xsl:value-of select="format-number(($published-pages div $total-pages) * 100, '###,##0')"/>%</span> of the Kangyur.
                        </div>
                    </div>
                    
                    <div class="stat translated">
                        <div class="heading">Translations awaiting publication:</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number($translated-pages, '#,###')"/>
                            </span> pages, 
                            <span>
                                <xsl:value-of select="format-number(m:outline-summary/m:tohs/@translated, '#,###')"/>
                            </span> texts, 
                            <span>
                                <xsl:value-of select="format-number(($translated-pages div $total-pages) * 100, '###,##0')"/>%</span> of the Kangyur.
                        </div>
                    </div>
                    
                    <div class="stat commissioned">
                        <div class="heading">Other translations in progress:</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number($in-translation-pages, '#,###')"/>
                            </span> pages, 
                            <span>
                                <xsl:value-of select="format-number(m:outline-summary/m:tohs/@in-translation, '#,###')"/>
                            </span> texts, 
                            <span>
                                <xsl:value-of select="format-number(($in-translation-pages div $total-pages) * 100, '###,##0')"/>%</span> of the Kangyur.
                        </div>
                    </div>
                    
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
                                backgroundColor: ['#4d6253','#566e90','#b76c1e','#bbbbbb']
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
            
            <ul class="nav nav-tabs" role="tablist" id="progress-tabs">
                <xsl:for-each select="m:tabs/m:tab">
                    <li role="presentation">
                        <xsl:if test="@active eq '1'">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="href" select="concat('?tab=', @id, '#progress-tabs')"/>
                            <xsl:value-of select="text()"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
            
            <div class="tab-content">
                
                <div class="text-list">
                    <div class="row table-headers">
                        <div class="col-sm-2 hidden-xs">Toh</div>
                        <div class="col-sm-8">Title</div>
                        <div class="col-sm-2">Pages</div>
                    </div>
                    <div class="list-section">
                        <xsl:for-each select="m:texts/m:text">
                            <div class="row list-item">
                                <div class="col-sm-2">
                                    <xsl:value-of select="m:toh/m:full"/>
                                </div>
                                <div class="col-sm-8">
                                    
                                    <xsl:call-template name="text-list-title">
                                        <xsl:with-param name="text" select="."/>
                                    </xsl:call-template>
                                    
                                    <xsl:call-template name="text-list-subtitles">
                                        <xsl:with-param name="text" select="."/>
                                    </xsl:call-template>
                                    
                                    <xsl:if test="m:translation/m:authors/m:author">
                                        <hr/>
                                        Translated by: 
                                        <xsl:value-of select="string-join(m:translation/m:authors/m:author/text(), ', ')"/>.
                                    </xsl:if>
                                    
                                </div>
                                <div class="col-sm-2">
                                    <xsl:value-of select="format-number(tei:bibl/tei:location/@count-pages, '#,###')"/>
                                </div>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div class="row table-footer">
                        <div class="col-sm-10 text-right">
                            Total pages:
                        </div>
                        <div class="col-sm-2">
                            <strong>
                                <xsl:value-of select="format-number(sum(m:texts/m:text/tei:bibl/tei:location/@count-pages), '#,###')"/>
                            </strong>
                        </div>
                    </div>
                </div>
                
            </div>
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>