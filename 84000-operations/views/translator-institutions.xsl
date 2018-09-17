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
                                            Listing 
                                            <xsl:value-of select="fn:format-number(xs:integer(count(m:translator-institutions/m:institution)),'#,##0')"/> institutions 
                                        </span>
                                        
                                        <form method="post" action="/translator-institutions.html" class="form-inline filter-form pull-right">
                                            
                                            <a class="btn btn-primary btn-sml">
                                                <xsl:attribute name="href" select="'/edit-translator-institution.html'"/>
                                                Add an institution
                                            </a>
                                            
                                        </form>
                                        
                                    </div>
                                    
                                    <xsl:for-each select="m:translator-institutions/m:institution">
                                        <xsl:sort select="@start-letter"/>
                                        <xsl:variable name="region-id" select="@region-id"/>
                                        <xsl:variable name="institution-type-id" select="@institution-type-id"/>
                                        <div class="item">
                                            
                                            <xsl:copy-of select="common:marker(@start-letter, if(preceding-sibling::m:institution[1]/@start-letter) then preceding-sibling::m:institution[1]/@start-letter else '')"/>
                                            
                                            <div class="row">
                                                <div class="col-sm-6">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', @xml:id)"/>
                                                        <xsl:value-of select="m:sort-name"/>
                                                    </a>
                                                </div>
                                                
                                                <div class="col-sm-3">
                                                    <xsl:value-of select="/m:response/m:translator-regions/m:region[@id eq $region-id]"/>
                                                </div>
                                                
                                                <div class="col-sm-3">
                                                    <xsl:value-of select="/m:response/m:translator-institution-types/m:institution-type[@id eq $institution-type-id]"/>
                                                </div>
                                            </div>
                                            
                                            
                                        </div>
                                    </xsl:for-each>
                                    
                                </div>
                                
                                <div id="letters-nav" class="col-nav">
                                    <xsl:copy-of select="common:marker-nav(m:translator-institutions/m:institution)"/>
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
            <xsl:with-param name="page-title" select="'Translator Institutions :: 84000 Operations'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>