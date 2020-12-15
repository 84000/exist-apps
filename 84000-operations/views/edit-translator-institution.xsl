<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <form method="post" class="form-horizontal form-update">
                        
                        <xsl:attribute name="action" select="'edit-translator-institution.html'"/>
                        <xsl:variable name="institution-id" select="m:institution/@xml:id"/>
                        
                        <input type="hidden" name="post-id">
                            <xsl:choose>
                                <xsl:when test="$institution-id">
                                    <xsl:attribute name="value" select="$institution-id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="value" select="'new'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </input>
                        
                        
                        <div class="row">
                            <div class="col-sm-6">
                                <fieldset>
                                    
                                    <legend>
                                        <xsl:choose>
                                            <xsl:when test="$institution-id">
                                                ID: <xsl:value-of select="$institution-id"/>
                                            </xsl:when>
                                            <xsl:otherwise>New institution </xsl:otherwise>
                                        </xsl:choose>
                                    </legend>
                                    
                                    <xsl:copy-of select="m:text-input('Name','name', m:institution/m:label, 9, 'required')"/>
                                    <xsl:copy-of select="m:select-input-name('Region', 'region-id', 9, /m:response/m:contributor-regions/m:region, m:institution/@region-id)"/>
                                    <xsl:copy-of select="m:select-input-name('Type', 'institution-type-id', 9, /m:response/m:contributor-institution-types/m:institution-type, m:institution/@institution-type-id)"/>
                                    
                                    <hr/>
                                    <div>
                                        <xsl:if test="$institution-id">
                                            <xsl:choose>
                                                <xsl:when test="count(m:person) gt 0">
                                                    <!-- Disable if there are acknowledgments -->
                                                    <span title="You cannot delete an institution with contributors">
                                                        <a href="#" class="btn btn-default disabled">
                                                            <xsl:value-of select="'Delete'"/>
                                                        </a>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <a class="btn btn-danger">
                                                        <xsl:attribute name="href" select="concat('/translator-institutions.html?delete=', $institution-id)"/>
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
                                <h4>
                                    <xsl:value-of select="'Contributors'"/>
                                </h4>
                                <hr class="sml-margin"/>
                                <xsl:choose>
                                    <xsl:when test="m:person">
                                        <ul class="list-unstyled">
                                            <xsl:for-each select="m:person">
                                                <xsl:sort select="m:label"/>
                                                <li>
                                                    <a target="_self">
                                                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', @xml:id)"/>
                                                        <xsl:value-of select="m:label"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div class="text-muted italic">
                                            <xsl:value-of select="'No contributors'"/>
                                        </div>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                            
                        </div>
                        
                    </form>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Institution | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>