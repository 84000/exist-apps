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
                            
                            <xsl:if test="m:team/@locked-by-user gt ''">
                                <div class="alert alert-danger" role="alert">
                                    <xsl:value-of select="concat('File sponsors.xml is currenly locked by user ', m:team/@locked-by-user, '. ')"/>
                                    You cannot modify this file until the lock is released.
                                </div>
                            </xsl:if>
                            
                            <form method="post" class="form-horizontal form-update">
                                
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
                                                        ID: <xsl:value-of select="$team-id"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>New team </xsl:otherwise>
                                                </xsl:choose>
                                            </legend>
                                            
                                            <xsl:copy-of select="m:text-input('Name','name', m:team/m:label, 9, 'required')"/>
                                            
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
                                                    Save
                                                </button>
                                                
                                            </div>
                                        </fieldset>
                                        
                                        <xsl:if test="m:team/m:acknowledgement">
                                            <section>
                                                <div class="relative" id="team-acknowledgements">
                                                    <xsl:if test="count(m:team/m:acknowledgement) gt 1">
                                                        <xsl:attribute name="class" select="'relative preview-list render-in-viewport'"/>
                                                    </xsl:if>
                                                    <h4>Acknowledgements</h4>
                                                    <xsl:call-template name="acknowledgements">
                                                        <xsl:with-param name="acknowledgements" select="m:team/m:acknowledgement"/>
                                                        <xsl:with-param name="css-class" select="''"/>
                                                        <xsl:with-param name="group" select="''"/>
                                                        <xsl:with-param name="link-href" select="concat($reading-room-path, '/translation/@translation-id.html')"/>
                                                    </xsl:call-template>
                                                </div>
                                            </section>
                                        </xsl:if>
                                        
                                    </div>
                                    
                                    <div class="col-sm-6">
                                        <xsl:if test="m:team/m:person">
                                            <div class="relative" id="team-persons">
                                                <h4>Contributors</h4>
                                                <ul>
                                                    <xsl:for-each select="m:team/m:person">
                                                        <li>
                                                            <a target="_self">
                                                                <xsl:attribute name="href" select="concat('/edit-translator.html?id=', @xml:id)"/>
                                                                <xsl:value-of select="m:label"/>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </xsl:if>
                                    </div>
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