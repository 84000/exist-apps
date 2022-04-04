<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../website-page.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container text-center">
                    <h1 class="title">
                        <xsl:value-of select="'Sections with Published Translations'"/>
                    </h1>
                </div>
            </div>
            
            <main class="content-band">
                <div class="content-band">
                    <div class="container">
                        <div class="row">
                            <div class="col-sm-6 col-sm-offset-3">
                                
                                <div id="filters-sidebar">
                                    <form class="form-horizontal">
                                        
                                        <div id="section-checkbox">
                                            <xsl:for-each select="m:section/m:section">
                                                <xsl:call-template name="section-checkbox">
                                                    <xsl:with-param name="section" select="."/>
                                                </xsl:call-template>
                                            </xsl:for-each>
                                        </div>
                                        
                                    </form>
                                </div>
                                
                            </div>
                        </div>
                    </div>
                </div>
            </main>
            
        </xsl:variable>
        
        <xsl:call-template name="widget-page">
            <xsl:with-param name="page-url" select="'http://read.84000.co/widget/section-checkbox.html'"/>
            <xsl:with-param name="page-class" select="'reading-room section '"/>
            <xsl:with-param name="page-title" select="'Sections with Published Translations | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="section-checkbox">
        
        <xsl:param name="section" as="element(m:section)"/>
        <xsl:variable name="count-published-descendants" select="$section/m:text-stats/m:stat[@type eq 'count-published-descendants']/@value" as="xs:integer"/>
        
        <xsl:if test="$count-published-descendants gt 0">
            <div class="nested-checkbox">
                <div class="checkbox">
                    <label class="center-vertical full-width">
                        
                        <input type="checkbox" name="filter-section-id[]">
                            <xsl:attribute name="value" select="$section/@id"/>
                            <xsl:if test="/m:response/m:request/m:filter[@section-id eq $section/@id]">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        
                        <span>
                            <xsl:attribute name="id" select="concat($section/@id, '-filter-label')"/>
                            <xsl:value-of select="$section/m:titles/m:title[@xml:lang eq 'en']"/>
                            <span class="small text-muted">
                                <xsl:value-of select="concat(' (', $count-published-descendants, ')')"/>
                            </span>
                        </span>
                        
                        <xsl:if test="$section[m:abstract/tei:p]">
                            <span class="text-right">
                                <a role="button" data-toggle="collapse" data-parent="#accordion" aria-expanded="false" class="collapsed">
                                    
                                    <xsl:attribute name="href" select="concat('#', $section/@id, '-filter-abstract')"/>
                                    <xsl:attribute name="aria-controls" select="concat($section/@id, '-filter-abstract')"/>
                                    
                                    <i class="fa fa-plus collapsed-show"/>
                                    <i class="fa fa-minus collapsed-hide"/>
                                </a>
                            </span>
                        </xsl:if>
                        
                    </label>
                    <xsl:if test="$section[m:abstract/tei:p]">
                        <div class="collapse" role="tabpanel" aria-expanded="false">
                            <xsl:attribute name="id" select="concat($section/@id, '-filter-abstract')"/>
                            <xsl:attribute name="aria-labelledby" select="concat($section/@id, '-filter-label')"/>
                            <div class="small text-muted sml-margin top bottom">
                                <xsl:apply-templates select="$section/m:abstract"/>
                            </div>
                        </div>
                    </xsl:if>
                </div>
                <xsl:for-each select="$section/m:section">
                    <xsl:call-template name="section-checkbox">
                        <xsl:with-param name="section" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </div>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>