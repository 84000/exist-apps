<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="selected-type" select="$request/m:article-types/m:type[@selected eq 'selected']" as="element(m:type)*"/>
    <xsl:variable name="page-url" select="concat($environment/m:url[@id eq 'utilities'], '/knowledgebase.html?') || string-join(($selected-type ! concat('article-type[]=', @id), $request/@sort ! concat('sort=', .)), '&amp;')" as="xs:string"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div id="articles-list">
                
                <form action="/knowledgebase.html" method="get" role="search" class="form-inline" data-loading="Searching...">
                    
                    <!-- Type checkboxes -->
                    <div class="center-vertical full-width">
                        
                        <div>
                            <div class="form-group">
                                
                                <xsl:for-each select="m:request/m:article-types/m:type">
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="article-type[]">
                                                <xsl:attribute name="value" select="@id"/>
                                                <xsl:if test="@selected eq 'selected'">
                                                    <xsl:attribute name="checked" select="'checked'"/>
                                                </xsl:if>
                                            </input>
                                            <xsl:value-of select="' ' || text()"/>
                                        </label>
                                    </div>
                                </xsl:for-each>
                                
                                <select name="sort" class="form-control">
                                    <option value="latest">
                                        <xsl:if test="$request[@sort eq 'latest']">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Most recently updated'"/>
                                    </option>
                                    <option value="name">
                                        <xsl:if test="$request[@sort eq 'name']">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Sort A-Z'"/>
                                    </option>
                                    <option value="status">
                                        <xsl:if test="$request[@sort eq 'status']">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Sort by status'"/>
                                    </option>
                                </select>
                                
                                <button type="submit" class="btn btn-primary btn-sm" title="Search">
                                    <i class="fa fa-refresh"/>
                                    <xsl:value-of select="' Reload'"/>
                                </button>
                                
                            </div>
                        </div>
                        
                        <xsl:if test="$environment/m:url[@id eq 'operations']">
                            <div>
                                <a target="84000-operations" class="btn btn-danger">
                                    <xsl:attribute name="href" select="'/create-article.html#ajax-source'"/>
                                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                    <xsl:attribute name="data-editor-callbackurl" select="common:internal-link(concat($environment/m:url[@id eq 'utilities'], '/knowledgebase.html?') || string-join(('article-type[]=articles', 'sort=latest'), '&amp;'), (), '#articles-list', $root/m:response/@lang)"/>
                                    <xsl:value-of select="'Add a new article'"/>
                                </a>
                            </div>
                        </xsl:if>
                        
                        <div>
                            
                            <!-- Pagination -->
                            <xsl:sequence select="common:pagination($request/@first-record, $request/@records-per-page, m:knowledgebase/@count-pages, $page-url)"/>
                            
                        </div>
                        
                    </div>
                    
                </form>
                
                <hr class="sml-margin"/>
                
                <xsl:choose>
                    <xsl:when test="m:knowledgebase/m:page">
                        <div class="div-list no-border-top">
                            <xsl:for-each select="m:knowledgebase/m:page">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="text-center text-muted">
                            <p class="italic">
                                <xsl:value-of select="'~ No matches for this query ~'"/>
                            </p>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
            
            <hr class="sml-margin"/>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Knowledgebase Pages | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Knowledgebase Pages'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="m:page[parent::m:knowledgebase]">
        
        <xsl:variable name="page-id" select="concat('page-', fn:encode-for-uri(@xml:id))"/>
        
        <div class="item">
            
            <!-- Title / status -->
            <div class="center-vertical full-width sml-margin bottom">
                
                <div>
                    <span class="h3">
                        <xsl:value-of select="m:titles ! (m:title[@type eq 'articleTitle'], m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], m:title[@type eq 'mainTitle'])[1]"/>
                    </span>
                    <small>
                        <xsl:value-of select="concat(' / ', @kb-id)"/>
                    </small>
                    <xsl:value-of select="' '"/>
                    <span class="label label-default">
                        <xsl:choose>
                            <xsl:when test="@type eq 'section'">
                                <xsl:value-of select="'Section'"/>
                            </xsl:when>
                            <xsl:when test="@type eq 'author'">
                                <xsl:value-of select="'Author'"/>
                            </xsl:when>
                            <xsl:when test="@type eq 'article'">
                                <xsl:value-of select="'Article'"/>
                            </xsl:when>
                        </xsl:choose>
                    </span>
                </div>
                
                <!-- Status -->
                <div class="text-right">
                    <span>
                        <xsl:choose>
                            <xsl:when test="@status-group eq 'published'">
                                <xsl:attribute name="class" select="'label label-success'"/>
                                <xsl:value-of select="concat(@status, ' / ', 'Published')"/>
                            </xsl:when>
                            <xsl:when test="@status-group eq 'in-progress'">
                                <xsl:attribute name="class" select="'label label-warning'"/>
                                <xsl:value-of select="concat(@status, ' / ', 'In-progress')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class" select="'label label-default'"/>
                                <xsl:value-of select="concat(@status, ' / ', 'Not published')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>
                
            </div>
            
            <!-- Links -->
            <div class="sml-margin bottom">
                <ul class="list-inline inline-dots">
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.tei')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.tei')"/>
                            <span class="small">
                                <xsl:value-of select="'tei'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.xml')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.xml')"/>
                            <span class="small">
                                <xsl:value-of select="'xml'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.html')"/>
                            <span class="small">
                                <xsl:value-of select="'html'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat('https://github.com/84000/data-tei/commits/master', substring-after(@document-url, concat($environment/@data-path, '/tei')))"/>
                            <xsl:attribute name="target" select="'_blank'"/>
                            <span class="small">
                                <xsl:value-of select="'commits'"/>
                            </span>
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Alert if file locked -->
            <xsl:if test="@locked-by-user gt ''">
                <div class="sml-margin bottom">
                    <span class="label label-danger">
                        <xsl:value-of select="concat('WARNING: This file is currenly locked by user ', @locked-by-user)"/>
                    </span>
                </div>
            </xsl:if>
            
            <!-- Location -->
            <div class="small text-muted sml-margin bottom">
                <xsl:value-of select="concat('File: ', @document-url)"/>
            </div>
            
            <!-- Version -->
            <div class="sml-margin bottom">
                <span class="text-danger small">
                    <xsl:value-of select="concat('Local TEI: ', @tei-version)"/>
                </span>
            </div>
            
            <!-- Version note -->
            
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>