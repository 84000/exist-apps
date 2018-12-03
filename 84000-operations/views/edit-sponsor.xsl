<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="../../84000-reading-room/xslt/forms.xsl"/>
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
                            
                            <xsl:if test="m:sponsor/@locked-by-user gt ''">
                                <div class="alert alert-danger" role="alert">
                                    <xsl:value-of select="concat('File sponsors.xml is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                                    You cannot modify this file until the lock is released.
                                </div>
                            </xsl:if>
                            
                            <form method="post" class="form-horizontal">
                                
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
                                                <div class="col-sm-4">
                                                    <select name="sponsor-type" id="sponsor-type" class="form-control">
                                                        <option value="sutra">
                                                            <xsl:if test="m:sponsor/@type eq 'sutra'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            Sutra
                                                        </option>
                                                        <option value="founding">
                                                            <xsl:if test="m:sponsor/@type eq 'founding'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            Founding
                                                        </option>
                                                        <option value="matching-funds">
                                                            <xsl:if test="m:sponsor/@type eq 'matching-funds'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            Matching Funds
                                                        </option>
                                                    </select>
                                                </div>
                                            </div>
                                        </fieldset>
                                        
                                    </div>
                                    
                                    <div class="col-sm-6">
                                        <xsl:if test="m:sponsor/m:acknowledgement">
                                            
                                            <h4>Acknowledgements</h4>
                                            
                                            <xsl:call-template name="acknowledgements">
                                                <xsl:with-param name="acknowledgements" select="m:sponsor/m:acknowledgement"/>
                                                <xsl:with-param name="css-class" select="''"/>
                                                <xsl:with-param name="group" select="''"/>
                                                <xsl:with-param name="link-href" select="'/edit-text-sponsors.html?id=@translation-id'"/>
                                            </xsl:call-template>
                                            
                                        </xsl:if>
                                        
                                        <!-- 
                                            
                                        <hr/>
                                        
                                        <div class="form-group">
                                            <label class="control-label col-sm-3" for="sponsor-text">
                                                Add as sponsor:
                                            </label>
                                            <div class="col-sm-9">
                                                <select name="sponsor-text" id="sponsor-text" class="form-control">
                                                    <xsl:for-each select="m:sponsored-texts/m:text[not(m:sponsors/m:sponsor[@xml:id eq $sponsor-id])]">
                                                        <xsl:sort select="xs:integer(m:toh/@number)"/>
                                                        <xsl:sort select="xs:integer(concat('0', m:toh/@chapter-number))"/>
                                                        <option>
                                                            <xsl:attribute name="value" select="@id"/>
                                                            <xsl:value-of select="concat(m:toh/m:full, ' / ', m:titles/m:title[@xml:lang eq 'en'])"/>
                                                        </option>
                                                    </xsl:for-each>
                                                </select>
                                            </div>
                                        </div>
                                         -->
                                        
                                    </div>
                                </div>
                                <hr/>
                                <a class="btn btn-danger">
                                    <xsl:attribute name="href" select="concat('/sponsors.html?delete=', $sponsor-id)"/>
                                    Delete
                                </a>
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