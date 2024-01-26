<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    
                    <!-- Section summaries -->
                    <xsl:for-each select="m:translation-summary[@section-id eq 'LOBBY']/m:translation-summary">
                        <div class="row">
                            <div class="col-sm-9">
                                
                                <h4>Translation Status - <xsl:value-of select="m:title"/>
                                </h4>
                                
                                <xsl:call-template name="translation-summary-table">
                                    <xsl:with-param name="translation-summary" select="."/>
                                </xsl:call-template>
                                
                            </div>
                            <div class="col-sm-3">
                                
                                <xsl:call-template name="translation-summary-graph">
                                    <xsl:with-param name="translation-summary" select="."/>
                                </xsl:call-template>
                                
                            </div>
                        </div>
                        <hr/>
                    </xsl:for-each>
                    
                    <!-- Links -->
                    <h4>Preview data on the public site</h4>
                    <div class="row">
                        <div class="col-sm-3">
                            <h5>Pages:</h5>
                            <ul class="list-unstyled">
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
                        </div>
                        <div class="col-sm-9">
                            <h5>Widgets:</h5>
                            <ul class="list-unstyled">
                                <li>
                                    Progress panel <a href="{ $reading-room-path }/widget/progress-panel.html" target="progress-panel">en</a> | <a href="{ $reading-room-path }/widget/progress-panel.html?lang=zh" target="progress-panel">zh</a>
                                </li>
                                <li>
                                    Progress chart <a href="{ $reading-room-path }/widget/progress-chart.html" target="progress-chart">en</a> | <a href="{ $reading-room-path }/widget/progress-chart.html?lang=zh" target="progress-chart">zh</a>
                                </li>
                                <li>
                                    Progress chart single <a href="{ $reading-room-path }/widget/progress-chart-single.html?work=UT4CZ5369" target="progress-chart-single">Kangyur en</a> | <a href="{ $reading-room-path }/widget/progress-chart-single.html?work=UT4CZ5369&amp;lang=zh" target="progress-chart-single">Kangyur zh</a> | <a href="{ $reading-room-path }/widget/progress-chart-single.html?work=UT23703" target="progress-chart-single">Tengyur en</a> | <a href="{ $reading-room-path }/widget/progress-chart-single.html?work=UT23703&amp;lang=zh" target="progress-chart-single">Tengyur zh</a>
                                </li>
                                <li>
                                    Download dāna <a href="{ $reading-room-path }/widget/download-dana.html?resource-id=UT22084-001-001" target="download-dana">en</a> | <a href="{ $reading-room-path }/widget/download-dana.html?resource-id=UT22084-001-001&amp;lang=zh" target="download-dana">zh</a>
                                </li>
                                <li>
                                    Section checkbox <a href="{ $reading-room-path }/widget/section-checkbox.html" target="section-checkbox">en</a> | <a href="{ $reading-room-path }/widget/section-checkbox.html?lang=zh" target="section-checkbox">zh</a>
                                </li>
                            </ul>
                        </div>
                    </div>
                    
                    <hr/>
                    
                    <!-- Latest activity -->
                    <xsl:variable name="recent-updated-texts" select="m:recent-updates/m:text"/>
                    <xsl:for-each select="('new-publication', 'new-version')">
                        
                        <xsl:variable name="recent-update-type" select="."/>
                        
                        <div class="center-vertical full-width bottom-margin">
                            
                            <div>
                                <h4 class="no-top-margin no-bottom-margin">
                                    
                                    <xsl:choose>
                                        <xsl:when test="$recent-update-type eq 'new-publication'">
                                            <xsl:value-of select="'New Publications'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'New Versions'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                    <xsl:value-of select="' '"/>
                                    <span class="label label-default">
                                        <xsl:value-of select="count($recent-updated-texts[@recent-update eq $recent-update-type])"/>
                                    </span>
                                    
                                </h4>
                            </div>
                            
                            <xsl:if test="position() eq 1">
                                <div>
                                    <a class="btn btn-primary pull-right">
                                        <xsl:attribute name="href" select="'recent-updates.xlsx'"/>
                                        <xsl:attribute name="title" select="'Download as spreadsheet'"/>
                                        <xsl:value-of select="'Download spreadsheet'"/>
                                    </a>
                                </div>
                            </xsl:if>
                            
                        </div>
                        
                        <xsl:choose>
                            <xsl:when test="$recent-updated-texts[@recent-update eq $recent-update-type]">
                                <table class="table no-border width-auto">
                                    <xsl:for-each select="$recent-updated-texts[@recent-update eq $recent-update-type]">
                                        
                                        <xsl:sort select="number(m:toh[1]/@number)"/>
                                        <xsl:sort select="m:toh[1]/@letter"/>
                                        <xsl:sort select="number(m:toh[1]/@chapter-number)"/>
                                        <xsl:sort select="m:toh[1]/@chapter-letter"/>
                                        
                                        <xsl:variable name="toh-key" select="(m:toh/@key)[1]"/>
                                        
                                        <tr class="vertical-top">
                                            <td>
                                                <span>
                                                    <xsl:attribute name="class">
                                                        <xsl:choose>
                                                            <xsl:when test="@status-group eq 'published'">
                                                                <xsl:value-of select="'label label-success'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'label label-warning'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="@status"/>
                                                </span>
                                            </td>
                                            <td>
                                                <h4 class="no-top-margin no-bottom-margin">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $toh-key, '.html')"/>
                                                        <xsl:attribute name="target" select="concat($toh-key, '.html')"/>
                                                        <xsl:attribute name="title" select="concat('Open ', $toh-key, '.html in the Reading Room')"/>
                                                        <xsl:value-of select="'Toh ' || string-join(m:toh/m:base, ' / ') || ' (' || @id || ') '"/>
                                                    </a>
                                                </h4>
                                                <div class="small">
                                                    <xsl:choose>
                                                        <xsl:when test="$recent-update-type eq 'new-publication'">
                                                            <xsl:variable name="published-statuses" select="/m:response/m:text-statuses/m:status[@type eq 'translation'][@group eq 'published']/@status-id" as="xs:string*"/>
                                                            <xsl:for-each select="tei:change[@type = ('translation-status', 'publication-status')][@status = $published-statuses]">
                                                                <xsl:sort select="@when"/>
                                                                <span class="text-muted">
                                                                    <xsl:value-of select="common:date-user-string(concat('Status ', @status, ' set'), @when, @who)"/>
                                                                </span>
                                                            </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:for-each select="tei:change">
                                                                <xsl:sort select="@when"/>
                                                                <span class="text-muted">
                                                                    <xsl:value-of select="common:date-user-string(concat('Version ', @status, ' created'), @when, @who)"/>
                                                                </span>
                                                                <br/>
                                                                <span class="text-danger">
                                                                    <xsl:value-of select="string-join(('Note: ', descendant::text() ! normalize-space()), '')"/>
                                                                </span>
                                                            </xsl:for-each>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <p class="text-muted italic">
                                    <xsl:value-of select="'No matching texts'"/>
                                </p>
                            </xsl:otherwise>
                        </xsl:choose>
                    
                    </xsl:for-each>
                    
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
    
    <xsl:template name="translation-summary-table">
        
        <xsl:param name="translation-summary" as="element(m:translation-summary)"/>
        
        <xsl:variable name="publication-summaries" select="$translation-summary/m:publications-summary[@scope eq 'descendant']"/>
        <xsl:variable name="text-statuses" select="/m:response/m:text-statuses" as="element(m:text-statuses)"/>
        
        <table class="table progress">
            <tbody>
                
                <xsl:for-each select="('total','published','translated','in-translation','not-started','sponsored')">
                    
                    <xsl:variable name="status" select="." as="xs:string"/>
                    
                    <xsl:variable name="text-status" as="element(m:status)*">
                        <xsl:choose>
                            <xsl:when test="$status eq 'not-started'">
                                <xsl:sequence select="$text-statuses/m:status[@group = ('not-started', 'in-application')]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$text-statuses/m:status[@group eq $status]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="label">
                        <xsl:choose>
                            <xsl:when test="$status eq 'total'">
                                <xsl:value-of select="'Total'"/>
                            </xsl:when>
                            <xsl:when test="$status eq 'published'">
                                <xsl:value-of select="'Published'"/>
                            </xsl:when>
                            <xsl:when test="$status eq 'translated'">
                                <xsl:value-of select="'Translated'"/>
                            </xsl:when>
                            <xsl:when test="$status eq 'in-translation'">
                                <xsl:value-of select="'In translation'"/>
                            </xsl:when>
                            <xsl:when test="$status eq 'not-started'">
                                <xsl:value-of select="'Not started'"/>
                            </xsl:when>
                            <xsl:when test="$status eq 'sponsored'">
                                <xsl:value-of select="'Sponsored'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$status"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <tr class="{ $status }">
                        <td>
                            <a>
                                <xsl:attribute name="href" select="concat('search.html?section-id=', $translation-summary/@section-id, if($text-status) then concat('&amp;status=', string-join($text-status/@status-id, ',')) else (), if($status eq 'sponsored') then concat('&amp;filter=', 'sponsored') else ())"/>
                                <xsl:value-of select="$label"/>
                                <xsl:if test="$text-status">
                                    <small> (<xsl:value-of select="string-join($text-status/@status-id, ', ')"/>)</small>
                                </xsl:if>
                            </a>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($publication-summaries[@grouping eq 'text']/m:texts/@*[local-name(.) eq $status], '#,###')"/> 
                            <span class="small text-muted"> texts</span>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($publication-summaries[@grouping eq 'text']/m:pages/@*[local-name(.) eq $status], '#,###')"/>
                            <span class="small text-muted"> pages</span>
                        </td>
                        <td>
                            <xsl:if test="not($status eq 'total')">
                                <span class="text-warning">
                                    <xsl:value-of select="format-number($publication-summaries[@grouping eq 'text']/m:pages/@*[local-name(.) eq $status] ! xs:integer(.) div $publication-summaries[@grouping eq 'text']/m:pages/@total ! xs:integer(.), '0.#%')"/>
                                </span>
                            </xsl:if>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($publication-summaries[@grouping eq 'toh']/m:texts/@*[local-name(.) eq $status], '#,###')"/>
                            <span class="small text-muted"> tohs*</span>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($publication-summaries[@grouping eq 'toh']/m:pages/@*[local-name(.) eq $status], '#,###')"/>
                            <span class="small text-muted"> toh pages*</span>
                        </td>
                        <td>
                            <xsl:if test="not($status eq 'total')">
                                <span class="text-warning">
                                    <xsl:value-of select="format-number($publication-summaries[@grouping eq 'toh']/m:pages/@*[local-name(.) eq $status] ! xs:integer(.) div $publication-summaries[@grouping eq 'toh']/m:pages/@total ! xs:integer(.), '0.#%')"/>
                                </span>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
                
            </tbody>
        </table>
        
        <div class="small text-muted">*Tohs can refer to duplicate texts in the Kangyur, hence the higher number when counted by Toh.</div>
        
    </xsl:template>
    
    <xsl:template name="translation-summary-graph">
        <xsl:param name="translation-summary" as="element(m:translation-summary)"/>
        <xsl:variable name="chart-id" select="concat('chart-', $translation-summary/@section-id)"/>
        
        <div style="width:260px;height:260px;margin:0 auto;">
            <canvas>
                <xsl:attribute name="id" select="$chart-id"/>
            </canvas>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.6.0/Chart.min.js"/>
            <script>
                
                <xsl:variable name="chart-script">
                    var ctx = document.getElementById('<xsl:value-of select="$chart-id"/>').getContext('2d');
                    var data = {
                        datasets: [{
                            data: [<xsl:value-of select="string-join($translation-summary/m:publications-summary[@scope eq 'descendant'][@grouping eq 'text']/m:pages/@*[local-name(.) = ('published','translated','in-translation','not-started')], ',')"/>],
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
                </xsl:variable>
                
                <xsl:value-of select="normalize-space($chart-script)"/>
                
            </script>
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>