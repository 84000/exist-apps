<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
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
                            <div class="row">
                                <div class="col-items div-list">
                                    
                                    <div class="item">
                                        
                                        <span class="small text-muted">
                                            Listing 
                                            <xsl:value-of select="fn:format-number(xs:integer(count(m:translators/m:translator)),'#,##0')"/> translators
                                        </span>
                                        
                                        <form method="post" action="/translators.html" class="form-inline filter-form pull-right">
                                            
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" name="include-acknowledgements" value="1">
                                                        <xsl:if test="m:request/@include-acknowledgements eq 'true'">
                                                            <xsl:attribute name="checked" select="'checked'"/>
                                                        </xsl:if>
                                                    </input>
                                                    List all acknowledgements
                                                </label>
                                            </div>
                                            
                                            <a class="btn btn-primary btn-sml">
                                                <xsl:attribute name="href" select="'/edit-translator.html'"/>
                                                Add a translator
                                            </a>
                                            
                                        </form>
                                        
                                    </div>
                                
                                    <xsl:for-each select="m:translators/m:translator">
                                        
                                        <xsl:sort select="@start-letter"/>
                                        
                                        <xsl:variable name="translator-id" select="@xml:id"/>
                                        
                                        <div class="item">
                                            
                                            <xsl:copy-of select="common:marker(@start-letter, if(preceding-sibling::m:translator[1]/@start-letter) then preceding-sibling::m:translator[1]/@start-letter else '')"/>
                                            
                                            <div class="row">
                                                <div class="col-sm-3">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', $translator-id)"/>
                                                        <xsl:value-of select="m:name"/>
                                                    </a>
                                                </div>
                                                <div class="col-sm-2">
                                                    <xsl:value-of select="$translator-id"/>
                                                </div>
                                                <div class="col-sm-3">
                                                    <xsl:if test="m:team">
                                                        <ul>
                                                            <xsl:for-each select="m:team">
                                                                <xsl:variable name="team-id" select="@id"/>
                                                                <li>
                                                                    <xsl:value-of select="/m:response/m:translator-teams/m:team[@xml:id eq $team-id]/m:name"/>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </xsl:if>
                                                </div>
                                                <div class="col-sm-4">
                                                    <xsl:if test="m:institution">
                                                        <ul>
                                                            <xsl:for-each select="m:institution">
                                                                <xsl:variable name="institution-id" select="@id"/>
                                                                <li>
                                                                    <xsl:value-of select="/m:response/m:translator-institutions/m:institution[@xml:id eq $institution-id]/m:name"/>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </xsl:if>
                                                </div>
                                            </div>
                                            
                                            <xsl:if test="m:acknowledgement">
                                                <div class="row">
                                                    <xsl:call-template name="acknowledgements">
                                                        <xsl:with-param name="acknowledgements" select="m:acknowledgement"/>
                                                        <xsl:with-param name="group" select="$translator-id"/>
                                                        <xsl:with-param name="css-class" select="'col-sm-6'"/>
                                                        <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:if>
                                        </div>
                                    </xsl:for-each>
                                    
                                </div>
                                
                                <div id="letters-nav" class="col-nav">
                                    <xsl:copy-of select="common:marker-nav(m:translators/m:translator)"/>
                                </div>
                                
                            </div>
                            
                        </div>
                    </div>
                </div>
            </div>
            
            <xsl:call-template name="link-to-top"/>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translators :: 84000 Operations'"/>
            <xsl:with-param name="page-description" select="'Translators configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>