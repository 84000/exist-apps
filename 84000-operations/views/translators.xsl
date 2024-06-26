<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    <div class="well well-sm center-vertical full-width bottom-margin">
                        
                        <span>
                            <xsl:value-of select="concat('Listing ', fn:format-number(xs:integer(count(m:contributor-persons/m:person)),'#,##0'), ' contributors')"/>
                        </span>
                        
                        <div>
                            <a class="btn btn-primary btn-sml">
                                <xsl:attribute name="href" select="'/edit-translator.html'"/>
                                <xsl:value-of select="'Add a contributor'"/>
                            </a>
                        </div>
                        
                    </div>
                    
                    <div class="row">
                        <div class="col-items div-list no-border-top">
                            
                            <xsl:for-each-group select="m:contributor-persons/m:person" group-by="@start-letter">
                                
                                <xsl:sort select="@start-letter"/>
                                
                                <div>
                                    
                                    <a class="marker">
                                        <xsl:attribute name="name" select="@start-letter"/>
                                        <xsl:attribute name="id" select="concat('marker-', @start-letter)"/>
                                        <xsl:value-of select="@start-letter"/>
                                    </a>
                                    
                                    <xsl:for-each select="fn:current-group()">
                                        
                                        <xsl:sort select="m:sort-name"/>
                                        
                                        <xsl:variable name="person-id" select="@xml:id"/>
                                        
                                        <div class="item">
                                            
                                            <div class="row">
                                                <div class="col-sm-5">
                                                    
                                                    <div class="center-vertical full-width">
                                                        <span>
                                                            <a>
                                                                <xsl:attribute name="href" select="concat('/edit-translator.html?id=', $person-id)"/>
                                                                <xsl:value-of select="m:label"/>
                                                            </a>
                                                            <span class="small text-muted">
                                                                <xsl:value-of select="concat(' / ', $person-id)"/>
                                                            </span>
                                                        </span>
                                                        <span class="text-right">
                                                            <xsl:if test="@count-contributions gt '0'">
                                                                <xsl:value-of select="' '"/>
                                                                <span class="badge badge-notification">
                                                                    <xsl:value-of select="@count-contributions"/>
                                                                </span>
                                                            </xsl:if>
                                                        </span>
                                                        
                                                    </div>
                                                    
                                                    <div>
                                                        <ul class="list-inline inline-dots small">
                                                            <xsl:if test="m:affiliation[@type eq 'academic']">
                                                                <li class="text-success">
                                                                    <xsl:value-of select="'Academic'"/>
                                                                </li>
                                                            </xsl:if>
                                                            <xsl:if test="m:affiliation[@type eq 'practitioner']">
                                                                <li class="text-warning">
                                                                    <xsl:value-of select="'Practitioner'"/>
                                                                </li>
                                                            </xsl:if>
                                                        </ul>
                                                    </div>
                                                    
                                                </div>
                                                <div class="col-sm-3">
                                                    <xsl:if test="m:team">
                                                        <ul>
                                                            <xsl:for-each select="m:team">
                                                                <xsl:variable name="team-id" select="@id"/>
                                                                <li>
                                                                    <xsl:value-of select="/m:response/m:contributor-teams/m:team[@xml:id eq $team-id]/m:label"/>
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
                                                                    <xsl:value-of select="/m:response/m:contributor-institutions/m:institution[@xml:id eq $institution-id]/m:label"/>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </xsl:if>
                                                </div>
                                            </div>
                                            
                                        </div>
                                        
                                    </xsl:for-each>
                                    
                                </div>
                                
                            </xsl:for-each-group>
                            
                        </div>
                        
                        <div class="col-nav affix-container">
                            <xsl:copy-of select="common:marker-nav(m:contributor-persons/m:person)"/>
                        </div>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translators | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translators configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>