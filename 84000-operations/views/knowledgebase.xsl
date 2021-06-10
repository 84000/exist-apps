<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    <div class="well well-sm bottom-margin">
                        
                        <div class="center-vertical full-width">
                            
                            <span class="small">
                                <xsl:value-of select="concat('Listing ', fn:format-number(xs:integer(count(m:knowledgebase/m:page)),'#,##0'), ' Knowledge Base articles')"/>
                            </span>
                            
                            <span>
                                <a href="#new-article-form-container" data-toggle="collapse" class="btn btn-primary btn-sml pull-right">
                                    <xsl:value-of select="'Add an article'"/>
                                </a>
                            </span>
                            
                        </div>
                        
                        <div class="collapse" id="new-article-form-container">
                            
                            <hr class="sml-margin"/>
                            
                            <form action="/knowledgebase.html" method="post" class="form-inline text-center bottom-margin">
                                <input type="hidden" name="form-action" value="new-kb-article"/>
                                <div class="form-group">
                                    <div class="input-group">
                                        <label for="new-kb-title" class="input-group-addon">
                                            <xsl:value-of select="'Title: '"/>
                                        </label>
                                        <input type="text" name="new-kb-title" id="new-kb-title" class="form-control" size="70"/>
                                        <div class="input-group-btn">
                                            <button type="submit" class="btn btn-primary">
                                                <xsl:value-of select="'Create this article'"/>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </form>
                            
                        </div>
                        
                    </div>
                    
                    <div class="row">
                        <div class="col-items div-list no-border-top">
                            
                            <xsl:for-each-group select="m:knowledgebase/m:page" group-by="@start-letter">
                                
                                <xsl:sort select="@start-letter"/>
                                
                                <div>
                                    
                                    <a class="marker">
                                        <xsl:attribute name="name" select="@start-letter"/>
                                        <xsl:attribute name="id" select="concat('marker-', @start-letter)"/>
                                        <xsl:value-of select="@start-letter"/>
                                    </a>
                                
                                    <xsl:for-each select="fn:current-group()">
                                        
                                        <xsl:sort select="m:sort-name"/>
                                        
                                        <div class="item">
                                            
                                            <div class="center-vertical full-width">
                                                <span>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html')"/>
                                                        <xsl:attribute name="target" select="@xml:id"/>
                                                        <xsl:value-of select="m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en']"/>
                                                    </a>
                                                </span>
                                                <span class="text-right">
                                                    <span>
                                                        <xsl:choose>
                                                            <xsl:when test="@status-group eq 'published'">
                                                                <xsl:attribute name="class" select="'label label-success'"/>
                                                                <xsl:value-of select="'Published'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:attribute name="class" select="'label label-default'"/>
                                                                <xsl:value-of select="'Not published'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                </span>
                                            </div>
                                            
                                            
                                            <ul class="list-inline inline-dots sml-margin top no-bottom-margin small hidden-print">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', @xml:id)"/>
                                                        <xsl:value-of select="'Edit headers'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html?view-mode=editor')"/>
                                                        <xsl:attribute name="target" select="@xml:id"/>
                                                        <xsl:value-of select="'Editor mode'"/>
                                                    </a>
                                                </li>
                                            </ul>
                                            
                                        </div>
                                        
                                    </xsl:for-each>
                                
                                </div>
                                
                            </xsl:for-each-group>
                            
                        </div>
                        
                        <div class="col-nav affix-container">
                            <xsl:copy-of select="common:marker-nav(m:knowledgebase/m:page)"/>
                        </div>
                        
                    </div>
                    
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Knowledge Base pages | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Knowledge Base pages for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>