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
                    
                    <div class="row">
                        <div class="col-sm-9">
                            
                        <form method="post" class="form-horizontal form-update" data-loading="Updating contributor...">
                            
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
                            
                            <fieldset>
                                
                                <legend>
                                    <xsl:choose>
                                        <xsl:when test="$person-id">
                                            <xsl:value-of select="concat('ID: ', $person-id)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'New contributor'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </legend>
                                
                                <xsl:sequence select="ops:text-input('Name','name', m:person/m:label, 10, 'required')"/>
                                
                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-2">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" name="affiliation[]" value="academic">
                                                    <xsl:if test="m:person/m:affiliation[@type eq 'academic']">
                                                        <xsl:attribute name="checked" select="'checked'"/>
                                                    </xsl:if>
                                                </input>
                                                <xsl:value-of select="' Academic'"/>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-sm-2">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" name="affiliation[]" value="practitioner">
                                                    <xsl:if test="m:person/m:affiliation[@type eq 'practitioner']">
                                                        <xsl:attribute name="checked" select="'checked'"/>
                                                    </xsl:if>
                                                </input>
                                                <xsl:value-of select="' Practitioner'"/>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="add-nodes-container">
                                    <xsl:choose>
                                        <xsl:when test="m:person/m:team">
                                            <xsl:for-each select="m:person/m:team">
                                                <div class="add-nodes-group">
                                                    <xsl:copy-of select="ops:select-input-name('Team', concat('team-id-', position()), 10, /m:response/m:contributor-teams/m:team, @id)"/>
                                                </div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div class="add-nodes-group">
                                                <xsl:copy-of select="ops:select-input-name('Team', 'team-id-1', 10, /m:response/m:contributor-teams/m:team, '')"/>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <div class="form-group">
                                        <div class="col-sm-offset-2 col-sm-10">
                                            <a href="#add-nodes" class="add-nodes">
                                                <span class="monospace">
                                                    <xsl:value-of select="'+'"/>
                                                </span>
                                                <xsl:value-of select="' add a team'"/>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="add-nodes-container">
                                    <xsl:choose>
                                        <xsl:when test="m:person/m:institution">
                                            <xsl:for-each select="m:person/m:institution">
                                                <div class="add-nodes-group">
                                                    <xsl:copy-of select="ops:select-input-name('Institution', concat('institution-id-', position()), 10, /m:response/m:contributor-institutions/m:institution, @id)"/>
                                                </div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div class="add-nodes-group">
                                                <xsl:copy-of select="ops:select-input-name('Institution', 'institution-id-1', 10, /m:response/m:contributor-institutions/m:institution, '')"/>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <div class="form-group">
                                        <div class="col-sm-offset-2 col-sm-10">
                                            <a href="#add-nodes" class="add-nodes">
                                                <span class="monospace">
                                                    <xsl:value-of select="'+'"/>
                                                </span>
                                                <xsl:value-of select="' add an institution'"/>
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
                                        <xsl:value-of select="'Save'"/>
                                    </button>
                                </div>
                                
                            </fieldset>
                            
                        </form>
                        
                        <section id="person-acknowledgements">
                            
                            <h3>
                                <xsl:value-of select="'Acknowledgements'"/>
                            </h3>
                            
                            <xsl:call-template name="acknowledgements">
                                <xsl:with-param name="acknowledgements" select="m:person/m:acknowledgement"/>
                                <xsl:with-param name="css-class" select="'bottom-margin'"/>
                                <xsl:with-param name="group" select="''"/>
                                <xsl:with-param name="link-href" select="'/edit-text-header.html?id=@translation-id'"/>
                            </xsl:call-template>
                            
                        </section>
                            
                        </div>
                    </div>
                
                </xsl:with-param>
            
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>