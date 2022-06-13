<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">

    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:call-template name="about">
            
            <xsl:with-param name="sub-content">
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'page-intro'"/>
                </xsl:call-template>
                
                <h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'text-list-title'"/>
                    </xsl:call-template>
                </h2>
                
                <div id="accordion" class="list-group accordion" role="tablist" aria-multiselectable="false">
                    
                    <xsl:variable name="priority-texts" select="m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/m:part[@status eq 'priority']]"/>
                    
                    <hr class="no-margin"/>
                    
                    <xsl:if test="count($priority-texts)">
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="'priority'"/>
                            <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                            <xsl:with-param name="title-opener" select="true()"/>
                            <xsl:with-param name="persist" select="true()"/>
                            <xsl:with-param name="title">
                                <div class="center-vertical align-left">
                                    <div>
                                        <h3 class="list-group-item-heading">
                                            <xsl:call-template name="local-text">
                                                <xsl:with-param name="local-key" select="'priority-title'"/>
                                            </xsl:call-template>
                                        </h3>
                                    </div>
                                    <div>
                                        <span class="badge badge-notification">
                                            <xsl:value-of select="count($priority-texts)"/>
                                        </span>
                                    </div>
                                </div>
                            </xsl:with-param>
                            <xsl:with-param name="content">
                                <div class="top-margin">
                                    <p class="italic">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'priority-description'"/>
                                        </xsl:call-template>
                                    </p>
                                </div>
                                <div class="top-margin">
                                    <xsl:call-template name="text-list">
                                        <xsl:with-param name="texts" select="$priority-texts"/>
                                        <xsl:with-param name="list-id" select="'priority'"/>
                                        <xsl:with-param name="grouping" select="'sponsorship'"/>
                                        <xsl:with-param name="show-sponsorship" select="true()"/>
                                        <xsl:with-param name="show-sponsorship-cost" select="true()"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    
                    <xsl:variable name="single-part-cost-groups" as="element()*" select="m:cost-groups/m:cost-group[xs:integer(@parts) eq 1]"/>
                    <xsl:for-each select="$single-part-cost-groups">
                        
                        <xsl:variable name="page-upper" as="xs:integer" select="@page-upper"/>
                        <xsl:variable name="group-cost" as="xs:integer" select="$page-upper * xs:integer(/m:response/m:cost-groups/@cost-per-page)"/>
                        <xsl:variable name="previous-page-upper" as="xs:integer" select="common:integer(preceding-sibling::m:cost-group[1]/@page-upper)"/>
                        <xsl:variable name="previous-group-cost" as="xs:integer" select="$previous-page-upper * xs:integer(/m:response/m:cost-groups/@cost-per-page)"/>
                        <xsl:variable name="group-title-app-text" as="xs:string">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'text-list-section-title'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="single-part-cost-group-texts" select="/m:response/m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/@rounded-cost/xs:integer(.) gt $previous-group-cost][m:sponsorship-status/m:cost/@rounded-cost/xs:integer(.) le $group-cost]"/>
                        
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="concat('cost-group-', position())"/>
                            <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                            <xsl:with-param name="title-opener" select="true()"/>
                            <xsl:with-param name="persist" select="true()"/>
                            <xsl:with-param name="title">
                                <div class="center-vertical align-left">
                                    <div>
                                        <h3 class="list-group-item-heading">
                                            <xsl:value-of select="replace(replace($group-title-app-text, '#pageUpper', xs:string($page-upper)), '#groupCost', format-number($group-cost, '#,###'))"/>
                                        </h3>
                                    </div>
                                    <div>
                                        <span class="badge badge-notification">
                                            <xsl:value-of select="count($single-part-cost-group-texts)"/>
                                        </span>
                                    </div>
                                </div>
                            </xsl:with-param>
                            <xsl:with-param name="content">
                                <div class="top-margin">
                                    <xsl:call-template name="text-list">
                                        <xsl:with-param name="texts" select="$single-part-cost-group-texts"/>
                                        <xsl:with-param name="list-id" select="concat('cost-group-', position())"/>
                                        <xsl:with-param name="grouping" select="'sponsorship'"/>
                                        <xsl:with-param name="show-sponsorship" select="true()"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                    </xsl:for-each>
                    
                    <xsl:variable name="remainder-title-app-text" as="xs:string">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'text-list-remainder-title'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="remainder-page-lower" select="max($single-part-cost-groups/@page-upper)"/>
                    <xsl:variable name="remainder-cost-lower" select="$remainder-page-lower * xs:integer(m:cost-groups/@cost-per-page)"/>
                    <xsl:variable name="remainder-texts" select="m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/@rounded-cost/xs:integer(.) gt $remainder-cost-lower]"/>
                    
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="concat('group-', count($single-part-cost-groups) + 1)"/>
                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                        <xsl:with-param name="title-opener" select="true()"/>
                        <xsl:with-param name="persist" select="true()"/>
                        <xsl:with-param name="title">
                            <div class="center-vertical align-left">
                                <div>
                                    <h3 class="list-group-item-heading">
                                        <xsl:value-of select="replace($remainder-title-app-text, '#pageLower', xs:string($remainder-page-lower))"/>
                                    </h3>
                                </div>
                                <div>
                                    <span class="badge badge-notification">
                                        <xsl:value-of select="count($remainder-texts)"/>
                                    </span>
                                </div>
                            </div>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            
                            <div class="row top-margin">
                                <div class="col-sm-12">
                                    <div class="center-vertical">
                                        <span>
                                            <span class="btn-round sml gray">
                                                <i class="fa fa-male"/>
                                            </span>
                                        </span>
                                        <span>
                                            <xsl:call-template name="local-text">
                                                <xsl:with-param name="local-key" select="'part-icon-label-sponsored'"/>
                                            </xsl:call-template>
                                        </span>
                                        <span>
                                            <span class="btn-round sml orange">
                                                <i class="fa fa-male"/>
                                            </span>
                                        </span>
                                        <span>
                                            <xsl:call-template name="local-text">
                                                <xsl:with-param name="local-key" select="'part-icon-label-available'"/>
                                            </xsl:call-template>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="top-margin">
                                <xsl:call-template name="text-list">
                                    <xsl:with-param name="texts" select="$remainder-texts"/>
                                    <xsl:with-param name="grouping" select="'sponsorship'"/>
                                    <xsl:with-param name="list-id" select="concat('group-', count($single-part-cost-groups) + 1)"/>
                                    <xsl:with-param name="show-sponsorship" select="true()"/>
                                    <xsl:with-param name="show-sponsorship-cost" select="true()"/>
                                </xsl:call-template>
                            </div>
                            
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'footer'"/>
                </xsl:call-template>
                
                <xsl:variable name="donate-footer">
                    <m:donate-footer>
                        <xsl:copy-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item | $eft-header/m:translation"/>
                    </m:donate-footer>
                </xsl:variable>
                
                <div id="donation-footer">
                    <xsl:apply-templates select="$donate-footer"/>
                </div>
                
            </xsl:with-param>
            
            <xsl:with-param name="side-content">
                
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

            <xsl:with-param name="page-class" select="'how-you-can-help'"/>

        </xsl:call-template>

    </xsl:template>
    
</xsl:stylesheet>