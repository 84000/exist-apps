<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <form method="post" class="form-horizontal form-update">
                        
                        <xsl:attribute name="action" select="'edit-sponsor.html'"/>
                        <xsl:variable name="sponsor-id" select="m:sponsor/@xml:id"/>
                        
                        <input type="hidden" name="post-id">
                            <xsl:choose>
                                <xsl:when test="$sponsor-id">
                                    <xsl:attribute name="value" select="$sponsor-id"/>
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
                                            <xsl:when test="$sponsor-id">
                                                ID: <xsl:value-of select="$sponsor-id"/>
                                            </xsl:when>
                                            <xsl:otherwise>New sponsor </xsl:otherwise>
                                        </xsl:choose>
                                    </legend>
                                    
                                    <xsl:copy-of select="m:text-input('Name','name', m:sponsor/m:label, 9, 'required')"/>
                                    <xsl:copy-of select="m:text-input('Internal name','internal-name', m:sponsor/m:internal-name, 9, '')"/>
                                    <xsl:copy-of select="m:text-input('Country','country', m:sponsor/m:country, 9, '')"/>
                                    
                                    <div class="form-group">
                                        <label class="control-label col-sm-3" for="sponsor-type">
                                            Sponsor type:
                                        </label>
                                        <xsl:variable name="sponsor" select="m:sponsor"/>
                                        <xsl:for-each select="('founding', 'sutra', 'matching')">
                                            <xsl:variable name="sponsor-type-id" select="."/>
                                            <div class="col-sm-3">
                                                <div class="checkbox">
                                                    <label>
                                                        <input type="checkbox" value="1">
                                                            <xsl:attribute name="name" select="concat($sponsor-type-id, '-type')"/>
                                                            <xsl:if test="$sponsor/m:type[@id eq $sponsor-type-id]">
                                                                <xsl:attribute name="checked" select="'checked'"/>
                                                            </xsl:if>
                                                        </input>
                                                        <xsl:value-of select="concat(upper-case(substring($sponsor-type-id,1,1)), substring($sponsor-type-id,2))"/>
                                                    </label>
                                                </div>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                    
                                    <hr/>
                                    
                                    <div>
                                        <xsl:if test="$sponsor-id">
                                            <xsl:choose>
                                                <xsl:when test="m:sponsor/m:acknowledgement">
                                                    <!-- Disable if there are acknowledgments -->
                                                    <span title="You cannot delete an credited sponsor">
                                                        <a href="#" class="btn btn-default disabled">
                                                            <xsl:value-of select="'Delete'"/>
                                                        </a>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <a class="btn btn-danger">
                                                        <xsl:attribute name="href" select="concat('/sponsors.html?delete=', $sponsor-id)"/>
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
                                <div class="relative" id="sponsor-acknowledgements">
                                    <xsl:if test="count(m:sponsor/m:acknowledgement) gt 1">
                                        <xsl:attribute name="class" select="'relative preview-list render-in-viewport'"/>
                                    </xsl:if>
                                    <h4>Acknowledgements</h4>
                                    <hr class="sml-margin"/>
                                    <xsl:call-template name="acknowledgements">
                                        <xsl:with-param name="acknowledgements" select="m:sponsor/m:acknowledgement"/>
                                        <xsl:with-param name="css-class" select="''"/>
                                        <xsl:with-param name="group" select="''"/>
                                        <xsl:with-param name="link-href" select="'/edit-text-sponsors.html?id=@translation-id'"/>
                                    </xsl:call-template>
                                </div>
                            </section>
                        </div>
                        
                    </form>
                </xsl:with-param>
            </xsl:call-template>
            
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