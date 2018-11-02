<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Operations Reports
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            <div class="row">
                                <div class="col-items div-list">
                                    
                                    <div class="item">
                                        <span class="small text-muted">
                                            <xsl:value-of select="fn:format-number(xs:integer(count(m:sponsors/m:sponsor)),'#,##0')"/> sponsors
                                        </span>
                                        
                                        <form method="post" action="/sponsors.html" class="form-inline filter-form pull-right">
                                          
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" name="include-acknowledgements" value="1">
                                                        <xsl:if test="m:request/@include-acknowledgements eq 'true'">
                                                            <xsl:attribute name="checked" select="'checked'"/>
                                                        </xsl:if>
                                                    </input>
                                                    List all acknowledgements
                                                </label>
                                            </div>
                                            
                                            <a class="btn btn-primary btn-sml">
                                                <xsl:attribute name="href" select="'/edit-sponsor.html'"/>
                                                Add a sponsor
                                            </a>
                                            
                                        </form>
                                        
                                    </div>
                                
                                    <xsl:for-each select="m:sponsors/m:sponsor">
                                        <xsl:sort select="@start-letter"/>
                                        <xsl:variable name="sponsor-id" select="@xml:id"/>
                                        
                                        <div class="item">
                                            
                                            <xsl:copy-of select="common:marker(@start-letter, if(preceding-sibling::m:sponsor[1]/@start-letter) then preceding-sibling::m:sponsor[1]/@start-letter else '')"/>
                                            
                                            <div class="row">
                                                <div class="col-sm-8">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-sponsor.html?id=', $sponsor-id)"/>
                                                        <xsl:value-of select="m:name"/>
                                                        <xsl:if test="m:internal-name">
                                                            <xsl:value-of select="concat(' / ', m:internal-name)"/>
                                                        </xsl:if>
                                                    </a>
                                                    <span class="small text-muted">
                                                        <xsl:value-of select="concat(' (', $sponsor-id, ')')"/>
                                                    </span>
                                                </div>
                                                <div class="col-sm-2">
                                                    <xsl:value-of select="m:country"/>
                                                </div>
                                                <div class="col-sm-2 text-right">
                                                    <xsl:choose>
                                                        <xsl:when test="@type eq 'sutra'">
                                                            <span class="label label-danger">
                                                                Sutra sponsor
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="@type eq 'founding'">
                                                            <span class="label label-warning">
                                                                Founding sponsor
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="@type eq 'matching-funds'">
                                                            <span class="label label-success">
                                                                Matching funds sponsor
                                                            </span>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </div>
                                                
                                            </div>
                                            
                                            <xsl:if test="m:acknowledgement">
                                                <div class="row">
                                                    <xsl:call-template name="acknowledgements">
                                                        <xsl:with-param name="acknowledgements" select="m:acknowledgement"/>
                                                        <xsl:with-param name="group" select="$sponsor-id"/>
                                                        <xsl:with-param name="css-class" select="'col-sm-6'"/>
                                                        <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:if>
                                            
                                        </div>
                                    </xsl:for-each>
                                    
                                </div>
                                
                                <div id="letters-nav" class="col-nav">
                                    <xsl:copy-of select="common:marker-nav(m:sponsors/m:sponsor)"/>
                                </div>
                                
                            </div>
                            
                        </div>
                    </div>
                </div>
            </div>
            
            <xsl:call-template name="link-to-top"/>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sponsors :: 84000 Operations'"/>
            <xsl:with-param name="page-description" select="'Sponsors configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>