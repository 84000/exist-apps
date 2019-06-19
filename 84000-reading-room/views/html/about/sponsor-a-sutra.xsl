<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">

            <h3>
                <xsl:call-template name="local-app-text">
                    <xsl:with-param name="local-key" select="'page-heading'"/>
                </xsl:call-template>
            </h3>

            <div class="row">
                <div class="col-sm-8">
                    <xsl:call-template name="local-app-text">
                        <xsl:with-param name="local-key" select="'page-intro'"/>
                    </xsl:call-template>
                </div>
                <div class="col-sm-4">
                    <div class="text-center bottom-margin">
                        <a class="btn btn-primary" href="https://84000.secure.force.com/donate" target="_blank" rel="noopener">
                            <xsl:call-template name="local-app-text">
                                <xsl:with-param name="local-key" select="'donate-label'"/>
                            </xsl:call-template>
                        </a>
                    </div>
                    <div class="well well-sm small">
                        <xsl:call-template name="local-app-text">
                            <xsl:with-param name="local-key" select="'pull-out'"/>
                        </xsl:call-template>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-sm-12">
                    
                    <h3>
                        <xsl:call-template name="local-app-text">
                            <xsl:with-param name="local-key" select="'text-list-title'"/>
                        </xsl:call-template>
                    </h3>

                    <div id="accordion" class="list-group accordion" role="tablist" aria-multiselectable="false">
                        
                        <xsl:variable name="priority-texts" select="m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/m:part[@status eq 'priority']]"/>
                        
                        <xsl:if test="count($priority-texts)">
                            <xsl:call-template name="expand-item">
                                <xsl:with-param name="id" select="'priority'"/>
                                <xsl:with-param name="title">
                                    <xsl:call-template name="local-app-text">
                                        <xsl:with-param name="local-key" select="'priority-title'"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="texts" select="$priority-texts"/>
                                <xsl:with-param name="description">
                                    <div class="top-margin">
                                        <p class="italic">
                                            <xsl:call-template name="local-app-text">
                                                <xsl:with-param name="local-key" select="'priority-description'"/>
                                            </xsl:call-template>
                                        </p>
                                    </div>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        
                        <xsl:variable name="single-part-cost-groups" as="element()*" select="m:cost-groups/m:cost-group[xs:integer(@parts) eq 1]"/>
                        <xsl:for-each select="$single-part-cost-groups">
                            <xsl:variable name="page-upper" as="xs:integer" select="@page-upper"/>
                            <xsl:variable name="group-cost" as="xs:integer" select="$page-upper * xs:integer(/m:response/m:cost-groups/@cost-per-page)"/>
                            <xsl:variable name="previous-page-upper" as="xs:integer" select="xs:integer(concat('0', preceding-sibling::m:cost-group[1]/@page-upper))"/>
                            <xsl:variable name="previous-group-cost" as="xs:integer" select="$previous-page-upper * xs:integer(/m:response/m:cost-groups/@cost-per-page)"/>
                            <xsl:variable name="group-title-app-text" as="xs:string">
                                <xsl:call-template name="local-app-text">
                                    <xsl:with-param name="local-key" select="'text-list-section-title'"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="expand-item">
                                <xsl:with-param name="id" select="concat('cost-group-', position())"/>
                                <xsl:with-param name="title" select="replace(replace($group-title-app-text, '#pageUpper', xs:string($page-upper)), '#groupCost', format-number($group-cost, '#,###'))"/>
                                <xsl:with-param name="texts" select="/m:response/m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/@rounded-cost/xs:integer(.) gt $previous-group-cost][m:sponsorship-status/m:cost/@rounded-cost/xs:integer(.) le $group-cost]"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        
                        
                        <xsl:variable name="remainder-title-app-text" as="xs:string">
                            <xsl:call-template name="local-app-text">
                                <xsl:with-param name="local-key" select="'text-list-remainder-title'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="remainder-page-lower" select="max($single-part-cost-groups/@page-upper)"/>
                        <xsl:variable name="remainder-cost-lower" select="$remainder-page-lower * xs:integer(m:cost-groups/@cost-per-page)"/>
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="concat('group-', count($single-part-cost-groups) + 1)"/>
                            <xsl:with-param name="title" select="replace($remainder-title-app-text, '#pageLower', xs:string($remainder-page-lower))"/>
                            <xsl:with-param name="texts" select="m:sponsorship-texts/m:text[m:sponsorship-status/m:cost/@rounded-cost/xs:integer(.) gt $remainder-cost-lower]"/>
                            <xsl:with-param name="description">
                                <div class="top-margin">
                                    <div class="center-vertical">
                                        <span>
                                            <img>
                                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/blue_person.png')"/>
                                            </img>
                                        </span>
                                        <span>
                                            <xsl:call-template name="local-app-text">
                                                <xsl:with-param name="local-key" select="'blue-person-label'"/>
                                            </xsl:call-template>
                                        </span>
                                        <span>
                                            <img>
                                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/orange_person.png')"/>
                                            </img>
                                        </span>
                                        <span>
                                            <xsl:call-template name="local-app-text">
                                                <xsl:with-param name="local-key" select="'orange-person-label'"/>
                                            </xsl:call-template>
                                        </span>
                                    </div>
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                    </div>
                    
                    <xsl:call-template name="local-app-text">
                        <xsl:with-param name="local-key" select="'footer'"/>
                    </xsl:call-template>
                    
                </div>
            </div>
        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>

    </xsl:template>
    
    <xsl:template name="expand-item">
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:param name="title" required="yes" as="xs:string"/>
        <xsl:param name="description" required="no" as="node()*"/>
        <xsl:param name="texts" required="yes" as="element()*"/>
        <div class="list-group-item">
            
            <div role="tab">
                <xsl:attribute name="id" select="concat($id, '-heading')"/>
                <a class="center-vertical full-width collapsed" role="button" data-toggle="collapse" data-parent="#accordion" aria-expanded="false">
                    <xsl:attribute name="href" select="concat('#', $id, '-detail')"/>
                    <xsl:attribute name="aria-controls" select="concat($id, '-detail')"/>
                    <span>
                        <span class="h3 list-group-item-heading">
                            <xsl:value-of select="concat($title, ' ')"/>
                            <span class="badge badge-notification">
                                <xsl:value-of select="count($texts)"/>
                            </span>
                        </span>
                    </span>
                    <span class="text-right">
                        <i class="fa fa-plus collapsed-show"/>
                        <i class="fa fa-minus collapsed-hide"/>
                    </span>
                </a>
            </div>
            
            <div class="panel-collapse collapse" role="tabpanel" aria-expanded="false">
                <xsl:attribute name="id" select="concat($id, '-detail')"/>
                <xsl:attribute name="aria-labelledby" select="concat($id, '-heading')"/>
                <div class="panel-body no-padding">
                    <xsl:copy-of select="$description"/>
                    <xsl:choose>
                        <xsl:when test="count($texts)">
                            <div class="text-list">
                                <div class="row table-headers">
                                    <div class="col-sm-2 hidden-xs">Toh</div>
                                    <div class="col-sm-10">Title</div>
                                </div>
                                <div class="list-section">
                                    <xsl:for-each-group select="$texts" group-by="m:sponsorship-status/@project-id">
                                    
                                        <div class="row list-item">
                                            <div class="col-sm-2 nowrap">
                                                
                                                <xsl:for-each select="current-group()">
                                                    <xsl:if test="position() ne 1">
                                                        <br/>+
                                                    </xsl:if>
                                                    <xsl:value-of select="m:toh/m:full"/>
                                                </xsl:for-each>
                                                
                                                <xsl:call-template name="status-label">
                                                    <xsl:with-param name="status-group" select="@status-group"/>
                                                </xsl:call-template>
                                                
                                            </div>
                                            <div class="col-sm-8">
                                                
                                                <xsl:for-each select="current-group()">
                                                    <xsl:if test="position() ne 1">
                                                        <hr/>
                                                    </xsl:if>
                                                    
                                                    <xsl:call-template name="text-list-title">
                                                        <xsl:with-param name="text" select="."/>
                                                    </xsl:call-template>
                                                    
                                                    <xsl:call-template name="text-list-subtitles">
                                                        <xsl:with-param name="text" select="."/>
                                                    </xsl:call-template>
                                                    
                                                    <xsl:call-template name="expandable-summary">
                                                        <xsl:with-param name="text" select="."/>
                                                    </xsl:call-template>
                                                    
                                                </xsl:for-each>
                                                
                                                <xsl:if test="m:sponsorship-status/m:status[@id eq 'reserved']">
                                                    <hr/>
                                                    <p class="text-danger">
                                                        <xsl:call-template name="local-app-text">
                                                            <xsl:with-param name="local-key" select="'reserved-label'"/>
                                                        </xsl:call-template>
                                                    </p>
                                                </xsl:if>
                                                
                                                <xsl:if test="count(m:sponsorship-status/m:cost/m:part) gt 1">
                                                    <hr/>
                                                    <div class="row">
                                                        <div class="col-sm-6">
                                                            <div>
                                                                <xsl:call-template name="local-app-text">
                                                                    <xsl:with-param name="local-key" select="'sponsor-part-label'"/>
                                                                </xsl:call-template>
                                                            </div>
                                                            <div class="center-vertical together">
                                                                <xsl:for-each-group select="m:sponsorship-status/m:cost/m:part" group-by="@amount">
                                                                    <xsl:for-each select="current-group()">
                                                                        <span>
                                                                            <xsl:choose>
                                                                                <xsl:when test="@status eq 'sponsored'">
                                                                                    <img>
                                                                                        <xsl:attribute name="src" select="concat($front-end-path, '/imgs/orange_person.png')"/>
                                                                                    </img>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <img>
                                                                                        <xsl:attribute name="src" select="concat($front-end-path, '/imgs/blue_person.png')"/>
                                                                                    </img>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </span>
                                                                    </xsl:for-each>
                                                                    <span>
                                                                        <xsl:value-of select="concat(count(current-group()), ' x ', 'US$',format-number(@amount, '#,###'))"/>
                                                                    </span>
                                                                </xsl:for-each-group>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- If none of the parts are taken offer the whole -->
                                                        <xsl:if test="not(m:sponsorship-status/m:cost/m:part[@status eq 'sponsored'])">
                                                            <div class="col-sm-6">
                                                                <div>
                                                                    <xsl:call-template name="local-app-text">
                                                                        <xsl:with-param name="local-key" select="'sponsor-whole-label'"/>
                                                                    </xsl:call-template>
                                                                </div>
                                                                <div class="center-vertical together">
                                                                    <span>
                                                                        <img>
                                                                            <xsl:attribute name="src" select="concat($front-end-path, '/imgs/blue_person.png')"/>
                                                                        </img>
                                                                    </span>
                                                                    <span>
                                                                        <xsl:value-of select="concat('US$',format-number(m:sponsorship-status/m:cost/@rounded-cost, '#,###'))"/>
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                    </div>
                                                </xsl:if>
                                                
                                            </div>
                                            <div class="col-sm-2">
                                                <xsl:value-of select="format-number(sum(m:sponsorship-status/m:cost/@pages), '#,###')"/> pages
                                            </div>
                                        </div>
                                        
                                    </xsl:for-each-group>
                                </div>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <hr class="sml-margin"/>
                            <p class="text-muted">
                                <xsl:call-template name="local-app-text">
                                    <xsl:with-param name="local-key" select="'no-texts-of-type'"/>
                                </xsl:call-template>
                            </p>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </div>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>