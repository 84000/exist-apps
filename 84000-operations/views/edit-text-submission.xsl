<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
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
                    
                    <div class="center-vertical full-width">
                        <span>
                            <span class="h3 text-sa text-muted">
                                <xsl:value-of select="concat('Toh 1-1', ': ', 'Tohoku 1-1 final draft(1).docx')"/>
                            </span>
                            <xsl:value-of select="' / '"/>
                            <a>
                                <xsl:attribute name="href" select="'#'"/>
                                <xsl:value-of select="'Download file '"/>
                                <i class="fa fa-cloud-download"/>
                            </a>
                        </span>
                        <span>
                            <div class="pull-right">
                                <xsl:copy-of select="common:translation-status('2.b')"/>
                            </div>
                        </span>
                    </div>
                    <hr/>
                    
                    <form method="post" class="form-horizontal form-update">
                        <xsl:attribute name="action" select="'edit-text-submission.html'"/>
                        <div class="row">
                            <div class="col-sm-9 margin-top-sm">
                                <div class="form-group">
                                    <label class="col-sm-3" for="name">Submitted</label>
                                    <div class="col-sm-9 text-muted">
                                        <xsl:value-of select="'12:03 on 25th Jan 2019 by john-canti '"/>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-3" for="name">Uploaded file name</label>
                                    <div class="col-sm-9 text-muted">
                                        <xsl:value-of select="'Tohoku 1-1 final draft.docx'"/>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-3" for="name">File in database</label>
                                    <div class="col-sm-9 text-muted">
                                        <xsl:value-of select="'84000-data/toh1-1/Tohoku 1-1 final draft(2).docx'"/>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-3" for="name">TEI file</label>
                                    <div class="col-sm-9 text-muted italic">
                                        <xsl:value-of select="'[No file]'"/>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" checked="checked"/>
                                        <xsl:value-of select="'Latest document'"/>
                                    </label>
                                    <p class="small text-muted italic">Validated automatically</p>
                                </div>
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" checked="checked"/>
                                        <xsl:value-of select="'Final draft'"/>
                                    </label>
                                    <p class="small text-muted italic">Set by andre at 12:44 26th Jan 2019</p>
                                </div>
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" checked="checked"/>
                                        <xsl:value-of select="'84000 template'"/>
                                    </label>
                                    <p class="small text-muted italic">Set by andre at 17:07 26th Jan 2019</p>
                                </div>
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox"/>
                                        <xsl:value-of select="'Generate TEI'"/>
                                    </label>
                                </div>
                            </div>
                        </div>
                        <hr/>
                        <div class="center-vertical full-width">
                            <span>
                                <button type="submit" class="btn btn-danger">Delete</button>
                            </span>
                            <span>
                                <button type="submit" class="btn btn-primary pull-right">Save</button>
                            </span>
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