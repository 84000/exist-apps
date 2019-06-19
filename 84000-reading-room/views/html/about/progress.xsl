<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="row about-stats">
                <div class="col-sm-6 col-lg-8">
                    
                    <xsl:variable name="total-pages" select="m:outline-summary/m:tohs/m:pages/@count"/>
                    <xsl:variable name="published-pages" select="m:outline-summary/m:tohs/m:pages/@published"/>
                    <xsl:variable name="translated-pages" select="m:outline-summary/m:tohs/m:pages/@translated"/>
                    <xsl:variable name="in-translation-pages" select="m:outline-summary/m:tohs/m:pages/@in-translation"/>
                    
                    <div class="stat green">
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
                    
                    <div class="stat blue">
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
                    
                    <div class="stat orange">
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
                <li role="presentation" class="active">
                    <a href="#translations-published" role="tab" data-toggle="tab" aria-controls="translations-published">
                        <xsl:value-of select="'Published Translations'"/>
                    </a>
                </li>
                <li role="presentation">
                    <a href="#translations-translated" role="tab" data-toggle="tab" aria-controls="translations-translated">
                        <xsl:value-of select="'Translations Awaiting Publication'"/>
                    </a>
                </li>
                <li role="presentation">
                    <a href="#translations-in-translation" role="tab" data-toggle="tab" aria-controls="translations-in-translation">
                        <xsl:value-of select="'Translations In Progress'"/>
                    </a>
                </li>
            </ul>
            
            <div class="tab-content">
                
                <xsl:call-template name="tab-list">
                    <xsl:with-param name="id" select="'translations-published'"/>
                    <xsl:with-param name="texts" select="m:translations-published/m:translation-status-texts/m:text"/>
                    <xsl:with-param name="active" select="true()"/>
                </xsl:call-template>
                
                <xsl:call-template name="tab-list">
                    <xsl:with-param name="id" select="'translations-translated'"/>
                    <xsl:with-param name="texts" select="m:translations-translated/m:translation-status-texts/m:text"/>
                </xsl:call-template>
                
                <xsl:call-template name="tab-list">
                    <xsl:with-param name="id" select="'translations-in-translation'"/>
                    <xsl:with-param name="texts" select="m:translations-in-translation/m:translation-status-texts/m:text"/>
                </xsl:call-template>
                
            </div>
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="tab-list">
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:param name="texts" required="yes" as="element()*"/>
        <xsl:param name="active" required="no" as="xs:boolean?"/>
        <div role="tabpanel" class="tab-pane fade">
            <xsl:attribute name="id" select="$id"/>
            <xsl:if test="$active">
                <xsl:attribute name="class" select="'tab-pane fade in active'"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$texts">
                    
                    <div class="text-list">
                        <div class="row table-headers">
                            <div class="col-sm-2 hidden-xs">Toh</div>
                            <div class="col-sm-10">Title</div>
                        </div>
                        <div class="list-section">
                            <xsl:for-each select="$texts">
                                <xsl:sort select="number(m:toh/@number)"/>
                                <xsl:sort select="m:toh/@letter"/>
                                <xsl:sort select="number(m:toh/@chapter-number)"/>
                                <xsl:sort select="m:toh/@chapter-letter"/>
                                
                                <div class="row list-item">
                                    <div class="col-sm-2">
                                        
                                        <xsl:value-of select="m:toh/m:full"/>
                                        
                                        <xsl:call-template name="status-label">
                                            <xsl:with-param name="status-group" select="@status-group"/>
                                        </xsl:call-template>
                                        
                                    </div>
                                    <div class="col-sm-8">
                                        
                                        <xsl:call-template name="text-list-title">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:call-template name="text-list-subtitles">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:call-template name="expandable-summary">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                    </div>
                                    <div class="col-sm-2">
                                        
                                        <xsl:value-of select="format-number(m:location/@count-pages/number(), '#,###')"/>
                                        
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                        
                        <div class="row table-footer">
                            <div class="col-sm-10 text-right">
                                <xsl:value-of select="'Total pages:'"/>
                            </div>
                            <div class="col-sm-2">
                                <strong>
                                    <xsl:value-of select="format-number(sum($texts/m:location/@count-pages/number()), '#,###')"/>
                                </strong>
                            </div>
                        </div>
                        
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <p class="text-muted italic">
                        <xsl:value-of select="'There are currently not texts in this list.'"/>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
</xsl:stylesheet>