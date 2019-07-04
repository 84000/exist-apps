<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/functions.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <xsl:call-template name="header"/>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="row">
                            <div class="col-sm-4">
                                <form method="post" role="search" class="form-inline">
                                    <xsl:attribute name="action" select="'/glossary-management.html'"/>
                                    <input type="hidden" name="tab" value="glossary-management"/>
                                    <input type="hidden" name="type" value="search"/>
                                    <input type="hidden" name="lang" value=""/>
                                    <div id="search-controls" class="input-group full-width">
                                        <input type="text" name="search" class="form-control" placeholder="Search all types and languages...">
                                            <xsl:attribute name="value" select="/m:response/m:request/m:search"/>
                                        </input>
                                        
                                        <span class="input-group-btn">
                                            <!-- 
                                            <select name="search-lang" class="form-control">
                                                <option value="en">
                                                    <xsl:if test="/m:response/m:request/@search-lang eq 'en'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'en'"/>
                                                </option>
                                                <option value="sa-ltn">
                                                    <xsl:if test="/m:response/m:request/@search-lang eq 'sa-ltn'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'skt'"/>
                                                </option>
                                                <option value="bo-ltn">
                                                    <xsl:if test="/m:response/m:request/@search-lang eq 'bo-ltn'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'wy'"/>
                                                </option>
                                            </select> -->
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fa fa-search"/>
                                            </button>
                                        </span>
                                    </div>
                                </form>
                                <div class="div-list sml-margin top">
                                    <xsl:choose>
                                        <xsl:when test="m:glossary/m:term">
                                            
                                            <xsl:for-each select="m:glossary/m:term">
                                                <div class="item">
                                                    <xsl:value-of select="normalize-space(m:main-term/text())"/>
                                                    
                                                    <span class="label label-default pull-right">
                                                        <xsl:choose>
                                                            <xsl:when test="m:main-term/@xml:lang gt ''">
                                                                <xsl:value-of select="m:main-term/@xml:lang"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'en'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        
                                                    </span>
                                                </div>
                                            </xsl:for-each>
                                            
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div class="item text-muted italic">
                                                <xsl:value-of select="'No search results'"/>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </div>
                            </div>
                            <div class="col-sm-8">
                                
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Glossary management | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Manage glossary entries'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>