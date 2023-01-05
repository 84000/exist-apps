<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    <div class="well well-sm center-vertical full-width bottom-margin">
                        
                        <span>
                            <xsl:value-of select="concat('Listing ', fn:format-number(xs:integer(count(m:contributor-institutions/m:institution)),'#,##0'), ' institutions')"/>
                        </span>
                        
                        <div>
                            <form method="post" action="/translator-institutions.html" class="form-inline filter-form pull-right">
                                
                                <div class="checkbox hidden"><!-- Hide this for now -->
                                    <label class="small">
                                        <input type="checkbox" name="include-contributors" value="1">
                                            <xsl:if test="m:request/@include-contributors eq 'true'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="'Show associated contributors'"/>
                                    </label>
                                </div>
                                
                                <a class="btn btn-primary btn-sml">
                                    <xsl:attribute name="href" select="'/edit-translator-institution.html'"/>
                                    <xsl:value-of select="'Add an institution'"/>
                                </a>
                                
                            </form>
                        </div>
                        
                    </div>
                    
                    <div class="row">
                        <div class="col-items div-list no-border-top">
                            
                            <xsl:for-each-group select="m:contributor-institutions/m:institution" group-by="@start-letter">
                                
                                <xsl:sort select="@start-letter"/>
                                
                                <div>
                                    
                                    <a class="marker">
                                        <xsl:attribute name="name" select="@start-letter"/>
                                        <xsl:attribute name="id" select="concat('marker-', @start-letter)"/>
                                        <xsl:value-of select="@start-letter"/>
                                    </a>
                                    
                                    <xsl:for-each select="fn:current-group()">
                                        
                                        <xsl:sort select="m:sort-name"/>
                                        
                                        <xsl:variable name="institution-id" select="@xml:id"/>
                                        <xsl:variable name="region-id" select="@region-id"/>
                                        <xsl:variable name="institution-type-id" select="@institution-type-id"/>
                                        
                                        <div class="item">
                                            
                                            <xsl:copy-of select="common:marker(@start-letter, if(preceding-sibling::m:institution[1]/@start-letter) then preceding-sibling::m:institution[1]/@start-letter else '')"/>
                                            
                                            <div class="row">
                                                <div class="col-sm-6">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', $institution-id)"/>
                                                        <xsl:value-of select="m:label"/>
                                                    </a>
                                                </div>
                                                
                                                <div class="col-sm-3">
                                                    <xsl:value-of select="/m:response/m:contributor-regions/m:region[@id eq $region-id]/m:label"/>
                                                </div>
                                                
                                                <div class="col-sm-3">
                                                    <xsl:value-of select="/m:response/m:contributor-institution-types/m:institution-type[@id eq $institution-type-id]/m:label"/>
                                                </div>
                                                
                                                <xsl:if test="/m:response/m:request/@include-contributors eq 'true'">
                                                    <div class="col-sm-12">
                                                        <ul>
                                                            <xsl:for-each select="/m:response/m:contributor-persons/m:person[m:institution/@id = $institution-id]">
                                                                <li>
                                                                    <xsl:value-of select="m:label"/>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                            
                                        </div>
                                        
                                        
                                    </xsl:for-each>
                                    
                                </div>
                                
                            </xsl:for-each-group>
                            
                        </div>
                        
                        <div class="col-nav affix-container">
                            <xsl:copy-of select="common:marker-nav(m:contributor-institutions/m:institution)"/>
                        </div>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Institutions | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>