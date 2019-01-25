<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
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
                            
                            <xsl:if test="m:person/@locked-by-user gt ''">
                                <div class="alert alert-danger" role="alert">
                                    <xsl:value-of select="concat('File sponsors.xml is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                                    You cannot modify this file until the lock is released.
                                </div>
                            </xsl:if>
                            
                            <form method="post" class="form-horizontal form-update">
                                
                                <xsl:attribute name="action" select="'edit-translator.html'"/>
                                <xsl:variable name="person-id" select="m:person/@xml:id"/>
                                
                                <input type="hidden" name="post-id">
                                    <xsl:choose>
                                        <xsl:when test="$person-id">
                                            <xsl:attribute name="value" select="$person-id"/>
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
                                                    <xsl:when test="$person-id">
                                                        ID: <xsl:value-of select="$person-id"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>New contributor</xsl:otherwise>
                                                </xsl:choose>
                                            </legend>
                                            
                                            <xsl:copy-of select="m:text-input('Name','name', m:person/m:label, 9, 'required')"/>
                                            
                                            <div class="add-nodes-container">
                                                <xsl:choose>
                                                    <xsl:when test="m:person/m:team">
                                                        <xsl:for-each select="m:person/m:team">
                                                            <div class="add-nodes-group">
                                                                <xsl:copy-of select="m:select-input-name('Team', concat('team-id-', position()), 9, /m:response/m:contributor-teams/m:team, @id)"/>
                                                            </div>
                                                        </xsl:for-each>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <div class="add-nodes-group">
                                                            <xsl:copy-of select="m:select-input-name('Team', 'team-id-1', 9, /m:response/m:contributor-teams/m:team, '')"/>
                                                        </div>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <div class="form-group">
                                                    <div class="col-sm-offset-3 col-sm-9">
                                                        <a href="#add-nodes" class="add-nodes">
                                                            <span class="monospace">+</span> add a team
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="add-nodes-container">
                                                <xsl:choose>
                                                    <xsl:when test="m:person/m:institution">
                                                        <xsl:for-each select="m:person/m:institution">
                                                            <div class="add-nodes-group">
                                                                <xsl:copy-of select="m:select-input-name('Institution', concat('institution-id-', position()), 9, /m:response/m:contributor-institutions/m:institution, @id)"/>
                                                            </div>
                                                        </xsl:for-each>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <div class="add-nodes-group">
                                                            <xsl:copy-of select="m:select-input-name('Institution', 'institution-id-1', 9, /m:response/m:contributor-institutions/m:institution, '')"/>
                                                        </div>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <div class="form-group">
                                                    <div class="col-sm-offset-3 col-sm-9">
                                                        <a href="#add-nodes" class="add-nodes">
                                                            <span class="monospace">+</span> add an institution
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <hr/>
                                            
                                            <div>
                                                <xsl:if test="$person-id">
                                                    <xsl:choose>
                                                        <xsl:when test="m:person/m:acknowledgement">
                                                            <!-- Disable if there are acknowledgments -->
                                                            <span title="You cannot delete a credited translator">
                                                                <a href="#" class="btn btn-default disabled">
                                                                    <xsl:value-of select="'Delete'"/>
                                                                </a>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <a class="btn btn-danger">
                                                                <xsl:attribute name="href" select="concat('/translators.html?delete=', $person-id)"/>
                                                                <xsl:value-of select="'Delete'"/>
                                                            </a>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:if>
                                            
                                                <button type="submit" class="btn btn-primary pull-right">
                                                    Save
                                                </button>
                                            </div>
                                            
                                        </fieldset>
                                    </div>
                                
                                    <section class="col-sm-6">
                                        <xsl:if test="m:person/m:acknowledgement">
                                            <div class="relative" id="person-acknowledgements">
                                                <xsl:if test="count(m:person/m:acknowledgement) gt 1">
                                                    <xsl:attribute name="class" select="'relative preview-list render-in-viewport'"/>
                                                </xsl:if>
                                                <h4>Acknowledgements</h4>
                                                <xsl:call-template name="acknowledgements">
                                                    <xsl:with-param name="acknowledgements" select="m:person/m:acknowledgement"/>
                                                    <xsl:with-param name="css-class" select="''"/>
                                                    <xsl:with-param name="group" select="''"/>
                                                    <xsl:with-param name="link-href" select="'/edit-text-header.html?id=@translation-id'"/>
                                                </xsl:call-template>
                                            </div>
                                        </xsl:if>
                                    </section>
                                    
                                </div>
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