<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="request-text" select="m:translations/m:text[@id eq /m:response/m:request/@text-id]"/>
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="page-content">
                    
                    <form action="/annotation-tei.html" method="post" class="filter-form" data-loading="Checking archive...">
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
                    </form>
                    
                    <h3>
                        <xsl:value-of select="($request-text/text(), '[Please select a text]')[1]"/>
                    </h3>
                    
                    <div class="div-list no-border-top">
                        
                        <div class="item">
                            <strong>
                                <xsl:value-of select="'Archived copies of the TEI'"/>
                            </strong>
                        </div>
                        
                        <xsl:choose>
                            <xsl:when test="m:archived-texts[m:text]">
                                <xsl:for-each select="m:archived-texts/m:text">
                                    
                                    <xsl:sort select="@last-modified ! xs:dateTime(.)" order="descending"/>
                                    
                                    <div class="item">
                                        
                                        <div>
                                            <xsl:value-of select="@archive-path"/>
                                            <xsl:value-of select="' / '"/>
                                            <a class="small">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key[1], '.html?archive-path=', @archive-path, '&amp;view-mode=annotation')"/>
                                                <xsl:attribute name="target" select="concat(@id, '.html')"/>
                                                <xsl:value-of select="'Annotation mode'"/>
                                            </a>
                                        </div>
                                        
                                        <div class="small text-muted">
                                            <xsl:value-of select="concat('Last modified: ', (@last-modified ! format-dateTime(., '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
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
                        
                        <xsl:if test="$request-text">
                            <div class="item">
                                
                                <form action="/annotation-tei.html" method="post" data-loading="Creating archive...">
                                    <input type="hidden" name="text-id" value="{ $request-text/@id }"/>
                                    <input type="hidden" name="form-action" value="archive-latest"/>
                                    <button type="submit" class="btn btn-success">
                                        <xsl:value-of select="'Archive a copy of the current TEI'"/>
                                    </button>
                                </form>
                                
                            </div>
                        </xsl:if>
                        
                        
                    </div>
                    
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