<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    <div class="well well-sm center-vertical full-width bottom-margin">
                        
                        <span>
                            <xsl:value-of select="concat('Listing ', fn:format-number(xs:integer(count(m:contributor-teams/m:team)),'#,##0'), ' translator teams ')"/>
                        </span>
                        
                        <div>
                            <a class="btn btn-primary btn-sml pull-right">
                                <xsl:attribute name="href" select="'/edit-translator-team.html'"/>
                                <xsl:value-of select="'Add a translator team'"/>
                            </a>
                        </div>
                        
                    </div>
                    
                    <div class="row">
                        <div class="col-items div-list no-border-top">
                            
                            <xsl:for-each-group select="m:contributor-teams/m:team" group-by="@start-letter">
                                
                                <xsl:sort select="@start-letter"/>
                                
                                <div>
                                    
                                    <a class="marker">
                                        <xsl:attribute name="name" select="@start-letter"/>
                                        <xsl:attribute name="id" select="concat('marker-', @start-letter)"/>
                                        <xsl:value-of select="@start-letter"/>
                                    </a>
                                    
                                    <xsl:for-each select="fn:current-group()">
                                        
                                        <xsl:sort select="m:sort-name"/>
                                        
                                        <xsl:variable name="team-id" select="@xml:id"/>
                                        
                                        <div class="item">
                                            
                                            <div class="row">
                                                <div class="col-sm-6">
                                                    
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', $team-id)"/>
                                                        <xsl:value-of select="m:label"/>
                                                    </a>
                                                    
                                                    <span class="small text-muted">
                                                        <xsl:value-of select="concat(' / ', $team-id, ' ')"/>
                                                    </span>
                                                    
                                                    <xsl:if test="@rend eq 'hidden'">
                                                        <span class="label label-default">
                                                            <xsl:value-of select="'Hidden'"/>
                                                        </span>
                                                    </xsl:if>
                                                    
                                                    <br/>
                                                    
                                                    <span>
                                                        
                                                        <span class="badge badge-notification">
                                                            <xsl:value-of select="count(m:instance)"/>
                                                        </span>
                                                        
                                                        <span class="btn-round-text">
                                                            <xsl:choose>
                                                                <xsl:when test="count(m:instance) eq 1">
                                                                    <xsl:value-of select="' project'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="' projects'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </span>
                                                        
                                                    </span>
                                                    
                                                </div>
                                                
                                                <div class="col-sm-6">
                                                    <section>
                                                        
                                                        <xsl:variable name="section-id" select="concat('team-contributors-', $team-id)"/>
                                                        <xsl:attribute name="id" select="$section-id"/>
                                                        
                                                        <xsl:if test="count(m:person) gt 12">
                                                            <xsl:attribute name="class" select="'preview-list preview'"/>
                                                            
                                                            <xsl:call-template name="preview-controls">
                                                                
                                                                <xsl:with-param name="section-id" select="$section-id"/>
                                                                <xsl:with-param name="href" select="concat('#', $section-id)"/>
                                                                
                                                            </xsl:call-template>
                                                        </xsl:if>
                                                        
                                                        <ul>
                                                            <xsl:for-each select="m:person">
                                                                <xsl:variable name="translator" select="."/>
                                                                <li>
                                                                    <xsl:value-of select="$translator/m:label"/>
                                                                    <span class="small text-muted">
                                                                        <xsl:value-of select="concat(' / ', $translator/@xml:id, ' ')"/>
                                                                    </span>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                        
                                                    </section>
                                                </div>
                                            
                                            </div>
                                            
                                        </div>
                                        
                                    </xsl:for-each>
                                </div>
                                
                            </xsl:for-each-group>
                            
                        </div>
                        
                        <div class="col-nav affix-container">
                            <xsl:copy-of select="common:marker-nav(m:contributor-teams/m:team)"/>
                        </div>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Teams | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Teams configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>