<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="about">
            
            <xsl:with-param name="sub-content">
                
                <div>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'page-intro'"/>
                    </xsl:call-template>
                </div>
                
                <h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'matching-funds-title'"/>
                    </xsl:call-template>
                </h2>
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'matching-funds-description'"/>
                </xsl:call-template>
                
                <div id="matching-funds" class="list-group accordion" role="tablist" aria-multiselectable="false">
                    
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'matching-funds-sponsors'"/>
                        <xsl:with-param name="accordion-selector" select="'#matching-funds'"/>
                        <xsl:with-param name="title">
                            <h3 class="list-group-item-heading">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'matching-funds-list-title'"/>
                                </xsl:call-template>
                            </h3>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <ul class="top-margin">
                                <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'matching-funds']]">
                                    <li>
                                        <xsl:value-of select="m:label"/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
                
                <h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'sutras-title'"/>
                    </xsl:call-template>
                </h2>
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'sutras-description'"/>
                </xsl:call-template>
                
                <div id="sutra" class="list-group accordion" role="tablist" aria-multiselectable="false">
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'sutra-sponsors'"/>
                        <xsl:with-param name="accordion-selector" select="'#sutra'"/>
                        <xsl:with-param name="title">
                            <h3 class="list-group-item-heading">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'sutras-list-title'"/>
                                </xsl:call-template>
                            </h3>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <div class="top-margin">
                                <xsl:call-template name="text-list">
                                    <xsl:with-param name="texts" select="m:sponsored-texts/m:text"/>
                                    <xsl:with-param name="list-id" select="'single-part-cost-group'"/>
                                    <xsl:with-param name="grouping" select="'text'"/>
                                    <xsl:with-param name="show-sponsors" select="true()"/>
                                </xsl:call-template>
                            </div>
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
                
                <h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'founding-title'"/>
                    </xsl:call-template>
                </h2>
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'founding-description'"/>
                </xsl:call-template>
                
                <div id="founding" class="list-group accordion" role="tablist" aria-multiselectable="false">
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'founding-sponsors'"/>
                        <xsl:with-param name="accordion-selector" select="'#founding'"/>
                        <xsl:with-param name="title">
                            <h3 class="list-group-item-heading">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'founding-list-title'"/>
                                </xsl:call-template>
                            </h3>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <table class="table no-border top-margin">
                                <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'founding']]">
                                    <xsl:sort select="xs:integer(fn:substring-after(@xml:id, 'sponsor-'))"/>
                                    <tr class="vertical-middle">
                                        <td class="nowrap">
                                            <xsl:value-of select="concat(position(), '.')"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="m:label"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </table>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </div>
            </xsl:with-param>
            
            <xsl:with-param name="side-content">
                
                <xsl:variable name="nav-sidebar">
                    <m:nav-sidebar>
                        <xsl:copy-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item/m:item[m:item[@url eq $active-url]]"/>
                    </m:nav-sidebar>
                </xsl:variable>
                
                <aside class="nav-sidebar">
                    <xsl:apply-templates select="$nav-sidebar"/>
                </aside>
                
                <aside>
                    <!-- Project Progress, get from ajax -->
                    <div id="project-progress">
                        <xsl:attribute name="data-onload-replace">
                            <xsl:choose>
                                <xsl:when test="$lang eq 'zh'">
                                    <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-chart.html#eft-progress-chart-panel&#34;}')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-chart.html?lang=', $lang ,'#eft-progress-chart-panel&#34;}')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>                            
                        <div class="panel panel-default">
                            <div class="panel-body loading"/>
                        </div>
                    </div>
                </aside>
                
            </xsl:with-param>
            
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>