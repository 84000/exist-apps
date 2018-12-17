<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Operations Reports
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <xsl:if test="m:updates/m:updated">
                                <div class="alert alert-success alert-temporary" role="alert">
                                    Updated
                                </div>
                            </xsl:if>
                            
                            <xsl:if test="m:institution/@locked-by-user gt ''">
                                <div class="alert alert-danger" role="alert">
                                    <xsl:value-of select="concat('File sponsors.xml is currenly locked by user ', m:institution/@locked-by-user, '. ')"/>
                                    You cannot modify this file until the lock is released.
                                </div>
                            </xsl:if>
                            
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
                                    
                                    <div class="col-sm-8">
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
                                            
                                        </fieldset>
                                    </div>
                                    
                                    <div class="col-sm-4">
                                        <h4>Contributors</h4>
                                        <ul>
                                            <xsl:for-each select="m:person">
                                                <li>
                                                    <a target="_self">
                                                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', @xml:id)"/>
                                                        <xsl:value-of select="m:label"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                    
                                </div>
                                <hr/>
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
                                <button type="submit" class="btn btn-primary pull-right">
                                    Save
                                </button>
                            </form>
                            
                        </div>
                    </div>
                    
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Institutions :: 84000 Operations'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>