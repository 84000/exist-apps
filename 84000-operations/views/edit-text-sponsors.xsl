<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
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
                            
                            <xsl:if test="m:translation/@locked-by-user gt ''">
                                <div class="alert alert-danger" role="alert">
                                    <xsl:value-of select="concat('File ', m:translation/@document-url, ' is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                                    You cannot modify this file until the lock is released.
                                </div>
                            </xsl:if>
                            
                            <form method="post" class="form-horizontal">
                                
                                <xsl:attribute name="action" select="'edit-text-sponsors.html'"/>
                                
                                <input type="hidden" name="post-id">
                                    <xsl:attribute name="value" select="m:translation/@id"/>
                                </input>
                                
                                <h3 class="text-sa text-muted italic">
                                    <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                                </h3>
                                <div class="row">
                                    <div class="col-sm-8 add-nodes-container">
                                        
                                        <xsl:copy-of select="m:select-input('Sponsorship Status', 'sponsorship-status', 9, 1, m:sponsorhip-statuses/m:status)"/>
                                        
                                        <fieldset>
                                            <legend>
                                                Sponsors
                                            </legend>
                                            <xsl:choose>
                                                <xsl:when test="m:translation/m:translation/m:sponsors/m:sponsor">
                                                    <xsl:call-template name="sponsors-controls">
                                                        <xsl:with-param name="text-sponsors" select="m:translation/m:translation/m:sponsors/m:sponsor"/>
                                                        <xsl:with-param name="all-sponsors" select="/m:response/m:sponsors/m:sponsor"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:call-template name="sponsors-controls">
                                                        <xsl:with-param name="text-sponsors">
                                                            <m:sponsor sameAs="dummy"/>
                                                        </xsl:with-param>
                                                        <xsl:with-param name="all-sponsors" select="/m:response/m:sponsors/m:sponsor"/>
                                                    </xsl:call-template>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <div>
                                                <a href="#add-nodes" class="add-nodes">
                                                    <span class="monospace">+</span> add a sponsor
                                                </a>
                                            </div>
                                        </fieldset>
                                        
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="text-bold">Acknowledgment</div>
                                        <xsl:if test="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                            <xsl:apply-templates select="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                            <hr/>
                                        </xsl:if>
                                        <p class="small text-muted">
                                            If a sponsor is not automatically recognised in the acknowledgement text then please specify what they are "expressed as". If a sponsor is already highlighted then you can leave this field blank.
                                        </p>
                                    </div>
                                </div>
                                
                                <hr/>
                                
                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <div class="pull-right">
                                            <div class="center-vertical">
                                                <span>
                                                    <a href="/search.html?sponsored=sponsored">
                                                        List of sponsored texts
                                                    </a>
                                                </span>
                                                <span>|</span>
                                                <span>
                                                    <a href="/edit-sponsor.html">
                                                        Add a new sponsor
                                                    </a>
                                                </span>
                                                <span>|</span>
                                                <span>
                                                    <button type="submit" class="btn btn-primary">Save</button>
                                                </span>
                                            </div>
                                        </div>
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
    
    <xsl:template name="sponsors-controls">
        <xsl:param name="text-sponsors" required="yes"/>
        <xsl:param name="all-sponsors" required="yes"/>
        <xsl:for-each select="$text-sponsors">
            <xsl:variable name="id" select="substring-after(@sameAs, 'sponsors.xml#')"/>
            <div class="form-group add-nodes-group">
                <div class="col-sm-5">
                    <select class="form-control">
                        <xsl:attribute name="name" select="concat('sponsor-id-', position())"/>
                        <option value=""/>
                        <xsl:for-each select="$all-sponsors">
                            <option>
                                <xsl:attribute name="value" select="concat('sponsors.xml#', @xml:id)"/>
                                <xsl:if test="@xml:id eq $id">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="m:internal-name">
                                        <xsl:value-of select="concat(m:name, ' / ', m:internal-name)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="m:name"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <label class="control-label col-sm-2">
                    expressed as:
                </label>
                <div class="col-sm-5">
                    <input class="form-control" placeholder="same">
                        <xsl:attribute name="name" select="concat('sponsor-expression-', position())"/>
                        <xsl:attribute name="value" select="text()"/>
                    </input>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>