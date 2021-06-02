<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="title" select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en'][1]"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <form action="edit-kb-header.html" method="post" class="form-horizontal form-update">
                        
                        <input type="hidden" name="form-action" value="update-kb-header"/>
                        <input type="hidden" name="id" value="{ m:knowledgebase/m:page/@xml:id }"/>
                        
                        <div class="row">
                            
                            <!-- Form -->
                            <div class="col-sm-8">
                                
                                <h2 class="no-top-margin">
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', m:knowledgebase/m:page/@xml:id, '.html?view-mode=editor')"/>
                                        <xsl:attribute name="target" select="concat(m:knowledgebase/m:page/@xml:id, '.html')"/>
                                        <xsl:value-of select="$title"/>
                                    </a>
                                </h2>
                                
                                <div>
                                    <a class="text-muted small">
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', m:knowledgebase/m:page/@xml:id, '.tei')"/>
                                        <xsl:attribute name="target" select="concat(m:knowledgebase/m:page/@xml:id, '.tei')"/>
                                        <xsl:value-of select="concat('TEI file: ', m:knowledgebase/m:page/@uri)"/>
                                    </a>
                                </div>
                                
                                <fieldset>
                                    
                                    <legend>
                                        <xsl:value-of select="'Status'"/>
                                    </legend>
                                    
                                    <!--Translation Status-->
                                    <div class="form-group">
                                        <label class="control-label col-sm-3" for="publication-status">
                                            <xsl:value-of select="'Publication status:'"/>
                                        </label>
                                        <div class="col-sm-9">
                                            <select class="form-control" name="publication-status" id="publication-status">
                                                <xsl:for-each select="m:text-statuses/m:status">
                                                    <xsl:sort select="@value eq '0'"/>
                                                    <xsl:sort select="@value"/>
                                                    <option>
                                                        <xsl:attribute name="value" select="@value"/>
                                                        <xsl:if test="@selected eq 'selected'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="concat(@value, ' / ', text())"/>
                                                    </option>
                                                </xsl:for-each>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <!--Publication Date-->
                                    <div class="form-group">
                                        <label class="control-label col-sm-3" for="publication-date">
                                            <xsl:value-of select="'Publication date:'"/>
                                        </label>
                                        <div class="col-sm-3">
                                            <input type="date" name="publication-date" id="publication-date" class="form-control">
                                                <xsl:attribute name="value" select="m:knowledgebase/m:publication/m:publication-date"/>
                                                <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                    <xsl:attribute name="required" select="'required'"/>
                                                </xsl:if>
                                            </input>
                                        </div>
                                        
                                    </div>
                                    
                                    <!--Version-->
                                    <div class="form-group">
                                        <label class="control-label col-sm-3" for="text-version">
                                            <xsl:value-of select="'Version:'"/>
                                        </label>
                                        <div class="col-sm-2">
                                            <input type="text" name="text-version" id="text-version" class="form-control" placeholder="e.g. v 1.0">
                                                <!-- Force the addition of a version number if the form is used -->
                                                <xsl:attribute name="value">
                                                    <xsl:choose>
                                                        <xsl:when test="m:knowledgebase/m:publication/m:edition/text()[1]/normalize-space()">
                                                            <xsl:value-of select="m:knowledgebase/m:publication/m:edition/text()[1]/normalize-space()"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'0.0.1'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                    <xsl:attribute name="required" select="'required'"/>
                                                </xsl:if>
                                            </input>
                                        </div>
                                        <div class="col-sm-2">
                                            <input type="text" name="text-version-date" id="text-version-date" class="form-control" placeholder="e.g. 2019">
                                                <xsl:attribute name="value">
                                                    <xsl:choose>
                                                        <xsl:when test="m:knowledgebase/m:publication/m:edition/tei:date/text()/normalize-space()">
                                                            <xsl:value-of select="m:knowledgebase/m:publication/m:edition/tei:date/text()/normalize-space()"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]')"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                    <xsl:attribute name="required" select="'required'"/>
                                                </xsl:if>
                                            </input>
                                        </div>
                                    </div>
                                    
                                    <!-- Version note -->
                                    <div class="form-group">
                                        <label class="control-label col-sm-3" for="text-version">
                                            <xsl:value-of select="'Version note:'"/>
                                        </label>
                                        <div class="col-sm-9">
                                            <input type="text" name="update-notes" id="update-notes" class="form-control"/>
                                        </div>
                                    </div>
                                    
                                </fieldset>
                                
                                <!-- Titles -->
                                <fieldset>
                                    
                                    <legend>
                                        <xsl:value-of select="'Titles'"/>
                                    </legend>
                                    
                                    <div class="add-nodes-container">
                                        <xsl:choose>
                                            <xsl:when test="m:knowledgebase/m:page/m:titles/m:title">
                                                <xsl:call-template name="titles-controls">
                                                    <xsl:with-param name="text-titles" select="m:knowledgebase/m:page/m:titles/m:title"/>
                                                    <xsl:with-param name="title-types" select="m:title-types/m:title-type"/>
                                                    <xsl:with-param name="title-langs" select="m:title-types/m:title-lang"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="titles-controls">
                                                    <xsl:with-param name="text-titles">
                                                        <m:title/>
                                                    </xsl:with-param>
                                                    <xsl:with-param name="title-types" select="m:title-types/m:title-type"/>
                                                    <xsl:with-param name="title-langs" select="m:title-types/m:title-lang"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <div class="form-group">
                                            <div class="col-sm-12">
                                                <a href="#add-nodes" class="add-nodes">
                                                    <span class="monospace">
                                                        <xsl:value-of select="'+'"/>
                                                    </span>
                                                    <xsl:value-of select="' add a title'"/>
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                    
                                </fieldset>
                                
                                <button type="submit" class="btn btn-primary pull-right">
                                    <xsl:value-of select="'Save'"/>
                                </button>
                                
                            </div>
                            
                            <!-- History -->
                            <div class="col-sm-4">
                                
                                <xsl:apply-templates select="m:knowledgebase/m:status-updates"/>
                                
                            </div>
                            
                        </div>
                        
                    </form>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat($title, ' - edit  | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Editing headers for Knowledge Base page: ', $title)"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>

    
</xsl:stylesheet>