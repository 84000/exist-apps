<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">

            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'page-heading'"/>
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'page-intro'"/>
            </xsl:call-template>
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'text-list-title'"/>
                </xsl:call-template>
            </h3>

            <div id="accordion" class="list-group accordion" role="tablist" aria-multiselectable="false">
                
                <xsl:variable name="priority-texts" select="m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/m:part[@status eq 'priority']]"/>
                
                <hr class="no-margin"/>
                
                <xsl:if test="count($priority-texts)">
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'priority'"/>
                        <xsl:with-param name="title">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'priority-title'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="show-count" select="count($priority-texts)"/>
                        <xsl:with-param name="content">
                            <div class="top-margin">
                                <p class="italic">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'priority-description'"/>
                                    </xsl:call-template>
                                </p>
                            </div>
                            <xsl:call-template name="text-list">
                                <xsl:with-param name="texts" select="$priority-texts"/>
                                <xsl:with-param name="grouping" select="'sponsorship'"/>
                                <xsl:with-param name="show-sponsorship" select="true()"/>
                            </xsl:call-template>
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
                        <xsl:with-param name="title" select="replace(replace($group-title-app-text, '#pageUpper', xs:string($page-upper)), '#groupCost', format-number($group-cost, '#,###'))"/>
                        <xsl:with-param name="show-count" select="count($single-part-cost-group-texts)"/>
                        <xsl:with-param name="content">
                            <xsl:call-template name="text-list">
                                <xsl:with-param name="texts" select="$single-part-cost-group-texts"/>
                                <xsl:with-param name="grouping" select="'sponsorship'"/>
                                <xsl:with-param name="show-sponsorship" select="true()"/>
                            </xsl:call-template>
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
                    <xsl:with-param name="title" select="replace($remainder-title-app-text, '#pageLower', xs:string($remainder-page-lower))"/>
                    <xsl:with-param name="show-count" select="count($remainder-texts)"/>
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
                        
                        <xsl:call-template name="text-list">
                            <xsl:with-param name="texts" select="$remainder-texts"/>
                            <xsl:with-param name="grouping" select="'sponsorship'"/>
                            <xsl:with-param name="show-sponsorship" select="true()"/>
                        </xsl:call-template>
                        
                    </xsl:with-param>
                </xsl:call-template>
            </div>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'footer'"/>
            </xsl:call-template>
                    
        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
            <xsl:with-param name="page-class" select="'how-you-can-help'"/>
        </xsl:call-template>

    </xsl:template>
    
    

</xsl:stylesheet>