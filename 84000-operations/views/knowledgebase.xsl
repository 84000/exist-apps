<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:webflow="http://read.84000.co/webflow-api" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <!--<xsl:variable name="environment" select="/m:response/m:environment"/>-->
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="text-statuses" select="/m:response/m:text-statuses"/>
    <xsl:variable name="selected-type" select="$request/m:article-types/m:type[@selected eq 'selected']" as="element(m:type)*"/>
    <xsl:variable name="page-url" select="concat($environment/m:url[@id eq 'operations'], '/knowledgebase.html?') || string-join(($selected-type ! concat('article-type[]=', @id), $request/@sort ! concat('sort=', .)), '&amp;')" as="xs:string"/>
    <xsl:variable name="webflow-api" select="/m:response/webflow:webflow-api"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
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
                                    
                                    <button type="submit" class="btn btn-round" title="Reload">
                                        <i class="fa fa-refresh"/>
                                    </button>
                                    
                                </div>
                            </div>
                            
                            <xsl:if test="$environment/m:url[@id eq 'operations']">
                                <div>
                                    <a target="84000-operations" class="btn btn-danger">
                                        <xsl:attribute name="href" select="'/create-article.html#ajax-source'"/>
                                        <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                        <xsl:attribute name="data-editor-callbackurl" select="common:internal-href(concat($environment/m:url[@id eq 'operations'], '/knowledgebase.html?') || string-join(('article-type[]=articles', 'sort=latest'), '&amp;'), (), '#articles-list', $root/m:response/@lang)"/>
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
                    
                </xsl:with-param>
                
                <xsl:with-param name="aside-content">
                    
                    <!-- Pop-up for tei-editor -->
                    <xsl:call-template name="tei-editor-footer"/>
                    
                </xsl:with-param>
                
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Knowledge Base Articles | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Manage and access articles in the 84000 Knowledge Base'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="m:page[parent::m:knowledgebase]">
        
        <xsl:variable name="page" select="."/>
        <xsl:variable name="page-id" select="concat('page-', fn:encode-for-uri($page/@xml:id))"/>
        <xsl:variable name="text-status" select="$page/@status"/>
        <xsl:variable name="webflow-api-item" select="$webflow-api//webflow:item[@id eq $page/@kb-id]"/>
        
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
                                <xsl:value-of select="concat($text-status, ' / ', $text-statuses/m:status[@status-id eq $text-status]/text())"/>
                            </xsl:when>
                            <xsl:when test="@status-group eq 'in-progress'">
                                <xsl:attribute name="class" select="'label label-warning'"/>
                                <xsl:value-of select="concat($text-status, ' / ', $text-statuses/m:status[@status-id eq $text-status]/text())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class" select="'label label-default'"/>
                                <xsl:value-of select="concat($text-status, ' / ', $text-statuses/m:status[@status-id eq $text-status]/text())"/>
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
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', @xml:id)"/>
                            <span class="small">
                                <xsl:value-of select="'edit headers'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html?view-mode=editor')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.html')"/>
                            <span class="small">
                                <xsl:value-of select="'edit article'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', @xml:id, '&amp;resource-type=knowledgebase')"/>
                            <span class="small">
                                <xsl:value-of select="'edit glossary'"/>
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
            
            <!-- Webflow connction -->
            <div class="center-vertical align-left">
                <span>
                    <xsl:choose>
                        <xsl:when test="$webflow-api-item and $webflow-api-item[not(@updated gt '')]">
                            <span class="label label-warning">
                                <xsl:value-of select="'No Webflow CMS updates'"/>
                            </span>
                        </xsl:when>
                        <xsl:when test="$webflow-api-item">
                            <span class="label label-default">
                                <xsl:value-of select="concat('Webflow CMS last updated ', (format-dateTime($webflow-api-item/@updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="label label-danger">
                                <xsl:value-of select="'Not linked to Webflow CMS'"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:if test="$webflow-api-item[@updated ! xs:dateTime(.) lt $page/@last-updated ! xs:dateTime(.)]">
                    <span>
                        <span class="label label-warning">
                            <xsl:value-of select="concat('Content updated ', (format-dateTime($page/@last-updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                        </span>
                    </span>
                </xsl:if>
            </div>
            
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>