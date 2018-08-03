<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="reading-room-page.xsl"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        <ul class="breadcrumb">
                            <li>
                                <a href="/utilities.html">
                                    Utilities
                                </a>
                            </li>
                            <li>
                                Edit <xsl:value-of select="m:translation/@id"/>
                            </li>
                        </ul>
                        <span>
                            <a class="pull-right">
                                <xsl:attribute name="href" select="concat('/translation/', m:translation/@id, '.html')"/>
                                <xsl:attribute name="target" select="m:translation/@id"/>
                                Preview
                            </a>
                        </span>
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:if test="m:updates/m:updated">
                            <div class="alert alert-success alert-temporary" role="alert">
                                Updated
                            </div>
                        </xsl:if>
                        
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation">
                                <xsl:if test="m:translation/m:titles">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=titles">Titles</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="m:translation/m:source">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=source">Source</a>
                            </li>
                        </ul>
                        
                        <div class="tab-content">
                            
                            
                            <form method="post" class="form-horizontal">
                                
                                <xsl:attribute name="action" select="concat('/translation/', m:translation/@id, '.edit')"/>
                                
                                <input type="hidden" name="translation-id">
                                    <xsl:attribute name="value" select="m:translation/@id"/>
                                </input>
                                
                                <xsl:if test="m:translation/m:titles">
                                    
                                    <input type="hidden" name="tab" value="titles"/>
                                    
                                    <xsl:copy-of select="m:text-input('English Title','title-en', m:translation/m:titles/m:title[@xml:lang eq 'en'], '10', '')"/>
                                   
                                    <xsl:copy-of select="m:text-input('Tibetan Title','title-bo', m:translation/m:titles/m:title[@xml:lang eq 'bo'], '10', 'text-bo')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Sanskrit Title','title-sa', m:translation/m:titles/m:title[@xml:lang eq 'sa-ltn'], '10', '')"/>
                                    
                                    <xsl:copy-of select="m:text-input('English Long Title','title-long-en', m:translation/m:long-titles/m:title[@xml:lang eq 'en'], '10', '')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Tibetan Long Title','title-long-bo', m:translation/m:long-titles/m:title[@xml:lang eq 'bo'], '10', 'text-bo')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Wylie Long Title','title-long-bo-ltn', m:translation/m:long-titles/m:title[@xml:lang eq 'bo-ltn'], '10', '')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Sanskrit Long Title','title-long-sa', m:translation/m:long-titles/m:title[@xml:lang eq 'sa-ltn'], '10', '')"/>
                                    
                                </xsl:if>
                                
                                <xsl:if test="m:translation/m:source">
                                    
                                    <input type="hidden" name="tab" value="source"/>
                                    
                                    <xsl:copy-of select="m:text-input('Toh','toh', m:translation/m:source/m:toh, '3', '')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Series','series', m:translation/m:source/m:series, '10', '')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Scope','scope', m:translation/m:source/m:scope, '10', '')"/>
                                    
                                    <xsl:copy-of select="m:text-input('Range','range', m:translation/m:source/m:range, '10', '')"/>
                                    
                                    <xsl:copy-of select="m:text-multiple-input('Author(s)','author', m:translation/m:source/m:authors/m:author, '4', '')"/>
                                    
                                </xsl:if>
                                
                                <hr/>
                                
                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <button type="submit" class="btn btn-primary">Save</button>
                                    </div>
                                </div>
                                
                            </form>
                            
                            
                        </div>
                    </div>
                    
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="app-id" select="@app-id"/>
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat('Edit Toh', m:translation/m:source/m:toh)"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:function name="m:text-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="size"/>
        <xsl:param name="css-class"/>
        <div class="form-group">
            <label class="col-sm-2 control-label">
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div class="col-sm-10">
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:attribute name="value" select="$value"/>
                    <xsl:attribute name="class" select="concat('form-control', ' ', $css-class)"/>
                </input>
            </div>
        </div>
    </xsl:function>
    
    <xsl:function name="m:text-multiple-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="values"/>
        <xsl:param name="size"/>
        <xsl:param name="css-class"/>
        <xsl:for-each select="$values">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:copy-of select="m:text-input($label, concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="m:text-input('+', concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
        <xsl:copy-of select="m:text-input('+', concat($name, '-', (count($values) + 1)), '', $size, $css-class)"/>
        
    </xsl:function>
    
</xsl:stylesheet>