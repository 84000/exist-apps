<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="common.xsl"/>
    
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
                            
                            <xsl:if test="m:translation/@locked-by-user gt ''">
                                <div class="alert alert-danger" role="alert">
                                    <xsl:value-of select="concat('File ', m:translation/@document-url, ' is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                                    You cannot modify this file until the lock is released.
                                </div>
                            </xsl:if>
                            
                            <form method="post" class="form-horizontal">
                                
                                <xsl:attribute name="action" select="'edit-text.html'"/>
                                
                                <input type="hidden" name="post-id">
                                    <xsl:attribute name="value" select="m:translation/@id"/>
                                </input>
                                
                                <fieldset>
                                    <legend>
                                        Titles
                                    </legend>
                                    <xsl:copy-of select="m:text-input('English Title','title-en', m:translation/m:titles/m:title[@xml:lang eq 'en'], 10, 'disabled')"/>
                                    <xsl:copy-of select="m:text-input('Tibetan Title','title-bo', m:translation/m:titles/m:title[@xml:lang eq 'bo'], 10, 'text-bo disabled')"/>
                                    <xsl:copy-of select="m:text-input('Sanskrit Title','title-sa', m:translation/m:titles/m:title[@xml:lang eq 'sa-ltn'], 10, 'disabled')"/>
                                    <xsl:copy-of select="m:text-input('Chinese Title','title-zh', m:translation/m:chinese-title, 10, '')"/>
                                </fieldset>
                                
                                <xsl:for-each select="m:translation/m:toh">
                                    <xsl:variable name="toh-key" select="@key"/>
                                    <xsl:variable name="toh-location" select="/m:response/m:translation/m:location[@key eq $toh-key]"/>
                                    <fieldset>
                                        <legend>
                                            Toh <xsl:value-of select="m:base"/>.
                                        </legend>
                                        <div class="row">
                                            <div class="col-sm-4">
                                                <xsl:copy-of select="m:text-input('Start volume',concat('start-volume-', $toh-key), $toh-location/m:start/@volume, 6, 'required')"/>
                                                <xsl:copy-of select="m:text-input('Start page',concat('start-page-', $toh-key), $toh-location/m:start/@page, 6, 'required')"/>
                                            </div>
                                            <div class="col-sm-4">
                                                <xsl:copy-of select="m:text-input('End volume',concat('end-volume-', $toh-key), $toh-location/m:end/@volume, 6, 'required')"/>
                                                <xsl:copy-of select="m:text-input('End page',concat('end-page-', $toh-key), $toh-location/m:end/@page, 6, 'required')"/>
                                            </div>
                                            <div class="col-sm-4">
                                                <xsl:copy-of select="m:text-input('Count pages',concat('count-pages-', $toh-key), $toh-location/@count-pages, 6, 'required')"/>
                                            </div>
                                        </div>
                                    </fieldset>
                                </xsl:for-each>
                                
                                <fieldset>
                                    <legend>Sponsors</legend>
                                    
                                    <div class="row">
                                        <div class="col-sm-8">
                                            
                                            <xsl:copy-of select="m:select-input('Sponsorship Status', 'sponsorship-status', 9, 1, m:sponsorhip-statuses/m:status)"/>
                                            
                                            <xsl:for-each select="m:translation/m:translation/m:sponsors/m:sponsor">
                                                <xsl:variable name="sponsor-id" select="substring-after(@sameAs, 'sponsors.xml#')"/>
                                                <div class="form-group">
                                                    <div class="col-sm-5">
                                                        <select class="form-control">
                                                            <xsl:attribute name="name" select="concat('sponsor-id-', position())"/>
                                                            <option value=""/>
                                                            <xsl:for-each select="/m:response/m:sponsors/m:sponsor">
                                                                <option>
                                                                    <xsl:attribute name="value" select="concat('sponsors.xml#', @xml:id)"/>
                                                                    <xsl:if test="@xml:id eq $sponsor-id">
                                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="m:name"/>
                                                                </option>
                                                            </xsl:for-each>
                                                        </select>
                                                    </div>
                                                    <label class="control-label col-sm-2">
                                                        expressed as:
                                                    </label>
                                                    <div class="col-sm-5">
                                                        <input class="form-control" placeholder="Same">
                                                            <xsl:attribute name="name" select="concat('sponsor-expression-', position())"/>
                                                            <xsl:attribute name="value" select="text()"/>
                                                        </input>
                                                    </div>
                                                </div>
                                            </xsl:for-each>
                                            
                                            <!-- Add new -->
                                            <div class="form-group">
                                                <div class="col-sm-5">
                                                    <select class="form-control" name="sponsor-id-0">
                                                        <option value=""/>
                                                        <xsl:for-each select="/m:response/m:sponsors/m:sponsor">
                                                            <option>
                                                                <xsl:attribute name="value" select="concat('sponsors.xml#', @xml:id)"/>
                                                                <xsl:value-of select="m:name"/>
                                                            </option>
                                                        </xsl:for-each>
                                                    </select>
                                                </div>
                                                <label class="control-label col-sm-2">
                                                    expressed as:
                                                </label>
                                                <div class="col-sm-5">
                                                    <input class="form-control" name="sponsor-expression-0" value="" placeholder="Same"/>
                                                </div>
                                            </div>
                                            
                                        </div>
                                        <div class="col-sm-4">
                                            <xsl:if test="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/@sponsored gt ''">
                                                <div class="text-bold">Acknowledgment</div>
                                                <xsl:if test="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                                    <xsl:apply-templates select="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                                    <hr/>
                                                </xsl:if>
                                            </xsl:if>
                                        </div>
                                    </div>
                                </fieldset>
                                
                                <fieldset>
                                    <legend>Translators</legend>
                                    
                                    <div class="row">
                                        <div class="col-sm-8">
                                            
                                            <xsl:copy-of select="m:select-input('Translation Status', 'translation-status', 9, 1, m:text-statuses/m:status)"/>
                                            
                                            <xsl:variable name="translator-summary" select="m:translation/m:translation/m:authors/m:summary[1]"/>
                                            <xsl:variable name="translator-team-id" select="substring-after($translator-summary/@sameAs, 'translators.xml#')"/>
                                            
                                            <div class="form-group">
                                                
                                                <label class="control-label col-sm-3">
                                                    Translator Team
                                                </label>
                                                
                                                <div class="col-sm-9">
                                                    <select class="form-control">
                                                        <xsl:attribute name="name" select="'translator-team-id'"/>
                                                        <option value=""/>
                                                        <xsl:for-each select="/m:response/m:translator-teams/m:team">
                                                            <option>
                                                                <xsl:attribute name="value" select="concat('translators.xml#', @xml:id)"/>
                                                                <xsl:if test="@xml:id eq $translator-team-id">
                                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="m:name"/>
                                                            </option>
                                                        </xsl:for-each>
                                                    </select>
                                                </div>
                                                
                                            </div>
                                            
                                            <xsl:for-each select="m:translation/m:translation/m:authors/m:author">
                                                <xsl:variable name="translator-id" select="substring-after(@sameAs, 'translators.xml#')"/>
                                                <div class="form-group">
                                                    <div class="col-sm-5">
                                                        <select class="form-control">
                                                            <xsl:attribute name="name" select="concat('translator-id-', position())"/>
                                                            <option value=""/>
                                                            <xsl:for-each select="/m:response/m:translators/m:translator">
                                                                <option>
                                                                    <xsl:attribute name="value" select="concat('translators.xml#', @xml:id)"/>
                                                                    <xsl:if test="@xml:id eq $translator-id">
                                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="m:name"/>
                                                                </option>
                                                            </xsl:for-each>
                                                        </select>
                                                    </div>
                                                    <label class="control-label col-sm-2">
                                                        expressed as:
                                                    </label>
                                                    <div class="col-sm-5">
                                                        <input class="form-control" placeholder="Same">
                                                            <xsl:attribute name="name" select="concat('translator-expression-', position())"/>
                                                            <xsl:attribute name="value" select="text()"/>
                                                        </input>
                                                    </div>
                                                </div>
                                            </xsl:for-each>
                                            
                                            <!-- Add new -->
                                            <div class="form-group">
                                                <div class="col-sm-5">
                                                    <select class="form-control" name="translator-id-0">
                                                        <option value=""/>
                                                        <xsl:for-each select="/m:response/m:translators/m:translator">
                                                            <option>
                                                                <xsl:attribute name="value" select="concat('translators.xml#', @xml:id)"/>
                                                                <xsl:value-of select="m:name"/>
                                                            </option>
                                                        </xsl:for-each>
                                                    </select>
                                                </div>
                                                <label class="control-label col-sm-2">
                                                    expressed as:
                                                </label>
                                                <div class="col-sm-5">
                                                    <input class="form-control" name="translator-expression-0" value="" placeholder="Same"/>
                                                </div>
                                            </div>
                                            
                                        </div>
                                        <div class="col-sm-4">
                                            
                                            <xsl:if test="m:translation/m:translation/m:authors/m:summary">
                                                <div class="text-bold">Attribution</div>
                                                <xsl:for-each select="m:translation/m:translation/m:authors/m:summary">
                                                    <p>
                                                        <xsl:apply-templates select="node()"/>
                                                    </p>
                                                </xsl:for-each>
                                                <hr/>
                                            </xsl:if>
                                            
                                            <xsl:if test="m:translation/m:translators/tei:div[@type eq 'acknowledgment']/tei:p">
                                                <div class="text-bold">Acknowledgment</div>
                                                <xsl:apply-templates select="m:translation/m:translators/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                                <hr/>
                                            </xsl:if>
                                            
                                        </div>
                                    </div>
                                </fieldset>
                                
                                <p class="small text-muted">
                                    If a sponsor or a translator is not automatically recognised in the acknowledgement text then please specify what they are "expressed as". If a sponsor or a translator is already highlighted then you can leave this field blank.
                                </p>
                                
                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <div class="pull-right">
                                            <div class="center-vertical">
                                                <span>
                                                    <a href="/progress.html?sponsored=sponsored">
                                                        List of sponsored texts
                                                    </a>
                                                </span>
                                                <span>|</span>
                                                <span>
                                                    <a target="_blank">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:translation/@id, '.html')"/>
                                                        View this text
                                                    </a>
                                                </span>
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
    
</xsl:stylesheet>