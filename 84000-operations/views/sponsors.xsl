<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <div class="well well-sm center-vertical full-width bottom-margin">
                        
                        <span class="small">
                            <xsl:value-of select="concat('Listing ', fn:format-number(xs:integer(count(m:sponsors/m:sponsor)),'#,##0'), ' sponsors')"/>
                        </span>
                        
                        <div>
                            <form method="post" action="/sponsors.html" class="form-inline filter-form pull-right">
                                
                                <div class="checkbox hidden"><!-- Hide this for now -->
                                    <label class="small">
                                        <input type="checkbox" name="include-acknowledgements" value="1">
                                            <xsl:if test="m:request/@include-acknowledgements eq 'true'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="'List all acknowledgements'"/>
                                    </label>
                                </div>
                                
                                <a class="btn btn-primary btn-sml">
                                    <xsl:attribute name="href" select="'/edit-sponsor.html'"/>
                                    <xsl:value-of select="'Add a sponsor'"/>
                                </a>
                                
                            </form>
                        </div>
                        
                    </div>
                    
                    <div class="row">
                        <div class="col-items div-list no-border-top">
                            
                            <xsl:for-each-group select="m:sponsors/m:sponsor" group-by="@start-letter">
                                
                                <xsl:sort select="@start-letter"/>
                                
                                <div>
                                    
                                    <a class="marker">
                                        <xsl:attribute name="name" select="@start-letter"/>
                                        <xsl:attribute name="id" select="concat('marker-', @start-letter)"/>
                                        <xsl:value-of select="@start-letter"/>
                                    </a>
                                    
                                    <xsl:for-each select="fn:current-group()">
                                        
                                        <xsl:sort select="m:sort-name"/>
                                        
                                        <xsl:variable name="sponsor-id" select="@xml:id"/>
                                        
                                        <div class="item">
                                            
                                            <div class="row">
                                                <div class="col-sm-9">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-sponsor.html?id=', $sponsor-id)"/>
                                                        <xsl:value-of select="m:label"/>
                                                        <xsl:if test="m:internal-name">
                                                            <xsl:value-of select="concat(' / ', m:internal-name)"/>
                                                        </xsl:if>
                                                    </a>
                                                    <xsl:if test="m:country/text()">
                                                        <span>
                                                            <xsl:value-of select="concat(' / ', m:country)"/>
                                                        </span>
                                                    </xsl:if>
                                                    <span class="small text-muted">
                                                        <xsl:value-of select="concat(' / ', $sponsor-id)"/>
                                                    </span>
                                                </div>
                                                <div class="col-sm-3 text-right">
                                                    <xsl:if test="m:type[@id eq 'matching-funds']">
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="'Matching'"/>
                                                        </span>
                                                    </xsl:if>
                                                    <xsl:if test="m:type[@id eq 'founding']">
                                                        <span class="label label-info">
                                                            <xsl:value-of select="'Founding'"/>
                                                        </span>
                                                    </xsl:if>
                                                    <xsl:if test="m:type[@id eq 'sutra']">
                                                        <span class="label label-warning">
                                                            <xsl:value-of select="'Sutra'"/>
                                                        </span>
                                                    </xsl:if>
                                                </div>
                                            </div>
                                            
                                            <xsl:if test="m:acknowledgement">
                                                <div class="row">
                                                    <xsl:call-template name="acknowledgements">
                                                        <xsl:with-param name="acknowledgements" select="m:acknowledgement"/>
                                                        <xsl:with-param name="group" select="''"/>
                                                        <xsl:with-param name="css-class" select="'col-sm-12'"/>
                                                        <xsl:with-param name="link-href" select="'/edit-text-sponsors.html?id=@translation-id'"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:if>
                                            
                                        </div>
                                        
                                    </xsl:for-each>
                                    
                                </div>
                                
                            </xsl:for-each-group>
                            
                        </div>
                        
                        <div class="col-nav affix-container">
                            <xsl:copy-of select="common:marker-nav(m:sponsors/m:sponsor)"/>
                        </div>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sponsors | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Sponsors configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>