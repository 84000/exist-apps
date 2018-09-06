<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="row">
                <div class="col-sm-8">
                    
                    <h2>84000 Translators</h2>
                    
                    <xsl:for-each select="m:translator-teams/m:team">
                        <xsl:variable name="team-id" select="@xml:id"/>
                        <div>
                            <h3>
                                <xsl:value-of select="m:name"/>
                            </h3>
                            <ul class="list-unstyled">
                                <xsl:for-each select="/m:response/m:translators/m:translator[m:team/@id = $team-id]">
                                    <li>
                                        <xsl:value-of select="m:name"/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </xsl:for-each>
                </div>
                <div class="col-sm-4">
                    <div class="about-stats">
                        
                        <h5>Summary</h5>
                        
                        <div>
                            <xsl:attribute name="class" select="concat('stat ', common:position-to-color(1, 'id'))"/>
                            <div class="heading">Number of Teams</div>
                            <div class="data">
                                <span>
                                    <xsl:value-of select="format-number(count(m:translator-teams/m:team), '#,###')"/>
                                </span> teams
                            </div>
                        </div>
                    
                        <div>
                            <xsl:attribute name="class" select="concat('stat ', common:position-to-color(2, 'id'))"/>
                            <div class="heading">Number of Translators</div>
                            <div class="data">
                                <span>
                                    <xsl:value-of select="format-number(count(m:translators/m:translator), '#,###')"/>
                                </span> translators
                            </div>
                        </div>
                        
                        <hr/>
                        
                        <h5>Translators by affiliation</h5>
                        
                        <xsl:for-each select="m:translator-institution-types/m:institution-type">
                            <div>
                                <xsl:attribute name="class" select="concat('stat ', common:position-to-color((position() + 2), 'id'))"/>
                                <div class="heading">
                                    <xsl:value-of select="m:name"/>
                                </div>
                                <div class="data">
                                    <span>
                                        <xsl:value-of select="m:stat[@type eq 'translator-percentage']/@value"/>%
                                    </span> of translators
                                </div>
                            </div>
                        </xsl:for-each>
                        
                        <xsl:variable name="count-institution-types" select="count(m:translator-institution-types/m:institution-type)"/>
                        <xsl:variable name="institution-types-chart-data">
                            <xsl:for-each select="m:translator-institution-types/m:institution-type">
                                <xsl:value-of select="m:stat[@type eq 'translator-percentage']/@value"/>
                                <xsl:if test="position() lt $count-institution-types">,</xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="institution-types-chart-labels">
                            <xsl:for-each select="m:translator-institution-types/m:institution-type">
                                '<xsl:value-of select="m:name"/>'
                                <xsl:if test="position() lt $count-institution-types">,</xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="institution-types-chart-colours">
                            <xsl:for-each select="m:translator-institution-types/m:institution-type">
                                '<xsl:value-of select="common:position-to-color((position() + 2), 'hex')"/>'
                                <xsl:if test="position() lt $count-institution-types">,</xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <canvas id="affiliation-pie" style="width:100%;height:225px;"/>
                        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js"/>
                        <script>
                            var ctx = document.getElementById("affiliation-pie").getContext('2d');
                            var data = {
                                datasets: [{
                                    data: [<xsl:value-of select="normalize-space($institution-types-chart-data)"/>],
                                    backgroundColor: [<xsl:value-of select="normalize-space($institution-types-chart-colours)"/>]
                                }],
                                labels: [<xsl:value-of select="normalize-space($institution-types-chart-labels)"/>]
                            };
                            var options = { 
                                legend: { display: false, position: 'right' },
                                tooltips: { callbacks: {
                                    label: function(tooltipItem, data) {
                                        var i = tooltipItem.index;
                                        var val = data.datasets[0].data[tooltipItem.index];
                                        return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "% " + data.labels[i];
                                    }}
                                }
                            };
                            var myPieChart = new Chart(ctx,{ type: 'pie', data: data, options: options });
                        </script>
                        
                        <hr/>
                        
                        <h5>Translators by region</h5>
                        
                        <xsl:for-each select="m:translator-regions/m:region">
                            <div>
                                <xsl:attribute name="class" select="concat('stat ', common:position-to-color(position(), 'id'))"/>
                                <div class="heading">
                                    <xsl:value-of select="m:name"/>
                                </div>
                                <div class="data">
                                    <span>
                                        <xsl:value-of select="m:stat[@type eq 'translator-percentage']/@value"/>%
                                    </span> of translators
                                </div>
                            </div>
                        </xsl:for-each>
                        
                        <xsl:variable name="count-regions" select="count(m:translator-regions/m:region)"/>
                        <xsl:variable name="region-chart-data">
                            <xsl:for-each select="m:translator-regions/m:region">
                                <xsl:value-of select="m:stat[@type eq 'translator-percentage']/@value"/>
                                <xsl:if test="position() lt $count-regions">,</xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="region-chart-labels">
                            <xsl:for-each select="m:translator-regions/m:region">
                                '<xsl:value-of select="m:name"/>'
                                <xsl:if test="position() lt $count-regions">,</xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="region-chart-colours">
                            <xsl:for-each select="m:translator-regions/m:region">
                                '<xsl:value-of select="common:position-to-color(position(), 'hex')"/>'
                                <xsl:if test="position() lt $count-regions">,</xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <canvas id="region-pie" style="width:100%;height:225px;"/>
                        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js"/>
                        <script>
                            var ctx = document.getElementById("region-pie").getContext('2d');
                            var data = {
                                datasets: [{
                                    data: [<xsl:value-of select="normalize-space($region-chart-data)"/>],
                                    backgroundColor: [<xsl:value-of select="normalize-space($region-chart-colours)"/>]
                                }],
                                labels: [<xsl:value-of select="normalize-space($region-chart-labels)"/>]
                            };
                            var options = { 
                                legend: { display: false, position: 'right' },
                                tooltips: { callbacks: {
                                    label: function(tooltipItem, data) {
                                        var i = tooltipItem.index;
                                        var val = data.datasets[0].data[tooltipItem.index];
                                        return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "% " + data.labels[i];
                                    }}
                                }
                            };
                            var myPieChart = new Chart(ctx,{ type: 'pie', data: data, options: options });
                        </script>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>