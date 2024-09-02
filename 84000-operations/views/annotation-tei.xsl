<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="response" select="/m:response"/>
    <xsl:variable name="text" select="$response/m:text"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
                    <!--<h3>
                        <xsl:value-of select="($request-text/text(), '[Please select a text]')[1]"/>
                    </h3>-->
                    
                    <!--<form action="/annotation-tei.html" method="get" class="filter-form" data-loading="Checking archive...">
                        <div class="form-group">
                            <select name="text-id" id="text-id" class="form-control">
                                <xsl:for-each select="m:translations/m:text">
                                    <xsl:sort select="@id"/>
                                    <option>
                                        <xsl:attribute name="value" select="@id"/>
                                        <xsl:if test="@selected">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="common:limit-str(data(.), 180)"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                    </form>-->
                    
                    <!-- Title / status -->
                    <div class="center-vertical full-width sml-margin bottom">
                        
                        <div class="h3">
                            <a target="_blank">
                                <xsl:attribute name="href" select="m:translation-href(($text/m:toh/@key)[1], (), (), (), (), $reading-room-path)"/>
                                <xsl:value-of select="concat(string-join($text/m:toh/m:full, ' / '), ' / ', $text/m:titles/m:title[@xml:lang eq 'en'][1])"/>
                            </a>
                        </div>
                        
                        <div class="text-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <!-- Links -->
                    <xsl:call-template name="text-links-list">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="disable-links" select="('annotation-tei')"/>
                        <xsl:with-param name="text-status" select="$response/m:text-statuses/m:status[@status-id eq $text/@status]"/>
                    </xsl:call-template>
                    
                    <hr class="sml-margin"/>
                                        
                    <!--<h2>
                        <xsl:value-of select="'Archived copies of the TEI'"/>
                    </h2>-->
                    
                    <div class="div-list no-border-top">
                        
                        
                        <xsl:choose>
                            <xsl:when test="m:archived-texts[m:text]">
                                <xsl:for-each select="m:archived-texts/m:text">
                                    
                                    <xsl:sort select="@last-modified ! xs:dateTime(.)" order="descending"/>
                                    
                                    <div class="item">
                                        
                                        <div>
                                            <xsl:value-of select="string-join((@archive-path, @file-name), '/')"/>
                                        </div>
                                        
                                        <div class="small text-muted">
                                            <xsl:value-of select="concat('Last modified: ', (@last-modified ! format-dateTime(., '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                                        </div>
                                        
                                        <div>
                                            <a class="small">
                                                <xsl:attribute name="href" select="m:translation-href(($text/m:toh/@key)[1], (), (), (), m:translation-url-parameters('', (concat('archive-path=', @archive-path), 'view-mode=annotation')), $reading-room-path)"/>
                                                <xsl:attribute name="target" select="concat(@id, '.html')"/>
                                                <xsl:value-of select="'Open in annotation mode'"/>
                                            </a>                                            
                                        </div>
                                        
                                    </div>
                                    
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                
                                <div class="item">
                                    
                                    <span class="italic text-muted">
                                        <xsl:value-of select="'No archived tei found for this translation'"/>
                                    </span>
                                    
                                </div>
                                
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <xsl:if test="$text[@id]">
                            <div class="item">
                                
                                <form action="/annotation-tei.html" method="post" data-loading="Creating archive...">
                                    <input type="hidden" name="text-id" value="{ $text/@id }"/>
                                    <input type="hidden" name="form-action" value="archive-latest"/>
                                    <button type="submit" class="btn btn-danger">
                                        <xsl:value-of select="'Archive a copy of the current TEI'"/>
                                    </button>
                                </form>
                                
                            </div>
                        </xsl:if>
                        
                    </div>
                    
                </xsl:with-param>
                
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                </xsl:with-param>
                
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Annotation Archive | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Archived copies of the translations that can be used for annotation'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>