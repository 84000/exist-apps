<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <form method="post" class="form-horizontal form-update" data-loading="Updating team...">
                        
                        <xsl:attribute name="action" select="'edit-translator-team.html'"/>
                        <xsl:variable name="team-id" select="m:team/@xml:id"/>
                        
                        <input type="hidden" name="post-id">
                            <xsl:choose>
                                <xsl:when test="$team-id">
                                    <xsl:attribute name="value" select="$team-id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="value" select="'new'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </input>
                        
                        <div class="row">
                            <div class="col-sm-6">
                                <fieldset class="bottom-margin">
                                    
                                    <legend>
                                        <xsl:choose>
                                            <xsl:when test="$team-id">
                                                <xsl:value-of select="concat('ID: ', $team-id)"/>
                                            </xsl:when>
                                            <xsl:otherwise>New team </xsl:otherwise>
                                        </xsl:choose>
                                    </legend>
                                    
                                    <xsl:copy-of select="ops:text-input('Name','name', m:team/m:label, 9, 'required')"/>
                                    
                                    <div class="form-group">
                                        <div class="col-sm-offset-3 col-sm-9">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" name="hidden" id="hidden" value="1">
                                                        <xsl:if test="m:team[@rend eq 'hidden']">
                                                            <xsl:attribute name="checked" select="'checked'"/>
                                                        </xsl:if>
                                                    </input>
                                                    <xsl:value-of select="'Hidden'"/>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <hr/>
                                    
                                    <div>
                                        
                                        <xsl:if test="$team-id">
                                            <xsl:choose>
                                                <xsl:when test="count(m:team/m:person) gt 0">
                                                    <!-- Disable if there are acknowledgments -->
                                                    <span title="You cannot delete a team with members">
                                                        <a href="#" class="btn btn-default disabled">
                                                            <xsl:value-of select="'Delete'"/>
                                                        </a>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <a class="btn btn-danger">
                                                        <xsl:attribute name="href" select="concat('/translator-teams.html?delete=', $team-id)"/>
                                                        <xsl:value-of select="'Delete'"/>
                                                    </a>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                        
                                        <button type="submit" class="btn btn-primary pull-right">
                                            <xsl:value-of select="'Save'"/>
                                        </button>
                                        
                                    </div>
                                </fieldset>
                                
                            </div>
                            
                            <div class="col-sm-6">
                                
                                <section class="bottom-margin">
                                    
                                    <xsl:variable name="section-id" select="'team-persons'"/>
                                    <xsl:attribute name="id" select="$section-id"/>
                                    
                                    <xsl:if test="count(m:team/m:person) gt 10">
                                        <xsl:attribute name="class" select="'preview-list preview bottom-margin'"/>
                                        
                                        <xsl:call-template name="preview-controls">
                                            
                                            <xsl:with-param name="section-id" select="$section-id"/>
                                            <xsl:with-param name="href" select="concat('#', $section-id)"/>
                                            
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                    <h4>
                                        <xsl:value-of select="'Contributors'"/>
                                    </h4>
                                    
                                    <hr class="sml-margin"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="m:team/m:person">
                                            <xsl:for-each select="m:team/m:person">
                                                <div>
                                                    <a target="_self">
                                                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', @xml:id)"/>
                                                        <xsl:value-of select="m:label"/>
                                                    </a>
                                                </div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div class="text-muted italic">
                                                <xsl:value-of select="'No contributors'"/>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </section>
                                
                                <section>
                                    
                                    <xsl:variable name="section-id" select="'team-acknowledgements'"/>
                                    <xsl:attribute name="id" select="$section-id"/>
                                    
                                    <xsl:if test="count(m:team/m:acknowledgement) gt 5">
                                        <xsl:attribute name="class" select="'preview-list preview'"/>
                                        
                                        <xsl:call-template name="preview-controls">
                                            
                                            <xsl:with-param name="section-id" select="$section-id"/>
                                            <xsl:with-param name="href" select="concat('#', $section-id)"/>
                                            
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                    <h4>
                                        <xsl:value-of select="'Attribution'"/>
                                    </h4>
                                    
                                    <hr class="sml-margin"/>
                                    
                                    <xsl:call-template name="acknowledgements">
                                        <xsl:with-param name="acknowledgements" select="m:team/m:acknowledgement"/>
                                        <xsl:with-param name="css-class" select="''"/>
                                        <xsl:with-param name="group" select="''"/>
                                        <xsl:with-param name="link-href" select="'/edit-text-header.html?id=@translation-id'"/>
                                    </xsl:call-template>
                                    
                                </section>
                                
                            </div>
                        </div>
                    </form>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Team | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>