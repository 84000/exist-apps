<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    <div class="row">
                        <div class="col-sm-9">
                            
                            <h4>Kangyur Translation Status</h4>
                            
                            <xsl:call-template name="outline-summary-table">
                                <xsl:with-param name="outline-summary" select="m:outline-summary[@work eq 'UT4CZ5369']"/>
                                <xsl:with-param name="text-statuses" select="m:text-statuses"/>
                            </xsl:call-template>
                            
                        </div>
                        <div class="col-sm-3">
                            
                            <xsl:call-template name="outline-summary-graph">
                                <xsl:with-param name="outline-summary" select="m:outline-summary[@work eq 'UT4CZ5369']"/>
                            </xsl:call-template>
                            
                        </div>
                    </div>
                    
                    <hr/>
                    
                    <div class="row">
                        <div class="col-sm-9">
                            
                            <h4>Tengyur Translation Status</h4>
                            
                            <xsl:call-template name="outline-summary-table">
                                <xsl:with-param name="outline-summary" select="m:outline-summary[@work eq 'UT23703']"/>
                                <xsl:with-param name="text-statuses" select="m:text-statuses"/>
                            </xsl:call-template>
                            
                        </div>
                        <div class="col-sm-3">
                            
                            <xsl:call-template name="outline-summary-graph">
                                <xsl:with-param name="outline-summary" select="m:outline-summary[@work eq 'UT23703']"/>
                            </xsl:call-template>
                            
                        </div>
                    </div>
                    
                    <hr/>
                    
                    <h4>Preview data on the public site</h4>
                    <ul>
                        <li>
                            Impact <a href="{ $reading-room-path }/about/impact.html" target="impact">en</a> | <a href="{ $reading-room-path }/about/impact.html?lang=zh" target="impact">zh</a>
                        </li>
                        <li>
                            Progress <a href="{ $reading-room-path }/about/progress.html" target="translations">en</a> | <a href="{ $reading-room-path }/about/progress.html?lang=zh" target="translations">zh</a>
                        </li>
                        <li>
                            Sponsor a Sutra <a href="{ $reading-room-path }/about/sponsor-a-sutra.html" target="sponsor-a-sutra">en</a> | <a href="{ $reading-room-path }/about/sponsor-a-sutra.html?lang=zh" target="sponsor-a-sutra">zh</a>
                        </li>
                        <li>
                            Sponsors <a href="{ $reading-room-path }/about/sponsors.html" target="sponsors">en</a> | <a href="{ $reading-room-path }/about/sponsors.html?lang=zh" target="sponsors">zh</a>
                        </li>
                        <li>
                            Translators <a href="{ $reading-room-path }/about/translators.html" target="translators">en</a> | <a href="{ $reading-room-path }/about/translators.html?lang=zh" target="translators">zh</a>
                        </li>
                    </ul>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
         
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Summary | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Project progress report for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="outline-summary-table">
        <xsl:param name="outline-summary" as="element(m:outline-summary)"/>
        <xsl:param name="text-statuses" as="element(m:text-statuses)"/>
        <table class="table progress">
            <tbody>
                
                <xsl:variable name="total-pages" select="$outline-summary/m:texts/m:pages/@count"/>
                <tr class="total">
                    <td>
                        <a>
                            <xsl:attribute name="href" select="concat('search.html?status=none&amp;work=', $outline-summary/@work)"/>
                            <xsl:value-of select="'Total'"/>
                        </a>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:texts/@count, '#,###')"/> 
                        <span class="small text-muted"> texts</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($total-pages, '#,###')"/>
                        <span class="small text-muted"> pages</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/@count, '#,###')"/>
                        <span class="small text-muted"> tohs*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/m:pages/@count, '#,###')"/>
                        <span class="small text-muted"> toh pages*</span>
                    </td>
                    <td> - </td>
                </tr>
                
                <xsl:variable name="published-pages" select="$outline-summary/m:texts/m:pages/@published"/>
                <tr class="published">
                    <td>
                        <a>
                            <xsl:attribute name="href" select="concat('search.html?status=', string-join($text-statuses/m:status[@group eq 'published']/@status-id, ','), '&amp;work=', $outline-summary/@work)"/>
                            <xsl:value-of select="'Published '"/> 
                            <small>(<xsl:value-of select="string-join($text-statuses/m:status[@group eq 'published']/@status-id, ', ')"/>)</small>
                        </a>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:texts/@published, '#,###')"/>
                        <span class="small text-muted"> texts</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($published-pages, '#,###')"/>
                        <span class="small text-muted"> pages</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/@published, '#,###')"/>
                        <span class="small text-muted"> tohs*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/m:pages/@published, '#,###')"/>
                        <span class="small text-muted"> toh pages*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number(($published-pages div $total-pages) * 100, '###,##0')"/>%
                    </td>
                </tr>
                
                <xsl:variable name="translated-pages" select="$outline-summary/m:texts/m:pages/@translated"/>
                <tr class="translated">
                    <td>
                        <a>
                            <xsl:attribute name="href" select="concat('search.html?status=', string-join($text-statuses/m:status[@group eq 'translated']/@status-id, ','), '&amp;work=', $outline-summary/@work)"/>
                            <xsl:value-of select="'Translated '"/> 
                            <small>(<xsl:value-of select="string-join($text-statuses/m:status[@group eq 'translated']/@status-id, ', ')"/>)</small>
                        </a>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:texts/@translated, '#,###')"/>
                        <span class="small text-muted"> texts</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($translated-pages, '#,###')"/>
                        <span class="small text-muted"> pages</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/@translated, '#,###')"/>
                        <span class="small text-muted"> tohs*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/m:pages/@translated, '#,###')"/>
                        <span class="small text-muted"> toh pages*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number(($translated-pages div $total-pages) * 100, '###,##0')"/>%
                    </td>
                </tr>
                <xsl:variable name="in-translation-pages" select="$outline-summary/m:texts/m:pages/@in-translation"/>
                <tr class="in-translation">
                    <td>
                        <a>
                            <xsl:attribute name="href" select="concat('search.html?status=', string-join($text-statuses/m:status[@group eq 'in-translation']/@status-id, ','), '&amp;work=', $outline-summary/@work)"/>
                            <xsl:value-of select="'In Translation '"/>  
                            <small>(<xsl:value-of select="string-join($text-statuses/m:status[@group eq 'in-translation']/@status-id, ', ')"/>)</small>
                        </a>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:texts/@in-translation, '#,###')"/>
                        <span class="small text-muted"> texts</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($in-translation-pages, '#,###')"/>
                        <span class="small text-muted"> pages</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/@in-translation, '#,###')"/>
                        <span class="small text-muted"> tohs*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/m:pages/@in-translation, '#,###')"/>
                        <span class="small text-muted"> toh pages*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number(($in-translation-pages div $total-pages) * 100, '###,##0')"/>%
                    </td>
                </tr>
                <xsl:variable name="not-started-pages" select="$outline-summary/m:texts/m:pages/@not-started"/>
                <tr class="not-started">
                    <td>
                        <a>
                            <xsl:attribute name="href" select="concat('search.html?status=0&amp;work=', $outline-summary/@work)"/>
                            <xsl:value-of select="'Not Started'"/>
                        </a>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:texts/@not-started, '#,###')"/>
                        <span class="small text-muted"> texts</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($not-started-pages, '#,###')"/>
                        <span class="small text-muted"> pages</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/@not-started, '#,###')"/>
                        <span class="small text-muted"> tohs*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/m:pages/@not-started, '#,###')"/>
                        <span class="small text-muted"> toh pages*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number(($not-started-pages div $total-pages) * 100, '###,##0')"/>%
                    </td>
                </tr>
                <xsl:variable name="sponsored-pages" select="$outline-summary/m:texts/m:pages/@sponsored"/>
                <tr class="sponsored">
                    <td>
                        <a>
                            <xsl:attribute name="href" select="concat('search.html?sponsored=sponsored&amp;work=', $outline-summary/@work)"/>
                            <xsl:value-of select="'Sponsored'"/>
                        </a>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:texts/@sponsored, '#,###')"/>
                        <span class="small text-muted"> texts</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($sponsored-pages, '#,###')"/>
                        <span class="small text-muted"> pages</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/@sponsored, '#,###')"/>
                        <span class="small text-muted"> tohs*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number($outline-summary/m:tohs/m:pages/@sponsored, '#,###')"/>
                        <span class="small text-muted"> toh pages*</span>
                    </td>
                    <td>
                        <xsl:value-of select="format-number(($sponsored-pages div $total-pages) * 100, '###,##0')"/>%
                    </td>
                </tr>
            </tbody>
        </table>
        
        <div class="small text-muted">
            *Tohs can refer to duplicate texts in the Kangyur, hence the higher number when counted by Toh.
        </div>
        
    </xsl:template>
    
    <xsl:template name="outline-summary-graph">
        <xsl:param name="outline-summary" as="element(m:outline-summary)"/>
        <xsl:variable name="chart-id" select="concat('chart-', $outline-summary/@work)"/>
        
        <div style="width:260px;height:260px;margin:0 auto;">
            <canvas>
                <xsl:attribute name="id" select="$chart-id"/>
            </canvas>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.6.0/Chart.min.js"/>
            <script>
                var ctx = document.getElementById('<xsl:value-of select="$chart-id"/>').getContext('2d');
                var data = {
                datasets: [{
                data: [
                <xsl:value-of select="$outline-summary/m:texts/m:pages/@published"/>, 
                <xsl:value-of select="$outline-summary/m:texts/m:pages/@translated"/>, 
                <xsl:value-of select="$outline-summary/m:texts/m:pages/@in-translation"/>, 
                <xsl:value-of select="$outline-summary/m:texts/m:pages/@not-started"/>
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
                var myPieChart = new Chart(ctx,{
                type: 'pie',
                data: data,
                options: options
                });
            </script>
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>