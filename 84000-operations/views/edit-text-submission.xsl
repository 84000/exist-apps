<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:choose>
                        <xsl:when test="$environment/m:conversion-conf">
                            <div class="alert alert-warning small text-center" role="alert">
                                <xsl:value-of select="'Using local TEI stylesheets to generate TEI.'"/>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="alert alert-warning small text-center" role="alert">
                                <xsl:value-of select="'Using remote TEI stylesheets to generate TEI.'"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:variable name="submission" select="m:submission"/>
                    
                    <div class="center-vertical full-width">
                        <span>
                            <span class="h3 text-sa text-muted">
                                <xsl:value-of select="concat(m:translation/m:toh/m:full, ' / ', $submission/@file-name)"/>
                            </span>
                            <xsl:value-of select="' / '"/>
                            <a>
                                <xsl:attribute name="href" select="concat('/imported-file/', $submission/@file-name, '?text-id=', $submission/@text-id, '&amp;submission-id=', $submission/@id)"/>
                                <xsl:value-of select="'Download file '"/>
                                <i class="fa fa-cloud-download"/>
                            </a>
                        </span>
                        <span class="text-right">
                            <xsl:copy-of select="ops:translation-status(m:translation/@status-group)"/>
                        </span>
                    </div>
                    <hr/>
                    
                    <form method="post" class="form-update" data-loading="Updating submission...">
                        <xsl:attribute name="action" select="'edit-text-submission.html'"/>
                        <input name="text-id" type="hidden">
                            <xsl:attribute name="value" select="m:request/@text-id"/>
                        </input>
                        <input name="submission-id" type="hidden">
                            <xsl:attribute name="value" select="m:request/@submission-id"/>
                        </input>
                        <div class="row">
                            <div class="col-sm-8 sml-margin top">
                                <div class="form-group">
                                    <label for="submission-date">
                                        <xsl:value-of select="'Submitted'"/>
                                    </label>
                                    <div class="text-muted" id="submission-date">
                                        <xsl:value-of select="common:date-user-string('', $submission/@date-time, $submission/@user)"/>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="original-file-name">
                                        <xsl:value-of select="'Uploaded file'"/>
                                    </label>
                                    <div class="text-muted" id="original-file-name">
                                        <xsl:choose>
                                            <xsl:when test="string($submission/@original-file-name)">
                                                <xsl:value-of select="$submission/@original-file-name"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$submission/@file-name"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="database-file">
                                        <xsl:value-of select="'Database file'"/>
                                    </label>
                                    <div class="text-muted" id="database-file">
                                        <xsl:value-of select="concat($submission/@file-collection, '/', $submission/@file-name)"/>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="tei-file">
                                        <xsl:value-of select="'TEI file'"/>
                                    </label>
                                    <div class="text-muted" id="tei-file">
                                        <xsl:choose>
                                            <xsl:when test="$submission/m:tei-file/@file-exists eq 'true'">
                                                <xsl:value-of select="concat($submission/@file-collection, '/', $submission/m:tei-file/@file-name)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'[No file]'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <h4 class="no-top-margin">
                                    <xsl:value-of select="'Checklist'"/>
                                </h4>
                                <hr class="sml-margin"/>
                                
                                <!-- Is this the latest? -->
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" value="latest" disabled="disabled">
                                            <xsl:if test="$submission/@latest eq 'true'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:choose>
                                            <xsl:when test="$submission/@file-type eq 'spreadsheet'">
                                                <xsl:value-of select="'Latest spreadsheet'"/>
                                            </xsl:when>
                                            <xsl:when test="$submission/@file-type eq 'document'">
                                                <xsl:value-of select="'Latest document'"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </label>
                                    <p class="small text-muted italic">
                                        <xsl:value-of select="'Validated automatically'"/>
                                    </p>
                                </div>
                                
                                <!-- Configured checklist -->
                                <xsl:for-each select="m:submission-checklist/*[local-name(.) eq $submission/@file-type]/m:item">
                                    <xsl:variable name="item" select="."/>
                                    <xsl:variable name="item-checked" select="$submission/m:item-checked[@item-id eq $item/@id]"/>
                                    <xsl:variable name="submission-tei-file" select="$submission/m:tei-file"/>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="checklist[]">
                                                <xsl:attribute name="value" select="$item/@id"/>
                                                <xsl:if test="$item-checked">
                                                    <xsl:attribute name="checked" select="'checked'"/>
                                                </xsl:if>
                                            </input>
                                            <xsl:value-of select="./text()"/>
                                        </label>
                                        <xsl:if test="$item-checked">
                                            <p class="small text-muted italic">
                                                <xsl:value-of select="common:date-user-string('Checked off ', $item-checked/@date-time, $item-checked/@user)"/>
                                            </p>
                                        </xsl:if>
                                    </div>
                                </xsl:for-each>
                                
                                <!-- Option for generating TEI -->
                                <div class="checkbox">
                                    <xsl:variable name="generate-tei-checked" select="$submission/m:item-checked[@item-id eq 'generate-tei']"/>
                                    <label>
                                        <input type="checkbox" name="checklist[]" value="generate-tei">
                                            <xsl:if test="$submission/m:tei-file/@file-exists eq 'true'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="'Generate TEI'"/>
                                    </label>
                                    <xsl:if test="$generate-tei-checked">
                                        <p class="small text-muted italic">
                                            <xsl:value-of select="common:date-user-string('Generated ', $generate-tei-checked/@date-time, $generate-tei-checked/@user)"/>
                                        </p>
                                    </xsl:if>
                                </div>
                                
                            </div>
                        </div>
                        <hr/>
                        <div class="center-vertical full-width">
                            <span>
                                <a class="btn btn-danger">
                                    <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', m:request/@text-id, '&amp;delete-submission-id=', m:request/@submission-id, '#submissions-form')"/>
                                    <xsl:value-of select="'Delete'"/>
                                </a>
                            </span>
                            <span>
                                <button type="submit" class="btn btn-primary pull-right">
                                    <xsl:value-of select="'Save'"/>
                                </button>
                            </span>
                        </div>
                    </form>
                    
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
    
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Text Submission | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>